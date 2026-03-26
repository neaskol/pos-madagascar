import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/data/local/app_database.dart';
import '../../domain/enums/adjustment_reason.dart';
import '../../domain/enums/inventory_movement_reason.dart';

/// Repository pour les ajustements de stock et l'historique des mouvements
/// Phase 3.14 - Différenciants #9 & #10
class StockAdjustmentRepository {
  final AppDatabase database;
  final _uuid = const Uuid();

  StockAdjustmentRepository(this.database);

  /// Créer un ajustement de stock complet (offline-first)
  Future<String> createAdjustment({
    required String storeId,
    required AdjustmentReason reason,
    required String createdBy,
    required List<AdjustmentItemData> items,
    String? notes,
  }) async {
    try {
      final adjustmentId = _uuid.v4();
      final now = DateTime.now().millisecondsSinceEpoch;

      // Créer l'ajustement principal
      final adjustment = StockAdjustmentsCompanion(
        id: Value(adjustmentId),
        storeId: Value(storeId),
        reason: Value(reason.index),
        notes: Value(notes),
        createdBy: Value(createdBy),
        synced: const Value(0),
        createdAt: Value(now),
        updatedAt: Value(now),
      );

      // Créer les lignes d'ajustement
      final adjustmentItems = <StockAdjustmentItemsCompanion>[];
      for (final itemData in items) {
        adjustmentItems.add(
          StockAdjustmentItemsCompanion(
            id: Value(_uuid.v4()),
            adjustmentId: Value(adjustmentId),
            itemId: Value(itemData.itemId),
            itemVariantId: Value(itemData.itemVariantId),
            quantityBefore: Value(itemData.quantityBefore),
            quantityChange: Value(itemData.quantityChange),
            quantityAfter: Value(itemData.quantityAfter),
            cost: Value(itemData.cost),
            synced: const Value(0),
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );
      }

      // Transaction atomique : créer l'ajustement + mettre à jour le stock + enregistrer l'historique
      // Drift rollback automatiquement en cas d'erreur
      try {
        await database.transaction(() async {
          // 1. Insérer l'ajustement et ses items
          await database.stockAdjustmentDao.insertFullAdjustment(
            adjustment: adjustment,
            items: adjustmentItems,
          );

          // 2. Mettre à jour le stock des items
          for (final itemData in items) {
            await _updateItemStock(
              itemId: itemData.itemId,
              variantId: itemData.itemVariantId,
              newStock: itemData.quantityAfter,
            );

            // 3. Enregistrer dans l'historique
            await _recordInventoryMovement(
              storeId: storeId,
              itemId: itemData.itemId,
              variantId: itemData.itemVariantId,
              reason: InventoryMovementReason.adjustment,
              referenceId: adjustmentId,
              quantityChange: itemData.quantityChange,
              quantityAfter: itemData.quantityAfter,
              cost: itemData.cost,
              employeeId: createdBy,
            );
          }
        });
      } catch (e) {
        // Transaction rollback automatiquement par Drift
        throw Exception('Erreur transaction ajustement atomique: $e');
      }

      // TODO: Sync vers Supabase en arrière-plan

      return adjustmentId;
    } catch (e) {
      throw Exception('Erreur création ajustement: $e');
    }
  }

  /// Obtenir un ajustement par ID
  Future<StockAdjustment?> getAdjustmentById(String id) async {
    return database.stockAdjustmentDao.getAdjustmentById(id).getSingleOrNull();
  }

  /// Stream des ajustements d'un magasin
  Stream<List<StockAdjustment>> watchAdjustmentsByStore(String storeId) {
    return database.stockAdjustmentDao.watchAdjustments(storeId);
  }

  /// Stream des items d'un ajustement
  Stream<List<StockAdjustmentItem>> watchAdjustmentItems(String adjustmentId) {
    return database.stockAdjustmentDao.watchAdjustmentItems(adjustmentId);
  }

  /// Stream de l'historique des mouvements d'un magasin
  Stream<List<InventoryHistory>> watchMovementsByStore(
    String storeId, {
    DateTime? dateFrom,
    DateTime? dateTo,
  }) {
    return database.inventoryHistoryDao.watchMovementsByStore(
      storeId,
      dateFrom: dateFrom,
      dateTo: dateTo,
    );
  }

  /// Stream de l'historique d'un item spécifique
  Stream<List<InventoryHistory>> watchMovementsByItem(String itemId) {
    return database.inventoryHistoryDao.watchMovementsByItem(itemId);
  }

  /// Enregistrer un mouvement de stock dans l'historique
  Future<void> recordMovement({
    required String storeId,
    required String itemId,
    String? variantId,
    required InventoryMovementReason reason,
    String? referenceId,
    required double quantityChange,
    required double quantityAfter,
    int? cost,
    String? employeeId,
  }) async {
    await _recordInventoryMovement(
      storeId: storeId,
      itemId: itemId,
      variantId: variantId,
      reason: reason,
      referenceId: referenceId,
      quantityChange: quantityChange,
      quantityAfter: quantityAfter,
      cost: cost ?? 0,
      employeeId: employeeId,
    );
  }

  // ─── MÉTHODES PRIVÉES ─────────────────────────────────────

  /// Mettre à jour le stock d'un item
  Future<void> _updateItemStock({
    required String itemId,
    String? variantId,
    required double newStock,
  }) async {
    if (variantId != null) {
      // Mettre à jour le stock du variant
      final now = DateTime.now().millisecondsSinceEpoch;
      await (database.update(database.itemVariants)
            ..where((tbl) => tbl.id.equals(variantId)))
          .write(
        ItemVariantsCompanion(
          inStock: Value(newStock.toInt()),
          updatedAt: Value(now),
          synced: const Value(0),
        ),
      );
    } else {
      // Mettre à jour le stock de l'item principal
      final now = DateTime.now().millisecondsSinceEpoch;
      await (database.update(database.items)
            ..where((tbl) => tbl.id.equals(itemId)))
          .write(
        ItemsCompanion(
          inStock: Value(newStock.toInt()),
          updatedAt: Value(now),
          synced: const Value(0),
        ),
      );
    }
  }

  /// Enregistrer un mouvement dans l'historique
  Future<void> _recordInventoryMovement({
    required String storeId,
    required String itemId,
    String? variantId,
    required InventoryMovementReason reason,
    String? referenceId,
    required double quantityChange,
    required double quantityAfter,
    required int cost,
    String? employeeId,
  }) async {
    final movement = InventoryHistoryCompanion(
      id: Value(_uuid.v4()),
      storeId: Value(storeId),
      itemId: Value(itemId),
      itemVariantId: Value(variantId),
      reason: Value(reason.index),
      referenceId: Value(referenceId),
      quantityChange: Value(quantityChange),
      quantityAfter: Value(quantityAfter),
      cost: Value(cost),
      employeeId: Value(employeeId),
      synced: const Value(0),
      createdAt: Value(DateTime.now().millisecondsSinceEpoch),
    );

    await database.inventoryHistoryDao.insertMovement(movement);
  }
}

/// Données pour créer un item d'ajustement
class AdjustmentItemData {
  final String itemId;
  final String? itemVariantId;
  final double quantityBefore;
  final double quantityChange;
  final double quantityAfter;
  final int cost;

  const AdjustmentItemData({
    required this.itemId,
    this.itemVariantId,
    required this.quantityBefore,
    required this.quantityChange,
    required this.quantityAfter,
    this.cost = 0,
  });
}

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/data/local/app_database.dart' hide Sale;

/// Repository pour les remboursements (offline-first)
/// Différenciant #1 : Remboursements offline vs Loyverse bloqué
class RefundRepository {
  final AppDatabase database;
  final _uuid = const Uuid();

  RefundRepository(this.database);

  /// Créer un remboursement complet (offline-first)
  Future<String> createRefund({
    required String saleId,
    required String storeId,
    required String employeeId,
    required List<RefundItemData> items,
    required String reason,
  }) async {
    try {
      final refundId = _uuid.v4();
      final now = DateTime.now();
      final timestamp = now.millisecondsSinceEpoch;

      // Calculer le total du remboursement
      final total = items.fold<int>(0, (sum, item) => sum + item.amount);

      // Créer le remboursement
      final refund = RefundsCompanion(
        id: Value(refundId),
        saleId: Value(saleId),
        storeId: Value(storeId),
        employeeId: Value(employeeId),
        total: Value(total),
        reason: Value(reason),
        synced: const Value(0),
        createdAt: Value(timestamp),
        updatedAt: Value(timestamp),
      );

      // Créer les lignes de remboursement
      final refundItems = items.map((item) {
        return RefundItemsCompanion(
          id: Value(_uuid.v4()),
          refundId: Value(refundId),
          saleItemId: Value(item.saleItemId),
          quantity: Value(item.quantity),
          amount: Value(item.amount),
          synced: const Value(0),
          createdAt: Value(timestamp),
          updatedAt: Value(timestamp),
        );
      }).toList();

      // Insérer en transaction
      await database.refundDao.insertFullRefund(
        refund: refund,
        items: refundItems,
      );

      // Mettre à jour le stock des items remboursés
      await _updateStockAfterRefund(items);

      // TODO: Sync vers Supabase en arrière-plan

      return refundId;
    } catch (e) {
      throw Exception('Erreur création remboursement: $e');
    }
  }

  /// Vérifier si une vente a déjà été remboursée
  Future<bool> isSaleRefunded(String saleId) async {
    final refunds = await database.refundDao
        .getRefundsBySale(saleId)
        .get();
    return refunds.isNotEmpty;
  }

  /// Obtenir les remboursements d'une vente
  Future<List<Refund>> getRefundsBySale(String saleId) async {
    return database.refundDao.getRefundsBySale(saleId).get();
  }

  /// Stream des remboursements d'un magasin
  Stream<List<Refund>> watchRefundsByStore(String storeId) {
    return database.refundDao.watchRefundsByStore(storeId);
  }

  /// Obtenir les items d'un remboursement
  Future<List<RefundItem>> getRefundItems(String refundId) async {
    return database.refundDao.getRefundItemsByRefund(refundId).get();
  }

  /// Mettre à jour le stock après remboursement
  /// Phase 3.14 : Enregistrement dans inventory_history
  Future<void> _updateStockAfterRefund(List<RefundItemData> items) async {
    for (final refundItem in items) {
      try {
        // 1. Récupérer le sale_item pour avoir l'item_id
        final saleItem = await (database.select(database.saleItems)
              ..where((tbl) => tbl.id.equals(refundItem.saleItemId)))
            .getSingleOrNull();

        if (saleItem == null) continue;

        // 2. Récupérer l'item pour vérifier track_stock
        final item = await (database.select(database.items)
              ..where((tbl) => tbl.id.equals(saleItem.itemId ?? '')))
            .getSingleOrNull();

        if (item == null || item.trackStock == 0) continue;

        // 3. Incrémenter le stock
        final newStock = item.inStock + refundItem.quantity.toInt();
        final now = DateTime.now().millisecondsSinceEpoch;

        await (database.update(database.items)
              ..where((tbl) => tbl.id.equals(item.id)))
            .write(
          ItemsCompanion(
            inStock: Value(newStock),
            updatedAt: Value(now),
            synced: const Value(0),
          ),
        );

        // 4. Enregistrer dans inventory_history
        final movement = InventoryHistoryCompanion(
          id: Value(_uuid.v4()),
          storeId: Value(item.storeId),
          itemId: Value(item.id),
          itemVariantId: Value(saleItem.itemVariantId),
          reason: const Value(1), // InventoryMovementReason.refund (index 1)
          referenceId: Value(refundItem.saleItemId),
          quantityChange: Value(refundItem.quantity),
          quantityAfter: Value(newStock.toDouble()),
          cost: Value(item.cost),
          employeeId: const Value(null),
          synced: const Value(0),
          createdAt: Value(now),
        );

        await database.inventoryHistoryDao.insertMovement(movement);
      } catch (e) {
        // Log error mais continuer pour les autres items
        print('Erreur mise à jour stock après refund: $e');
      }
    }
  }
}

/// Données pour créer un item de remboursement
class RefundItemData {
  final String saleItemId;
  final double quantity;
  final int amount; // en Ariary

  const RefundItemData({
    required this.saleItemId,
    required this.quantity,
    required this.amount,
  });
}

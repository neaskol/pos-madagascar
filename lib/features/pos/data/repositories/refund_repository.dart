import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/data/local/app_database.dart' hide Sale;
import '../../domain/entities/sale.dart';

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
  Future<void> _updateStockAfterRefund(List<RefundItemData> items) async {
    for (final refundItem in items) {
      // TODO: Récupérer l'item original depuis sale_items pour avoir item_id
      // TODO: Vérifier si track_stock = true
      // TODO: Incrémenter in_stock de la quantité remboursée
      // TODO: Enregistrer dans inventory_history (si table existe)

      // Pour l'instant, laisser en placeholder
      // Sera implémenté dans Phase 3.14 avec inventory_history
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

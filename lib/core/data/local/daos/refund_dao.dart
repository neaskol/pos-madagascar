import 'package:drift/drift.dart';
import '../app_database.dart';

part 'refund_dao.g.dart';

/// DAO pour les tables refunds et refund_items
/// Gère les remboursements (offline-first - Différenciant #1)
@DriftAccessor(include: {
  '../tables/refunds.drift',
})
class RefundDao extends DatabaseAccessor<AppDatabase> with _$RefundDaoMixin {
  RefundDao(AppDatabase db) : super(db);

  // ─── REFUNDS ──────────────────────────────────────────

  /// Insère un remboursement complet (refund + items) en transaction
  Future<void> insertFullRefund({
    required RefundsCompanion refund,
    required List<RefundItemsCompanion> items,
  }) async {
    await transaction(() async {
      await into(refunds).insert(refund);
      for (final item in items) {
        await into(refundItems).insert(item);
      }
    });
  }

  /// Insère un remboursement
  Future<int> insertRefund(RefundsCompanion refund) =>
      into(refunds).insert(refund);

  /// Marque un remboursement comme synchronisé
  Future<bool> markRefundSynced(String id) async {
    final rowsAffected = await (update(refunds)
          ..where((tbl) => tbl.id.equals(id)))
        .write(const RefundsCompanion(synced: Value(1)));
    return rowsAffected > 0;
  }

  /// Stream pour écouter les remboursements d'un magasin
  Stream<List<Refund>> watchRefundsByStore(String storeId) =>
      getRefundsByStore(storeId).watch();

  // ─── REFUND ITEMS ─────────────────────────────────────

  /// Insère une ligne de remboursement
  Future<int> insertRefundItem(RefundItemsCompanion item) =>
      into(refundItems).insert(item);

  /// Marque une ligne comme synchronisée
  Future<bool> markRefundItemSynced(String id) async {
    final rowsAffected = await (update(refundItems)
          ..where((tbl) => tbl.id.equals(id)))
        .write(const RefundItemsCompanion(synced: Value(1)));
    return rowsAffected > 0;
  }

  // ─── UPSERT (SYNC) ────────────────────────────────────

  /// Upsert (insert ou update) un remboursement depuis Supabase
  Future<void> upsertRefund(RefundsCompanion refund) async {
    await into(refunds).insertOnConflictUpdate(refund);
  }

  /// Upsert un refund_item depuis Supabase
  Future<void> upsertRefundItem(RefundItemsCompanion item) async {
    await into(refundItems).insertOnConflictUpdate(item);
  }
}

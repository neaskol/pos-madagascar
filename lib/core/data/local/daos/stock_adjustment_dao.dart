import 'package:drift/drift.dart';
import '../app_database.dart';

part 'stock_adjustment_dao.g.dart';

@DriftAccessor(include: {
  '../tables/stock_adjustments.drift',
  '../tables/stock_adjustment_items.drift',
})
class StockAdjustmentDao extends DatabaseAccessor<AppDatabase>
    with _$StockAdjustmentDaoMixin {
  StockAdjustmentDao(AppDatabase db) : super(db);

  // ─── STOCK ADJUSTMENTS ────────────────────────────────

  /// Insère un ajustement complet (adjustment + items) en transaction
  Future<void> insertFullAdjustment({
    required Insertable<StockAdjustment> adjustment,
    required List<Insertable<StockAdjustmentItem>> items,
  }) async {
    await transaction(() async {
      await into(stockAdjustments).insert(adjustment);
      for (final item in items) {
        await into(stockAdjustmentItems).insert(item);
      }
    });
  }

  /// Obtenir un ajustement par ID (utilise la query Drift)
  Selectable<StockAdjustment> getAdjustmentById(String id) =>
      (select(stockAdjustments)..where((t) => t.id.equals(id)));

  /// Stream des ajustements d'un magasin
  Stream<List<StockAdjustment>> watchAdjustments(String storeId) =>
      getAdjustmentsByStore(storeId).watch();

  /// Stream des items d'un ajustement
  Stream<List<StockAdjustmentItem>> watchAdjustmentItems(String adjustmentId) =>
      getAdjustmentItemsByAdjustment(adjustmentId).watch();

  /// Marque un ajustement comme synchronisé
  Future<bool> markSynced(String id) async {
    final rowsAffected = await (update(stockAdjustments)
          ..where((tbl) => tbl.id.equals(id)))
        .write(const StockAdjustmentsCompanion(synced: Value(1)));
    return rowsAffected > 0;
  }

  /// Marque un item d'ajustement comme synchronisé
  Future<bool> markItemSynced(String id) async {
    final rowsAffected = await (update(stockAdjustmentItems)
          ..where((tbl) => tbl.id.equals(id)))
        .write(const StockAdjustmentItemsCompanion(synced: Value(1)));
    return rowsAffected > 0;
  }

  // ─── UPSERT (SYNC) ────────────────────────────────────

  /// Upsert (insert ou update) un ajustement de stock depuis Supabase
  Future<void> upsertStockAdjustment(StockAdjustmentsCompanion adjustment) async {
    await into(stockAdjustments).insertOnConflictUpdate(adjustment);
  }

  /// Upsert un stock_adjustment_item depuis Supabase
  Future<void> upsertStockAdjustmentItem(StockAdjustmentItemsCompanion item) async {
    await into(stockAdjustmentItems).insertOnConflictUpdate(item);
  }
}

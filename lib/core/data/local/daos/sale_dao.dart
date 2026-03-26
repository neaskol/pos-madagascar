import 'package:drift/drift.dart';
import '../app_database.dart';

part 'sale_dao.g.dart';

/// DAO pour les tables sales, sale_items, sale_payments
/// Gère les ventes finalisées, lignes de vente et paiements
@DriftAccessor(include: {
  '../tables/sales.drift',
  '../tables/sale_items.drift',
  '../tables/sale_payments.drift',
})
class SaleDao extends DatabaseAccessor<AppDatabase> with _$SaleDaoMixin {
  SaleDao(AppDatabase db) : super(db);

  // ─── SALES ────────────────────────────────────────────

  /// Insère une vente complète (sale + items + payments) en transaction
  Future<void> insertFullSale({
    required SalesCompanion sale,
    required List<SaleItemsCompanion> items,
    required List<SalePaymentsCompanion> payments,
  }) async {
    await transaction(() async {
      await into(sales).insert(sale);
      for (final item in items) {
        await into(saleItems).insert(item);
      }
      for (final payment in payments) {
        await into(salePayments).insert(payment);
      }
    });
  }

  /// Insère une vente
  Future<int> insertSale(SalesCompanion sale) =>
      into(sales).insert(sale);

  /// Met à jour une vente et marque comme non synchronisée
  Future<bool> updateSale(SalesCompanion sale) async {
    final rowsAffected = await (update(sales)
          ..where((tbl) => tbl.id.equals(sale.id.value)))
        .write(sale.copyWith(
      synced: const Value(0),
      updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
    ));
    return rowsAffected > 0;
  }

  /// Suppression logique d'une vente
  Future<bool> deleteSale(String id) async {
    final rowsAffected = await (update(sales)
          ..where((tbl) => tbl.id.equals(id)))
        .write(SalesCompanion(
      deletedAt: Value(DateTime.now().millisecondsSinceEpoch),
      synced: const Value(0),
      updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
    ));
    return rowsAffected > 0;
  }

  /// Marque une vente comme synchronisée
  Future<bool> markSaleSynced(String id) async {
    final rowsAffected = await (update(sales)
          ..where((tbl) => tbl.id.equals(id)))
        .write(const SalesCompanion(synced: Value(1)));
    return rowsAffected > 0;
  }

  /// Génère le prochain numéro de reçu
  Future<String> generateReceiptNumber(String storeId) async {
    final result = await getLastReceiptNumber(storeId).getSingleOrNull();
    if (result == null) {
      return '0001';
    }
    final lastNumber = int.tryParse(result) ?? 0;
    return (lastNumber + 1).toString().padLeft(4, '0');
  }

  /// Stream pour écouter les ventes d'un magasin
  Stream<List<Sale>> watchSalesByStore(String storeId) =>
      getSalesByStore(storeId).watch();

  /// Nombre de ventes du jour
  Future<int> countSalesToday(String storeId) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    final result = await getSalesByDateRange(
      storeId,
      startOfDay.millisecondsSinceEpoch,
      endOfDay.millisecondsSinceEpoch,
    ).get();
    return result.length;
  }

  /// Total des ventes du jour
  Future<int> totalSalesToday(String storeId) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    final result = await getSalesByDateRange(
      storeId,
      startOfDay.millisecondsSinceEpoch,
      endOfDay.millisecondsSinceEpoch,
    ).get();
    return result.fold<int>(0, (sum, sale) => sum + sale.total);
  }

  // ─── SALE ITEMS ───────────────────────────────────────

  /// Insère une ligne de vente
  Future<int> insertSaleItem(SaleItemsCompanion item) =>
      into(saleItems).insert(item);

  /// Marque une ligne comme synchronisée
  Future<bool> markSaleItemSynced(String id) async {
    final rowsAffected = await (update(saleItems)
          ..where((tbl) => tbl.id.equals(id)))
        .write(const SaleItemsCompanion(synced: Value(1)));
    return rowsAffected > 0;
  }

  // ─── SALE PAYMENTS ────────────────────────────────────

  /// Insère un paiement
  Future<int> insertSalePayment(SalePaymentsCompanion payment) =>
      into(salePayments).insert(payment);

  /// Marque un paiement comme synchronisé
  Future<bool> markSalePaymentSynced(String id) async {
    final rowsAffected = await (update(salePayments)
          ..where((tbl) => tbl.id.equals(id)))
        .write(const SalePaymentsCompanion(synced: Value(1)));
    return rowsAffected > 0;
  }

  // ─── UPSERT (SYNC) ────────────────────────────────────

  /// Upsert (insert ou update) une vente depuis Supabase
  Future<void> upsertSale(SalesCompanion sale) async {
    await into(sales).insertOnConflictUpdate(sale);
  }

  /// Upsert un sale_item depuis Supabase
  Future<void> upsertSaleItem(SaleItemsCompanion item) async {
    await into(saleItems).insertOnConflictUpdate(item);
  }

  /// Upsert un sale_payment depuis Supabase
  Future<void> upsertSalePayment(SalePaymentsCompanion payment) async {
    await into(salePayments).insertOnConflictUpdate(payment);
  }
}

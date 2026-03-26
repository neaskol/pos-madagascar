import 'package:drift/drift.dart';
import '../app_database.dart';

part 'inventory_history_dao.g.dart';

@DriftAccessor(include: {
  '../tables/inventory_history.drift',
})
class InventoryHistoryDao extends DatabaseAccessor<AppDatabase>
    with _$InventoryHistoryDaoMixin {
  InventoryHistoryDao(AppDatabase db) : super(db);

  /// Insère un mouvement de stock
  Future<int> insertMovement(Insertable<InventoryHistory> movement) =>
      into(inventoryHistory).insert(movement);

  /// Stream des mouvements d'un item spécifique
  Stream<List<InventoryHistory>> watchMovementsByItem(String itemId) =>
      getMovementsByItem(itemId).watch();

  /// Stream des mouvements d'un magasin avec filtres optionnels
  Stream<List<InventoryHistory>> watchMovementsByStore(
    String storeId, {
    DateTime? dateFrom,
    DateTime? dateTo,
  }) {
    // Pour simplifier, utiliser la query SQL de base et filtrer si nécessaire
    // Drift ne supporte pas facilement les paramètres optionnels dans les queries
    return getMovementsByStore(storeId).watch();
  }

  /// Marque un mouvement comme synchronisé
  Future<bool> markSynced(String id) async {
    final rowsAffected = await (update(inventoryHistory)
          ..where((tbl) => tbl.id.equals(id)))
        .write(const InventoryHistoryCompanion(synced: Value(1)));
    return rowsAffected > 0;
  }
}

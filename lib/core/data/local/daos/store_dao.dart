import 'package:drift/drift.dart';
import '../app_database.dart';

part 'store_dao.g.dart';

/// DAO pour la table stores
/// Gère toutes les opérations CRUD sur les magasins en local (SQLite via Drift)
@DriftAccessor(include: {'../tables/stores.drift'})
class StoreDao extends DatabaseAccessor<AppDatabase> with _$StoreDaoMixin {
  StoreDao(AppDatabase db) : super(db);

  // Les queries définies dans stores.drift sont automatiquement générées
  // et disponibles via le mixin _$StoreDaoMixin:
  // - getAllStores() retourne Selectable<Store>
  // - getStoreById(id) retourne Selectable<Store>
  // - getUnsyncedStores() retourne Selectable<Store>
  //
  // Utiliser .get() pour Future<List<T>>, .getSingleOrNull() pour Future<T?>,
  // .watch() pour Stream<List<T>>, .watchSingleOrNull() pour Stream<T?>

  /// Insère ou met à jour un magasin (upsert)
  Future<int> insertStore(StoresCompanion store) =>
      into(stores).insertOnConflictUpdate(store);

  /// Met à jour un magasin existant et marque comme non synchronisé
  Future<bool> updateStore(StoresCompanion store) async {
    final rowsAffected = await (update(stores)
          ..where((tbl) => tbl.id.equals(store.id.value)))
        .write(store.copyWith(
      synced: const Value(0),
      updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
    ));
    return rowsAffected > 0;
  }

  /// Suppression logique (soft delete) d'un magasin
  Future<bool> deleteStore(String id) async {
    final rowsAffected = await (update(stores)..where((tbl) => tbl.id.equals(id))).write(
      StoresCompanion(
        deletedAt: Value(DateTime.now().millisecondsSinceEpoch),
        synced: const Value(0),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
    return rowsAffected > 0;
  }

  /// Marque un magasin comme synchronisé avec Supabase
  Future<bool> markStoreSynced(String id) async {
    final rowsAffected = await (update(stores)..where((tbl) => tbl.id.equals(id))).write(
      const StoresCompanion(
        synced: Value(1),
      ),
    );
    return rowsAffected > 0;
  }

  /// Compte le nombre total de magasins non supprimés
  Future<int> countStores() async {
    final query = selectOnly(stores)
      ..addColumns([stores.id.count()])
      ..where(stores.deletedAt.isNull());
    final result = await query.getSingleOrNull();
    return result?.read(stores.id.count()) ?? 0;
  }

  /// Stream pour écouter les changements sur tous les magasins
  Stream<List<Store>> watchAllStores() =>
      getAllStores().watch();

  /// Stream pour écouter les changements sur un magasin spécifique
  Stream<Store?> watchStoreById(String id) =>
      getStoreById(id).watchSingleOrNull();
}

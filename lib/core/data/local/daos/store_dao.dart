import 'package:drift/drift.dart';
import '../app_database.dart';

part 'store_dao.g.dart';

/// DAO pour la table stores
/// Gère toutes les opérations CRUD sur les magasins en local (SQLite via Drift)
@DriftAccessor(include: {'../tables/stores.drift'})
class StoreDao extends DatabaseAccessor<AppDatabase> with _$StoreDaoMixin {
  StoreDao(AppDatabase db) : super(db);

  /// Récupère tous les magasins non supprimés
  Future<List<Store>> getAllStores() => getAllStoresQuery().get();

  /// Récupère un magasin par ID
  Future<Store?> getStoreById(String id) =>
      getStoreByIdQuery(id).getSingleOrNull();

  /// Récupère tous les magasins non synchronisés avec Supabase
  Future<List<Store>> getUnsyncedStores() =>
      getUnsyncedStoresQuery().get();

  /// Insère un nouveau magasin
  Future<int> insertStore(StoresCompanion store) =>
      into(stores).insert(store);

  /// Met à jour un magasin existant et marque comme non synchronisé
  Future<bool> updateStore(StoresCompanion store) async {
    return await (update(stores)
          ..where((tbl) => tbl.id.equals(store.id.value)))
        .write(store.copyWith(
      synced: const Value(false),
      updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
    ));
  }

  /// Suppression logique (soft delete) d'un magasin
  Future<bool> deleteStore(String id) async {
    return await (update(stores)..where((tbl) => tbl.id.equals(id))).write(
      StoresCompanion(
        deletedAt: Value(DateTime.now().millisecondsSinceEpoch),
        synced: const Value(false),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  /// Marque un magasin comme synchronisé avec Supabase
  Future<bool> markStoreSynced(String id) async {
    return await (update(stores)..where((tbl) => tbl.id.equals(id))).write(
      const StoresCompanion(
        synced: Value(true),
      ),
    );
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
      getAllStoresQuery().watch();

  /// Stream pour écouter les changements sur un magasin spécifique
  Stream<Store?> watchStoreById(String id) =>
      getStoreByIdQuery(id).watchSingleOrNull();
}

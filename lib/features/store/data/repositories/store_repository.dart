import 'package:drift/drift.dart';
import '../../../../core/data/local/app_database.dart';

/// Repository pour la gestion des magasins
/// Couche intermédiaire entre les DAOs Drift et les BLoCs
class StoreRepository {
  final AppDatabase _database;

  StoreRepository(this._database);

  // Getters pour accéder aux DAOs
  StoreDao get _storeDao => _database.storeDao;

  /// Récupérer tous les magasins locaux
  Stream<List<Store>> watchAllStores() {
    return _storeDao.getAllStores().watch();
  }

  /// Récupérer un magasin par ID
  Future<Store?> getStoreById(String storeId) {
    return _storeDao.getStoreById(storeId).getSingleOrNull();
  }

  /// Créer un nouveau magasin
  Future<void> createStore({
    required String id,
    required String name,
    String? address,
    String? phone,
    String? logoUrl,
    String currency = 'MGA',
    String timezone = 'Indian/Antananarivo',
  }) async {
    final companion = StoresCompanion(
      id: Value(id),
      name: Value(name),
      address: Value(address),
      phone: Value(phone),
      logoUrl: Value(logoUrl),
      currency: Value(currency),
      timezone: Value(timezone),
      updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      synced: const Value(0),
    );

    await _storeDao.insertStore(companion);
  }

  /// Mettre à jour un magasin
  Future<void> updateStore({
    required String id,
    String? name,
    String? address,
    String? phone,
    String? logoUrl,
    String? currency,
    String? timezone,
  }) async {
    final companion = StoresCompanion(
      id: Value(id),
      name: name != null ? Value(name) : const Value.absent(),
      address: address != null ? Value(address) : const Value.absent(),
      phone: phone != null ? Value(phone) : const Value.absent(),
      logoUrl: logoUrl != null ? Value(logoUrl) : const Value.absent(),
      currency: currency != null ? Value(currency) : const Value.absent(),
      timezone: timezone != null ? Value(timezone) : const Value.absent(),
      updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      synced: const Value(0),
    );

    await _storeDao.updateStore(companion);
  }

  /// Supprimer un magasin
  Future<void> deleteStore(String storeId) {
    return _storeDao.deleteStore(storeId);
  }

  /// Récupérer les magasins non synchronisés
  Future<List<Store>> getUnsyncedStores() {
    return _storeDao.getUnsyncedStores().get();
  }

  /// Marquer un magasin comme synchronisé
  Future<void> markStoreAsSynced(String storeId) {
    return _storeDao.markStoreSynced(storeId);
  }

  /// Compter le nombre total de magasins
  Future<int> countStores() {
    return _storeDao.countStores();
  }
}

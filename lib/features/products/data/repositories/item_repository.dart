import 'package:drift/drift.dart';
import '../../../../core/data/local/app_database.dart';

/// Repository pour la gestion des items (produits)
/// Couche intermédiaire entre les DAOs Drift et les BLoCs
class ItemRepository {
  final AppDatabase _database;

  ItemRepository(this._database);

  // Getters pour accéder aux DAOs
  ItemDao get _itemDao => _database.itemDao;

  /// Récupérer tous les items d'un magasin
  Stream<List<Item>> watchStoreItems(String storeId) {
    return _itemDao.getItemsByStore(storeId).watch();
  }

  /// Récupérer un item par ID
  Future<Item?> getItemById(String itemId) {
    return _itemDao.getItemById(itemId).getSingleOrNull();
  }

  /// Récupérer un item par SKU
  Future<Item?> getItemBySku(String storeId, String sku) {
    return _itemDao.getItemsBySku(sku).getSingleOrNull();
  }

  /// Récupérer un item par code-barres
  Future<Item?> getItemByBarcode(String storeId, String barcode) {
    return _itemDao.getItemByBarcode(barcode).getSingleOrNull();
  }

  /// Récupérer tous les items d'une catégorie
  Stream<List<Item>> watchCategoryItems(String categoryId) async* {
    // getItemsByCategory retourne Future<List<Item>>, pas Selectable
    // On le convertit en Stream
    yield await _itemDao.getItemsByCategory(categoryId);
  }

  /// Récupérer tous les items disponibles à la vente
  Stream<List<Item>> watchAvailableItems(String storeId) {
    return _itemDao.getAvailableItems(storeId).watch();
  }

  /// Rechercher des items par nom
  Future<List<Item>> searchItemsByName(String storeId, String query) {
    return _itemDao.searchItems(storeId, query).get();
  }

  /// Créer un nouvel item
  Future<void> createItem({
    required String id,
    required String storeId,
    required String name,
    String? description,
    String? sku,
    String? barcode,
    String? categoryId,
    required int price,
    int cost = 0,
    bool costIsPercentage = false,
    String soldBy = 'piece',
    bool availableForSale = true,
    bool trackStock = false,
    int inStock = 0,
    int lowStockThreshold = 0,
    bool isComposite = false,
    bool useProduction = false,
    String? imageUrl,
    int averageCost = 0,
  }) async {
    final companion = ItemsCompanion(
      id: Value(id),
      storeId: Value(storeId),
      name: Value(name),
      description: Value(description),
      sku: Value(sku),
      barcode: Value(barcode),
      categoryId: Value(categoryId),
      price: Value(price),
      cost: Value(cost),
      costIsPercentage: Value(costIsPercentage ? 1 : 0),
      soldBy: Value(soldBy),
      availableForSale: Value(availableForSale ? 1 : 0),
      trackStock: Value(trackStock ? 1 : 0),
      inStock: Value(inStock),
      lowStockThreshold: Value(lowStockThreshold),
      isComposite: Value(isComposite ? 1 : 0),
      useProduction: Value(useProduction ? 1 : 0),
      imageUrl: Value(imageUrl),
      averageCost: Value(averageCost),
      updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      synced: const Value(0),
    );

    await _itemDao.insertItem(companion);
  }

  /// Mettre à jour un item
  Future<void> updateItem({
    required String id,
    String? name,
    String? description,
    String? sku,
    String? barcode,
    String? categoryId,
    int? price,
    int? cost,
    bool? costIsPercentage,
    String? soldBy,
    bool? availableForSale,
    bool? trackStock,
    int? inStock,
    int? lowStockThreshold,
    bool? isComposite,
    bool? useProduction,
    String? imageUrl,
    int? averageCost,
  }) async {
    final companion = ItemsCompanion(
      id: Value(id),
      name: name != null ? Value(name) : const Value.absent(),
      description: description != null ? Value(description) : const Value.absent(),
      sku: sku != null ? Value(sku) : const Value.absent(),
      barcode: barcode != null ? Value(barcode) : const Value.absent(),
      categoryId: categoryId != null ? Value(categoryId) : const Value.absent(),
      price: price != null ? Value(price) : const Value.absent(),
      cost: cost != null ? Value(cost) : const Value.absent(),
      costIsPercentage: costIsPercentage != null ? Value(costIsPercentage ? 1 : 0) : const Value.absent(),
      soldBy: soldBy != null ? Value(soldBy) : const Value.absent(),
      availableForSale: availableForSale != null ? Value(availableForSale ? 1 : 0) : const Value.absent(),
      trackStock: trackStock != null ? Value(trackStock ? 1 : 0) : const Value.absent(),
      inStock: inStock != null ? Value(inStock) : const Value.absent(),
      lowStockThreshold: lowStockThreshold != null ? Value(lowStockThreshold) : const Value.absent(),
      isComposite: isComposite != null ? Value(isComposite ? 1 : 0) : const Value.absent(),
      useProduction: useProduction != null ? Value(useProduction ? 1 : 0) : const Value.absent(),
      imageUrl: imageUrl != null ? Value(imageUrl) : const Value.absent(),
      averageCost: averageCost != null ? Value(averageCost) : const Value.absent(),
      updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      synced: const Value(0),
    );

    await _itemDao.updateItem(companion);
  }

  /// Supprimer un item
  Future<void> deleteItem(String itemId) {
    return _itemDao.deleteItem(itemId);
  }

  /// Mettre à jour le stock d'un item
  Future<void> updateItemStock(String itemId, int newStock) async {
    await _itemDao.updateStock(
      itemId: itemId,
      quantityChange: newStock,
    );
  }

  /// Mettre à jour le coût moyen d'un item
  Future<void> updateAverageCost(String itemId, int newAverageCost) async {
    final item = await getItemById(itemId);
    if (item == null) return;

    await _itemDao.updateItem(
      ItemsCompanion(
        id: Value(itemId),
        averageCost: Value(newAverageCost),
        synced: const Value(0),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  /// Récupérer les items avec stock bas
  Future<List<Item>> getLowStockItems(String storeId) {
    return _itemDao.getLowStockItems(storeId).get();
  }

  /// Récupérer les items non synchronisés
  Future<List<Item>> getUnsyncedItems() {
    return _itemDao.getUnsyncedItems().get();
  }

  /// Marquer un item comme synchronisé
  Future<void> markItemAsSynced(String itemId) {
    return _itemDao.markItemSynced(itemId);
  }

  /// Compter le nombre d'items d'un magasin
  Future<int> countStoreItems(String storeId) {
    return _itemDao.countItemsByStore(storeId);
  }
}

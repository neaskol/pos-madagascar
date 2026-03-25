import 'package:drift/drift.dart';
import '../app_database.dart';

part 'item_dao.g.dart';

/// DAO pour la table items
/// Gère toutes les opérations CRUD sur les produits/articles
@DriftAccessor(include: {'../tables/items.drift'})
class ItemDao extends DatabaseAccessor<AppDatabase> with _$ItemDaoMixin {
  ItemDao(AppDatabase db) : super(db);

  // Les queries définies dans items.drift sont automatiquement générées
  // et disponibles via le mixin _$ItemDaoMixin:
  // - getItemsByStore(storeId) retourne Selectable<Item>
  // - getAvailableItems(storeId) retourne Selectable<Item>
  // - getItemById(id) retourne Selectable<Item>
  // - getItemByBarcode(barcode) retourne Selectable<Item>
  // - getItemsBySku(sku) retourne Selectable<Item>
  // - getLowStockItems(storeId) retourne Selectable<Item>
  // - getUnsyncedItems() retourne Selectable<Item>
  //
  // Utiliser .get() pour Future<List<T>>, .getSingleOrNull() pour Future<T?>,
  // .watch() pour Stream<List<T>>, .watchSingleOrNull() pour Stream<T?>

  /// Insère un nouvel item
  Future<int> insertItem(ItemsCompanion item) =>
      into(items).insert(item);

  /// Met à jour un item existant et marque comme non synchronisé
  Future<bool> updateItem(ItemsCompanion item) async {
    final rowsAffected = await (update(items)
          ..where((tbl) => tbl.id.equals(item.id.value)))
        .write(item.copyWith(
      synced: const Value(0),
      updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
    ));
    return rowsAffected > 0;
  }

  /// Suppression logique (soft delete) d'un item
  Future<bool> deleteItem(String id) async {
    final rowsAffected = await (update(items)..where((tbl) => tbl.id.equals(id))).write(
      ItemsCompanion(
        deletedAt: Value(DateTime.now().millisecondsSinceEpoch),
        synced: const Value(0),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
    return rowsAffected > 0;
  }

  /// Marque un item comme synchronisé avec Supabase
  Future<bool> markItemSynced(String id) async {
    final rowsAffected = await (update(items)..where((tbl) => tbl.id.equals(id))).write(
      const ItemsCompanion(
        synced: Value(1),
      ),
    );
    return rowsAffected > 0;
  }

  /// Compte le nombre d'items dans un magasin
  Future<int> countItemsByStore(String storeId) async {
    final query = selectOnly(items)
      ..addColumns([items.id.count()])
      ..where(items.storeId.equals(storeId))
      ..where(items.deletedAt.isNull());
    final result = await query.getSingleOrNull();
    return result?.read(items.id.count()) ?? 0;
  }

  /// Récupère les items d'une catégorie
  Future<List<Item>> getItemsByCategory(String categoryId) {
    return (select(items)
          ..where((tbl) =>
              tbl.categoryId.equals(categoryId) &
              tbl.deletedAt.isNull())
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.name)]))
        .get();
  }

  /// Met à jour le stock d'un item (après vente ou réception)
  Future<bool> updateStock({
    required String itemId,
    required int quantityChange,
    int? newAverageCost,
  }) async {
    final item = await getItemById(itemId).getSingleOrNull();
    if (item == null) return false;

    final newStock = item.inStock + quantityChange;
    if (newStock < 0 && item.trackStock == 1) {
      // Stock négatif non autorisé si suivi de stock activé
      // (sauf si negative_stock_alerts est activé dans store_settings)
      throw Exception('Stock insuffisant');
    }

    final rowsAffected = await (update(items)..where((tbl) => tbl.id.equals(itemId))).write(
      ItemsCompanion(
        inStock: Value(newStock),
        averageCost: newAverageCost != null ? Value(newAverageCost) : const Value.absent(),
        synced: const Value(0),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
    return rowsAffected > 0;
  }

  /// Active ou désactive un item pour la vente
  Future<bool> setItemAvailability(String id, bool available) async {
    final rowsAffected = await (update(items)..where((tbl) => tbl.id.equals(id))).write(
      ItemsCompanion(
        availableForSale: Value(available ? 1 : 0),
        synced: const Value(0),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
    return rowsAffected > 0;
  }

  /// Vérifie si un SKU existe déjà dans le magasin
  Future<bool> skuExists(String storeId, String sku, {String? excludeItemId}) async {
    final query = select(items)
      ..where((tbl) =>
          tbl.storeId.equals(storeId) &
          tbl.sku.equals(sku) &
          tbl.deletedAt.isNull());

    if (excludeItemId != null) {
      query.where((tbl) => tbl.id.equals(excludeItemId).not());
    }

    final result = await query.getSingleOrNull();
    return result != null;
  }

  /// Compte les items en stock faible dans un magasin
  Future<int> countLowStockItems(String storeId) async {
    final query = selectOnly(items)
      ..addColumns([items.id.count()])
      ..where(items.storeId.equals(storeId))
      ..where(items.trackStock.equals(1))
      ..where(items.inStock.isSmallerOrEqual(items.lowStockThreshold))
      ..where(items.deletedAt.isNull());
    final result = await query.getSingleOrNull();
    return result?.read(items.id.count()) ?? 0;
  }

  /// Stream pour écouter les changements sur les items d'un magasin
  Stream<List<Item>> watchItemsByStore(String storeId) =>
      getItemsByStore(storeId).watch();

  /// Stream pour écouter les changements sur les items disponibles
  Stream<List<Item>> watchAvailableItems(String storeId) =>
      getAvailableItems(storeId).watch();

  /// Stream pour écouter les changements sur un item spécifique
  Stream<Item?> watchItemById(String id) =>
      getItemById(id).watchSingleOrNull();

  /// Stream pour écouter les items en stock faible
  Stream<List<Item>> watchLowStockItems(String storeId) =>
      getLowStockItems(storeId).watch();
}

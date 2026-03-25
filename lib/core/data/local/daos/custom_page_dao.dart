import 'package:drift/drift.dart';
import '../app_database.dart';

part 'custom_page_dao.g.dart';

/// DAO pour gérer les pages personnalisées de produits
@DriftAccessor(include: {'../tables/custom_pages.drift'})
class CustomPageDao extends DatabaseAccessor<AppDatabase>
    with _$CustomPageDaoMixin {
  CustomPageDao(AppDatabase db) : super(db);

  // ========== CUSTOM PRODUCT PAGES ==========

  /// Obtenir toutes les pages d'un magasin, triées par sort_order
  Future<List<CustomProductPage>> getStorePages(String storeId) {
    return (select(customProductPages)
          ..where((p) => p.storeId.equals(storeId))
          ..orderBy([(p) => OrderingTerm.asc(p.sortOrder)]))
        .get();
  }

  /// Obtenir la page par défaut d'un magasin
  Future<CustomProductPage?> getDefaultPage(String storeId) {
    return (select(customProductPages)
          ..where((p) => p.storeId.equals(storeId) & p.isDefault.equals(1)))
        .getSingleOrNull();
  }

  /// Obtenir une page par ID
  Future<CustomProductPage?> getPageById(String pageId) {
    return (select(customProductPages)..where((p) => p.id.equals(pageId)))
        .getSingleOrNull();
  }

  /// Créer une nouvelle page personnalisée
  Future<int> createPage(CustomProductPagesCompanion page) async {
    return await into(customProductPages).insert(page);
  }

  /// Mettre à jour une page
  Future<bool> updatePage(CustomProductPagesCompanion page) async {
    final rowsAffected = await (update(customProductPages)
          ..where((tbl) => tbl.id.equals(page.id.value)))
        .write(page.copyWith(
      synced: const Value(0),
      updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
    ));
    return rowsAffected > 0;
  }

  /// Supprimer une page (cascade supprime les items et grilles associés)
  Future<int> deletePage(String pageId) async {
    // Supprimer les items de la page
    await (delete(customPageItems)..where((i) => i.pageId.equals(pageId))).go();

    // Supprimer les grilles de catégories de la page
    await (delete(customPageCategoryGrids)..where((g) => g.pageId.equals(pageId))).go();

    // Supprimer la page elle-même
    return await (delete(customProductPages)
          ..where((p) => p.id.equals(pageId)))
        .go();
  }

  /// Créer la page par défaut "All Products" pour un nouveau magasin
  Future<int> createDefaultPage(String storeId, String name) async {
    final pageId = DateTime.now().millisecondsSinceEpoch.toString();
    final now = DateTime.now().millisecondsSinceEpoch;

    return await into(customProductPages).insert(
      CustomProductPagesCompanion.insert(
        id: pageId,
        storeId: storeId,
        name: name,
        sortOrder: const Value(0),
        isDefault: const Value(1),
        createdAt: now,
        updatedAt: now,
        synced: const Value(0),
      ),
    );
  }

  // ========== CUSTOM PAGE ITEMS ==========

  /// Obtenir tous les items d'une page, triés par position
  Future<List<CustomPageItem>> getPageItems(String pageId) {
    return (select(customPageItems)
          ..where((i) => i.pageId.equals(pageId))
          ..orderBy([(i) => OrderingTerm.asc(i.position)]))
        .get();
  }

  /// Ajouter un item à une page
  Future<int> addItemToPage({
    required String pageId,
    required String itemId,
    required int position,
  }) async {
    final itemPageId = DateTime.now().millisecondsSinceEpoch.toString();
    final now = DateTime.now().millisecondsSinceEpoch;

    return await into(customPageItems).insert(
      CustomPageItemsCompanion.insert(
        id: itemPageId,
        pageId: pageId,
        itemId: itemId,
        position: position,
        createdAt: now,
        synced: const Value(0),
      ),
    );
  }

  /// Supprimer un item d'une page
  Future<int> removeItemFromPage({
    required String pageId,
    required String itemId,
  }) async {
    return await (delete(customPageItems)
          ..where((i) => i.pageId.equals(pageId) & i.itemId.equals(itemId)))
        .go();
  }

  /// Mettre à jour la position d'un item dans une page
  Future<bool> updateItemPosition({
    required String pageId,
    required String itemId,
    required int newPosition,
  }) async {
    final rowsAffected = await (update(customPageItems)
          ..where((i) => i.pageId.equals(pageId) & i.itemId.equals(itemId)))
        .write(CustomPageItemsCompanion(
          position: Value(newPosition),
          synced: const Value(0),
        ));
    return rowsAffected > 0;
  }

  /// Réorganiser tous les items d'une page (pour drag & drop)
  Future<void> reorderPageItems({
    required String pageId,
    required List<String> itemIds,
  }) async {
    return await transaction(() async {
      for (var i = 0; i < itemIds.length; i++) {
        await updateItemPosition(
          pageId: pageId,
          itemId: itemIds[i],
          newPosition: i,
        );
      }
    });
  }

  /// Supprimer tous les items d'une page
  Future<int> clearPageItems(String pageId) async {
    return await (delete(customPageItems)
          ..where((i) => i.pageId.equals(pageId)))
        .go();
  }

  // ========== CUSTOM PAGE CATEGORY GRIDS ==========

  /// Obtenir toutes les grilles de catégories d'une page
  Future<List<CustomPageCategoryGrid>> getPageCategoryGrids(String pageId) {
    return (select(customPageCategoryGrids)
          ..where((g) => g.pageId.equals(pageId))
          ..orderBy([(g) => OrderingTerm.asc(g.position)]))
        .get();
  }

  /// Ajouter une grille de catégorie à une page
  Future<int> addCategoryGridToPage({
    required String pageId,
    required String categoryId,
    required int position,
  }) async {
    final gridId = DateTime.now().millisecondsSinceEpoch.toString();
    final now = DateTime.now().millisecondsSinceEpoch;

    return await into(customPageCategoryGrids).insert(
      CustomPageCategoryGridsCompanion.insert(
        id: gridId,
        pageId: pageId,
        categoryId: categoryId,
        position: position,
        createdAt: now,
        synced: const Value(0),
      ),
    );
  }

  /// Supprimer une grille de catégorie d'une page
  Future<int> removeCategoryGridFromPage({
    required String pageId,
    required String categoryId,
  }) async {
    return await (delete(customPageCategoryGrids)
          ..where(
              (g) => g.pageId.equals(pageId) & g.categoryId.equals(categoryId)))
        .go();
  }

  /// Supprimer toutes les grilles de catégories d'une page
  Future<int> clearPageCategoryGrids(String pageId) async {
    return await (delete(customPageCategoryGrids)
          ..where((g) => g.pageId.equals(pageId)))
        .go();
  }

  // ========== SYNC ==========

  /// Marquer une page comme synchronisée
  Future<void> markPageAsSynced(String pageId) async {
    await (update(customProductPages)..where((p) => p.id.equals(pageId)))
        .write(const CustomProductPagesCompanion(synced: Value(1)));
  }

  /// Obtenir toutes les pages non synchronisées
  Future<List<CustomProductPage>> getUnsyncedPages(String storeId) {
    return (select(customProductPages)
          ..where((p) => p.storeId.equals(storeId) & p.synced.equals(0)))
        .get();
  }

  /// Marquer tous les items d'une page comme synchronisés
  Future<void> markPageItemsAsSynced(String pageId) async {
    await (update(customPageItems)..where((i) => i.pageId.equals(pageId)))
        .write(const CustomPageItemsCompanion(synced: Value(1)));
  }

  /// Marquer toutes les grilles de catégories d'une page comme synchronisées
  Future<void> markPageCategoryGridsAsSynced(String pageId) async {
    await (update(customPageCategoryGrids)
          ..where((g) => g.pageId.equals(pageId)))
        .write(const CustomPageCategoryGridsCompanion(synced: Value(1)));
  }

  // ========== QUERIES COMPLEXES ==========

  /// Obtenir le nombre d'items sur une page
  Future<int> getPageItemCount(String pageId) async {
    final countQuery = selectOnly(customPageItems)
      ..where(customPageItems.pageId.equals(pageId))
      ..addColumns([customPageItems.id.count()]);

    final result = await countQuery.getSingleOrNull();
    return result?.read(customPageItems.id.count()) ?? 0;
  }

  /// Obtenir le nombre total de pages d'un magasin
  Future<int> getStorePageCount(String storeId) async {
    final countQuery = selectOnly(customProductPages)
      ..where(customProductPages.storeId.equals(storeId))
      ..addColumns([customProductPages.id.count()]);

    final result = await countQuery.getSingleOrNull();
    return result?.read(customProductPages.id.count()) ?? 0;
  }

  /// Vérifier si un item est déjà sur une page
  Future<bool> isItemOnPage({
    required String pageId,
    required String itemId,
  }) async {
    final result = await (select(customPageItems)
          ..where((i) => i.pageId.equals(pageId) & i.itemId.equals(itemId)))
        .getSingleOrNull();
    return result != null;
  }

  /// Vérifier si une catégorie est déjà sur une page
  Future<bool> isCategoryOnPage({
    required String pageId,
    required String categoryId,
  }) async {
    final result = await (select(customPageCategoryGrids)
          ..where(
              (g) => g.pageId.equals(pageId) & g.categoryId.equals(categoryId)))
        .getSingleOrNull();
    return result != null;
  }

  /// Stream pour écouter les pages d'un magasin
  Stream<List<CustomProductPage>> watchStorePages(String storeId) {
    return (select(customProductPages)
          ..where((p) => p.storeId.equals(storeId))
          ..orderBy([(p) => OrderingTerm.asc(p.sortOrder)]))
        .watch();
  }

  /// Stream pour écouter une page spécifique
  Stream<CustomProductPage?> watchPageById(String pageId) {
    return (select(customProductPages)..where((p) => p.id.equals(pageId)))
        .watchSingleOrNull();
  }

  /// Stream pour écouter les items d'une page
  Stream<List<CustomPageItem>> watchPageItems(String pageId) {
    return (select(customPageItems)
          ..where((i) => i.pageId.equals(pageId))
          ..orderBy([(i) => OrderingTerm.asc(i.position)]))
        .watch();
  }

  /// Stream pour écouter les grilles de catégories d'une page
  Stream<List<CustomPageCategoryGrid>> watchPageCategoryGrids(String pageId) {
    return (select(customPageCategoryGrids)
          ..where((g) => g.pageId.equals(pageId))
          ..orderBy([(g) => OrderingTerm.asc(g.position)]))
        .watch();
  }
}

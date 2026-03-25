import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/data/local/app_database.dart';
import '../../domain/entities/custom_product_page.dart';
import 'package:drift/drift.dart' as drift;
import 'dart:developer' as developer;

/// Repository pour gérer les pages personnalisées de produits
/// Pattern: Local-first avec synchronisation Supabase en arrière-plan
class CustomPageRepositoryImpl {
  final AppDatabase _database;
  final SupabaseClient _supabase;

  CustomPageRepositoryImpl({
    required AppDatabase database,
    required SupabaseClient supabase,
  })  : _database = database,
        _supabase = supabase;

  // ========== PAGES ==========

  /// Obtenir toutes les pages d'un magasin
  Future<List<CustomProductPageEntity>> getStorePages(String storeId) async {
    final pages = await _database.customPageDao.getStorePages(storeId);
    return pages.map(_pageToEntity).toList();
  }

  /// Obtenir la page par défaut
  Future<CustomProductPageEntity?> getDefaultPage(String storeId) async {
    final page = await _database.customPageDao.getDefaultPage(storeId);
    return page != null ? _pageToEntity(page) : null;
  }

  /// Créer une nouvelle page
  Future<CustomProductPageEntity> createPage({
    required String storeId,
    required String name,
    required int sortOrder,
    String? createdBy,
  }) async {
    final pageId = DateTime.now().millisecondsSinceEpoch.toString();
    final now = DateTime.now().millisecondsSinceEpoch;

    final companion = CustomProductPagesCompanion.insert(
      id: pageId,
      storeId: storeId,
      name: name,
      sortOrder: drift.Value(sortOrder),
      isDefault: const drift.Value(0),
      createdBy: drift.Value(createdBy),
      createdAt: now,
      updatedAt: now,
      synced: const drift.Value(0),
    );

    await _database.customPageDao.createPage(companion);

    // Sync avec Supabase en arrière-plan
    _syncPageToSupabase(pageId);

    final page = await _database.customPageDao.getPageById(pageId);
    return _pageToEntity(page!);
  }

  /// Mettre à jour une page
  Future<void> updatePage({
    required String pageId,
    String? name,
    int? sortOrder,
  }) async {
    final page = await _database.customPageDao.getPageById(pageId);
    if (page == null) throw Exception('Page not found');

    final companion = CustomProductPagesCompanion(
      id: drift.Value(pageId),
      name: name != null ? drift.Value(name) : drift.Value.absent(),
      sortOrder: sortOrder != null ? drift.Value(sortOrder) : drift.Value.absent(),
      updatedAt: drift.Value(DateTime.now().millisecondsSinceEpoch),
      synced: const drift.Value(0),
    );

    await _database.customPageDao.updatePage(companion);

    // Sync avec Supabase
    _syncPageToSupabase(pageId);
  }

  /// Supprimer une page
  Future<void> deletePage(String pageId) async {
    await _database.customPageDao.deletePage(pageId);

    // Supprimer de Supabase
    try {
      await _supabase.from('custom_product_pages').delete().eq('id', pageId);
    } catch (e) {
      // Ignorer les erreurs offline
    }
  }

  /// Créer la page par défaut "All Products"
  Future<void> createDefaultPage(String storeId, String name) async {
    await _database.customPageDao.createDefaultPage(storeId, name);
  }

  // ========== PAGE ITEMS ==========

  /// Obtenir les items d'une page
  Future<List<CustomPageItemEntity>> getPageItems(String pageId) async {
    final items = await _database.customPageDao.getPageItems(pageId);
    return items.map(_pageItemToEntity).toList();
  }

  /// Ajouter un item à une page
  Future<void> addItemToPage({
    required String pageId,
    required String itemId,
    required int position,
  }) async {
    await _database.customPageDao.addItemToPage(
      pageId: pageId,
      itemId: itemId,
      position: position,
    );

    // Sync avec Supabase
    _syncPageItemsToSupabase(pageId);
  }

  /// Supprimer un item d'une page
  Future<void> removeItemFromPage({
    required String pageId,
    required String itemId,
  }) async {
    await _database.customPageDao.removeItemFromPage(
      pageId: pageId,
      itemId: itemId,
    );

    // Supprimer de Supabase
    try {
      await _supabase
          .from('custom_page_items')
          .delete()
          .eq('page_id', pageId)
          .eq('item_id', itemId);
    } catch (e) {
      // Ignorer les erreurs offline
    }
  }

  /// Réorganiser les items d'une page (drag & drop)
  Future<void> reorderPageItems({
    required String pageId,
    required List<String> itemIds,
  }) async {
    await _database.customPageDao.reorderPageItems(
      pageId: pageId,
      itemIds: itemIds,
    );

    // Sync avec Supabase
    _syncPageItemsToSupabase(pageId);
  }

  /// Vider tous les items d'une page
  Future<void> clearPageItems(String pageId) async {
    await _database.customPageDao.clearPageItems(pageId);

    // Supprimer de Supabase
    try {
      await _supabase.from('custom_page_items').delete().eq('page_id', pageId);
    } catch (e) {
      // Ignorer les erreurs offline
    }
  }

  // ========== PAGE CATEGORY GRIDS ==========

  /// Obtenir les grilles de catégories d'une page
  Future<List<CustomPageCategoryGridEntity>> getPageCategoryGrids(
      String pageId) async {
    final grids = await _database.customPageDao.getPageCategoryGrids(pageId);
    return grids.map(_categoryGridToEntity).toList();
  }

  /// Ajouter une grille de catégorie à une page
  Future<void> addCategoryGridToPage({
    required String pageId,
    required String categoryId,
    required int position,
  }) async {
    await _database.customPageDao.addCategoryGridToPage(
      pageId: pageId,
      categoryId: categoryId,
      position: position,
    );

    // Sync avec Supabase
    _syncPageCategoryGridsToSupabase(pageId);
  }

  /// Supprimer une grille de catégorie d'une page
  Future<void> removeCategoryGridFromPage({
    required String pageId,
    required String categoryId,
  }) async {
    await _database.customPageDao.removeCategoryGridFromPage(
      pageId: pageId,
      categoryId: categoryId,
    );

    // Supprimer de Supabase
    try {
      await _supabase
          .from('custom_page_category_grids')
          .delete()
          .eq('page_id', pageId)
          .eq('category_id', categoryId);
    } catch (e) {
      // Ignorer les erreurs offline
    }
  }

  // ========== HELPERS ==========

  /// Vérifier si un item est sur une page
  Future<bool> isItemOnPage({
    required String pageId,
    required String itemId,
  }) async {
    return await _database.customPageDao.isItemOnPage(
      pageId: pageId,
      itemId: itemId,
    );
  }

  /// Obtenir le nombre d'items sur une page
  Future<int> getPageItemCount(String pageId) async {
    return await _database.customPageDao.getPageItemCount(pageId);
  }

  // ========== SYNCHRONISATION SUPABASE ==========

  /// Synchroniser une page vers Supabase
  Future<void> _syncPageToSupabase(String pageId) async {
    try {
      final page = await _database.customPageDao.getPageById(pageId);
      if (page == null) return;

      final data = {
        'id': page.id,
        'store_id': page.storeId,
        'name': page.name,
        'sort_order': page.sortOrder,
        'is_default': page.isDefault == 1,
        'created_by': page.createdBy,
        'created_at':
            DateTime.fromMillisecondsSinceEpoch(page.createdAt).toIso8601String(),
        'updated_at':
            DateTime.fromMillisecondsSinceEpoch(page.updatedAt).toIso8601String(),
      };

      await _supabase.from('custom_product_pages').upsert(data);

      // Marquer comme synchronisé
      await _database.customPageDao.markPageAsSynced(pageId);
    } catch (e) {
      // Ignorer les erreurs offline - sera synchronisé plus tard
      developer.log('Erreur sync page: $e', name: 'CustomPageRepository');
    }
  }

  /// Synchroniser les items d'une page vers Supabase
  Future<void> _syncPageItemsToSupabase(String pageId) async {
    try {
      final items = await _database.customPageDao.getPageItems(pageId);

      for (final item in items) {
        final data = {
          'id': item.id,
          'page_id': item.pageId,
          'item_id': item.itemId,
          'position': item.position,
          'created_at':
              DateTime.fromMillisecondsSinceEpoch(item.createdAt).toIso8601String(),
        };

        await _supabase.from('custom_page_items').upsert(data);
      }

      // Marquer comme synchronisés
      await _database.customPageDao.markPageItemsAsSynced(pageId);
    } catch (e) {
      developer.log('Erreur sync page items: $e', name: 'CustomPageRepository');
    }
  }

  /// Synchroniser les grilles de catégories vers Supabase
  Future<void> _syncPageCategoryGridsToSupabase(String pageId) async {
    try {
      final grids = await _database.customPageDao.getPageCategoryGrids(pageId);

      for (final grid in grids) {
        final data = {
          'id': grid.id,
          'page_id': grid.pageId,
          'category_id': grid.categoryId,
          'position': grid.position,
          'created_at':
              DateTime.fromMillisecondsSinceEpoch(grid.createdAt).toIso8601String(),
        };

        await _supabase.from('custom_page_category_grids').upsert(data);
      }

      // Marquer comme synchronisés
      await _database.customPageDao.markPageCategoryGridsAsSynced(pageId);
    } catch (e) {
      developer.log('Erreur sync category grids: $e', name: 'CustomPageRepository');
    }
  }

  // ========== CONVERSION ENTITIES ==========

  CustomProductPageEntity _pageToEntity(CustomProductPage page) {
    return CustomProductPageEntity(
      id: page.id,
      storeId: page.storeId,
      name: page.name,
      sortOrder: page.sortOrder,
      isDefault: page.isDefault == 1,
      createdBy: page.createdBy,
      createdAt: DateTime.fromMillisecondsSinceEpoch(page.createdAt),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(page.updatedAt),
      synced: page.synced == 1,
    );
  }

  CustomPageItemEntity _pageItemToEntity(CustomPageItem item) {
    return CustomPageItemEntity(
      id: item.id,
      pageId: item.pageId,
      itemId: item.itemId,
      position: item.position,
      createdAt: DateTime.fromMillisecondsSinceEpoch(item.createdAt),
      synced: item.synced == 1,
    );
  }

  CustomPageCategoryGridEntity _categoryGridToEntity(
      CustomPageCategoryGrid grid) {
    return CustomPageCategoryGridEntity(
      id: grid.id,
      pageId: grid.pageId,
      categoryId: grid.categoryId,
      position: grid.position,
      createdAt: DateTime.fromMillisecondsSinceEpoch(grid.createdAt),
      synced: grid.synced == 1,
    );
  }
}

import 'package:drift/drift.dart';
import '../app_database.dart';

part 'category_dao.g.dart';

/// DAO pour la table categories
/// Gère toutes les opérations CRUD sur les catégories de produits
@DriftAccessor(include: {'../tables/categories.drift'})
class CategoryDao extends DatabaseAccessor<AppDatabase>
    with _$CategoryDaoMixin {
  CategoryDao(AppDatabase db) : super(db);

  /// Récupère toutes les catégories d'un magasin (triées par sort_order puis nom)
  Future<List<Category>> getCategoriesByStore(String storeId) =>
      getCategoriesByStoreQuery(storeId).get();

  /// Récupère une catégorie par ID
  Future<Category?> getCategoryById(String id) =>
      getCategoryByIdQuery(id).getSingleOrNull();

  /// Récupère toutes les catégories non synchronisées
  Future<List<Category>> getUnsyncedCategories() =>
      getUnsyncedCategoriesQuery().get();

  /// Insère une nouvelle catégorie
  Future<int> insertCategory(CategoriesCompanion category) =>
      into(categories).insert(category);

  /// Met à jour une catégorie existante et marque comme non synchronisée
  Future<bool> updateCategory(CategoriesCompanion category) async {
    return await (update(categories)
          ..where((tbl) => tbl.id.equals(category.id.value)))
        .write(category.copyWith(
      synced: const Value(false),
      updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
    ));
  }

  /// Suppression logique (soft delete) d'une catégorie
  Future<bool> deleteCategory(String id) async {
    return await (update(categories)..where((tbl) => tbl.id.equals(id))).write(
      CategoriesCompanion(
        deletedAt: Value(DateTime.now().millisecondsSinceEpoch),
        synced: const Value(false),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  /// Marque une catégorie comme synchronisée avec Supabase
  Future<bool> markCategorySynced(String id) async {
    return await (update(categories)..where((tbl) => tbl.id.equals(id))).write(
      const CategoriesCompanion(
        synced: Value(true),
      ),
    );
  }

  /// Compte le nombre de catégories dans un magasin
  Future<int> countCategoriesByStore(String storeId) async {
    final query = selectOnly(categories)
      ..addColumns([categories.id.count()])
      ..where(categories.storeId.equals(storeId))
      ..where(categories.deletedAt.isNull());
    final result = await query.getSingleOrNull();
    return result?.read(categories.id.count()) ?? 0;
  }

  /// Récupère le prochain ordre de tri pour une nouvelle catégorie
  Future<int> getNextSortOrder(String storeId) async {
    final query = selectOnly(categories)
      ..addColumns([categories.sortOrder.max()])
      ..where(categories.storeId.equals(storeId))
      ..where(categories.deletedAt.isNull());
    final result = await query.getSingleOrNull();
    final maxOrder = result?.read(categories.sortOrder.max()) ?? -1;
    return maxOrder + 1;
  }

  /// Réorganise l'ordre de tri des catégories
  Future<void> reorderCategories(String storeId, List<String> categoryIds) async {
    await transaction(() async {
      for (var i = 0; i < categoryIds.length; i++) {
        await (update(categories)..where((tbl) => tbl.id.equals(categoryIds[i])))
            .write(
          CategoriesCompanion(
            sortOrder: Value(i),
            synced: const Value(false),
            updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
          ),
        );
      }
    });
  }

  /// Recherche de catégories par nom
  Future<List<Category>> searchCategories(String storeId, String query) {
    return (select(categories)
          ..where((tbl) =>
              tbl.storeId.equals(storeId) &
              tbl.name.like('%$query%') &
              tbl.deletedAt.isNull())
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.name)]))
        .get();
  }

  /// Stream pour écouter les changements sur les catégories d'un magasin
  Stream<List<Category>> watchCategoriesByStore(String storeId) =>
      getCategoriesByStoreQuery(storeId).watch();

  /// Stream pour écouter les changements sur une catégorie spécifique
  Stream<Category?> watchCategoryById(String id) =>
      getCategoryByIdQuery(id).watchSingleOrNull();
}

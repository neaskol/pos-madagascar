import 'package:drift/drift.dart';
import '../../../../core/data/local/app_database.dart';

/// Repository pour la gestion des catégories de produits
/// Couche intermédiaire entre les DAOs Drift et les BLoCs
class CategoryRepository {
  final AppDatabase _database;

  CategoryRepository(this._database);

  // Getters pour accéder aux DAOs
  CategoryDao get _categoryDao => _database.categoryDao;

  /// Récupérer toutes les catégories d'un magasin (triées par sort_order)
  Stream<List<Category>> watchStoreCategories(String storeId) {
    return _categoryDao.getCategoriesByStore(storeId).watch();
  }

  /// Récupérer une catégorie par ID
  Future<Category?> getCategoryById(String categoryId) {
    return _categoryDao.getCategoryById(categoryId).getSingleOrNull();
  }

  /// Créer une nouvelle catégorie
  Future<void> createCategory({
    required String id,
    required String storeId,
    required String name,
    String? color,
    int sortOrder = 0,
  }) async {
    final companion = CategoriesCompanion(
      id: Value(id),
      storeId: Value(storeId),
      name: Value(name),
      color: Value(color),
      sortOrder: Value(sortOrder),
      updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      synced: const Value(0),
    );

    await _categoryDao.insertCategory(companion);
  }

  /// Mettre à jour une catégorie
  Future<void> updateCategory({
    required String id,
    String? name,
    String? color,
    int? sortOrder,
  }) async {
    final companion = CategoriesCompanion(
      id: Value(id),
      name: name != null ? Value(name) : const Value.absent(),
      color: color != null ? Value(color) : const Value.absent(),
      sortOrder: sortOrder != null ? Value(sortOrder) : const Value.absent(),
      updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      synced: const Value(0),
    );

    await _categoryDao.updateCategory(companion);
  }

  /// Supprimer une catégorie
  Future<void> deleteCategory(String categoryId) {
    return _categoryDao.deleteCategory(categoryId);
  }

  /// Réorganiser les catégories (mettre à jour sort_order)
  Future<void> reorderCategories(String storeId, List<String> categoryIds) async {
    for (int i = 0; i < categoryIds.length; i++) {
      await updateCategory(
        id: categoryIds[i],
        sortOrder: i,
      );
    }
  }

  /// Récupérer les catégories non synchronisées
  Future<List<Category>> getUnsyncedCategories() {
    return _categoryDao.getUnsyncedCategories().get();
  }

  /// Marquer une catégorie comme synchronisée
  Future<void> markCategoryAsSynced(String categoryId) {
    return _categoryDao.markCategorySynced(categoryId);
  }

  /// Compter le nombre de catégories d'un magasin
  Future<int> countStoreCategories(String storeId) {
    return _categoryDao.countCategoriesByStore(storeId);
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/category_repository.dart';
import 'category_event.dart';
import 'category_state.dart';

/// BLoC pour la gestion des catégories
/// Pattern : Repository → BLoC → UI
class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryRepository _repository;

  CategoryBloc(this._repository) : super(const CategoryInitial()) {
    on<LoadStoreCategoriesEvent>(_onLoadStoreCategories);
    on<LoadCategoryByIdEvent>(_onLoadCategoryById);
    on<CreateCategoryEvent>(_onCreateCategory);
    on<UpdateCategoryEvent>(_onUpdateCategory);
    on<DeleteCategoryEvent>(_onDeleteCategory);
    on<ReorderCategoriesEvent>(_onReorderCategories);
  }

  /// Charger toutes les catégories d'un magasin
  Future<void> _onLoadStoreCategories(
    LoadStoreCategoriesEvent event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      emit(const CategoryLoading());
      await emit.forEach(
        _repository.watchStoreCategories(event.storeId),
        onData: (categories) => CategoriesLoaded(categories),
        onError: (error, stackTrace) => CategoryError(error.toString()),
      );
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  /// Charger une catégorie par ID
  Future<void> _onLoadCategoryById(
    LoadCategoryByIdEvent event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      emit(const CategoryLoading());
      final category = await _repository.getCategoryById(event.categoryId);

      if (category != null) {
        emit(CategoryLoaded(category));
      } else {
        emit(const CategoryError('Catégorie introuvable'));
      }
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  /// Créer une nouvelle catégorie
  Future<void> _onCreateCategory(
    CreateCategoryEvent event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      emit(const CategoryLoading());
      await _repository.createCategory(
        id: event.id,
        storeId: event.storeId,
        name: event.name,
        color: event.color,
        sortOrder: event.sortOrder,
      );
      emit(const CategoryOperationSuccess('Catégorie créée avec succès'));
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  /// Mettre à jour une catégorie
  Future<void> _onUpdateCategory(
    UpdateCategoryEvent event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      emit(const CategoryLoading());
      await _repository.updateCategory(
        id: event.id,
        name: event.name,
        color: event.color,
        sortOrder: event.sortOrder,
      );
      emit(const CategoryOperationSuccess('Catégorie mise à jour avec succès'));
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  /// Supprimer une catégorie
  Future<void> _onDeleteCategory(
    DeleteCategoryEvent event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      emit(const CategoryLoading());
      await _repository.deleteCategory(event.categoryId);
      emit(const CategoryOperationSuccess('Catégorie supprimée avec succès'));
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  /// Réorganiser les catégories
  Future<void> _onReorderCategories(
    ReorderCategoriesEvent event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      emit(const CategoryLoading());
      await _repository.reorderCategories(event.storeId, event.categoryIds);
      emit(const CategoryOperationSuccess('Catégories réorganisées avec succès'));
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }
}

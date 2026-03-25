import 'package:equatable/equatable.dart';
import '../../../../core/data/local/app_database.dart';

/// States pour la gestion des catégories
abstract class CategoryState extends Equatable {
  const CategoryState();

  @override
  List<Object?> get props => [];
}

/// État initial
class CategoryInitial extends CategoryState {
  const CategoryInitial();
}

/// Chargement en cours
class CategoryLoading extends CategoryState {
  const CategoryLoading();
}

/// Liste des catégories chargée avec succès
class CategoriesLoaded extends CategoryState {
  final List<Category> categories;

  const CategoriesLoaded(this.categories);

  @override
  List<Object?> get props => [categories];
}

/// Catégorie unique chargée avec succès
class CategoryLoaded extends CategoryState {
  final Category category;

  const CategoryLoaded(this.category);

  @override
  List<Object?> get props => [category];
}

/// Opération réussie (création, mise à jour, suppression, réorganisation)
class CategoryOperationSuccess extends CategoryState {
  final String message;

  const CategoryOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

/// Erreur
class CategoryError extends CategoryState {
  final String message;

  const CategoryError(this.message);

  @override
  List<Object?> get props => [message];
}

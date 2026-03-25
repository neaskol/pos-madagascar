import 'package:equatable/equatable.dart';

/// Events pour la gestion des catégories
abstract class CategoryEvent extends Equatable {
  const CategoryEvent();

  @override
  List<Object?> get props => [];
}

/// Charger toutes les catégories d'un magasin
class LoadStoreCategoriesEvent extends CategoryEvent {
  final String storeId;

  const LoadStoreCategoriesEvent(this.storeId);

  @override
  List<Object?> get props => [storeId];
}

/// Charger une catégorie par ID
class LoadCategoryByIdEvent extends CategoryEvent {
  final String categoryId;

  const LoadCategoryByIdEvent(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}

/// Créer une nouvelle catégorie
class CreateCategoryEvent extends CategoryEvent {
  final String id;
  final String storeId;
  final String name;
  final String? color;
  final int sortOrder;

  const CreateCategoryEvent({
    required this.id,
    required this.storeId,
    required this.name,
    this.color,
    this.sortOrder = 0,
  });

  @override
  List<Object?> get props => [id, storeId, name, color, sortOrder];
}

/// Mettre à jour une catégorie
class UpdateCategoryEvent extends CategoryEvent {
  final String id;
  final String? name;
  final String? color;
  final int? sortOrder;

  const UpdateCategoryEvent({
    required this.id,
    this.name,
    this.color,
    this.sortOrder,
  });

  @override
  List<Object?> get props => [id, name, color, sortOrder];
}

/// Supprimer une catégorie
class DeleteCategoryEvent extends CategoryEvent {
  final String categoryId;

  const DeleteCategoryEvent(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}

/// Réorganiser les catégories
class ReorderCategoriesEvent extends CategoryEvent {
  final String storeId;
  final List<String> categoryIds;

  const ReorderCategoriesEvent(this.storeId, this.categoryIds);

  @override
  List<Object?> get props => [storeId, categoryIds];
}

import 'package:equatable/equatable.dart';

/// Événements pour le CustomPageBloc
abstract class CustomPageEvent extends Equatable {
  const CustomPageEvent();

  @override
  List<Object?> get props => [];
}

/// Charger les pages d'un magasin
class LoadStorePages extends CustomPageEvent {
  final String storeId;

  const LoadStorePages(this.storeId);

  @override
  List<Object?> get props => [storeId];
}

/// Sélectionner une page
class SelectPage extends CustomPageEvent {
  final String pageId;

  const SelectPage(this.pageId);

  @override
  List<Object?> get props => [pageId];
}

/// Créer une nouvelle page
class CreatePage extends CustomPageEvent {
  final String storeId;
  final String name;
  final int sortOrder;
  final String? createdBy;

  const CreatePage({
    required this.storeId,
    required this.name,
    required this.sortOrder,
    this.createdBy,
  });

  @override
  List<Object?> get props => [storeId, name, sortOrder, createdBy];
}

/// Mettre à jour une page
class UpdatePage extends CustomPageEvent {
  final String pageId;
  final String? name;
  final int? sortOrder;

  const UpdatePage({
    required this.pageId,
    this.name,
    this.sortOrder,
  });

  @override
  List<Object?> get props => [pageId, name, sortOrder];
}

/// Supprimer une page
class DeletePage extends CustomPageEvent {
  final String pageId;

  const DeletePage(this.pageId);

  @override
  List<Object?> get props => [pageId];
}

/// Ajouter un item à la page courante
class AddItemToCurrentPage extends CustomPageEvent {
  final String itemId;

  const AddItemToCurrentPage(this.itemId);

  @override
  List<Object?> get props => [itemId];
}

/// Supprimer un item de la page courante
class RemoveItemFromCurrentPage extends CustomPageEvent {
  final String itemId;

  const RemoveItemFromCurrentPage(this.itemId);

  @override
  List<Object?> get props => [itemId];
}

/// Réorganiser les items de la page courante
class ReorderCurrentPageItems extends CustomPageEvent {
  final List<String> itemIds;

  const ReorderCurrentPageItems(this.itemIds);

  @override
  List<Object?> get props => [itemIds];
}

/// Vider tous les items de la page courante
class ClearCurrentPageItems extends CustomPageEvent {
  const ClearCurrentPageItems();
}

/// Charger les items de la page courante
class LoadCurrentPageItems extends CustomPageEvent {
  const LoadCurrentPageItems();
}

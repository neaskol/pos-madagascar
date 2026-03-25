import 'package:equatable/equatable.dart';
import '../../../../core/data/local/app_database.dart';

/// States pour la gestion des items (produits)
abstract class ItemState extends Equatable {
  const ItemState();

  @override
  List<Object?> get props => [];
}

/// État initial
class ItemInitial extends ItemState {
  const ItemInitial();
}

/// Chargement en cours
class ItemLoading extends ItemState {
  const ItemLoading();
}

/// Liste des items chargée avec succès
class ItemsLoaded extends ItemState {
  final List<Item> items;

  const ItemsLoaded(this.items);

  @override
  List<Object?> get props => [items];
}

/// Item unique chargé avec succès
class ItemLoaded extends ItemState {
  final Item item;

  const ItemLoaded(this.item);

  @override
  List<Object?> get props => [item];
}

/// Opération réussie (création, mise à jour, suppression, stock)
class ItemOperationSuccess extends ItemState {
  final String message;

  const ItemOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

/// Erreur
class ItemError extends ItemState {
  final String message;

  const ItemError(this.message);

  @override
  List<Object?> get props => [message];
}

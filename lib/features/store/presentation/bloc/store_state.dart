import 'package:equatable/equatable.dart';
import '../../../../core/data/local/app_database.dart';

/// States pour la gestion des magasins
abstract class StoreState extends Equatable {
  const StoreState();

  @override
  List<Object?> get props => [];
}

/// État initial
class StoreInitial extends StoreState {
  const StoreInitial();
}

/// Chargement en cours
class StoreLoading extends StoreState {
  const StoreLoading();
}

/// Liste des magasins chargée avec succès
class StoresLoaded extends StoreState {
  final List<Store> stores;

  const StoresLoaded(this.stores);

  @override
  List<Object?> get props => [stores];
}

/// Magasin unique chargé avec succès
class StoreLoaded extends StoreState {
  final Store store;

  const StoreLoaded(this.store);

  @override
  List<Object?> get props => [store];
}

/// Opération réussie (création, mise à jour, suppression)
class StoreOperationSuccess extends StoreState {
  final String message;

  const StoreOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

/// Erreur
class StoreError extends StoreState {
  final String message;

  const StoreError(this.message);

  @override
  List<Object?> get props => [message];
}

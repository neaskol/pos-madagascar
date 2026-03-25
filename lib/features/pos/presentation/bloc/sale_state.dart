import 'package:equatable/equatable.dart';
import '../../domain/entities/sale.dart';

/// States pour la gestion des ventes
abstract class SaleState extends Equatable {
  const SaleState();

  @override
  List<Object?> get props => [];
}

/// État initial
class SaleInitial extends SaleState {
  const SaleInitial();
}

/// Création de vente en cours
class SaleCreating extends SaleState {
  const SaleCreating();
}

/// Vente créée avec succès
class SaleCreated extends SaleState {
  final Sale sale;

  const SaleCreated(this.sale);

  @override
  List<Object?> get props => [sale];
}

/// Chargement des ventes en cours
class SalesLoading extends SaleState {
  const SalesLoading();
}

/// Liste des ventes chargée
class SalesLoaded extends SaleState {
  final List<Sale> sales;

  const SalesLoaded(this.sales);

  @override
  List<Object?> get props => [sales];
}

/// Vente unique chargée
class SaleLoaded extends SaleState {
  final Sale sale;

  const SaleLoaded(this.sale);

  @override
  List<Object?> get props => [sale];
}

/// Erreur
class SaleError extends SaleState {
  final String message;

  const SaleError(this.message);

  @override
  List<Object?> get props => [message];
}

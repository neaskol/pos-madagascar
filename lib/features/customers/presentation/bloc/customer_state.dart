import 'package:equatable/equatable.dart';
import '../../../../core/data/local/app_database.dart';

/// States pour la gestion des clients
abstract class CustomerState extends Equatable {
  const CustomerState();

  @override
  List<Object?> get props => [];
}

/// État initial
class CustomerInitial extends CustomerState {
  const CustomerInitial();
}

/// Chargement en cours
class CustomerLoading extends CustomerState {
  const CustomerLoading();
}

/// Liste des clients chargée avec succès
class CustomersLoaded extends CustomerState {
  final List<Customer> customers;

  const CustomersLoaded(this.customers);

  @override
  List<Object?> get props => [customers];
}

/// Client unique chargé avec succès
class CustomerLoaded extends CustomerState {
  final Customer customer;

  const CustomerLoaded(this.customer);

  @override
  List<Object?> get props => [customer];
}

/// Opération réussie (création, mise à jour, suppression)
class CustomerOperationSuccess extends CustomerState {
  final String message;

  const CustomerOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

/// Erreur
class CustomerError extends CustomerState {
  final String message;

  const CustomerError(this.message);

  @override
  List<Object?> get props => [message];
}

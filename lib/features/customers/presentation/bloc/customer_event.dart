import 'package:equatable/equatable.dart';

/// Events pour la gestion des clients
abstract class CustomerEvent extends Equatable {
  const CustomerEvent();

  @override
  List<Object?> get props => [];
}

/// Charger tous les clients d'un magasin
class LoadCustomersEvent extends CustomerEvent {
  final String storeId;

  const LoadCustomersEvent(this.storeId);

  @override
  List<Object?> get props => [storeId];
}

/// Rechercher des clients
class SearchCustomersEvent extends CustomerEvent {
  final String storeId;
  final String query;

  const SearchCustomersEvent(this.storeId, this.query);

  @override
  List<Object?> get props => [storeId, query];
}

/// Charger un client par ID
class LoadCustomerByIdEvent extends CustomerEvent {
  final String customerId;

  const LoadCustomerByIdEvent(this.customerId);

  @override
  List<Object?> get props => [customerId];
}

/// Créer un nouveau client
class CreateCustomerEvent extends CustomerEvent {
  final String storeId;
  final String name;
  final String? phone;
  final String? email;
  final String? loyaltyCardBarcode;
  final String? notes;
  final String? createdBy;

  const CreateCustomerEvent({
    required this.storeId,
    required this.name,
    this.phone,
    this.email,
    this.loyaltyCardBarcode,
    this.notes,
    this.createdBy,
  });

  @override
  List<Object?> get props => [
        storeId,
        name,
        phone,
        email,
        loyaltyCardBarcode,
        notes,
        createdBy,
      ];
}

/// Mettre à jour un client
class UpdateCustomerEvent extends CustomerEvent {
  final String id;
  final String? name;
  final String? phone;
  final String? email;
  final String? loyaltyCardBarcode;
  final String? notes;

  const UpdateCustomerEvent({
    required this.id,
    this.name,
    this.phone,
    this.email,
    this.loyaltyCardBarcode,
    this.notes,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        phone,
        email,
        loyaltyCardBarcode,
        notes,
      ];
}

/// Supprimer un client
class DeleteCustomerEvent extends CustomerEvent {
  final String customerId;

  const DeleteCustomerEvent(this.customerId);

  @override
  List<Object?> get props => [customerId];
}

/// Charger les clients avec crédit en cours
class LoadCustomersWithCreditEvent extends CustomerEvent {
  final String storeId;

  const LoadCustomersWithCreditEvent(this.storeId);

  @override
  List<Object?> get props => [storeId];
}

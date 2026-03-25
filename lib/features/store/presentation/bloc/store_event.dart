import 'package:equatable/equatable.dart';

/// Events pour la gestion des magasins
abstract class StoreEvent extends Equatable {
  const StoreEvent();

  @override
  List<Object?> get props => [];
}

/// Charger tous les magasins
class LoadStoresEvent extends StoreEvent {
  const LoadStoresEvent();
}

/// Charger un magasin par ID
class LoadStoreByIdEvent extends StoreEvent {
  final String storeId;

  const LoadStoreByIdEvent(this.storeId);

  @override
  List<Object?> get props => [storeId];
}

/// Créer un nouveau magasin
class CreateStoreEvent extends StoreEvent {
  final String id;
  final String name;
  final String? address;
  final String? phone;
  final String? logoUrl;
  final String? currency;
  final String? timezone;

  const CreateStoreEvent({
    required this.id,
    required this.name,
    this.address,
    this.phone,
    this.logoUrl,
    this.currency,
    this.timezone,
  });

  @override
  List<Object?> get props => [id, name, address, phone, logoUrl, currency, timezone];
}

/// Mettre à jour un magasin
class UpdateStoreEvent extends StoreEvent {
  final String id;
  final String? name;
  final String? address;
  final String? phone;
  final String? logoUrl;
  final String? currency;
  final String? timezone;

  const UpdateStoreEvent({
    required this.id,
    this.name,
    this.address,
    this.phone,
    this.logoUrl,
    this.currency,
    this.timezone,
  });

  @override
  List<Object?> get props => [id, name, address, phone, logoUrl, currency, timezone];
}

/// Supprimer un magasin
class DeleteStoreEvent extends StoreEvent {
  final String storeId;

  const DeleteStoreEvent(this.storeId);

  @override
  List<Object?> get props => [storeId];
}

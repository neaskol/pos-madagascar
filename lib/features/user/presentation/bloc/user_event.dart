import 'package:equatable/equatable.dart';

/// Events pour la gestion des utilisateurs
abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
}

/// Charger tous les utilisateurs d'un magasin
class LoadStoreUsersEvent extends UserEvent {
  final String storeId;

  const LoadStoreUsersEvent(this.storeId);

  @override
  List<Object?> get props => [storeId];
}

/// Charger un utilisateur par ID
class LoadUserByIdEvent extends UserEvent {
  final String userId;

  const LoadUserByIdEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Charger un utilisateur par email
class LoadUserByEmailEvent extends UserEvent {
  final String email;

  const LoadUserByEmailEvent(this.email);

  @override
  List<Object?> get props => [email];
}

/// Charger les utilisateurs actifs d'un magasin
class LoadActiveUsersEvent extends UserEvent {
  final String storeId;

  const LoadActiveUsersEvent(this.storeId);

  @override
  List<Object?> get props => [storeId];
}

/// Charger les utilisateurs par rôle
class LoadUsersByRoleEvent extends UserEvent {
  final String storeId;
  final String role;

  const LoadUsersByRoleEvent(this.storeId, this.role);

  @override
  List<Object?> get props => [storeId, role];
}

/// Créer un nouvel utilisateur
class CreateUserEvent extends UserEvent {
  final String id;
  final String storeId;
  final String name;
  final String email;
  final String? phone;
  final String role;
  final String? pinHash;
  final bool emailVerified;
  final bool active;

  const CreateUserEvent({
    required this.id,
    required this.storeId,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    this.pinHash,
    this.emailVerified = false,
    this.active = true,
  });

  @override
  List<Object?> get props => [id, storeId, name, email, phone, role, pinHash, emailVerified, active];
}

/// Mettre à jour un utilisateur
class UpdateUserEvent extends UserEvent {
  final String id;
  final String? name;
  final String? email;
  final String? phone;
  final String? role;
  final String? pinHash;
  final bool? emailVerified;
  final bool? active;

  const UpdateUserEvent({
    required this.id,
    this.name,
    this.email,
    this.phone,
    this.role,
    this.pinHash,
    this.emailVerified,
    this.active,
  });

  @override
  List<Object?> get props => [id, name, email, phone, role, pinHash, emailVerified, active];
}

/// Supprimer un utilisateur
class DeleteUserEvent extends UserEvent {
  final String userId;

  const DeleteUserEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Vérifier le PIN d'un utilisateur
class VerifyUserPinEvent extends UserEvent {
  final String userId;
  final String pinHash;

  const VerifyUserPinEvent(this.userId, this.pinHash);

  @override
  List<Object?> get props => [userId, pinHash];
}

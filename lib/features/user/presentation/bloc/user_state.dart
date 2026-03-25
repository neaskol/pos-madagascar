import 'package:equatable/equatable.dart';
import '../../../../core/data/local/app_database.dart';

/// States pour la gestion des utilisateurs
abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object?> get props => [];
}

/// État initial
class UserInitial extends UserState {
  const UserInitial();
}

/// Chargement en cours
class UserLoading extends UserState {
  const UserLoading();
}

/// Liste des utilisateurs chargée avec succès
class UsersLoaded extends UserState {
  final List<User> users;

  const UsersLoaded(this.users);

  @override
  List<Object?> get props => [users];
}

/// Utilisateur unique chargé avec succès
class UserLoaded extends UserState {
  final User user;

  const UserLoaded(this.user);

  @override
  List<Object?> get props => [user];
}

/// Vérification du PIN réussie
class UserPinVerified extends UserState {
  final bool isValid;

  const UserPinVerified(this.isValid);

  @override
  List<Object?> get props => [isValid];
}

/// Opération réussie (création, mise à jour, suppression)
class UserOperationSuccess extends UserState {
  final String message;

  const UserOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

/// Erreur
class UserError extends UserState {
  final String message;

  const UserError(this.message);

  @override
  List<Object?> get props => [message];
}

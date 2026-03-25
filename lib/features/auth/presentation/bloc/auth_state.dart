import 'package:equatable/equatable.dart';
import '../../../../core/data/local/app_database.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// État initial
class AuthInitial extends AuthState {}

/// Chargement en cours
class AuthLoading extends AuthState {}

/// Non authentifié
class AuthUnauthenticated extends AuthState {}

/// Authentifié mais pas de magasin (setup wizard requis)
class AuthAuthenticatedNoStore extends AuthState {
  final String userId;

  const AuthAuthenticatedNoStore({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Authentifié avec magasin (redirection vers PIN ou app)
class AuthAuthenticatedWithStore extends AuthState {
  final User user;
  final String storeId;

  const AuthAuthenticatedWithStore({
    required this.user,
    required this.storeId,
  });

  @override
  List<Object?> get props => [user, storeId];
}

/// Employés du magasin chargés (pour écran PIN)
class AuthStoreEmployeesLoaded extends AuthState {
  final List<User> employees;
  final String storeId;

  const AuthStoreEmployeesLoaded({
    required this.employees,
    required this.storeId,
  });

  @override
  List<Object?> get props => [employees, storeId];
}

/// Session PIN active (utilisateur sélectionné via PIN)
class AuthPinSessionActive extends AuthState {
  final User user;

  const AuthPinSessionActive({required this.user});

  @override
  List<Object?> get props => [user];
}

/// Erreur d'authentification
class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Mot de passe réinitialisé (email envoyé)
class AuthPasswordResetSent extends AuthState {
  final String email;

  const AuthPasswordResetSent({required this.email});

  @override
  List<Object?> get props => [email];
}

/// Magasin créé avec succès
class AuthStoreCreated extends AuthState {
  final String storeId;

  const AuthStoreCreated({required this.storeId});

  @override
  List<Object?> get props => [storeId];
}

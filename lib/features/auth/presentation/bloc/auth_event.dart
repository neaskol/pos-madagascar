import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Vérifier l'état d'authentification au démarrage
class AuthCheckRequested extends AuthEvent {}

/// Connexion avec email et mot de passe
class AuthEmailSignInRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthEmailSignInRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

/// Inscription avec email et mot de passe
class AuthEmailSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;
  final String? phone;

  const AuthEmailSignUpRequested({
    required this.email,
    required this.password,
    required this.name,
    this.phone,
  });

  @override
  List<Object?> get props => [email, password, name, phone];
}

/// Connexion avec PIN
class AuthPinSignInRequested extends AuthEvent {
  final String userId;
  final String pin;

  const AuthPinSignInRequested({
    required this.userId,
    required this.pin,
  });

  @override
  List<Object?> get props => [userId, pin];
}

/// Déconnexion
class AuthSignOutRequested extends AuthEvent {}

/// Réinitialisation du mot de passe
class AuthPasswordResetRequested extends AuthEvent {
  final String email;

  const AuthPasswordResetRequested({required this.email});

  @override
  List<Object?> get props => [email];
}

/// Création du magasin initial (setup wizard)
class AuthStoreCreationRequested extends AuthEvent {
  final String name;
  final String? address;
  final String? phone;
  final String? logoUrl;
  final String currency;
  final String timezone;
  final int cashRoundingUnit;
  final String receiptLanguage;
  final String interfaceLanguage;

  const AuthStoreCreationRequested({
    required this.name,
    this.address,
    this.phone,
    this.logoUrl,
    this.currency = 'MGA',
    this.timezone = 'Indian/Antananarivo',
    this.cashRoundingUnit = 0,
    this.receiptLanguage = 'fr',
    this.interfaceLanguage = 'fr',
  });

  @override
  List<Object?> get props => [
        name,
        address,
        phone,
        logoUrl,
        currency,
        timezone,
        cashRoundingUnit,
        receiptLanguage,
        interfaceLanguage,
      ];
}

/// Configuration initiale du PIN (après setup wizard)
class AuthPinSetupRequested extends AuthEvent {
  final String userId;
  final String pin;

  const AuthPinSetupRequested({
    required this.userId,
    required this.pin,
  });

  @override
  List<Object?> get props => [userId, pin];
}

/// Charger les employés du magasin (pour écran PIN)
class AuthLoadStoreEmployeesRequested extends AuthEvent {
  final String storeId;

  const AuthLoadStoreEmployeesRequested({required this.storeId});

  @override
  List<Object?> get props => [storeId];
}

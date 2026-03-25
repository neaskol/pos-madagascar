import 'package:equatable/equatable.dart';
import '../../../../core/data/local/app_database.dart';

/// States pour la gestion des crédits clients
abstract class CreditState extends Equatable {
  const CreditState();

  @override
  List<Object?> get props => [];
}

/// État initial
class CreditInitial extends CreditState {
  const CreditInitial();
}

/// Chargement en cours
class CreditLoading extends CreditState {
  const CreditLoading();
}

/// Liste des crédits chargée avec succès
class CreditsLoaded extends CreditState {
  final List<Credit> credits;

  const CreditsLoaded(this.credits);

  @override
  List<Object?> get props => [credits];
}

/// Crédit unique chargé avec succès
class CreditLoaded extends CreditState {
  final Credit credit;

  const CreditLoaded(this.credit);

  @override
  List<Object?> get props => [credit];
}

/// Liste des paiements de crédit chargée avec succès
class CreditPaymentsLoaded extends CreditState {
  final List<CreditPayment> payments;

  const CreditPaymentsLoaded(this.payments);

  @override
  List<Object?> get props => [payments];
}

/// Résumé des crédits chargé avec succès
class CreditSummaryLoaded extends CreditState {
  final Map<String, dynamic> summary;

  const CreditSummaryLoaded(this.summary);

  @override
  List<Object?> get props => [summary];
}

/// Opération réussie (création, paiement)
class CreditOperationSuccess extends CreditState {
  final String message;

  const CreditOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

/// Erreur
class CreditError extends CreditState {
  final String message;

  const CreditError(this.message);

  @override
  List<Object?> get props => [message];
}

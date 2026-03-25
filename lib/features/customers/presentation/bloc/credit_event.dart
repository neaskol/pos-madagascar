import 'package:equatable/equatable.dart';

/// Events pour la gestion des crédits clients
abstract class CreditEvent extends Equatable {
  const CreditEvent();

  @override
  List<Object?> get props => [];
}

/// Charger tous les crédits d'un magasin
class LoadCreditsEvent extends CreditEvent {
  final String storeId;

  const LoadCreditsEvent(this.storeId);

  @override
  List<Object?> get props => [storeId];
}

/// Charger les crédits d'un client
class LoadCreditsByCustomerEvent extends CreditEvent {
  final String customerId;

  const LoadCreditsByCustomerEvent(this.customerId);

  @override
  List<Object?> get props => [customerId];
}

/// Charger un crédit par ID
class LoadCreditByIdEvent extends CreditEvent {
  final String creditId;

  const LoadCreditByIdEvent(this.creditId);

  @override
  List<Object?> get props => [creditId];
}

/// Charger les crédits en retard
class LoadOverdueCreditsEvent extends CreditEvent {
  final String storeId;

  const LoadOverdueCreditsEvent(this.storeId);

  @override
  List<Object?> get props => [storeId];
}

/// Charger les crédits par statut
class LoadCreditsByStatusEvent extends CreditEvent {
  final String storeId;
  final String status;

  const LoadCreditsByStatusEvent(this.storeId, this.status);

  @override
  List<Object?> get props => [storeId, status];
}

/// Créer un nouveau crédit
class CreateCreditEvent extends CreditEvent {
  final String storeId;
  final String customerId;
  final String? saleId;
  final int amountTotal;
  final DateTime? dueDate;
  final String? notes;
  final String? createdBy;

  const CreateCreditEvent({
    required this.storeId,
    required this.customerId,
    this.saleId,
    required this.amountTotal,
    this.dueDate,
    this.notes,
    this.createdBy,
  });

  @override
  List<Object?> get props => [
        storeId,
        customerId,
        saleId,
        amountTotal,
        dueDate,
        notes,
        createdBy,
      ];
}

/// Enregistrer un paiement de crédit
class RecordCreditPaymentEvent extends CreditEvent {
  final String creditId;
  final int amount;
  final String paymentType;
  final String? paymentReference;
  final String? notes;
  final String? createdBy;

  const RecordCreditPaymentEvent({
    required this.creditId,
    required this.amount,
    required this.paymentType,
    this.paymentReference,
    this.notes,
    this.createdBy,
  });

  @override
  List<Object?> get props => [
        creditId,
        amount,
        paymentType,
        paymentReference,
        notes,
        createdBy,
      ];
}

/// Charger les paiements d'un crédit
class LoadCreditPaymentsEvent extends CreditEvent {
  final String creditId;

  const LoadCreditPaymentsEvent(this.creditId);

  @override
  List<Object?> get props => [creditId];
}

/// Charger le résumé des crédits d'un client
class LoadCreditSummaryEvent extends CreditEvent {
  final String customerId;

  const LoadCreditSummaryEvent(this.customerId);

  @override
  List<Object?> get props => [customerId];
}

/// Charger le résumé des crédits du magasin
class LoadStoreCreditSummaryEvent extends CreditEvent {
  final String storeId;

  const LoadStoreCreditSummaryEvent(this.storeId);

  @override
  List<Object?> get props => [storeId];
}

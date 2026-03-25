import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/credit_repository.dart';
import 'credit_event.dart';
import 'credit_state.dart';

/// BLoC pour la gestion des crédits clients
/// Pattern : Repository → BLoC → UI
class CreditBloc extends Bloc<CreditEvent, CreditState> {
  final CreditRepository _repository;

  CreditBloc(this._repository) : super(const CreditInitial()) {
    on<LoadCreditsEvent>(_onLoadCredits);
    on<LoadCreditsByCustomerEvent>(_onLoadCreditsByCustomer);
    on<LoadCreditByIdEvent>(_onLoadCreditById);
    on<LoadOverdueCreditsEvent>(_onLoadOverdueCredits);
    on<LoadCreditsByStatusEvent>(_onLoadCreditsByStatus);
    on<CreateCreditEvent>(_onCreateCredit);
    on<RecordCreditPaymentEvent>(_onRecordCreditPayment);
    on<LoadCreditPaymentsEvent>(_onLoadCreditPayments);
    on<LoadCreditSummaryEvent>(_onLoadCreditSummary);
    on<LoadStoreCreditSummaryEvent>(_onLoadStoreCreditSummary);
  }

  /// Charger tous les crédits d'un magasin
  Future<void> _onLoadCredits(
    LoadCreditsEvent event,
    Emitter<CreditState> emit,
  ) async {
    try {
      emit(const CreditLoading());
      final credits = await _repository.getCredits(event.storeId);
      emit(CreditsLoaded(credits));
    } catch (e) {
      emit(CreditError(e.toString()));
    }
  }

  /// Charger les crédits d'un client
  Future<void> _onLoadCreditsByCustomer(
    LoadCreditsByCustomerEvent event,
    Emitter<CreditState> emit,
  ) async {
    try {
      emit(const CreditLoading());
      final credits = await _repository.getCreditsByCustomer(event.customerId);
      emit(CreditsLoaded(credits));
    } catch (e) {
      emit(CreditError(e.toString()));
    }
  }

  /// Charger un crédit par ID
  Future<void> _onLoadCreditById(
    LoadCreditByIdEvent event,
    Emitter<CreditState> emit,
  ) async {
    try {
      emit(const CreditLoading());
      final credit = await _repository.getCreditById(event.creditId);

      if (credit != null) {
        emit(CreditLoaded(credit));
      } else {
        emit(const CreditError('Crédit introuvable'));
      }
    } catch (e) {
      emit(CreditError(e.toString()));
    }
  }

  /// Charger les crédits en retard
  Future<void> _onLoadOverdueCredits(
    LoadOverdueCreditsEvent event,
    Emitter<CreditState> emit,
  ) async {
    try {
      emit(const CreditLoading());
      final credits = await _repository.getOverdueCredits(event.storeId);
      emit(CreditsLoaded(credits));
    } catch (e) {
      emit(CreditError(e.toString()));
    }
  }

  /// Charger les crédits par statut
  Future<void> _onLoadCreditsByStatus(
    LoadCreditsByStatusEvent event,
    Emitter<CreditState> emit,
  ) async {
    try {
      emit(const CreditLoading());
      final credits = await _repository.getCreditsByStatus(
        event.storeId,
        event.status,
      );
      emit(CreditsLoaded(credits));
    } catch (e) {
      emit(CreditError(e.toString()));
    }
  }

  /// Créer un nouveau crédit
  Future<void> _onCreateCredit(
    CreateCreditEvent event,
    Emitter<CreditState> emit,
  ) async {
    try {
      emit(const CreditLoading());
      await _repository.createCredit(
        storeId: event.storeId,
        customerId: event.customerId,
        saleId: event.saleId,
        amountTotal: event.amountTotal,
        dueDate: event.dueDate,
        notes: event.notes,
        createdBy: event.createdBy,
      );
      emit(const CreditOperationSuccess('Crédit enregistré'));
    } catch (e) {
      emit(CreditError(e.toString()));
    }
  }

  /// Enregistrer un paiement de crédit
  Future<void> _onRecordCreditPayment(
    RecordCreditPaymentEvent event,
    Emitter<CreditState> emit,
  ) async {
    try {
      emit(const CreditLoading());
      await _repository.recordCreditPayment(
        creditId: event.creditId,
        amount: event.amount,
        paymentType: event.paymentType,
        paymentReference: event.paymentReference,
        notes: event.notes,
        createdBy: event.createdBy,
      );
      emit(const CreditOperationSuccess('Paiement enregistré'));
    } catch (e) {
      emit(CreditError(e.toString()));
    }
  }

  /// Charger les paiements d'un crédit
  Future<void> _onLoadCreditPayments(
    LoadCreditPaymentsEvent event,
    Emitter<CreditState> emit,
  ) async {
    try {
      emit(const CreditLoading());
      final payments = await _repository.getCreditPayments(event.creditId);
      emit(CreditPaymentsLoaded(payments));
    } catch (e) {
      emit(CreditError(e.toString()));
    }
  }

  /// Charger le résumé des crédits d'un client
  Future<void> _onLoadCreditSummary(
    LoadCreditSummaryEvent event,
    Emitter<CreditState> emit,
  ) async {
    try {
      emit(const CreditLoading());
      final summary = await _repository.getCreditSummary(event.customerId);
      emit(CreditSummaryLoaded(summary));
    } catch (e) {
      emit(CreditError(e.toString()));
    }
  }

  /// Charger le résumé des crédits du magasin
  Future<void> _onLoadStoreCreditSummary(
    LoadStoreCreditSummaryEvent event,
    Emitter<CreditState> emit,
  ) async {
    try {
      emit(const CreditLoading());
      final summary = await _repository.getStoreCreditSummary(event.storeId);
      emit(CreditSummaryLoaded(summary));
    } catch (e) {
      emit(CreditError(e.toString()));
    }
  }
}

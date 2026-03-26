import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/customer_repository.dart';
import '../../../../core/data/remote/sync_service.dart';
import 'customer_event.dart';
import 'customer_state.dart';
import 'dart:developer' as developer;

/// BLoC pour la gestion des clients
/// Pattern : Repository → BLoC → UI
class CustomerBloc extends Bloc<CustomerEvent, CustomerState> {
  final CustomerRepository _repository;
  final SyncService? _syncService;

  CustomerBloc(this._repository, [this._syncService]) : super(const CustomerInitial()) {
    on<LoadCustomersEvent>(_onLoadCustomers);
    on<SearchCustomersEvent>(_onSearchCustomers);
    on<LoadCustomerByIdEvent>(_onLoadCustomerById);
    on<CreateCustomerEvent>(_onCreateCustomer);
    on<UpdateCustomerEvent>(_onUpdateCustomer);
    on<DeleteCustomerEvent>(_onDeleteCustomer);
    on<LoadCustomersWithCreditEvent>(_onLoadCustomersWithCredit);
  }

  /// Charger tous les clients d'un magasin
  Future<void> _onLoadCustomers(
    LoadCustomersEvent event,
    Emitter<CustomerState> emit,
  ) async {
    try {
      // Ne pas émettre loading si on a déjà des clients chargés
      if (state is! CustomersLoaded) {
        emit(const CustomerLoading());
      }
      final customers = await _repository.getCustomers(event.storeId);
      emit(CustomersLoaded(customers));
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }

  /// Rechercher des clients
  Future<void> _onSearchCustomers(
    SearchCustomersEvent event,
    Emitter<CustomerState> emit,
  ) async {
    try {
      // Ne pas émettre loading si on a déjà des clients chargés
      if (state is! CustomersLoaded) {
        emit(const CustomerLoading());
      }
      final customers = await _repository.searchCustomers(event.storeId, event.query);
      emit(CustomersLoaded(customers));
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }

  /// Charger un client par ID
  Future<void> _onLoadCustomerById(
    LoadCustomerByIdEvent event,
    Emitter<CustomerState> emit,
  ) async {
    try {
      emit(const CustomerLoading());
      final customer = await _repository.getCustomerById(event.customerId);

      if (customer != null) {
        emit(CustomerLoaded(customer));
      } else {
        emit(const CustomerError('Client introuvable'));
      }
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }

  /// Créer un nouveau client
  Future<void> _onCreateCustomer(
    CreateCustomerEvent event,
    Emitter<CustomerState> emit,
  ) async {
    try {
      emit(const CustomerLoading());
      await _repository.createCustomer(
        storeId: event.storeId,
        name: event.name,
        phone: event.phone,
        email: event.email,
        loyaltyCardBarcode: event.loyaltyCardBarcode,
        notes: event.notes,
        createdBy: event.createdBy,
      );
      emit(const CustomerOperationSuccess('Client créé avec succès'));

      // Synchroniser immédiatement avec Supabase
      _triggerImmediateSync();
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }

  /// Mettre à jour un client
  Future<void> _onUpdateCustomer(
    UpdateCustomerEvent event,
    Emitter<CustomerState> emit,
  ) async {
    try {
      emit(const CustomerLoading());
      await _repository.updateCustomer(
        id: event.id,
        name: event.name,
        phone: event.phone,
        email: event.email,
        loyaltyCardBarcode: event.loyaltyCardBarcode,
        notes: event.notes,
      );
      emit(const CustomerOperationSuccess('Client mis à jour'));

      // Synchroniser immédiatement avec Supabase
      _triggerImmediateSync();
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }

  /// Supprimer un client
  Future<void> _onDeleteCustomer(
    DeleteCustomerEvent event,
    Emitter<CustomerState> emit,
  ) async {
    try {
      emit(const CustomerLoading());
      await _repository.deleteCustomer(event.customerId);
      emit(const CustomerOperationSuccess('Client supprimé'));

      // Synchroniser immédiatement avec Supabase
      _triggerImmediateSync();
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }

  /// Charger les clients avec crédit en cours
  Future<void> _onLoadCustomersWithCredit(
    LoadCustomersWithCreditEvent event,
    Emitter<CustomerState> emit,
  ) async {
    try {
      // Ne pas émettre loading si on a déjà des clients chargés
      if (state is! CustomersLoaded) {
        emit(const CustomerLoading());
      }
      final customers = await _repository.getCustomersWithCredit(event.storeId);
      emit(CustomersLoaded(customers));
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }

  /// Déclenche une synchronisation immédiate en arrière-plan
  void _triggerImmediateSync() {
    if (_syncService != null) {
      _syncService.forceSyncNow().then((result) {
        if (result.isSuccess) {
          developer.log(
            'Immediate sync completed: ${result.summary}',
            name: 'CustomerBloc',
          );
        } else if (result.hasErrors) {
          developer.log(
            'Immediate sync had errors: ${result.errors.join(", ")}',
            name: 'CustomerBloc',
          );
        }
      }).catchError((e) {
        developer.log(
          'Immediate sync failed',
          name: 'CustomerBloc',
          error: e,
        );
      });
    }
  }
}

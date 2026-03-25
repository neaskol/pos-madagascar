import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/store_settings_repository.dart';
import 'store_settings_event.dart';
import 'store_settings_state.dart';

/// BLoC pour la gestion des réglages du magasin
/// Pattern : Repository → BLoC → UI
class StoreSettingsBloc extends Bloc<StoreSettingsEvent, StoreSettingsState> {
  final StoreSettingsRepository _repository;

  StoreSettingsBloc(this._repository) : super(const StoreSettingsInitial()) {
    on<LoadStoreSettingsEvent>(_onLoadStoreSettings);
    on<CreateDefaultSettingsEvent>(_onCreateDefaultSettings);
    on<UpdateStoreSettingsEvent>(_onUpdateStoreSettings);
    on<ToggleShiftsEvent>(_onToggleShifts);
    on<ToggleOpenTicketsEvent>(_onToggleOpenTickets);
    on<ToggleLowStockNotificationsEvent>(_onToggleLowStockNotifications);
    on<UpdateCashRoundingUnitEvent>(_onUpdateCashRoundingUnit);
    on<UpdateReceiptFooterEvent>(_onUpdateReceiptFooter);
    on<UpdateMVolaMerchantNumberEvent>(_onUpdateMVolaMerchantNumber);
    on<UpdateOrangeMoneyMerchantNumberEvent>(_onUpdateOrangeMoneyMerchantNumber);
    on<ToggleMobileMoneyEvent>(_onToggleMobileMoney);
  }

  /// Charger les réglages d'un magasin
  Future<void> _onLoadStoreSettings(
    LoadStoreSettingsEvent event,
    Emitter<StoreSettingsState> emit,
  ) async {
    try {
      emit(const StoreSettingsLoading());
      await emit.forEach(
        _repository.watchStoreSettings(event.storeId),
        onData: (settings) {
          if (settings != null) {
            return StoreSettingsLoaded(settings);
          } else {
            return const StoreSettingsNotFound();
          }
        },
        onError: (error, stackTrace) => StoreSettingsError(error.toString()),
      );
    } catch (e) {
      emit(StoreSettingsError(e.toString()));
    }
  }

  /// Créer les réglages par défaut
  Future<void> _onCreateDefaultSettings(
    CreateDefaultSettingsEvent event,
    Emitter<StoreSettingsState> emit,
  ) async {
    try {
      emit(const StoreSettingsLoading());
      await _repository.createDefaultSettings(event.storeId);
      emit(const StoreSettingsOperationSuccess('Réglages créés avec succès'));
    } catch (e) {
      emit(StoreSettingsError(e.toString()));
    }
  }

  /// Mettre à jour les réglages
  Future<void> _onUpdateStoreSettings(
    UpdateStoreSettingsEvent event,
    Emitter<StoreSettingsState> emit,
  ) async {
    try {
      emit(const StoreSettingsLoading());
      await _repository.updateSettings(
        storeId: event.storeId,
        shiftsEnabled: event.shiftsEnabled,
        timeClockEnabled: event.timeClockEnabled,
        openTicketsEnabled: event.openTicketsEnabled,
        predefinedTicketsEnabled: event.predefinedTicketsEnabled,
        kitchenPrintersEnabled: event.kitchenPrintersEnabled,
        customerDisplayEnabled: event.customerDisplayEnabled,
        diningOptionsEnabled: event.diningOptionsEnabled,
        lowStockNotifications: event.lowStockNotifications,
        negativeStockAlerts: event.negativeStockAlerts,
        weightBarcodesEnabled: event.weightBarcodesEnabled,
        cashRoundingUnit: event.cashRoundingUnit,
        receiptFooter: event.receiptFooter,
      );
      emit(const StoreSettingsOperationSuccess('Réglages mis à jour avec succès'));
    } catch (e) {
      emit(StoreSettingsError(e.toString()));
    }
  }

  /// Toggle shifts
  Future<void> _onToggleShifts(
    ToggleShiftsEvent event,
    Emitter<StoreSettingsState> emit,
  ) async {
    try {
      emit(const StoreSettingsLoading());
      await _repository.toggleShifts(event.storeId, event.enabled);
      emit(const StoreSettingsOperationSuccess('Shifts mis à jour'));
    } catch (e) {
      emit(StoreSettingsError(e.toString()));
    }
  }

  /// Toggle open tickets
  Future<void> _onToggleOpenTickets(
    ToggleOpenTicketsEvent event,
    Emitter<StoreSettingsState> emit,
  ) async {
    try {
      emit(const StoreSettingsLoading());
      await _repository.toggleOpenTickets(event.storeId, event.enabled);
      emit(const StoreSettingsOperationSuccess('Tickets ouverts mis à jour'));
    } catch (e) {
      emit(StoreSettingsError(e.toString()));
    }
  }

  /// Toggle low stock notifications
  Future<void> _onToggleLowStockNotifications(
    ToggleLowStockNotificationsEvent event,
    Emitter<StoreSettingsState> emit,
  ) async {
    try {
      emit(const StoreSettingsLoading());
      await _repository.toggleLowStockNotifications(event.storeId, event.enabled);
      emit(const StoreSettingsOperationSuccess('Notifications de stock bas mises à jour'));
    } catch (e) {
      emit(StoreSettingsError(e.toString()));
    }
  }

  /// Mettre à jour l'unité d'arrondi caisse
  Future<void> _onUpdateCashRoundingUnit(
    UpdateCashRoundingUnitEvent event,
    Emitter<StoreSettingsState> emit,
  ) async {
    try {
      emit(const StoreSettingsLoading());
      await _repository.updateCashRoundingUnit(event.storeId, event.unit);
      emit(const StoreSettingsOperationSuccess('Arrondi caisse mis à jour'));
    } catch (e) {
      emit(StoreSettingsError(e.toString()));
    }
  }

  /// Mettre à jour le footer des reçus
  Future<void> _onUpdateReceiptFooter(
    UpdateReceiptFooterEvent event,
    Emitter<StoreSettingsState> emit,
  ) async {
    try {
      emit(const StoreSettingsLoading());
      await _repository.updateReceiptFooter(event.storeId, event.footer);
      emit(const StoreSettingsOperationSuccess('Footer des reçus mis à jour'));
    } catch (e) {
      emit(StoreSettingsError(e.toString()));
    }
  }

  /// Mettre à jour le numéro marchand MVola (Phase 3.8)
  Future<void> _onUpdateMVolaMerchantNumber(
    UpdateMVolaMerchantNumberEvent event,
    Emitter<StoreSettingsState> emit,
  ) async {
    try {
      emit(const StoreSettingsLoading());
      await _repository.updateMVolaMerchantNumber(event.storeId, event.merchantNumber);
      emit(const StoreSettingsOperationSuccess('Numéro marchand MVola mis à jour'));
    } catch (e) {
      emit(StoreSettingsError(e.toString()));
    }
  }

  /// Mettre à jour le numéro marchand Orange Money (Phase 3.8)
  Future<void> _onUpdateOrangeMoneyMerchantNumber(
    UpdateOrangeMoneyMerchantNumberEvent event,
    Emitter<StoreSettingsState> emit,
  ) async {
    try {
      emit(const StoreSettingsLoading());
      await _repository.updateOrangeMoneyMerchantNumber(event.storeId, event.merchantNumber);
      emit(const StoreSettingsOperationSuccess('Numéro marchand Orange Money mis à jour'));
    } catch (e) {
      emit(StoreSettingsError(e.toString()));
    }
  }

  /// Toggle mobile money (Phase 3.8)
  Future<void> _onToggleMobileMoney(
    ToggleMobileMoneyEvent event,
    Emitter<StoreSettingsState> emit,
  ) async {
    try {
      emit(const StoreSettingsLoading());
      await _repository.toggleMobileMoney(event.storeId, event.enabled);
      emit(const StoreSettingsOperationSuccess('Paiements mobile money mis à jour'));
    } catch (e) {
      emit(StoreSettingsError(e.toString()));
    }
  }
}

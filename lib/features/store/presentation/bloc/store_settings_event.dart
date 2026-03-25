import 'package:equatable/equatable.dart';

/// Events pour la gestion des réglages du magasin
abstract class StoreSettingsEvent extends Equatable {
  const StoreSettingsEvent();

  @override
  List<Object?> get props => [];
}

/// Charger les réglages d'un magasin
class LoadStoreSettingsEvent extends StoreSettingsEvent {
  final String storeId;

  const LoadStoreSettingsEvent(this.storeId);

  @override
  List<Object?> get props => [storeId];
}

/// Créer les réglages par défaut
class CreateDefaultSettingsEvent extends StoreSettingsEvent {
  final String storeId;

  const CreateDefaultSettingsEvent(this.storeId);

  @override
  List<Object?> get props => [storeId];
}

/// Mettre à jour les réglages
class UpdateStoreSettingsEvent extends StoreSettingsEvent {
  final String storeId;
  final bool? shiftsEnabled;
  final bool? timeClockEnabled;
  final bool? openTicketsEnabled;
  final bool? predefinedTicketsEnabled;
  final bool? kitchenPrintersEnabled;
  final bool? customerDisplayEnabled;
  final bool? diningOptionsEnabled;
  final bool? lowStockNotifications;
  final bool? negativeStockAlerts;
  final bool? weightBarcodesEnabled;
  final int? cashRoundingUnit;
  final String? receiptFooter;

  const UpdateStoreSettingsEvent({
    required this.storeId,
    this.shiftsEnabled,
    this.timeClockEnabled,
    this.openTicketsEnabled,
    this.predefinedTicketsEnabled,
    this.kitchenPrintersEnabled,
    this.customerDisplayEnabled,
    this.diningOptionsEnabled,
    this.lowStockNotifications,
    this.negativeStockAlerts,
    this.weightBarcodesEnabled,
    this.cashRoundingUnit,
    this.receiptFooter,
  });

  @override
  List<Object?> get props => [
        storeId,
        shiftsEnabled,
        timeClockEnabled,
        openTicketsEnabled,
        predefinedTicketsEnabled,
        kitchenPrintersEnabled,
        customerDisplayEnabled,
        diningOptionsEnabled,
        lowStockNotifications,
        negativeStockAlerts,
        weightBarcodesEnabled,
        cashRoundingUnit,
        receiptFooter,
      ];
}

/// Toggle shifts
class ToggleShiftsEvent extends StoreSettingsEvent {
  final String storeId;
  final bool enabled;

  const ToggleShiftsEvent(this.storeId, this.enabled);

  @override
  List<Object?> get props => [storeId, enabled];
}

/// Toggle open tickets
class ToggleOpenTicketsEvent extends StoreSettingsEvent {
  final String storeId;
  final bool enabled;

  const ToggleOpenTicketsEvent(this.storeId, this.enabled);

  @override
  List<Object?> get props => [storeId, enabled];
}

/// Toggle low stock notifications
class ToggleLowStockNotificationsEvent extends StoreSettingsEvent {
  final String storeId;
  final bool enabled;

  const ToggleLowStockNotificationsEvent(this.storeId, this.enabled);

  @override
  List<Object?> get props => [storeId, enabled];
}

/// Mettre à jour l'unité d'arrondi caisse
class UpdateCashRoundingUnitEvent extends StoreSettingsEvent {
  final String storeId;
  final int unit;

  const UpdateCashRoundingUnitEvent(this.storeId, this.unit);

  @override
  List<Object?> get props => [storeId, unit];
}

/// Mettre à jour le footer des reçus
class UpdateReceiptFooterEvent extends StoreSettingsEvent {
  final String storeId;
  final String? footer;

  const UpdateReceiptFooterEvent(this.storeId, this.footer);

  @override
  List<Object?> get props => [storeId, footer];
}

import 'package:drift/drift.dart';
import '../../../../core/data/local/app_database.dart';

/// Repository pour la gestion des réglages du magasin
/// Couche intermédiaire entre les DAOs Drift et les BLoCs
class StoreSettingsRepository {
  final AppDatabase _database;

  StoreSettingsRepository(this._database);

  // Getters pour accéder aux DAOs
  StoreSettingsDao get _settingsDao => _database.storeSettingsDao;

  /// Récupérer les réglages d'un magasin
  Stream<StoreSetting?> watchStoreSettings(String storeId) {
    return _settingsDao.getSettingsByStore(storeId).watchSingleOrNull();
  }

  /// Récupérer les réglages d'un magasin (one-time)
  Future<StoreSetting?> getStoreSettings(String storeId) {
    return _settingsDao.getSettingsByStore(storeId).getSingleOrNull();
  }

  /// Créer les réglages par défaut pour un nouveau magasin
  Future<void> createDefaultSettings(String storeId) async {
    final companion = StoreSettingsCompanion(
      storeId: Value(storeId),
      shiftsEnabled: const Value(0),
      timeClockEnabled: const Value(0),
      openTicketsEnabled: const Value(0),
      predefinedTicketsEnabled: const Value(0),
      kitchenPrintersEnabled: const Value(0),
      customerDisplayEnabled: const Value(0),
      diningOptionsEnabled: const Value(0),
      lowStockNotifications: const Value(1),
      negativeStockAlerts: const Value(0),
      weightBarcodesEnabled: const Value(0),
      cashRoundingUnit: const Value(0),
      receiptFooter: const Value(null),
      updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      synced: const Value(0),
    );

    await _settingsDao.insertSettings(companion);
  }

  /// Mettre à jour un ou plusieurs réglages
  Future<void> updateSettings({
    required String storeId,
    bool? shiftsEnabled,
    bool? timeClockEnabled,
    bool? openTicketsEnabled,
    bool? predefinedTicketsEnabled,
    bool? kitchenPrintersEnabled,
    bool? customerDisplayEnabled,
    bool? diningOptionsEnabled,
    bool? lowStockNotifications,
    bool? negativeStockAlerts,
    bool? weightBarcodesEnabled,
    int? cashRoundingUnit,
    String? receiptFooter,
  }) async {
    final companion = StoreSettingsCompanion(
      storeId: Value(storeId),
      shiftsEnabled: shiftsEnabled != null ? Value(shiftsEnabled ? 1 : 0) : const Value.absent(),
      timeClockEnabled: timeClockEnabled != null ? Value(timeClockEnabled ? 1 : 0) : const Value.absent(),
      openTicketsEnabled: openTicketsEnabled != null ? Value(openTicketsEnabled ? 1 : 0) : const Value.absent(),
      predefinedTicketsEnabled: predefinedTicketsEnabled != null ? Value(predefinedTicketsEnabled ? 1 : 0) : const Value.absent(),
      kitchenPrintersEnabled: kitchenPrintersEnabled != null ? Value(kitchenPrintersEnabled ? 1 : 0) : const Value.absent(),
      customerDisplayEnabled: customerDisplayEnabled != null ? Value(customerDisplayEnabled ? 1 : 0) : const Value.absent(),
      diningOptionsEnabled: diningOptionsEnabled != null ? Value(diningOptionsEnabled ? 1 : 0) : const Value.absent(),
      lowStockNotifications: lowStockNotifications != null ? Value(lowStockNotifications ? 1 : 0) : const Value.absent(),
      negativeStockAlerts: negativeStockAlerts != null ? Value(negativeStockAlerts ? 1 : 0) : const Value.absent(),
      weightBarcodesEnabled: weightBarcodesEnabled != null ? Value(weightBarcodesEnabled ? 1 : 0) : const Value.absent(),
      cashRoundingUnit: cashRoundingUnit != null ? Value(cashRoundingUnit) : const Value.absent(),
      receiptFooter: receiptFooter != null ? Value(receiptFooter) : const Value.absent(),
      updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      synced: const Value(0),
    );

    await _settingsDao.updateSettings(companion);
  }

  /// Activer/Désactiver les shifts
  Future<void> toggleShifts(String storeId, bool enabled) {
    return _settingsDao.toggleFeature(storeId: storeId, shiftsEnabled: enabled);
  }

  /// Activer/Désactiver les tickets ouverts
  Future<void> toggleOpenTickets(String storeId, bool enabled) {
    return _settingsDao.toggleFeature(storeId: storeId, openTicketsEnabled: enabled);
  }

  /// Activer/Désactiver les notifications de stock bas
  Future<void> toggleLowStockNotifications(String storeId, bool enabled) {
    return _settingsDao.toggleFeature(storeId: storeId, lowStockNotifications: enabled);
  }

  /// Mettre à jour l'unité d'arrondi caisse
  Future<void> updateCashRoundingUnit(String storeId, int unit) async {
    await _settingsDao.updateSettings(
      StoreSettingsCompanion(
        storeId: Value(storeId),
        cashRoundingUnit: Value(unit),
        synced: const Value(0),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  /// Mettre à jour le footer des reçus
  Future<void> updateReceiptFooter(String storeId, String? footer) async {
    await _settingsDao.updateSettings(
      StoreSettingsCompanion(
        storeId: Value(storeId),
        receiptFooter: Value(footer),
        synced: const Value(0),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  /// Récupérer les réglages non synchronisés
  Future<List<StoreSetting>> getUnsyncedSettings() {
    return _settingsDao.getUnsyncedSettings().get();
  }

  /// Marquer les réglages comme synchronisés
  Future<void> markSettingsAsSynced(String storeId) {
    return _settingsDao.markSettingsSynced(storeId);
  }
}

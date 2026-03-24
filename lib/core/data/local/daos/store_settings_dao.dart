import 'package:drift/drift.dart';
import '../app_database.dart';

part 'store_settings_dao.g.dart';

/// DAO pour la table store_settings
/// Gère les réglages modulaires de chaque magasin (toggles de fonctionnalités)
@DriftAccessor(include: {'../tables/store_settings.drift'})
class StoreSettingsDao extends DatabaseAccessor<AppDatabase>
    with _$StoreSettingsDaoMixin {
  StoreSettingsDao(AppDatabase db) : super(db);

  /// Récupère les réglages d'un magasin
  Future<StoreSetting?> getSettingsByStore(String storeId) =>
      getSettingsByStoreQuery(storeId).getSingleOrNull();

  /// Récupère tous les réglages non synchronisés
  Future<List<StoreSetting>> getUnsyncedSettings() =>
      getUnsyncedSettingsQuery().get();

  /// Insère les réglages par défaut pour un nouveau magasin
  Future<int> insertSettings(StoreSettingsCompanion settings) =>
      into(storeSettings).insert(settings);

  /// Met à jour les réglages d'un magasin et marque comme non synchronisé
  Future<bool> updateSettings(StoreSettingsCompanion settings) async {
    return await (update(storeSettings)
          ..where((tbl) => tbl.storeId.equals(settings.storeId.value)))
        .write(settings.copyWith(
      synced: const Value(false),
      updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
    ));
  }

  /// Marque les réglages comme synchronisés avec Supabase
  Future<bool> markSettingsSynced(String storeId) async {
    return await (update(storeSettings)
          ..where((tbl) => tbl.storeId.equals(storeId)))
        .write(
      const StoreSettingsCompanion(
        synced: Value(true),
      ),
    );
  }

  /// Crée les réglages par défaut pour un nouveau magasin
  Future<int> createDefaultSettings(String storeId) {
    return insertSettings(
      StoreSettingsCompanion(
        storeId: Value(storeId),
        shiftsEnabled: const Value(false),
        timeClockEnabled: const Value(false),
        openTicketsEnabled: const Value(false),
        predefinedTicketsEnabled: const Value(false),
        kitchenPrintersEnabled: const Value(false),
        customerDisplayEnabled: const Value(false),
        diningOptionsEnabled: const Value(false),
        lowStockNotifications: const Value(true),
        negativeStockAlerts: const Value(false),
        weightBarcodesEnabled: const Value(false),
        cashRoundingUnit: const Value(0),
        receiptFooter: const Value(null),
        synced: const Value(false),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  /// Active/désactive une fonctionnalité spécifique
  Future<bool> toggleFeature({
    required String storeId,
    String? featureName,
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
  }) async {
    return await (update(storeSettings)
          ..where((tbl) => tbl.storeId.equals(storeId)))
        .write(
      StoreSettingsCompanion(
        shiftsEnabled: shiftsEnabled != null ? Value(shiftsEnabled) : const Value.absent(),
        timeClockEnabled: timeClockEnabled != null ? Value(timeClockEnabled) : const Value.absent(),
        openTicketsEnabled: openTicketsEnabled != null ? Value(openTicketsEnabled) : const Value.absent(),
        predefinedTicketsEnabled: predefinedTicketsEnabled != null ? Value(predefinedTicketsEnabled) : const Value.absent(),
        kitchenPrintersEnabled: kitchenPrintersEnabled != null ? Value(kitchenPrintersEnabled) : const Value.absent(),
        customerDisplayEnabled: customerDisplayEnabled != null ? Value(customerDisplayEnabled) : const Value.absent(),
        diningOptionsEnabled: diningOptionsEnabled != null ? Value(diningOptionsEnabled) : const Value.absent(),
        lowStockNotifications: lowStockNotifications != null ? Value(lowStockNotifications) : const Value.absent(),
        negativeStockAlerts: negativeStockAlerts != null ? Value(negativeStockAlerts) : const Value.absent(),
        weightBarcodesEnabled: weightBarcodesEnabled != null ? Value(weightBarcodesEnabled) : const Value.absent(),
        synced: const Value(false),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  /// Stream pour écouter les changements sur les réglages d'un magasin
  Stream<StoreSetting?> watchSettingsByStore(String storeId) =>
      getSettingsByStoreQuery(storeId).watchSingleOrNull();
}

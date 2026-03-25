import 'package:drift/drift.dart';
import '../app_database.dart';

part 'store_settings_dao.g.dart';

/// DAO pour la table store_settings
/// Gère les réglages modulaires de chaque magasin (toggles de fonctionnalités)
@DriftAccessor(include: {'../tables/store_settings.drift'})
class StoreSettingsDao extends DatabaseAccessor<AppDatabase>
    with _$StoreSettingsDaoMixin {
  StoreSettingsDao(AppDatabase db) : super(db);

  // Les queries définies dans store_settings.drift sont automatiquement générées
  // et disponibles via le mixin _$StoreSettingsDaoMixin:
  // - getSettingsByStore(storeId) retourne Selectable<StoreSetting>
  // - getUnsyncedSettings() retourne Selectable<StoreSetting>
  //
  // Utiliser .get() pour Future<List<T>>, .getSingleOrNull() pour Future<T?>,
  // .watch() pour Stream<List<T>>, .watchSingleOrNull() pour Stream<T?>

  /// Insère les réglages par défaut pour un nouveau magasin
  Future<int> insertSettings(StoreSettingsCompanion settings) =>
      into(storeSettings).insert(settings);

  /// Met à jour les réglages d'un magasin et marque comme non synchronisé
  Future<bool> updateSettings(StoreSettingsCompanion settings) async {
    final rowsAffected = await (update(storeSettings)
          ..where((tbl) => tbl.storeId.equals(settings.storeId.value)))
        .write(settings.copyWith(
      synced: const Value(0),
      updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
    ));
    return rowsAffected > 0;
  }

  /// Marque les réglages comme synchronisés avec Supabase
  Future<bool> markSettingsSynced(String storeId) async {
    final rowsAffected = await (update(storeSettings)
          ..where((tbl) => tbl.storeId.equals(storeId)))
        .write(
      const StoreSettingsCompanion(
        synced: Value(1),
      ),
    );
    return rowsAffected > 0;
  }

  /// Crée les réglages par défaut pour un nouveau magasin
  Future<int> createDefaultSettings(String storeId) {
    return insertSettings(
      StoreSettingsCompanion(
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
        synced: const Value(0),
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
    final rowsAffected = await (update(storeSettings)
          ..where((tbl) => tbl.storeId.equals(storeId)))
        .write(
      StoreSettingsCompanion(
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
        synced: const Value(0),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
    return rowsAffected > 0;
  }

  /// Stream pour écouter les changements sur les réglages d'un magasin
  Stream<StoreSetting?> watchSettingsByStore(String storeId) =>
      getSettingsByStore(storeId).watchSingleOrNull();
}

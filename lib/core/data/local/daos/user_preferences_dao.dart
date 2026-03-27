import 'package:drift/drift.dart';
import '../app_database.dart';

part 'user_preferences_dao.g.dart';

@DriftAccessor(include: {'../tables/user_preferences.drift'})
class UserPreferencesDao extends DatabaseAccessor<AppDatabase>
    with _$UserPreferencesDaoMixin {
  UserPreferencesDao(AppDatabase db) : super(db);

  /// Récupérer les préférences de l'utilisateur connecté
  Stream<UserPreference?> watchPreferences(String userId) {
    return (select(userPreferences)
          ..where((p) => p.userId.equals(userId))
          ..limit(1))
        .watchSingleOrNull();
  }

  /// Récupérer les préférences (une seule fois)
  Future<UserPreference?> getPreferences(String userId) {
    return (select(userPreferences)
          ..where((p) => p.userId.equals(userId))
          ..limit(1))
        .getSingleOrNull();
  }

  /// Créer ou mettre à jour les préférences
  Future<void> upsertPreferences(UserPreferencesCompanion preferences) async {
    await into(userPreferences).insertOnConflictUpdate(preferences);
  }

  /// Mettre à jour uniquement le thème
  Future<void> updateThemeMode(String userId, String themeMode) async {
    await (update(userPreferences)
          ..where((p) => p.userId.equals(userId)))
        .write(UserPreferencesCompanion(
      themeMode: Value(themeMode),
      updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      synced: const Value(0),
    ));
  }

  /// Mettre à jour uniquement la langue
  Future<void> updateLocale(String userId, String locale) async {
    await (update(userPreferences)
          ..where((p) => p.userId.equals(userId)))
        .write(UserPreferencesCompanion(
      locale: Value(locale),
      updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      synced: const Value(0),
    ));
  }

  /// Mettre à jour les préférences de notifications
  Future<void> updateNotifications({
    required String userId,
    bool? enableNotifications,
    bool? enableLowStockAlerts,
    bool? enableSalesSound,
    bool? enableVibration,
  }) async {
    final companion = UserPreferencesCompanion(
      updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      synced: const Value(0),
    );

    await (update(userPreferences)
          ..where((p) => p.userId.equals(userId)))
        .write(UserPreferencesCompanion(
      enableNotifications: enableNotifications != null
          ? Value(enableNotifications ? 1 : 0)
          : const Value.absent(),
      enableLowStockAlerts: enableLowStockAlerts != null
          ? Value(enableLowStockAlerts ? 1 : 0)
          : const Value.absent(),
      enableSalesSound: enableSalesSound != null
          ? Value(enableSalesSound ? 1 : 0)
          : const Value.absent(),
      enableVibration: enableVibration != null
          ? Value(enableVibration ? 1 : 0)
          : const Value.absent(),
      updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      synced: const Value(0),
    ));
  }

  /// Mettre à jour les préférences POS
  Future<void> updatePosSettings({
    required String userId,
    bool? autoPrintReceipt,
    bool? quickCheckoutMode,
    bool? showProductImages,
  }) async {
    await (update(userPreferences)
          ..where((p) => p.userId.equals(userId)))
        .write(UserPreferencesCompanion(
      autoPrintReceipt: autoPrintReceipt != null
          ? Value(autoPrintReceipt ? 1 : 0)
          : const Value.absent(),
      quickCheckoutMode: quickCheckoutMode != null
          ? Value(quickCheckoutMode ? 1 : 0)
          : const Value.absent(),
      showProductImages: showProductImages != null
          ? Value(showProductImages ? 1 : 0)
          : const Value.absent(),
      updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      synced: const Value(0),
    ));
  }

  /// Mettre à jour l'échelle de police
  Future<void> updateFontScale(String userId, double fontScale) async {
    await (update(userPreferences)
          ..where((p) => p.userId.equals(userId)))
        .write(UserPreferencesCompanion(
      fontScale: Value(fontScale),
      updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      synced: const Value(0),
    ));
  }

  /// Mettre à jour les préférences de sync
  Future<void> updateSyncSettings({
    required String userId,
    bool? autoSync,
    int? syncFrequencyMinutes,
  }) async {
    await (update(userPreferences)
          ..where((p) => p.userId.equals(userId)))
        .write(UserPreferencesCompanion(
      autoSync:
          autoSync != null ? Value(autoSync ? 1 : 0) : const Value.absent(),
      syncFrequencyMinutes: syncFrequencyMinutes != null
          ? Value(syncFrequencyMinutes)
          : const Value.absent(),
      updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      synced: const Value(0),
    ));
  }

  /// Créer les préférences par défaut pour un nouvel utilisateur
  Future<void> createDefaultPreferences(String userId) async {
    await into(userPreferences).insert(
      UserPreferencesCompanion.insert(
        id: userId, // Utiliser le userId comme id
        userId: userId,
        themeMode: const Value('system'),
        locale: const Value('fr'),
        enableNotifications: const Value(1),
        enableLowStockAlerts: const Value(1),
        enableSalesSound: const Value(1),
        enableVibration: const Value(1),
        autoPrintReceipt: const Value(0),
        quickCheckoutMode: const Value(0),
        showProductImages: const Value(1),
        fontScale: const Value(1.0),
        compactView: const Value(0),
        autoSync: const Value(1),
        syncFrequencyMinutes: const Value(30),
        updatedAt: DateTime.now().millisecondsSinceEpoch,
        synced: const Value(0),
      ),
      mode: InsertMode.insertOrIgnore,
    );
  }
}

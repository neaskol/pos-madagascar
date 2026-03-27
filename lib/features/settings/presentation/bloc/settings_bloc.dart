import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/data/local/app_database.dart';
import '../../../../core/data/remote/sync_service.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final UserPreferencesDao _preferencesDao;
  final SyncService _syncService;
  StreamSubscription? _preferencesSubscription;

  SettingsBloc({
    required UserPreferencesDao preferencesDao,
    required SyncService syncService,
  })  : _preferencesDao = preferencesDao,
        _syncService = syncService,
        super(SettingsInitial()) {
    on<LoadSettings>(_onLoadSettings);
    on<UpdateThemeMode>(_onUpdateThemeMode);
    on<UpdateLocale>(_onUpdateLocale);
    on<UpdateNotificationSettings>(_onUpdateNotificationSettings);
    on<UpdatePosSettings>(_onUpdatePosSettings);
    on<UpdateFontScale>(_onUpdateFontScale);
    on<UpdateSyncSettings>(_onUpdateSyncSettings);
    on<TriggerManualSync>(_onTriggerManualSync);
    on<_PreferencesUpdated>(_onPreferencesUpdated);
  }

  Future<void> _onLoadSettings(
    LoadSettings event,
    Emitter<SettingsState> emit,
  ) async {
    emit(SettingsLoading());

    try {
      // Créer les préférences par défaut si elles n'existent pas
      await _preferencesDao.createDefaultPreferences(event.userId);

      // S'abonner aux changements
      await _preferencesSubscription?.cancel();
      _preferencesSubscription = _preferencesDao
          .watchPreferences(event.userId)
          .listen((preferences) {
        if (preferences != null) {
          add(_PreferencesUpdated(preferences));
        }
      });

      // Charger les préférences initiales
      final preferences = await _preferencesDao.getPreferences(event.userId);
      if (preferences != null) {
        emit(SettingsLoaded(preferences: preferences));
      } else {
        emit(const SettingsError('Impossible de charger les préférences'));
      }
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  Future<void> _onUpdateThemeMode(
    UpdateThemeMode event,
    Emitter<SettingsState> emit,
  ) async {
    final currentState = state;
    if (currentState is SettingsLoaded) {
      try {
        await _preferencesDao.updateThemeMode(
          currentState.preferences.userId,
          event.themeMode,
        );
        // Le stream mettra à jour l'état automatiquement
      } catch (e) {
        emit(SettingsError(e.toString()));
        emit(currentState); // Restaurer l'état précédent
      }
    }
  }

  Future<void> _onUpdateLocale(
    UpdateLocale event,
    Emitter<SettingsState> emit,
  ) async {
    final currentState = state;
    if (currentState is SettingsLoaded) {
      try {
        await _preferencesDao.updateLocale(
          currentState.preferences.userId,
          event.locale,
        );
        // Le stream mettra à jour l'état automatiquement
      } catch (e) {
        emit(SettingsError(e.toString()));
        emit(currentState);
      }
    }
  }

  Future<void> _onUpdateNotificationSettings(
    UpdateNotificationSettings event,
    Emitter<SettingsState> emit,
  ) async {
    final currentState = state;
    if (currentState is SettingsLoaded) {
      try {
        await _preferencesDao.updateNotifications(
          userId: currentState.preferences.userId,
          enableNotifications: event.enableNotifications,
          enableLowStockAlerts: event.enableLowStockAlerts,
          enableSalesSound: event.enableSalesSound,
          enableVibration: event.enableVibration,
        );
      } catch (e) {
        emit(SettingsError(e.toString()));
        emit(currentState);
      }
    }
  }

  Future<void> _onUpdatePosSettings(
    UpdatePosSettings event,
    Emitter<SettingsState> emit,
  ) async {
    final currentState = state;
    if (currentState is SettingsLoaded) {
      try {
        await _preferencesDao.updatePosSettings(
          userId: currentState.preferences.userId,
          autoPrintReceipt: event.autoPrintReceipt,
          quickCheckoutMode: event.quickCheckoutMode,
          showProductImages: event.showProductImages,
        );
      } catch (e) {
        emit(SettingsError(e.toString()));
        emit(currentState);
      }
    }
  }

  Future<void> _onUpdateFontScale(
    UpdateFontScale event,
    Emitter<SettingsState> emit,
  ) async {
    final currentState = state;
    if (currentState is SettingsLoaded) {
      try {
        await _preferencesDao.updateFontScale(
          currentState.preferences.userId,
          event.fontScale,
        );
      } catch (e) {
        emit(SettingsError(e.toString()));
        emit(currentState);
      }
    }
  }

  Future<void> _onUpdateSyncSettings(
    UpdateSyncSettings event,
    Emitter<SettingsState> emit,
  ) async {
    final currentState = state;
    if (currentState is SettingsLoaded) {
      try {
        await _preferencesDao.updateSyncSettings(
          userId: currentState.preferences.userId,
          autoSync: event.autoSync,
          syncFrequencyMinutes: event.syncFrequencyMinutes,
        );
      } catch (e) {
        emit(SettingsError(e.toString()));
        emit(currentState);
      }
    }
  }

  Future<void> _onTriggerManualSync(
    TriggerManualSync event,
    Emitter<SettingsState> emit,
  ) async {
    final currentState = state;
    if (currentState is SettingsLoaded) {
      emit(currentState.copyWith(isSyncing: true));

      try {
        await _syncService.forceSyncNow();
        final now = DateTime.now();
        emit(currentState.copyWith(
          isSyncing: false,
          lastSyncTime: now,
        ));
        emit(SettingsSyncSuccess(now));
        // Restaurer l'état loaded après le message de succès
        emit(currentState.copyWith(
          isSyncing: false,
          lastSyncTime: now,
        ));
      } catch (e) {
        emit(currentState.copyWith(isSyncing: false));
        emit(SettingsSyncError(e.toString()));
        emit(currentState.copyWith(isSyncing: false));
      }
    }
  }

  // Event privé pour mettre à jour l'état quand les préférences changent
  void _onPreferencesUpdated(
    _PreferencesUpdated event,
    Emitter<SettingsState> emit,
  ) {
    final currentState = state;
    if (currentState is SettingsLoaded) {
      emit(currentState.copyWith(preferences: event.preferences));
    } else {
      emit(SettingsLoaded(preferences: event.preferences));
    }
  }

  @override
  Future<void> close() {
    _preferencesSubscription?.cancel();
    return super.close();
  }
}

// Event privé pour les mises à jour du stream
class _PreferencesUpdated extends SettingsEvent {
  final UserPreference preferences;

  const _PreferencesUpdated(this.preferences);

  @override
  List<Object?> get props => [preferences];
}

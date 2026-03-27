part of 'settings_bloc.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final UserPreference preferences;
  final bool isSyncing;
  final DateTime? lastSyncTime;

  const SettingsLoaded({
    required this.preferences,
    this.isSyncing = false,
    this.lastSyncTime,
  });

  SettingsLoaded copyWith({
    UserPreference? preferences,
    bool? isSyncing,
    DateTime? lastSyncTime,
  }) {
    return SettingsLoaded(
      preferences: preferences ?? this.preferences,
      isSyncing: isSyncing ?? this.isSyncing,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
    );
  }

  @override
  List<Object?> get props => [preferences, isSyncing, lastSyncTime];
}

class SettingsError extends SettingsState {
  final String message;

  const SettingsError(this.message);

  @override
  List<Object?> get props => [message];
}

class SettingsSyncSuccess extends SettingsState {
  final DateTime syncTime;

  const SettingsSyncSuccess(this.syncTime);

  @override
  List<Object?> get props => [syncTime];
}

class SettingsSyncError extends SettingsState {
  final String message;

  const SettingsSyncError(this.message);

  @override
  List<Object?> get props => [message];
}

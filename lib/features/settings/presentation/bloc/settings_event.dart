part of 'settings_bloc.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSettings extends SettingsEvent {
  final String userId;

  const LoadSettings(this.userId);

  @override
  List<Object?> get props => [userId];
}

class UpdateThemeMode extends SettingsEvent {
  final String themeMode;

  const UpdateThemeMode(this.themeMode);

  @override
  List<Object?> get props => [themeMode];
}

class UpdateLocale extends SettingsEvent {
  final String locale;

  const UpdateLocale(this.locale);

  @override
  List<Object?> get props => [locale];
}

class UpdateNotificationSettings extends SettingsEvent {
  final bool? enableNotifications;
  final bool? enableLowStockAlerts;
  final bool? enableSalesSound;
  final bool? enableVibration;

  const UpdateNotificationSettings({
    this.enableNotifications,
    this.enableLowStockAlerts,
    this.enableSalesSound,
    this.enableVibration,
  });

  @override
  List<Object?> get props => [
        enableNotifications,
        enableLowStockAlerts,
        enableSalesSound,
        enableVibration,
      ];
}

class UpdatePosSettings extends SettingsEvent {
  final bool? autoPrintReceipt;
  final bool? quickCheckoutMode;
  final bool? showProductImages;

  const UpdatePosSettings({
    this.autoPrintReceipt,
    this.quickCheckoutMode,
    this.showProductImages,
  });

  @override
  List<Object?> get props => [
        autoPrintReceipt,
        quickCheckoutMode,
        showProductImages,
      ];
}

class UpdateFontScale extends SettingsEvent {
  final double fontScale;

  const UpdateFontScale(this.fontScale);

  @override
  List<Object?> get props => [fontScale];
}

class UpdateSyncSettings extends SettingsEvent {
  final bool? autoSync;
  final int? syncFrequencyMinutes;

  const UpdateSyncSettings({
    this.autoSync,
    this.syncFrequencyMinutes,
  });

  @override
  List<Object?> get props => [autoSync, syncFrequencyMinutes];
}

class TriggerManualSync extends SettingsEvent {
  const TriggerManualSync();
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/theme_ext.dart';
import '../bloc/settings_bloc.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_tile.dart';
import '../widgets/theme_selector_sheet.dart';
import '../widgets/language_selector_sheet.dart';
import '../widgets/font_scale_sheet.dart';
import '../widgets/sync_frequency_sheet.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
        elevation: 0,
      ),
      body: BlocConsumer<SettingsBloc, SettingsState>(
        listener: (context, state) {
          if (state is SettingsSyncSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.settingsSyncSuccess),
                backgroundColor: context.success,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is SettingsSyncError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: context.danger,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is SettingsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is SettingsLoaded) {
            final prefs = state.preferences;

            return ListView(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              children: [
                // APPARENCE
                SettingsSection(
                  title: l10n.settingsAppearance,
                  children: [
                    SettingsTile(
                      leading: const Icon(Icons.palette_outlined),
                      title: l10n.settingsTheme,
                      subtitle: _getThemeLabel(context, prefs.themeMode),
                      onTap: () => _showThemeSelector(context, prefs.themeMode),
                    ),
                    SettingsTile(
                      leading: const Icon(Icons.format_size),
                      title: l10n.settingsFontSize,
                      subtitle: _getFontScaleLabel(context, prefs.fontScale),
                      onTap: () => _showFontScaleSelector(context, prefs.fontScale),
                    ),
                    SettingsTile.switchTile(
                      leading: const Icon(Icons.view_compact_outlined),
                      title: l10n.settingsCompactView,
                      subtitle: l10n.settingsCompactViewDesc,
                      value: prefs.compactView == 1,
                      onChanged: (value) {
                        // TODO: Implémenter compact view
                      },
                    ),
                  ],
                ),

                // LANGUE
                SettingsSection(
                  title: l10n.settingsLanguage,
                  children: [
                    SettingsTile(
                      leading: const Icon(Icons.language),
                      title: l10n.settingsLanguageInterface,
                      subtitle: prefs.locale == 'fr'
                          ? l10n.settingsLanguageFrench
                          : l10n.settingsLanguageMalagasy,
                      onTap: () => _showLanguageSelector(context, prefs.locale),
                    ),
                  ],
                ),

                // NOTIFICATIONS
                SettingsSection(
                  title: l10n.settingsNotifications,
                  children: [
                    SettingsTile.switchTile(
                      leading: const Icon(Icons.notifications_outlined),
                      title: l10n.settingsEnableNotifications,
                      subtitle: l10n.settingsEnableNotificationsDesc,
                      value: prefs.enableNotifications == 1,
                      onChanged: (value) {
                        context.read<SettingsBloc>().add(
                              UpdateNotificationSettings(
                                enableNotifications: value,
                              ),
                            );
                      },
                    ),
                    SettingsTile.switchTile(
                      leading: const Icon(Icons.inventory_2_outlined),
                      title: l10n.settingsLowStockAlerts,
                      subtitle: l10n.settingsLowStockAlertsDesc,
                      value: prefs.enableLowStockAlerts == 1,
                      onChanged: (value) {
                        context.read<SettingsBloc>().add(
                              UpdateNotificationSettings(
                                enableLowStockAlerts: value,
                              ),
                            );
                      },
                    ),
                    SettingsTile.switchTile(
                      leading: const Icon(Icons.volume_up_outlined),
                      title: l10n.settingsSalesSound,
                      subtitle: l10n.settingsSalesSoundDesc,
                      value: prefs.enableSalesSound == 1,
                      onChanged: (value) {
                        context.read<SettingsBloc>().add(
                              UpdateNotificationSettings(
                                enableSalesSound: value,
                              ),
                            );
                      },
                    ),
                    SettingsTile.switchTile(
                      leading: const Icon(Icons.vibration),
                      title: l10n.settingsVibration,
                      subtitle: l10n.settingsVibrationDesc,
                      value: prefs.enableVibration == 1,
                      onChanged: (value) {
                        context.read<SettingsBloc>().add(
                              UpdateNotificationSettings(
                                enableVibration: value,
                              ),
                            );
                      },
                    ),
                  ],
                ),

                // POINT DE VENTE
                SettingsSection(
                  title: l10n.settingsPOS,
                  children: [
                    SettingsTile.switchTile(
                      leading: const Icon(Icons.print_outlined),
                      title: l10n.settingsAutoPrintReceipt,
                      subtitle: l10n.settingsAutoPrintReceiptDesc,
                      value: prefs.autoPrintReceipt == 1,
                      onChanged: (value) {
                        context.read<SettingsBloc>().add(
                              UpdatePosSettings(autoPrintReceipt: value),
                            );
                      },
                    ),
                    SettingsTile.switchTile(
                      leading: const Icon(Icons.flash_on_outlined),
                      title: l10n.settingsQuickCheckout,
                      subtitle: l10n.settingsQuickCheckoutDesc,
                      value: prefs.quickCheckoutMode == 1,
                      onChanged: (value) {
                        context.read<SettingsBloc>().add(
                              UpdatePosSettings(quickCheckoutMode: value),
                            );
                      },
                    ),
                    SettingsTile.switchTile(
                      leading: const Icon(Icons.image_outlined),
                      title: l10n.settingsShowProductImages,
                      subtitle: l10n.settingsShowProductImagesDesc,
                      value: prefs.showProductImages == 1,
                      onChanged: (value) {
                        context.read<SettingsBloc>().add(
                              UpdatePosSettings(showProductImages: value),
                            );
                      },
                    ),
                  ],
                ),

                // SYNCHRONISATION
                SettingsSection(
                  title: l10n.settingsSync,
                  children: [
                    SettingsTile.switchTile(
                      leading: const Icon(Icons.sync),
                      title: l10n.settingsAutoSync,
                      subtitle: l10n.settingsAutoSyncDesc,
                      value: prefs.autoSync == 1,
                      onChanged: (value) {
                        context.read<SettingsBloc>().add(
                              UpdateSyncSettings(autoSync: value),
                            );
                      },
                    ),
                    if (prefs.autoSync == 1)
                      SettingsTile(
                        leading: const Icon(Icons.schedule),
                        title: l10n.settingsSyncFrequency,
                        subtitle: _getSyncFrequencyLabel(
                          context,
                          prefs.syncFrequencyMinutes,
                        ),
                        onTap: () => _showSyncFrequencySelector(
                          context,
                          prefs.syncFrequencyMinutes,
                        ),
                      ),
                    SettingsTile(
                      leading: state.isSyncing
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.sync),
                      title: l10n.settingsSyncNow,
                      subtitle: state.lastSyncTime != null
                          ? l10n.settingsLastSync(
                              _formatLastSync(context, state.lastSyncTime!),
                            )
                          : null,
                      onTap: state.isSyncing
                          ? null
                          : () {
                              context
                                  .read<SettingsBloc>()
                                  .add(const TriggerManualSync());
                            },
                    ),
                  ],
                ),

                // À PROPOS
                SettingsSection(
                  title: l10n.settingsAbout,
                  children: [
                    SettingsTile(
                      leading: const Icon(Icons.info_outline),
                      title: l10n.settingsVersion,
                      subtitle: '1.0.0',
                      trailing: const SizedBox.shrink(),
                    ),
                    SettingsTile(
                      leading: const Icon(Icons.star_outline),
                      title: l10n.settingsRateApp,
                      onTap: () {
                        // TODO: Ouvrir le store
                      },
                    ),
                    SettingsTile(
                      leading: const Icon(Icons.share_outlined),
                      title: l10n.settingsShareApp,
                      onTap: () {
                        // TODO: Partager l'app
                      },
                    ),
                    SettingsTile(
                      leading: const Icon(Icons.help_outline),
                      title: l10n.settingsContactSupport,
                      onTap: () {
                        // TODO: Contacter le support
                      },
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.xl),
              ],
            );
          }

          return const Center(child: Text('Erreur de chargement'));
        },
      ),
    );
  }

  String _getThemeLabel(BuildContext context, String themeMode) {
    final l10n = AppLocalizations.of(context)!;
    switch (themeMode) {
      case 'light':
        return l10n.settingsThemeLight;
      case 'dark':
        return l10n.settingsThemeDark;
      default:
        return l10n.settingsThemeSystem;
    }
  }

  String _getFontScaleLabel(BuildContext context, double fontScale) {
    final l10n = AppLocalizations.of(context)!;
    if (fontScale <= 0.9) return l10n.settingsFontSizeSmall;
    if (fontScale >= 1.1) return l10n.settingsFontSizeLarge;
    return l10n.settingsFontSizeNormal;
  }

  String _getSyncFrequencyLabel(BuildContext context, int minutes) {
    final l10n = AppLocalizations.of(context)!;
    switch (minutes) {
      case 1:
        return l10n.settingsSyncFrequency1min;
      case 5:
        return l10n.settingsSyncFrequency5min;
      case 60:
        return l10n.settingsSyncFrequency1hour;
      default:
        return l10n.settingsSyncFrequency30min;
    }
  }

  String _formatLastSync(BuildContext context, DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return 'À l\'instant';
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours}h';
    return 'Il y a ${diff.inDays}j';
  }

  void _showThemeSelector(BuildContext context, String currentTheme) {
    showModalBottomSheet(
      context: context,
      builder: (_) => ThemeSelectorSheet(currentTheme: currentTheme),
    );
  }

  void _showLanguageSelector(BuildContext context, String currentLocale) {
    showModalBottomSheet(
      context: context,
      builder: (_) => LanguageSelectorSheet(currentLocale: currentLocale),
    );
  }

  void _showFontScaleSelector(BuildContext context, double currentScale) {
    showModalBottomSheet(
      context: context,
      builder: (_) => FontScaleSheet(currentScale: currentScale),
    );
  }

  void _showSyncFrequencySelector(BuildContext context, int currentFrequency) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SyncFrequencySheet(currentFrequency: currentFrequency),
    );
  }
}

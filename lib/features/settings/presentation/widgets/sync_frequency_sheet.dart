import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/theme_ext.dart';
import '../bloc/settings_bloc.dart';

class SyncFrequencySheet extends StatelessWidget {
  final int currentFrequency;

  const SyncFrequencySheet({
    super.key,
    required this.currentFrequency,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.sheet),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
              child: Text(
                l10n.settingsSyncFrequency,
                style: GoogleFonts.sora(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: context.textPri,
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            _FrequencyOption(
              icon: Icons.flash_on,
              title: l10n.settingsSyncFrequency1min,
              value: 1,
              selected: currentFrequency == 1,
              onTap: () {
                context.read<SettingsBloc>().add(
                      const UpdateSyncSettings(syncFrequencyMinutes: 1),
                    );
                Navigator.pop(context);
              },
            ),

            _FrequencyOption(
              icon: Icons.schedule,
              title: l10n.settingsSyncFrequency5min,
              value: 5,
              selected: currentFrequency == 5,
              onTap: () {
                context.read<SettingsBloc>().add(
                      const UpdateSyncSettings(syncFrequencyMinutes: 5),
                    );
                Navigator.pop(context);
              },
            ),

            _FrequencyOption(
              icon: Icons.schedule,
              title: l10n.settingsSyncFrequency30min,
              value: 30,
              selected: currentFrequency == 30,
              onTap: () {
                context.read<SettingsBloc>().add(
                      const UpdateSyncSettings(syncFrequencyMinutes: 30),
                    );
                Navigator.pop(context);
              },
            ),

            _FrequencyOption(
              icon: Icons.schedule,
              title: l10n.settingsSyncFrequency1hour,
              value: 60,
              selected: currentFrequency == 60,
              onTap: () {
                context.read<SettingsBloc>().add(
                      const UpdateSyncSettings(syncFrequencyMinutes: 60),
                    );
                Navigator.pop(context);
              },
            ),

            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}

class _FrequencyOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final int value;
  final bool selected;
  final VoidCallback onTap;

  const _FrequencyOption({
    required this.icon,
    required this.title,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.page,
          vertical: 16,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: selected
                    ? (context.isDark
                        ? const Color(0xFFB8965A).withValues(alpha: 0.15)
                        : const Color(0xFF5C4F3A).withValues(alpha: 0.15))
                    : context.isDark
                        ? const Color(0xFF2E2520)
                        : const Color(0xFFF8F4ED),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                icon,
                color: selected ? context.accent : context.textSec,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.sora(
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  color: selected ? context.textPri : context.textSec,
                ),
              ),
            ),
            if (selected)
              Icon(
                Icons.check_circle,
                color: context.accent,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

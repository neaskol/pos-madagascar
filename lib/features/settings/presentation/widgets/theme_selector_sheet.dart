import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/theme_ext.dart';
import '../bloc/settings_bloc.dart';

class ThemeSelectorSheet extends StatelessWidget {
  final String currentTheme;

  const ThemeSelectorSheet({
    super.key,
    required this.currentTheme,
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
                l10n.settingsTheme,
                style: GoogleFonts.sora(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: context.textPri,
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            _ThemeOption(
              icon: Icons.brightness_5,
              title: l10n.settingsThemeLight,
              value: 'light',
              selected: currentTheme == 'light',
              onTap: () {
                context.read<SettingsBloc>().add(const UpdateThemeMode('light'));
                Navigator.pop(context);
              },
            ),

            _ThemeOption(
              icon: Icons.dark_mode,
              title: l10n.settingsThemeDark,
              value: 'dark',
              selected: currentTheme == 'dark',
              onTap: () {
                context.read<SettingsBloc>().add(const UpdateThemeMode('dark'));
                Navigator.pop(context);
              },
            ),

            _ThemeOption(
              icon: Icons.brightness_auto,
              title: l10n.settingsThemeSystem,
              value: 'system',
              selected: currentTheme == 'system',
              onTap: () {
                context.read<SettingsBloc>().add(const UpdateThemeMode('system'));
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

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeOption({
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
                        ? const Color(0xFFB8965A).withOpacity(0.15)
                        : const Color(0xFF5C4F3A).withOpacity(0.15))
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

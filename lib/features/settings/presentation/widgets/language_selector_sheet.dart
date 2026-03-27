import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/theme_ext.dart';
import '../bloc/settings_bloc.dart';

class LanguageSelectorSheet extends StatelessWidget {
  final String currentLocale;

  const LanguageSelectorSheet({
    super.key,
    required this.currentLocale,
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
                l10n.settingsLanguageInterface,
                style: GoogleFonts.sora(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: context.textPri,
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            _LanguageOption(
              flag: '🇫🇷',
              title: l10n.settingsLanguageFrench,
              subtitle: 'Français',
              value: 'fr',
              selected: currentLocale == 'fr',
              onTap: () {
                context.read<SettingsBloc>().add(const UpdateLocale('fr'));
                Navigator.pop(context);
              },
            ),

            _LanguageOption(
              flag: '🇲🇬',
              title: l10n.settingsLanguageMalagasy,
              subtitle: 'Malagasy',
              value: 'mg',
              selected: currentLocale == 'mg',
              onTap: () {
                context.read<SettingsBloc>().add(const UpdateLocale('mg'));
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

class _LanguageOption extends StatelessWidget {
  final String flag;
  final String title;
  final String subtitle;
  final String value;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.flag,
    required this.title,
    required this.subtitle,
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
              child: Center(
                child: Text(
                  flag,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.sora(
                      fontSize: 14,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                      color: selected ? context.textPri : context.textSec,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.sora(
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                      color: context.textHint,
                    ),
                  ),
                ],
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

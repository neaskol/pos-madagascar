import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/theme_ext.dart';
import '../bloc/settings_bloc.dart';

class FontScaleSheet extends StatelessWidget {
  final double currentScale;

  const FontScaleSheet({
    super.key,
    required this.currentScale,
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
                l10n.settingsFontSize,
                style: GoogleFonts.sora(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: context.textPri,
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            _FontScaleOption(
              title: l10n.settingsFontSizeSmall,
              scale: 0.85,
              selected: currentScale <= 0.9,
              onTap: () {
                context.read<SettingsBloc>().add(const UpdateFontScale(0.85));
                Navigator.pop(context);
              },
            ),

            _FontScaleOption(
              title: l10n.settingsFontSizeNormal,
              scale: 1.0,
              selected: currentScale > 0.9 && currentScale < 1.1,
              onTap: () {
                context.read<SettingsBloc>().add(const UpdateFontScale(1.0));
                Navigator.pop(context);
              },
            ),

            _FontScaleOption(
              title: l10n.settingsFontSizeLarge,
              scale: 1.2,
              selected: currentScale >= 1.1,
              onTap: () {
                context.read<SettingsBloc>().add(const UpdateFontScale(1.2));
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

class _FontScaleOption extends StatelessWidget {
  final String title;
  final double scale;
  final bool selected;
  final VoidCallback onTap;

  const _FontScaleOption({
    required this.title,
    required this.scale,
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
              child: Center(
                child: Text(
                  'Aa',
                  style: GoogleFonts.sora(
                    fontSize: 14 * scale,
                    fontWeight: FontWeight.w600,
                    color: selected ? context.accent : context.textSec,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.sora(
                  fontSize: 14 * scale,
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

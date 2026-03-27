import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/theme_ext.dart';

class SettingsTile extends StatelessWidget {
  final Widget? leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const SettingsTile({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  factory SettingsTile.switchTile({
    Widget? leading,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SettingsTile(
      leading: leading,
      title: title,
      subtitle: subtitle,
      trailing: _SettingsSwitch(value: value, onChanged: onChanged),
      onTap: () => onChanged(!value),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: 14,
        ),
        child: Row(
          children: [
            if (leading != null) ...[
              IconTheme(
                data: IconThemeData(
                  color: context.textSec,
                  size: 22,
                ),
                child: leading!,
              ),
              const SizedBox(width: AppSpacing.lg),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.sora(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: context.textPri,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: GoogleFonts.sora(
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                        color: context.textSec,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: AppSpacing.md),
              trailing!,
            ] else if (onTap != null) ...[
              const SizedBox(width: AppSpacing.md),
              Icon(
                Icons.chevron_right,
                color: context.textHint,
                size: 20,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SettingsSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsSwitch({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: value,
      onChanged: onChanged,
      activeColor: context.isDark
          ? const Color(0xFFB8965A) // darkAccent
          : const Color(0xFF5C4F3A), // lightAccent
    );
  }
}

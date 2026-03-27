import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/theme_ext.dart';

class SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const SettingsSection({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            AppSpacing.xl,
            AppSpacing.page,
            AppSpacing.sm,
          ),
          child: Text(
            title.toUpperCase(),
            style: GoogleFonts.sora(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.7,
              color: context.textHint,
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
          child: Column(
            children: [
              for (int i = 0; i < children.length; i++) ...[
                children[i],
                if (i < children.length - 1)
                  Divider(
                    height: 0.5,
                    indent: 56,
                    color: context.border,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

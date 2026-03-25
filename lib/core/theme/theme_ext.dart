import 'package:flutter/material.dart';
import 'app_colors.dart';

extension ThemeContextExt on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  Color get bg       => isDark ? AppColors.darkBackground    : AppColors.lightBackground;
  Color get surface  => isDark ? AppColors.darkSurface       : AppColors.lightSurface;
  Color get border   => isDark ? AppColors.darkBorder        : AppColors.lightBorder;
  Color get textPri  => isDark ? AppColors.darkTextPrimary   : AppColors.lightTextPrimary;
  Color get textSec  => isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
  Color get textHint => isDark ? AppColors.darkTextTertiary  : AppColors.lightTextTertiary;
  Color get accent   => isDark ? AppColors.darkAccent        : AppColors.lightAccent;
  Color get danger   => isDark ? AppColors.dangerDark        : AppColors.dangerLight;
  Color get warning  => isDark ? AppColors.warningDark       : AppColors.warningLight;
  Color get success  => isDark ? AppColors.successDark       : AppColors.successLight;
  Color get dangerBg => isDark ? AppColors.dangerBgDark      : AppColors.dangerBgLight;
  Color get warningBg => isDark ? AppColors.warningBgDark    : AppColors.warningBgLight;
  Color get successBg => isDark ? AppColors.successBgDark    : AppColors.successBgLight;
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_dimensions.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkBackground,
    colorScheme: const ColorScheme.dark(
      surface:       AppColors.darkSurface,
      primary:       AppColors.darkTextPrimary,
      secondary:     AppColors.darkAccent,
      onPrimary:     AppColors.darkBackground,
      onSurface:     AppColors.darkTextPrimary,
      outline:       AppColors.darkBorder,
      error:         AppColors.dangerDark,
    ),
    textTheme: _textTheme(AppColors.darkTextPrimary, AppColors.darkTextSecondary),
    cardTheme: CardThemeData(
      color: AppColors.darkSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: const BorderSide(color: AppColors.darkBorder, width: 0.5),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.darkBorder,
      thickness: 0.5,
      space: 0,
    ),
    inputDecorationTheme: _inputTheme(
      fill: AppColors.darkSurface,
      border: AppColors.darkBorder,
      borderFocus: AppColors.darkTextPrimary,
      hint: AppColors.darkTextTertiary,
      text: AppColors.darkTextPrimary,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkBackground,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: AppColors.darkTextPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(color: AppColors.darkTextPrimary),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.darkSurface,
      selectedItemColor: AppColors.darkTextPrimary,
      unselectedItemColor: AppColors.darkTextTertiary,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
    ),
  );

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.lightBackground,
    colorScheme: const ColorScheme.light(
      surface:       AppColors.lightSurface,
      primary:       AppColors.lightTextPrimary,
      secondary:     AppColors.lightAccent,
      onPrimary:     AppColors.lightBackground,
      onSurface:     AppColors.lightTextPrimary,
      outline:       AppColors.lightBorder,
      error:         AppColors.dangerLight,
    ),
    textTheme: _textTheme(AppColors.lightTextPrimary, AppColors.lightTextSecondary),
    cardTheme: CardThemeData(
      color: AppColors.lightSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: const BorderSide(color: AppColors.lightBorder, width: 0.5),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.lightBorder,
      thickness: 0.5,
      space: 0,
    ),
    inputDecorationTheme: _inputTheme(
      fill: AppColors.lightSurface,
      border: AppColors.lightBorder,
      borderFocus: AppColors.lightTextPrimary,
      hint: AppColors.lightTextTertiary,
      text: AppColors.lightTextPrimary,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.lightBackground,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: AppColors.lightTextPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(color: AppColors.lightTextPrimary),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.lightSurface,
      selectedItemColor: AppColors.lightTextPrimary,
      unselectedItemColor: AppColors.lightTextTertiary,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
    ),
  );

  static TextTheme _textTheme(Color primary, Color secondary) =>
    GoogleFonts.soraTextTheme().copyWith(
      displayLarge:   GoogleFonts.sora(color: primary,   fontSize: 32, fontWeight: FontWeight.w700, letterSpacing: -0.5),
      headlineMedium: GoogleFonts.sora(color: primary,   fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: -0.2),
      titleLarge:     GoogleFonts.sora(color: primary,   fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: -0.2),
      titleMedium:    GoogleFonts.sora(color: primary,   fontSize: 14, fontWeight: FontWeight.w500),
      bodyLarge:      GoogleFonts.sora(color: primary,   fontSize: 14, fontWeight: FontWeight.w400, height: 1.5),
      bodyMedium:     GoogleFonts.sora(color: secondary, fontSize: 13, fontWeight: FontWeight.w300, height: 1.5),
      labelSmall:     GoogleFonts.sora(color: secondary, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.7),
    );

  static InputDecorationTheme _inputTheme({
    required Color fill,
    required Color border,
    required Color borderFocus,
    required Color hint,
    required Color text,
  }) => InputDecorationTheme(
    filled: true,
    fillColor: fill,
    hintStyle: TextStyle(color: hint, fontSize: 14),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.input),
      borderSide: BorderSide(color: border, width: 0.5),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.input),
      borderSide: BorderSide(color: border, width: 0.5),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.input),
      borderSide: BorderSide(color: borderFocus, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.input),
      borderSide: const BorderSide(color: AppColors.dangerLight, width: 1),
    ),
  );
}

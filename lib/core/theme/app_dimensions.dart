class AppRadius {
  AppRadius._();
  static const double xs    = 4.0;
  static const double sm    = 8.0;
  static const double md    = 10.0;
  static const double input = 10.0;
  static const double card  = 14.0;
  static const double lg    = 16.0;
  static const double xl    = 20.0;
  static const double sheet = 24.0;
  static const double full  = 999.0;
}

class AppSpacing {
  AppSpacing._();
  static const double xs   = 4.0;
  static const double sm   = 8.0;
  static const double md   = 12.0;
  static const double lg   = 16.0;
  static const double xl   = 24.0;
  static const double xxl  = 32.0;
  static const double page = 16.0;  // padding horizontal standard
}

// ─── COMPATIBILITÉ AVEC LES ANCIENS ÉCRANS ───────────────────────────────────

class AppDimensions {
  AppDimensions._();

  // Spacing aliases
  static const double paddingSmall = AppSpacing.sm;
  static const double paddingMedium = AppSpacing.md;
  static const double paddingLarge = AppSpacing.lg;
  static const double paddingExtraLarge = AppSpacing.xl;

  static const double spacingSmall = AppSpacing.sm;
  static const double spacingMedium = AppSpacing.md;
  static const double spacingLarge = AppSpacing.lg;
  static const double spacingExtraLarge = AppSpacing.xl;

  // Radius aliases
  static const double radiusSmall = AppRadius.sm;
  static const double radiusMedium = AppRadius.md;
  static const double radiusLarge = AppRadius.lg;
  static const double radiusCard = AppRadius.card;
}

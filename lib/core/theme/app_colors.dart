import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ─── DARK MODE — Obsidian ─────────────────────────────────────────────────
  static const darkBackground    = Color(0xFF18130F); // fond principal
  static const darkSurface       = Color(0xFF241E19); // cartes, surfaces
  static const darkSurfaceHigh   = Color(0xFF2E2520); // hover, surfaces surélevées
  static const darkBorder        = Color(0xFF3A322A); // séparateurs, borders
  static const darkBorderStrong  = Color(0xFF4A4038); // borders accentuées
  static const darkTextPrimary   = Color(0xFFEDE5D8); // texte principal
  static const darkTextSecondary = Color(0xFF8A7A68); // texte secondaire
  static const darkTextTertiary  = Color(0xFF5A504A); // hints, labels désactivés
  static const darkAccent        = Color(0xFFB8965A); // or brûlé — totaux, highlights
  static const darkAccentMuted   = Color(0xFF7A6040); // accent atténué

  // ─── LIGHT MODE — Lin naturel ─────────────────────────────────────────────
  static const lightBackground    = Color(0xFFF2EBE0); // fond de page
  static const lightSurface       = Color(0xFFFFFFFF); // cartes, surfaces
  static const lightSurfaceHigh   = Color(0xFFF8F4ED); // hover, zones
  static const lightBorder        = Color(0xFFE0D5C5); // séparateurs
  static const lightBorderStrong  = Color(0xFFC8BAA8); // borders accentuées
  static const lightTextPrimary   = Color(0xFF1A1510); // texte principal
  static const lightTextSecondary = Color(0xFF8A7D6A); // texte secondaire
  static const lightTextTertiary  = Color(0xFFB8AC9C); // hints, labels désactivés
  static const lightAccent        = Color(0xFF5C4F3A); // brun grège — totaux, CTA secondaires
  static const lightAccentMuted   = Color(0xFF8A7D6A); // accent atténué

  // ─── SÉMANTIQUE — identiques dark & light ────────────────────────────────
  // Danger (rupture stock, erreur, crédit en retard)
  static const dangerDark        = Color(0xFFD4614A);
  static const dangerLight       = Color(0xFFC0392B);
  static const dangerBgDark      = Color(0xFF2A1510);
  static const dangerBgLight     = Color(0xFFFAEAE8);

  // Warning (stock bas, alerte non critique)
  static const warningDark       = Color(0xFFD4A030);
  static const warningLight      = Color(0xFFB8780A);
  static const warningBgDark     = Color(0xFF261E08);
  static const warningBgLight    = Color(0xFFFAF0DC);

  // Success (paiement confirmé, stock ok)
  static const successDark       = Color(0xFF6AAF7A);
  static const successLight      = Color(0xFF2E7D52);
  static const successBgDark     = Color(0xFF0E2018);
  static const successBgLight    = Color(0xFFE8F5EE);

  // ─── ALIAS POUR COMPATIBILITÉ ────────────────────────────────────────────
  // Utilisés par les anciens écrans, mapping vers les vraies couleurs

  // Texte
  static const textPrimary = lightTextPrimary;
  static const textSecondary = lightTextSecondary;
  static const textTertiary = lightTextTertiary;

  // Backgrounds
  static const backgroundPrimary = lightBackground;
  static const backgroundSecondary = lightSurface;

  // Borders
  static const borderLight = lightBorder;

  // Couleurs sémantiques simplifiées
  static const primary = lightAccent;
  static const danger = dangerLight;
  static const warning = warningLight;
  static const success = successLight;

  // Blanc
  static const white = Color(0xFFFFFFFF);
}

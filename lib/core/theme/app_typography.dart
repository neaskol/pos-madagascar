import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  AppTypography._();

  // ─── Titres ───────────────────────────────────────────────────────────────
  // Titres d'écrans (AppBar, headers)
  static TextStyle get screenTitle => GoogleFonts.sora(
    fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: -0.2,
  );

  // Titres de sections / cartes
  static TextStyle get sectionTitle => GoogleFonts.sora(
    fontSize: 14, fontWeight: FontWeight.w600,
  );

  // Section header uppercase (VENTES DU JOUR, TOTAL, etc.)
  static TextStyle get sectionLabel => GoogleFonts.sora(
    fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.7,
  );

  // ─── Corps ────────────────────────────────────────────────────────────────
  // Corps principal
  static TextStyle get body => GoogleFonts.sora(
    fontSize: 14, fontWeight: FontWeight.w400, height: 1.5,
  );

  // Corps secondaire / sous-titres
  static TextStyle get bodySmall => GoogleFonts.sora(
    fontSize: 13, fontWeight: FontWeight.w300, height: 1.5,
  );

  // ─── UI éléments ──────────────────────────────────────────────────────────
  // Labels formulaires
  static TextStyle get label => GoogleFonts.sora(
    fontSize: 12, fontWeight: FontWeight.w500,
  );

  // Hints / placeholders
  static TextStyle get hint => GoogleFonts.sora(
    fontSize: 13, fontWeight: FontWeight.w300,
  );

  // Bouton principal (PAYER, VALIDER...)
  static TextStyle get button => GoogleFonts.sora(
    fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.5,
  );

  // ─── Montants Ariary — l'or brûlé en Sora 700 est le moment fort ─────────
  // Lignes panier, prix produits
  static TextStyle get amount => GoogleFonts.sora(
    fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: -0.3,
  );

  // Total final à la caisse — 32px le plus visible
  static TextStyle get amountLarge => GoogleFonts.sora(
    fontSize: 32, fontWeight: FontWeight.w700, letterSpacing: -0.5,
  );

  // Monnaie rendue (après paiement cash)
  static TextStyle get amountChange => GoogleFonts.sora(
    fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.3,
  );

  // ─── ALIAS POUR COMPATIBILITÉ ────────────────────────────────────────────
  // Utilisés par les anciens écrans

  static TextStyle get heading3 => sectionTitle;
  static TextStyle get heading4 => sectionTitle;
  static TextStyle get body1 => body;
  static TextStyle get body2 => body;
  static TextStyle get caption => bodySmall;
}

# Système de design — POS Madagascar
## Palette validée : Obsidian (dark) × Lin naturel (light)

Charger ce fichier quand : création d'un écran, composant UI, couleurs, typographie, animations.

---

## Identité visuelle

**Police : Sora** (Google Fonts) — douce, premium, contraste 300→700 saisissant
**Mots-clés** : luxe discret, sobre, monochrome chaud, matière
**Références** : Hermès (chaleur), Aesop (sobriété), Revolut (modernité), Square (clarté)
**Anti-patterns absolus** :
- Zéro vert, bleu, rouge, orange dans l'UI standard (seulement pour les états sémantiques)
- Zéro gradient
- Zéro ombre portée (box-shadow)
- Zéro emoji comme icône — utiliser Lucide Icons (`lucide_flutter`)
- Zéro animation > 300ms (la caisse doit être rapide)
- Zéro dark mode ajouté après coup — les deux modes sont conçus ensemble

---

## AppColors — classe Dart complète

```dart
// lib/core/theme/app_colors.dart

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
}
```

---

## AppTheme — ThemeData complet

```dart
// lib/core/theme/app_theme.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkBackground,
    colorScheme: const ColorScheme.dark(
      background:    AppColors.darkBackground,
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
      background:    AppColors.lightBackground,
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
    GoogleFonts.interTextTheme().copyWith(
      displayLarge:  TextStyle(color: primary, fontSize: 32, fontWeight: FontWeight.w700),
      headlineMedium:TextStyle(color: primary, fontSize: 20, fontWeight: FontWeight.w600),
      titleLarge:    TextStyle(color: primary, fontSize: 16, fontWeight: FontWeight.w600),
      titleMedium:   TextStyle(color: primary, fontSize: 14, fontWeight: FontWeight.w500),
      bodyLarge:     TextStyle(color: primary, fontSize: 14, fontWeight: FontWeight.w400, height: 1.5),
      bodyMedium:    TextStyle(color: secondary, fontSize: 13, fontWeight: FontWeight.w400),
      labelSmall:    TextStyle(color: secondary, fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.7),
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
```

---

## AppRadius & AppSpacing

```dart
// lib/core/theme/app_dimensions.dart

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
```

---

## AppTypography

**Police choisie : Sora** (Google Fonts)
Douce, premium, contraste 300→700 saisissant. Harmonise parfaitement avec l'or brûlé.

```yaml
# pubspec.yaml
dependencies:
  google_fonts: ^6.2.1
```

```dart
// lib/core/theme/app_typography.dart

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
}
```

```dart
// Dans AppTheme — remplacer la méthode _textTheme :
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
```
```

---

## Composants Flutter — règles par mode

### Helper : accéder aux bonnes couleurs selon le mode actuel

```dart
// lib/core/theme/theme_ext.dart

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
}
```

---

### Bouton primaire (Payer, Valider, Créer)

```dart
// Dark  : fond #EDE5D8 (ivoire), texte #18130F (obsidian)
// Light : fond #1A1510 (noir brun), texte #F2EBE0 (lin)
// Hauteur : 52px · border-radius : 12px · texte 13px 600 · lettre-espacement 0.5

SizedBox(
  width: double.infinity,
  height: 52,
  child: ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: context.isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
      foregroundColor: context.isDark ? AppColors.darkBackground   : AppColors.lightBackground,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
      textStyle: AppTypography.button,
    ),
    onPressed: onPressed,
    child: Text(label),
  ),
)
```

### Bouton secondaire (Annuler, Retour)

```dart
// Dark  : bordure #3A322A, texte #EDE5D8, fond transparent
// Light : bordure #E0D5C5, texte #1A1510, fond transparent

OutlinedButton.styleFrom(
  foregroundColor: context.textPri,
  side: BorderSide(color: context.border, width: 1),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
  textStyle: AppTypography.button,
)
```

### Bouton destructif (Supprimer, Annuler vente)

```dart
// Fond : danger (selon mode) · texte blanc
ElevatedButton.styleFrom(
  backgroundColor: context.danger,
  foregroundColor: Colors.white,
  elevation: 0,
)
```

---

### Cartes (Card)

```dart
// Utiliser le CardTheme défini dans AppTheme — pas besoin de style inline
// border-radius 14px · border 0.5px · elevation 0 · fond surface

// Card avec padding standard :
Card(
  child: Padding(
    padding: const EdgeInsets.all(AppSpacing.lg),
    child: content,
  ),
)
```

### Cartes métriques (Dashboard)

```dart
// Dark  : fond #241E19 (surface), pas de border, radius 12
// Light : fond #F8F4ED (surfaceHigh), pas de border, radius 12
// Label 11px uppercase au-dessus · valeur 22-28px bold en dessous

Container(
  padding: const EdgeInsets.all(AppSpacing.lg),
  decoration: BoxDecoration(
    color: context.isDark ? AppColors.darkSurface : AppColors.lightSurfaceHigh,
    borderRadius: BorderRadius.circular(AppRadius.card),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: AppTypography.sectionLabel.copyWith(color: context.textHint)),
      const SizedBox(height: 6),
      Text(value, style: AppTypography.amount.copyWith(color: context.textPri)),
    ],
  ),
)
```

---

### Items de liste (ListView.builder)

```dart
// Dark  : fond transparent sur #18130F, divider #3A322A
// Light : fond blanc sur #F2EBE0, divider #E0D5C5
// Hauteur 60px · photo 44×44 border-radius 8 · swipe left = rouge

ListTile(
  contentPadding: const EdgeInsets.symmetric(
    horizontal: AppSpacing.lg,
    vertical: AppSpacing.sm,
  ),
  leading: ClipRRect(
    borderRadius: BorderRadius.circular(AppRadius.sm),
    child: image, // 44x44
  ),
  title: Text(name, style: AppTypography.body.copyWith(color: context.textPri)),
  subtitle: Text(sub, style: AppTypography.bodySmall.copyWith(color: context.textSec)),
  trailing: trailing,
)
// Séparateur :
Divider(height: 0.5, color: context.border, indent: 76)
```

---

### Badges de statut (pills)

```dart
// Shape pill · padding 3px vertical 10px horizontal · 11px weight 600
// Couleurs :
//   Payé / Ok      → successBg + success text
//   En attente     → fond brun/ivoire atténué + textSec
//   En retard      → dangerBg + danger text
//   Draft          → surface + textTertiary
//   En transit     → warningBg + warning text

Container(
  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
  decoration: BoxDecoration(
    color: bgColor,
    borderRadius: BorderRadius.circular(AppRadius.full),
  ),
  child: Text(label, style: TextStyle(
    fontSize: 11, fontWeight: FontWeight.w600, color: textColor,
  )),
)
```

---

### Montants à la caisse

```dart
// RÈGLE : les montants en Ariary sont le seul endroit où l'accent apparaît
// Dark  : accent or brûlé #B8965A
// Light : accent brun grège #5C4F3A
// Format obligatoire : NumberFormat('#,###', 'fr').format(amount) + ' Ar'

Text(
  '${NumberFormat('#,###', 'fr').format(amount)} Ar',
  style: AppTypography.amountLarge.copyWith(color: context.accent),
)

// Total final (bouton Payer) : même couleur mais plus grand encore (32px)
// Sous-totaux et lignes panier : textPrimary (pas accent)
```

---

### Bandeau offline

```dart
// Dark  : fond #261E08 (warningBgDark), texte #D4A030
// Light : fond #FAF0DC (warningBgLight), texte #B8780A
// Hauteur 36px · texte 12px · apparaît sous l'AppBar
// Animation : AnimatedContainer height 0→36 en 250ms

AnimatedContainer(
  duration: const Duration(milliseconds: 250),
  height: isOffline ? 36 : 0,
  color: context.isDark ? AppColors.warningBgDark : AppColors.warningBgLight,
  child: Center(
    child: Text(
      'Hors-ligne · données sauvegardées localement',
      style: TextStyle(
        fontSize: 12,
        color: context.warning,
        fontWeight: FontWeight.w500,
      ),
    ),
  ),
)
```

---

### Empty states

```dart
// Toujours : icône Lucide 48px (textTertiary) + titre (textPrimary) + description (textSecondary) + CTA
// Fond transparent — utilise le fond de page

Column(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    Icon(LucideIcons.packageOpen, size: 48, color: context.textHint),
    const SizedBox(height: AppSpacing.lg),
    Text(title, style: AppTypography.sectionTitle.copyWith(color: context.textPri)),
    const SizedBox(height: AppSpacing.sm),
    Text(description, style: AppTypography.bodySmall.copyWith(color: context.textSec),
         textAlign: TextAlign.center),
    const SizedBox(height: AppSpacing.xl),
    PrimaryButton(label: ctaLabel, onPressed: onCta),
  ],
)
```

---

### Shimmer loading

```dart
// Dark  : base #241E19, highlight #3A322A
// Light : base #EDE8DF, highlight #F5F0E8
// Package : shimmer

Shimmer.fromColors(
  baseColor:  context.isDark ? AppColors.darkSurface : const Color(0xFFEDE8DF),
  highlightColor: context.isDark ? AppColors.darkBorder : const Color(0xFFF5F0E8),
  child: skeletonWidget,
)
```

---

## Règles absolues pour l'écran caisse (POS)

```
1. Le bouton PAYER est toujours visible sans scroller
2. Le total final utilise l'accent (or ou brun) en 32px bold
3. Les sous-totaux et lignes du panier utilisent textPrimary (pas accent)
4. Le bouton PAYER : ivoire sur obsidian (dark) / noir sur lin (light) — jamais de couleur
5. Ajouter un item = 1 tap, pas 2
6. La quantité dans le panier est modifiable par un simple tap
7. Chaque ligne panier : nom + quantité + prix total ligne — lisible en 1 coup d'œil
8. Monnaie rendue : textPrimary bold 24px — bien visible après paiement cash
9. Tablette : 2 colonnes (grille 58% / panier 42%)
10. Smartphone : grille pleine largeur + panier en bottom panel fixe 240px
```

---

## Règles générales

- Zone de tap minimum **48×48px** sur tous les éléments interactifs
- Transitions : **200ms** pour les états (hover, focus) · **300ms** pour les navigations
- `prefers-reduced-motion` : désactiver toutes les animations si activé
- Icônes : **Lucide Icons** exclusivement (`lucide_flutter`)
- Tester sur **Android bas de gamme** (écran 5.5", densité 2x, fond sombre AMOLED)
- **Sora** se charge depuis Google Fonts au premier lancement — précharger dans `main()` : `await GoogleFonts.pendingFonts([GoogleFonts.sora()])`
- Tester en **plein soleil** (Lin naturel) : contraste textPrimary sur lightBackground ≥ 7:1 ✓

---

## Installation du skill UI UX Pro Max

Pour générer un design system complémentaire ou valider des choix UI :

```bash
# Installer une fois
npm install -g uipro-cli
uipro init --ai claude

# Générer des recommandations pour un écran spécifique
python3 .claude/skills/ui-ux-pro-max/scripts/search.py \
  "luxury minimal retail POS dark warm charcoal sora font" --design-system -p "POS Madagascar" -f markdown
```

Les recommendations du skill **ne remplacent pas** les tokens définis ici — elles complètent.
En cas de conflit : les tokens de ce fichier ont priorité.

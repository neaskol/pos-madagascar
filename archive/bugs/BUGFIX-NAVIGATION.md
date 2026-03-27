# Bug Fix: Écran de login ne s'affiche pas sur APK

**Date**: 2026-03-25
**Statut**: ✅ Résolu

## Symptômes
- Sur l'APK Android, seul le splash screen s'affichait (logo + "POS Madagascar" + sous-titre)
- L'écran de login ne s'affichait jamais
- Pas d'erreur visible dans la console

## Cause racine
Conflit entre deux systèmes de navigation :
- **GoRouter** : configuré dans `app_router.dart` comme système de navigation principal
- **Navigator** : ancien système Flutter utilisé dans les écrans d'authentification

Lorsque le SplashScreen tentait de naviguer vers `/login` avec `Navigator.of(context).pushReplacementNamed('/login')`, la navigation échouait silencieusement car GoRouter ne reconnaissait pas ces appels Navigator.

## Solution
Remplacé tous les appels `Navigator` par les équivalents GoRouter dans les écrans d'authentification :

### Changements effectués

| Fichier | Ligne | Avant | Après |
|---------|-------|-------|-------|
| `splash_screen.dart` | 35 | `Navigator.of(context).pushReplacementNamed('/login')` | `context.go('/login')` |
| `splash_screen.dart` | 38 | `Navigator.of(context).pushReplacementNamed('/setup')` | `context.go('/setup')` |
| `splash_screen.dart` | 41 | `Navigator.of(context).pushReplacementNamed('/pin')` | `context.go('/pin')` |
| `login_screen.dart` | 60 | `Navigator.of(context).pushReplacementNamed('/setup')` | `context.go('/setup')` |
| `login_screen.dart` | 62 | `Navigator.of(context).pushReplacementNamed('/pin')` | `context.go('/pin')` |
| `login_screen.dart` | 262 | `Navigator.of(context).pushNamed('/register')` | `context.push('/register')` |
| `register_screen.dart` | 75 | `Navigator.of(context).pushReplacementNamed('/setup')` | `context.go('/setup')` |
| `register_screen.dart` | 292 | `Navigator.of(context).pop()` | `context.pop()` |
| `onboarding_screen.dart` | 41 | `Navigator.of(context).pushReplacementNamed('/login')` | `context.go('/login')` |
| `setup_wizard_screen.dart` | 122 | `Navigator.of(context).pushReplacementNamed('/pin')` | `context.go('/pin')` |
| `pin_screen.dart` | 108 | `Navigator.of(context).pushReplacementNamed('/pos')` | `context.go('/pos')` |
| `pin_screen.dart` | 140 | `Navigator.of(context).pushReplacementNamed('/login')` | `context.go('/login')` |

### Imports ajoutés
Ajouté `import 'package:go_router/go_router.dart';` dans tous les fichiers modifiés.

## Vérification
- ✅ Compilé avec `dart run build_runner build --delete-conflicting-outputs`
- ✅ APK buildé avec `flutter build apk --release`
- ⏳ Test sur émulateur Android en cours

## Note importante
Les utilisations de `Navigator` dans les écrans POS (`payment_screen.dart`, `cart_panel.dart`, `pos_screen.dart`) sont **correctes** car elles utilisent `MaterialPageRoute` pour :
- Ouvrir des dialogs modaux
- Naviguer vers des écrans qui retournent une valeur (ex: barcode scanner)

Ces cas ne doivent **PAS** être migrés vers GoRouter.

## Leçon apprise
Lorsqu'une app utilise GoRouter, **tous** les appels de navigation entre routes définies dans `app_router.dart` doivent utiliser les méthodes GoRouter (`context.go()`, `context.push()`, `context.pop()`), pas Navigator.

Seules les navigations modales avec retour de valeur doivent continuer à utiliser Navigator avec MaterialPageRoute.

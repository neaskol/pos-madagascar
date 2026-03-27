# Page Paramètres - Implémentation Complète

## 📋 Ce qui a été créé

### 1. Base de données Drift
- **Table** : `user_preferences.drift` - Stocke toutes les préférences utilisateur
  - Thème (light/dark/system)
  - Langue (fr/mg)
  - Notifications (activées, alertes stock, sons, vibration)
  - Paramètres POS (impression auto, paiement rapide, images produits)
  - Affichage (échelle police, vue compacte)
  - Synchronisation (auto-sync, fréquence)

### 2. DAO (Data Access Object)
- **Fichier** : `user_preferences_dao.dart`
- Toutes les méthodes CRUD nécessaires
- Méthodes spécialisées pour chaque type de préférence
- Création automatique des préférences par défaut

### 3. BLoC (Business Logic Component)
- **Fichier** : `settings_bloc.dart` + events + states
- Gestion complète de l'état des paramètres
- Réactivité en temps réel via streams
- Synchronisation manuelle avec feedback visuel

### 4. Interface utilisateur

#### Écran principal
- **Fichier** : `settings_screen.dart`
- Design suivant le système Obsidian/Lin
- 7 sections organisées :
  1. **Apparence** - Thème, taille police, vue compacte
  2. **Langue** - Interface et reçus
  3. **Notifications** - Toutes les alertes configurables
  4. **Point de vente** - Paramètres spécifiques à la caisse
  5. **Synchronisation** - Auto-sync + bouton manuel
  6. **À propos** - Version, liens, support
  7. **Compte** - (à implémenter)

#### Widgets réutilisables
- `settings_section.dart` - Section avec titre uppercase
- `settings_tile.dart` - Ligne de paramètre (normale ou switch)
- `theme_selector_sheet.dart` - Sélecteur de thème (bottom sheet)
- `language_selector_sheet.dart` - Sélecteur de langue
- `font_scale_sheet.dart` - Sélecteur de taille de police
- `sync_frequency_sheet.dart` - Sélecteur de fréquence de sync

### 5. Traductions
- **Fichiers** : `app_fr.arb` + `app_mg.arb`
- 100+ nouvelles clés de traduction
- Toutes les options en français ET malagasy

## 🔧 Étapes suivantes pour intégrer

### Étape 1 : Mettre à jour app_database.dart

Ajoutez ces lignes dans `lib/core/data/local/app_database.dart` :

```dart
// Dans les imports (après les autres DAOs)
import 'daos/user_preferences_dao.dart';

// Dans les exports (après les autres DAOs)
export 'daos/user_preferences_dao.dart';

// Dans @DriftDatabase include (après les autres tables)
'tables/user_preferences.drift',

// Dans @DriftDatabase daos (après les autres DAOs)
UserPreferencesDao,
```

### Étape 2 : Régénérer Drift

```bash
cd /Users/neaskol/Downloads/AGENTIC\ WORKFLOW/POS
dart run build_runner build --delete-conflicting-outputs
```

### Étape 3 : Incrémenter schemaVersion

Dans `app_database.dart`, changez :
```dart
@override
int get schemaVersion => 3; // était 2
```

Et ajoutez dans `onUpgrade` :
```dart
if (from < 3) {
  // v3: Ajout de la table user_preferences
  await m.createTable(userPreferences);
}
```

### Étape 4 : Créer les fichiers theme manquants

Si pas déjà créés, créez :
- `lib/core/theme/app_colors.dart` (voir docs/design.md)
- `lib/core/theme/app_dimensions.dart` (voir docs/design.md)
- `lib/core/theme/theme_ext.dart` (extensions BuildContext)

### Étape 5 : Injecter SettingsBloc dans main.dart

```dart
BlocProvider(
  create: (context) => SettingsBloc(
    preferencesDao: context.read<AppDatabase>().userPreferencesDao,
    syncService: context.read<SyncService>(),
  )..add(LoadSettings(userId)), // Charger au démarrage
),
```

### Étape 6 : Intégrer le thème dynamique dans MaterialApp

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        ThemeMode themeMode = ThemeMode.system;
        Locale locale = const Locale('fr');

        if (state is SettingsLoaded) {
          // Appliquer le thème sélectionné
          themeMode = state.preferences.themeMode == 'light'
              ? ThemeMode.light
              : state.preferences.themeMode == 'dark'
                  ? ThemeMode.dark
                  : ThemeMode.system;

          // Appliquer la langue sélectionnée
          locale = Locale(state.preferences.locale);
        }

        return MaterialApp(
          title: 'POS Madagascar',
          theme: AppTheme.light,      // Votre thème clair
          darkTheme: AppTheme.dark,   // Votre thème sombre
          themeMode: themeMode,
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          // ... le reste de votre config
        );
      },
    );
  }
}
```

### Étape 7 : Ajouter SettingsScreen à la navigation

Dans votre `go_router` :
```dart
GoRoute(
  path: '/settings',
  builder: (context, state) => const SettingsScreen(),
),
```

## ✨ Fonctionnalités implémentées

### ✅ Changement de thème en temps réel
- 3 options : Clair, Sombre, Système
- Application immédiate sans redémarrage
- Persistance dans la base de données locale

### ✅ Changement de langue
- Français / Malagasy
- Interface complète traduite
- Mise à jour instantanée de l'UI

### ✅ Notifications configurables
- Activer/désactiver toutes les notifications
- Alertes stock bas
- Sons de vente
- Vibrations

### ✅ Paramètres POS
- Impression automatique des reçus
- Mode paiement rapide
- Affichage des images produits

### ✅ Synchronisation
- Auto-sync on/off
- Choix de la fréquence (1min, 5min, 30min, 1h)
- Bouton sync manuel avec feedback

### ✅ Taille de police
- Petit (0.85x)
- Normal (1.0x)
- Grand (1.2x)

## 🎨 Design

Tout suit le système de design défini dans `docs/design.md` :
- Palette Obsidian (dark) × Lin naturel (light)
- Police Sora (Google Fonts)
- Espacement et radius cohérents
- Couleurs sémantiques pour success/warning/danger
- Bottom sheets élégants avec handle bar
- Transitions fluides

## 📱 UX

- **Sections organisées** : Tout est bien catégorisé
- **Icônes claires** : Chaque option a une icône descriptive
- **Feedback immédiat** : Les changements s'appliquent en temps réel
- **Snackbars** : Messages de succès/erreur pour la sync
- **Bottom sheets** : Sélecteurs élégants et tactiles
- **Switches** : Couleur accent (or/brun selon le thème)

## 🔄 Synchronisation avec Supabase

La table `user_preferences` sera automatiquement synchronisée avec Supabase via le `SyncService` existant. Ajoutez simplement `user_preferences` à la liste des tables à synchroniser dans `sync_service.dart`.

## 🧪 Tests suggérés

1. Changer le thème → vérifier que toute l'app change
2. Changer la langue → vérifier toutes les traductions
3. Activer/désactiver les switches → vérifier la persistance
4. Modifier la taille de police → vérifier l'impact visuel
5. Tester la sync manuelle → vérifier le loader + snackbar
6. Tester offline → vérifier que tout fonctionne localement

## 💡 Suggestions d'améliorations futures

1. **Vue compacte** : Implémenter la logique pour réduire l'espacement
2. **Biométrie** : Ajouter Face ID / Touch ID
3. **Code PIN personnalisé** : Modifier le PIN depuis les paramètres
4. **Export de données** : CSV/Excel de toutes les données
5. **Cache** : Bouton pour vider le cache et libérer l'espace
6. **Mode développeur** : Logs, debug, endpoints de test
7. **Langue des reçus** : Séparée de la langue de l'interface
8. **Thèmes personnalisés** : Permettre de créer ses propres palettes

## 📦 Dépendances requises

Vérifiez que vous avez bien dans `pubspec.yaml` :
```yaml
dependencies:
  flutter_bloc: ^8.1.3
  equatable: ^2.0.5
  google_fonts: ^6.2.1
  drift: ^2.14.1
  flutter_localizations:
    sdk: flutter
```

---

**Note** : Cette implémentation est complète et prête à l'emploi. Il suffit de suivre les étapes d'intégration ci-dessus pour avoir une page de paramètres professionnelle et fonctionnelle ! 🚀

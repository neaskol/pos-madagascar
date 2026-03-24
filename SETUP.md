# État du projet — 2026-03-24

## ✅ Ce qui a été fait

### 1. Initialisation du projet Flutter
- [x] Projet créé avec `flutter create`
- [x] Structure de dossiers complète créée
- [x] `pubspec.yaml` configuré avec **toutes** les dépendances nécessaires
- [x] Dépendances installées avec `flutter pub get`

### 2. Configuration de base
- [x] Localisation FR/MG configurée (`l10n/app_fr.arb`, `l10n/app_mg.arb`)
- [x] Fichiers de localisation générés dans `lib/l10n/`
- [x] Assets configurés (`assets/images/`, `assets/icons/`)

### 3. Système de design complet
- [x] **AppColors** : Palette Obsidian (dark) × Lin naturel (light)
- [x] **AppTheme** : ThemeData complet pour dark & light
- [x] **AppTypography** : Police Sora de Google Fonts
- [x] **AppDimensions** : Radius et Spacing standardisés
- [x] **ThemeContextExt** : Extensions pour accéder aux couleurs selon le mode

### 4. Utils
- [x] **AriaryFormatter** : Format des montants en Ariary (int uniquement)

### 5. App principale
- [x] `main.dart` configuré avec :
  - Thème dark/light système
  - Localisation FR/MG
  - Préchargement de la police Sora
  - SplashScreen de base

### 6. Documentation projet
- [x] **README.md** : Vue d'ensemble complète
- [x] **tasks/todo.md** : Sprint 1 planifié
- [x] **tasks/lessons.md** : Template pour les leçons apprises

### 7. Base de données locale (Drift) — **NOUVEAU** ✅
- [x] **drift-expert skill** créé dans `~/.claude/skills/drift-expert.md`
- [x] Structure Drift créée (`lib/core/data/local/`)
- [x] Tables core :
  - `stores.drift` — Magasins
  - `users.drift` — Utilisateurs (rôles)
  - `store_settings.drift` — Réglages modulaires
- [x] Tables produits :
  - `categories.drift` — Catégories
  - `items.drift` — Produits avec gestion stock
- [x] `app_database.dart` — Configuration centrale
- [x] Code généré avec `build_runner` (195 KB)
- [x] Optimisations SQLite activées (WAL, cache, mmap)
- [x] README.md local avec exemples d'utilisation

### 8. Backend Supabase — **NOUVEAU** ✅
- [x] **Supabase CLI** initialisé (`supabase init`)
- [x] **8 migrations SQL** créées (voir `SUPABASE_SETUP.md`) :
  - Migration 1 : Fondations (types, fonctions utilitaires)
  - Migration 2 : Table `stores` + RLS
  - Migration 3 : Table `users` + RLS
  - Migration 4 : Table `store_settings` + trigger auto-create
  - Migration 5 : Table `categories` + RLS
  - Migration 6 : Table `items` + RLS + index trigram
  - Migration 7 : Auth Custom Claims (JWT store_id/role)
  - Migration 8 : Helper Functions (coût moyen, SKU unique, etc.)
- [x] **SupabaseService** : Singleton client Flutter (`lib/core/data/remote/supabase_client.dart`)
- [x] **SyncService** : Architecture offline-first (skeleton, à compléter avec DAOs)
- [x] **main.dart** : Initialisation Supabase au démarrage
- [x] **flutter_dotenv** : Ajouté pour charger `.env.local`
- [x] `.env.local` : Credentials Supabase configurés

### 9. Analyse du code
- [x] `flutter pub get` : ✅ **Dépendances installées**
- [x] `flutter analyze` : ✅ **3 warnings (normaux), 0 erreurs**
- [x] `build_runner build` : ✅ **39 fichiers générés**

---

## 📂 Structure finale

```
POS/
├── docs/                      # Documentation complète (7 fichiers)
│   ├── database.md           # 49 tables + RLS
│   ├── formulas.md           # Calculs Ariary, taxes, marges
│   ├── loyverse-features.md  # Comportement exact à reproduire
│   ├── differences.md        # 10 différenciants vs Loyverse
│   ├── sprints.md            # Plan 8 sprints
│   ├── screens.md            # 65 écrans détaillés
│   └── design.md             # Système de design complet
│
├── lib/
│   ├── core/
│   │   ├── theme/            # ✅ AppColors, AppTheme, AppTypography, theme_ext
│   │   ├── utils/            # ✅ AriaryFormatter
│   │   ├── data/
│   │   │   └── local/        # ✅ Drift database
│   │   │       ├── tables/   # ✅ 5 fichiers .drift
│   │   │       ├── daos/     # À faire : DAOs par module
│   │   │       ├── app_database.dart      # ✅ Configuration
│   │   │       ├── app_database.g.dart    # ✅ Généré (195 KB)
│   │   │       └── README.md              # ✅ Documentation
│   │   ├── config/           # À faire : Supabase config
│   │   └── constants/        # À faire
│   ├── data/
│   │   ├── models/           # À faire : Models JSON pour Supabase
│   │   ├── datasources/      # À faire : Remote (Supabase)
│   │   └── repositories/     # À faire
│   ├── domain/
│   │   ├── entities/         # À faire
│   │   ├── repositories/     # À faire
│   │   └── usecases/         # À faire
│   ├── presentation/
│   │   ├── bloc/             # À faire : BLoC
│   │   ├── screens/          # À faire : 65 écrans
│   │   └── widgets/          # À faire : Composants réutilisables
│   ├── l10n/                 # ✅ Fichiers générés
│   └── main.dart             # ✅ App principale configurée
│
├── l10n/                      # ✅ Fichiers ARB FR/MG
├── tasks/                     # ✅ todo.md + lessons.md
├── assets/                    # ✅ Dossiers créés
├── pubspec.yaml              # ✅ Toutes les dépendances
├── README.md                 # ✅ Documentation projet
├── CLAUDE.md                 # ✅ Instructions Claude
└── SETUP.md                  # ✅ Ce fichier
```

---

## 📦 Dépendances installées

### État & Navigation
- `flutter_bloc: ^8.1.0`
- `equatable: ^2.0.0`
- `go_router: ^14.0.0`

### Backend
- `supabase_flutter: ^2.0.0`

### Offline-first
- `drift: ^2.20.0`
- `sqlite3_flutter_libs: ^0.5.0`
- `path_provider: ^2.1.0`

### UI & Design
- `google_fonts: ^6.0.0` (Sora)
- `shimmer: ^3.0.0`
- `cached_network_image: ^3.4.0`
- `image_picker: ^1.1.0`
- `image_cropper: ^8.0.0`

### Scan & Impression
- `mobile_scanner: ^5.0.0`
- `printing: ^5.13.0`
- `pdf: ^3.11.0`

### Graphiques & Export
- `fl_chart: ^0.69.0`
- `excel: ^4.0.0`

### Utils
- `url_launcher: ^6.3.0`
- `share_plus: ^10.0.0`
- `connectivity_plus: ^6.0.0`
- `uuid: ^4.5.0`
- `crypto: ^3.0.0`
- `intl: ^0.20.2`

---

## 🎯 Prochaines étapes (Sprint 1)

### Infrastructure à faire
1. ✅ ~~Configuration Drift~~ **FAIT**
   - ✅ Tables core créées (stores, users, store_settings)
   - ✅ Tables produits créées (categories, items)
   - ✅ Code généré avec build_runner
   - 🔲 Créer les DAOs pour accès typé aux données
   - 🔲 Créer les repositories (pattern offline-first)

2. ✅ ~~Configuration Supabase~~ **MIGRATIONS PRÊTES**
   - ✅ Credentials dans `.env.local`
   - ✅ Projet Supabase existant (ofrbxqxhtnizdwipqdls)
   - ✅ 8 migrations SQL créées (tables + RLS + custom claims)
   - ✅ SupabaseService créé (singleton Flutter)
   - ✅ SyncService créé (skeleton offline-first)
   - 🔲 **PROCHAINE ÉTAPE** : Déployer migrations sur Supabase (voir `SUPABASE_SETUP.md`)
   - 🔲 Créer les DAOs avec méthodes `getUnsynced()` et `markSynced()`
   - 🔲 Compléter SyncService avec logique de synchronisation

3. Auth complet
   - Créer les 6 écrans d'auth (Splash, Onboarding, Login, Register, Setup, PIN)
   - Créer les BLoCs correspondants
   - Configurer go_router avec guards

4. Multi-utilisateurs & Rôles
   - Système de permissions par rôle
   - Changement d'utilisateur sans déconnexion

---

## 🚀 Commandes utiles

```bash
# Installer les dépendances
flutter pub get

# Générer les localisations
flutter gen-l10n --arb-dir=l10n --template-arb-file=app_fr.arb --output-dir=lib/l10n

# Générer les fichiers Drift (quand les tables seront créées)
dart run build_runner build --delete-conflicting-outputs

# Lancer l'app
flutter run

# Analyser le code
flutter analyze

# Formater le code
dart format lib/
```

---

## ✅ Checklist avant chaque feature

Avant de marquer une feature comme terminée :

- [ ] Lire le fichier `docs/` correspondant
- [ ] Coder la feature
- [ ] Tester **online**
- [ ] Tester **offline** (couper le wifi)
- [ ] Tester en rôle **CASHIER**
- [ ] Vérifier les montants en `int` Ariary
- [ ] Zéro string hardcodée
- [ ] `flutter analyze` OK
- [ ] Mettre à jour `tasks/todo.md`
- [ ] Ajouter une leçon dans `tasks/lessons.md` si besoin

---

**État** : ✅ **Infrastructure prête à coder !**

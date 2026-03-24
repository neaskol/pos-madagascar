# POS Madagascar 🇲🇬

**Système de caisse moderne et gratuit pour Madagascar**

Reproduit [Loyverse](https://loyverse.com) exactement, puis le **dépasse** avec 10 différenciants majeurs.

---

## 🎯 Pourquoi POS Madagascar ?

Loyverse est le POS #1 mondial (1M+ utilisateurs, gratuit), mais a **3 problèmes critiques** à Madagascar :

1. **Offline limité** — remboursements et nouveaux clients bloqués sans internet
2. **Multi-users payant** — $25/mois par employé supplémentaire
3. **Pas de Mobile Money** — MVola et Orange Money inexistants

---

## 🚀 Les 10 différenciants

| # | Feature | Loyverse | POS Madagascar |
|---|---------|----------|----------------|
| 1 | **Offline 100%** | Remboursements bloqués | Tout fonctionne offline |
| 2 | **Multi-users** | $25/mois | **Gratuit** |
| 3 | **Vente à crédit** | ❌ Inexistant | ✅ Complet avec rappels |
| 4 | **Mobile Money** | ❌ | ✅ MVola + Orange Money |
| 5 | **Interface Malagasy** | ❌ | ✅ Première app POS en Malagasy |
| 6 | **Coût en %** | ❌ Montant fixe seulement | ✅ Pourcentage possible |
| 7 | **Photos stock** | ❌ Caisse seulement | ✅ Partout (liste, rapports) |
| 8 | **Forced modifiers** | ❌ Optionnels seulement | ✅ Obligatoires configurables |
| 9 | **Inventaire avancé** | $25/mois | **Gratuit** |
| 10 | **Export inventaire** | ❌ Impossible | ✅ PDF + Excel |

---

## 📚 Documentation

Toute la documentation est dans le dossier [`docs/`](docs/) :

- **[`database.md`](docs/database.md)** : schéma complet (49 tables), RLS, Drift
- **[`formulas.md`](docs/formulas.md)** : calculs taxes, coût moyen pondéré, marges
- **[`loyverse-features.md`](docs/loyverse-features.md)** : comportement exact à reproduire
- **[`differences.md`](docs/differences.md)** : gaps Loyverse + nos différenciants
- **[`sprints.md`](docs/sprints.md)** : plan en 8 sprints (3 phases)
- **[`screens.md`](docs/screens.md)** : 65 écrans détaillés
- **[`design.md`](docs/design.md)** : système de design complet (Obsidian × Lin naturel + Sora)

---

## 🛠️ Stack technique

| Couche | Technologie |
|--------|-------------|
| Framework | Flutter 3.x + Dart |
| State | flutter_bloc |
| Navigation | go_router |
| Backend | Supabase (PostgreSQL + Auth + Storage + Realtime) |
| **Offline** | **Drift (SQLite local)** — offline-first |
| Graphiques | fl_chart |
| Scan | mobile_scanner |
| Impression | ESC/POS Bluetooth |
| Localisation | flutter_localizations + intl |
| Paiements | MVola API + Orange Money API |

---

## 🎨 Design

**Palette** : Obsidian (dark) × Lin naturel (light)
**Police** : [Sora](https://fonts.google.com/specimen/Sora) (Google Fonts) — douce, premium
**Icônes** : Lucide Icons
**Règles absolues** :
- Zéro gradient, zéro box-shadow
- Montants en `int` Ariary (jamais `double`)
- Format : `1 500 000 Ar` (espaces, pas de virgules)

---

## 📂 Structure du projet

```
lib/
├── core/
│   ├── theme/          # AppColors, AppTheme, AppTypography, theme_ext
│   ├── config/         # Configuration Supabase, Drift
│   ├── utils/          # Formatters (Ariary), helpers
│   └── constants/
├── data/
│   ├── models/         # Models Drift + JSON
│   ├── datasources/    # LocalDataSource (Drift) + RemoteDataSource (Supabase)
│   └── repositories/   # Repository pattern
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
└── presentation/
    ├── bloc/           # BLoC (state management)
    ├── screens/        # 65 écrans
    └── widgets/        # Composants réutilisables
```

---

## 🚀 Démarrer

```bash
# Installer les dépendances
flutter pub get

# Générer les fichiers de localisation
flutter gen-l10n --arb-dir=l10n --template-arb-file=app_fr.arb --output-dir=lib/l10n

# Lancer l'app
flutter run

# Générer les fichiers Drift (après création des tables)
dart run build_runner build --delete-conflicting-outputs
```

---

## ✅ Checklist avant chaque commit

- [ ] Fonctionne **online**
- [ ] Fonctionne **offline** (couper wifi et tester)
- [ ] Testé en rôle **CASHIER** (pas seulement ADMIN)
- [ ] Montants en `int` Ariary, format correct
- [ ] Zéro string hardcodée dans les widgets
- [ ] Logs d'activité enregistrés si action importante
- [ ] `tasks/todo.md` mis à jour

---

## 📝 Conventions

### Ariary
```dart
// TOUJOURS int, jamais double
int price = 150000;
String formatted = AriaryFormatter.format(price); // "150 000 Ar"
```

### Localisation
```dart
// JAMAIS de string hardcodée
Text(AppLocalizations.of(context)!.appName)
```

### Offline-first
```dart
// Toujours écrire dans Drift EN PREMIER, Supabase en arrière-plan
await localDataSource.insertSale(sale);
syncService.syncSale(sale); // async, non bloquant
```

---

## 🎯 Sprint actuel

**Sprint 1 — Fondation** (en cours)

Voir [`tasks/todo.md`](tasks/todo.md) pour les tâches détaillées.

---

## 📄 Licence

Propriétaire — Tous droits réservés.

---

**Fait avec ❤️ pour Madagascar**

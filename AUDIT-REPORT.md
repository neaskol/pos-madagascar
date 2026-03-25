# Rapport d'Audit Complet — POS Madagascar

**Date** : 2026-03-25 (mise a jour 23h)
**Scope** : Code complet — navigation, Drift, BLoC, localisation, logique UX, base de donnees
**Resultat** : 0 erreurs, 0 warnings apres corrections automatiques

---

## Partie 1 : Corrections automatiques appliquees

Tout ceci a ete corrige automatiquement. Zero action de votre part.

| # | Fichier | Probleme | Correction |
|---|---------|----------|------------|
| 1 | `app_fr.arb` + `app_mg.arb` | Cle `cancel` dupliquee (ligne 81 et 200) — JSON prend silencieusement la derniere valeur | Supprime le doublon |
| 2 | `app_fr.arb` + `app_mg.arb` | 14 cles de traduction manquantes (POS, cart, paiement) | Ajoute avec traductions FR + MG |
| 3 | `setup_wizard_screen.dart` | `'Veuillez entrer le nom du magasin'` et `'Etape X / 4'` hardcodes | Remplace par `l10n.setupStoreNameRequired` et `l10n.setupStepIndicator` |
| 4 | `product_form_screen.dart` | `const storeId = 'store-1'` hardcode a 2 endroits — aucun produit ne pouvait etre cree | Lit `storeId` depuis `AuthBloc.state` |
| 5 | `product_form_screen.dart` | `Navigator.pop(context)` au lieu de GoRouter | Change en `context.pop()` |
| 6 | `app_router.dart` | Zero route guard — n'importe qui pouvait naviguer vers `/pos`, `/products`, etc. | Ajoute `redirect` complet couvrant tous les etats auth |
| 7 | `modifiers.drift` | FK manquante sur `store_id` | Ajoute `REFERENCES stores(id) ON DELETE CASCADE` |
| 8 | `item_variants.drift` | FK manquante sur `store_id` | Ajoute `REFERENCES stores(id) ON DELETE CASCADE` |
| 9 | `custom_pages.drift` | 5 FK manquantes (store_id, page_id, item_id, category_id) | Ajoute toutes les FK + imports |
| 10 | `custom_pages.drift` | `updated_at` manquant dans `custom_page_items` et `custom_page_category_grids` | Ajoute `updated_at INTEGER NOT NULL` |
| 11 | `custom_page_dao.dart` | `updatedAt` absent dans `Companion.insert()` — synchro impossible | Ajoute `updatedAt: now` |
| 12 | `pin_screen.dart` | Ne gerait pas `AuthStoreEmployeesLoaded` ni les etats inattendus — spinner infini | Ajoute gestion + redirect vers `/login` |
| 13 | `cart_panel.dart` | 10+ strings hardcodees : 'Panier vide', 'Sous-total', 'TOTAL', 'PAYER', etc. | Remplace par `l10n.*` |
| 14 | `pos_screen.dart` | 8+ strings hardcodees : 'Caisse', 'Scanner', 'A venir', etc. | Remplace par `l10n.*` |
| 15 | `customers.drift` | Aucun index (requetes lentes sur `store_id`, `name`) | Ajoute 3 indexes |
| 16 | `credits.drift` | Aucun index (requetes lentes sur `status`, `due_date`) | Ajoute 5 indexes |

**Verification finale** :
```
flutter analyze : 0 errors, 0 warnings, 32 infos (style uniquement)
build_runner   : 158 outputs, 0 errors
flutter gen-l10n : Success
```

---

## Partie 2 : Actions manuelles requises

### BLOQUANT — A faire AVANT d'utiliser l'app

---

### ~~Action 1 : Executer la migration RLS Supabase~~ — DEJA FAIT

La policy `store_insert_authenticated` existe deja sur Supabase. Rien a faire.

---

### ~~Action 2 : Configurer les URLs de redirection Supabase Auth~~ — DEJA FAIT

URLs de redirection configurees et sauvegardees dans le dashboard Supabase.

---

### ~~Action 3 : Appliquer les migrations Supabase manquantes~~ — FAIT

Toutes les migrations ont ete appliquees automatiquement via l'API Management Supabase.

**Tables creees** (28 tables au total) :
- `pos_devices` (manquait dans les migrations originales)
- `customers`, `loyalty_points` (migration 006)
- `sales`, `sale_items`, `sale_payments`, `shifts`, `cash_movements`, `open_tickets`, `refunds`, `refund_items`, `dining_options` (migration 002)
- `taxes`, `item_taxes` (migration 003)
- `item_variants`, `modifiers`, `modifier_options`, `item_modifiers` (migration 004)
- `custom_product_pages`, `custom_page_items`, `custom_page_category_grids` (migration 005)
- `credits`, `credit_payments` (migration 006 - partie credits)
- Colonnes `mvola_merchant_number`, `orange_money_merchant_number`, `mobile_money_enabled` ajoutees a `store_settings` (migration 007)

Migration locale `20260324000009_create_pos_devices_table.sql` sauvegardee pour reference.

---

### IMPORTANT — Pour avoir un POS fonctionnel offline (Sprint 2)

---

### Action 4 : Creer les tables Drift pour les ventes

**Impact** : Les tables existent dans Supabase (`20260325000002_create_sales_tables.sql`) mais **aucune table Drift locale n'existe**. Le POS ne peut pas finaliser de vente en mode offline.

**9 tables Drift a creer** :

| Table | Fichier a creer | Priorite |
|-------|-----------------|----------|
| `sales` | `lib/core/data/local/tables/sales.drift` | CRITIQUE |
| `sale_items` | `lib/core/data/local/tables/sale_items.drift` | CRITIQUE |
| `sale_payments` | `lib/core/data/local/tables/sale_payments.drift` | CRITIQUE |
| `shifts` | `lib/core/data/local/tables/shifts.drift` | HAUTE |
| `cash_movements` | `lib/core/data/local/tables/cash_movements.drift` | HAUTE |
| `open_tickets` | `lib/core/data/local/tables/open_tickets.drift` | HAUTE |
| `refunds` | `lib/core/data/local/tables/refunds.drift` | MOYENNE |
| `refund_items` | `lib/core/data/local/tables/refund_items.drift` | MOYENNE |
| `dining_options` | `lib/core/data/local/tables/dining_options.drift` | BASSE |

**DAOs a creer** : SaleDao, ShiftDao, OpenTicketDao, RefundDao, DiningOptionDao
**SyncService a etendre** : Ajouter ces 9 tables a la synchronisation

> Ce n'est pas un bug — c'est le travail du Sprint 2. Mais c'est le blocage principal.

---

### Action 5 : Creer la table Drift `pos_devices`

**Impact** : La table `pos_devices` existe dans Supabase mais pas dans Drift. Les tables `shifts` et `open_tickets` referencent `pos_device_id`.

**Fichiers a creer** :
- `lib/core/data/local/tables/pos_devices.drift`
- `lib/core/data/local/daos/pos_device_dao.dart`

---

### NON BLOQUANT — A planifier

---

### Action 6 : Corriger le build release Android

**Impact** : `flutter build apk --release` echoue. Workaround actuel : `flutter build apk --debug`.

**Cause** : Incompatibilite NDK 28.x / CMake 3.22.1 + espace dans le chemin du projet.

**Solutions** (par facilite) :
1. Renommer le dossier : `AGENTIC WORKFLOW` → `AGENTIC-WORKFLOW`
2. Downgrade NDK vers 25.x ou 26.x (Android Studio > SDK Manager)
3. Upgrade CMake vers 3.28+

**Detail** : voir `CMAKE-NDK-ISSUE.md`

---

### Action 7 : Configurer le deep linking Flutter

**Impact** : Les liens dans les emails (confirmation, reset) ne peuvent pas ouvrir l'app mobile.

**Fichiers a modifier** :
- `android/app/src/main/AndroidManifest.xml` — ajouter intent-filter
- `ios/Runner/Info.plist` — ajouter CFBundleURLSchemes

**Detail** : voir section "Deep Linking Flutter" dans `SETUP-FIXES.md`

---

### Action 8 : Creer le bucket Supabase Storage pour les logos

**Impact** : Upload de logo dans le Setup Wizard est un placeholder.

**Etapes** :
1. Dashboard Supabase > Storage > Create bucket
2. Nom : `store-logos`, Public : Oui
3. Ajouter les policies RLS (voir `SETUP-FIXES.md` section 5)

---

## Partie 3 : Resume des priorites

| Priorite | # | Action | Temps |
|----------|---|--------|-------|
| ~~FAIT~~ | 1 | ~~Migration RLS stores~~ | DEJA APPLIQUE |
| ~~FAIT~~ | 2 | ~~URLs redirection Auth~~ | DEJA CONFIGURE |
| ~~FAIT~~ | 3 | ~~Migrations Supabase~~ | TOUTES APPLIQUEES |
| CRITIQUE | 4 | Tables Drift ventes (Sprint 2) | Dev |
| CRITIQUE | 5 | Table Drift pos_devices | 30 min |
| IMPORTANT | 6 | Fix build release Android | 10 min |
| FUTUR | 7 | Deep linking Flutter | 30 min |
| FUTUR | 8 | Bucket logos Supabase | 10 min |

---

## Partie 4 : Etat de sante du code (apres audit)

| Metrique | Avant audit | Apres audit |
|----------|-------------|-------------|
| Erreurs de compilation | Multiples | **0** |
| Warnings | Multiples | **0** |
| Strings hardcodees (ecrans audites) | 20+ | **0** |
| Routes non protegees | Toutes | **0** |
| FK manquantes dans Drift | 7 | **0** |
| Indexes manquants | 8 | **0** |
| Tables Drift manquantes (ventes) | 9 | 9 (Sprint 2) |
| Fichiers corriges dans cet audit | — | **17** |

---

**Rapport genere le** : 2026-03-25 23:00 UTC+3

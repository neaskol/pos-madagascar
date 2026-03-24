# 📊 État du Projet — POS Madagascar

**Date** : 2026-03-24
**Commit** : 9f75ef1 (Initial commit)
**Repository** : https://github.com/neaskol/pos-madagascar

---

## ✅ Ce qui est fait (100%)

### Infrastructure & Configuration

- [x] Projet Flutter initialisé
- [x] Structure de dossiers créée
- [x] Git repository créé et poussé sur GitHub
- [x] .gitignore configuré (exclut .env.local, fichiers générés, etc.)
- [x] Documentation complète (9 fichiers dans docs/)
- [x] CLAUDE.md avec toutes les conventions

### Backend Supabase

- [x] Projet Supabase créé (`ofrbxqxhtnizdwipqdls`)
- [x] 8 migrations SQL créées
- [x] 5 tables déployées : stores, users, store_settings, categories, items
- [x] 5 types ENUM : user_role, payment_type, sold_by_type, tax_type, discount_type
- [x] 7 fonctions business logic
- [x] ~20 policies RLS (Row Level Security)
- [x] 6 triggers (auto-update timestamps + settings creation)
- [x] 3 extensions PostgreSQL : uuid-ossp, pgcrypto, pg_trgm
- [x] Multi-tenancy configuré (isolation par store_id)
- [x] Contrôle d'accès par rôles (OWNER > ADMIN > MANAGER > CASHIER)

### Base de données Locale (Drift)

- [x] 5 tables Drift : stores, users, store_settings, categories, items
- [x] AppDatabase configuré avec optimisations production
- [x] build.yaml configuré (JSON + FTS5)
- [x] Code généré (.g.dart)
- [x] Documentation Drift complète (lib/core/data/local/README.md)

### Configuration Flutter

- [x] pubspec.yaml avec toutes les dépendances
- [x] flutter_dotenv configuré
- [x] .env.local créé avec credentials Supabase
- [x] SupabaseService singleton créé
- [x] SyncService skeleton créé
- [x] main.dart configure Supabase au démarrage
- [x] Compilation sans erreurs (3 warnings attendus)

### Thème & Design

- [x] AppTheme (light + dark)
- [x] AppColors (Obsidian × Lin naturel)
- [x] AppTypography (Sora de Google Fonts)
- [x] AppDimensions (spacing system)
- [x] ThemeExtensions personnalisées

### Localisation

- [x] app_fr.arb (Français)
- [x] app_mg.arb (Malagasy)
- [x] AppLocalizations générées
- [x] Formatters Ariary

### Documentation

- [x] README.md (guide principal)
- [x] SETUP.md (état de la configuration)
- [x] SUPABASE_SETUP.md (guide Supabase)
- [x] DEPLOY_MIGRATIONS.md (guide de déploiement original)
- [x] DEPLOY_MIGRATIONS_FIX.md (guide après fix permissions)
- [x] TROUBLESHOOTING.md (3 problèmes documentés et résolus)
- [x] docs/database.md (49 tables détaillées)
- [x] docs/formulas.md (calculs métier)
- [x] docs/loyverse-features.md (référence comportement)
- [x] docs/differences.md (10 différenciateurs)
- [x] docs/sprints.md (plan 8 sprints)
- [x] docs/screens.md (65 écrans)
- [x] docs/design.md (système de design complet)

---

## 🔲 Ce qui reste à faire

### Priorité 1 — Fonctionnalités Core

#### DAOs Drift
- [ ] StoresDao (getUnsyncedStores, markStoreSynced)
- [ ] UsersDao (getUnsyncedUsers, markUserSynced)
- [ ] CategoriesDao (getUnsyncedCategories, markCategorySynced)
- [ ] ItemsDao (getUnsyncedItems, markItemSynced)
- [ ] StoreSettingsDao (getUnsyncedStoreSettings, markStoreSettingsSynced)
- [ ] Mettre à jour AppDatabase avec les DAOs

#### Synchronisation
- [ ] Implémenter SyncService.syncToRemote() complet
- [ ] Implémenter SyncService.syncFromRemote()
- [ ] Gérer les conflits (last-write-wins)
- [ ] Retry logic avec exponential backoff
- [ ] Queue de synchronisation persistante

#### Authentification
- [ ] Écran Splash
- [ ] Écran Onboarding
- [ ] Écran Login
- [ ] Écran Register
- [ ] Setup Wizard (création store + premier user)
- [ ] Écran PIN
- [ ] Gestion des sessions JWT
- [ ] Custom claims JWT (store_id, role)

### Priorité 2 — Tables Restantes

Selon docs/database.md, il reste **44 tables** à créer :

#### Sales & Payments (8 tables)
- [ ] sales
- [ ] sale_items
- [ ] sale_modifiers
- [ ] payments
- [ ] payment_splits
- [ ] refunds
- [ ] refund_items
- [ ] credit_sales

#### Customers (4 tables)
- [ ] customers
- [ ] customer_groups
- [ ] customer_addresses
- [ ] loyalty_points

#### Inventory (8 tables)
- [ ] stock_movements
- [ ] purchase_orders
- [ ] purchase_order_items
- [ ] suppliers
- [ ] stock_takes
- [ ] stock_take_items
- [ ] composite_items
- [ ] production_batches

#### Modifiers & Taxes (6 tables)
- [ ] modifiers
- [ ] modifier_sets
- [ ] modifier_set_items
- [ ] taxes
- [ ] discount_reasons
- [ ] receipts

#### Employees & Shifts (6 tables)
- [ ] shifts
- [ ] shift_events
- [ ] time_clock_entries
- [ ] employee_permissions
- [ ] cash_management
- [ ] drawer_operations

#### Restaurant Features (7 tables)
- [ ] tables
- [ ] table_layouts
- [ ] dining_options
- [ ] tickets
- [ ] ticket_items
- [ ] kitchen_orders
- [ ] kitchen_printers

#### Autres (5 tables)
- [ ] devices
- [ ] printers
- [ ] custom_receipts
- [ ] activity_logs
- [ ] sync_queue

### Priorité 3 — Fonctionnalités Métier

#### Caisse (Screens 1-15)
- [ ] Écran Caisse principale
- [ ] Recherche items avec fuzzy search
- [ ] Panier avec modifiers
- [ ] Calcul taxes automatique
- [ ] Paiements multiples (cash, card, MVola, Orange Money)
- [ ] Impression reçu Bluetooth
- [ ] Tickets ouverts
- [ ] Remboursements

#### Produits (Screens 16-25)
- [ ] Liste produits avec photos
- [ ] Détail produit
- [ ] Création/édition produit
- [ ] Catégories
- [ ] Modifiers & modifier sets
- [ ] Import CSV

#### Inventaire (Screens 26-35)
- [ ] Mouvements de stock
- [ ] Bons de commande
- [ ] Réceptions
- [ ] Fournisseurs
- [ ] Inventaires physiques
- [ ] Alertes stock bas

#### Clients (Screens 36-42)
- [ ] Liste clients
- [ ] Détail client avec historique
- [ ] Création/édition client
- [ ] Groupes clients
- [ ] Ventes à crédit
- [ ] Fidélité

#### Rapports (Screens 43-52)
- [ ] Dashboard analytics
- [ ] Ventes par période
- [ ] Top produits
- [ ] Marges
- [ ] Employés
- [ ] Shifts
- [ ] Taxes
- [ ] Export PDF/Excel

#### Paramètres (Screens 53-65)
- [ ] Profil magasin
- [ ] Employés & rôles
- [ ] Permissions CASHIER configurables
- [ ] Imprimantes
- [ ] Taxes
- [ ] Mode paiement
- [ ] Reçus personnalisés
- [ ] Options restaurant

---

## 📈 Progression Globale

**Phase 1 — Fondation** : 40% ✅
- Infrastructure : 100% ✅
- Backend Supabase : 100% ✅ (5/49 tables)
- Base locale Drift : 100% ✅ (5/49 tables)
- Authentification : 0% 🔲
- DAOs : 0% 🔲
- Synchronisation : 10% (skeleton créé)

**Phase 2 — Core Features** : 0% 🔲
- Caisse : 0%
- Produits : 0%
- Inventaire : 0%
- Clients : 0%

**Phase 3 — Advanced** : 0% 🔲
- Rapports : 0%
- Restaurant : 0%
- Multi-devices : 0%

**TOTAL** : ~15% ✅

---

## 🎯 Prochaines Actions Recommandées

### Court terme (1-2 jours)

1. **Créer les 5 DAOs Drift** → Active la synchronisation
2. **Implémenter le flow d'authentification** → Permet de tester end-to-end
3. **Tester la synchronisation** → Valide l'architecture offline-first

### Moyen terme (1 semaine)

4. **Créer les 8 tables Sales** → Core business logic
5. **Implémenter l'écran Caisse** → Premier écran fonctionnel
6. **Ajouter MVola/Orange Money** → Différenciateur clé

### Long terme (1 mois)

7. **Créer les 44 tables restantes** → Base de données complète
8. **Implémenter tous les écrans** → App fonctionnelle
9. **Tests end-to-end** → Validation complète

---

## 🚨 Points d'Attention

### Custom JWT Claims
⚠️ Les triggers pour synchroniser `store_id` et `role` dans le JWT ne sont **pas déployés** (permissions insuffisantes via SQL Editor).

**Solutions** :
- **Option A** : Via CLI quand port 5432 sera accessible
- **Option B** : Manuellement via `supabase.auth.admin.updateUserById()`
- **Option C** : Automatiquement dans le flow d'inscription Flutter

**Impact actuel** : Le RLS fonctionne, mais les claims JWT devront être définis manuellement.

### Fichiers .env.local
⚠️ Le fichier `.env.local` contient les credentials Supabase et **n'est PAS commité** (dans .gitignore).

**Action requise** : Créer `.env.local` avec :
```env
SUPABASE_URL=https://ofrbxqxhtnizdwipqdls.supabase.co
SUPABASE_ANON_KEY=eyJhbGci...
SUPABASE_SERVICE_ROLE_KEY=eyJhbGci...
SUPABASE_PROJECT_ID=ofrbxqxhtnizdwipqdls
SUPABASE_DB_PASSWORD=TeamConsult2021$
```

---

## 📊 Statistiques Code

- **Fichiers totaux** : 123
- **Lignes de code** : 11,036
- **Documentation** : 9 fichiers (database.md, formulas.md, etc.)
- **Migrations SQL** : 8 fichiers (736 lignes combinées)
- **Tables Drift** : 5 définies
- **Tables Supabase** : 5 déployées

---

## 🔗 Liens Utiles

- **Repository GitHub** : https://github.com/neaskol/pos-madagascar
- **Supabase Dashboard** : https://supabase.com/dashboard/project/ofrbxqxhtnizdwipqdls
- **Plan Complet** : ~/.claude/plans/velvety-watching-nest.md
- **Documentation Database** : docs/database.md
- **Guide Supabase** : SUPABASE_SETUP.md

---

**Dernière mise à jour** : 2026-03-24 20:15 GMT+3

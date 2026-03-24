# Configuration Supabase — POS Madagascar

**Date** : 2026-03-24
**Statut** : ✅ Infrastructure créée — Migrations SQL prêtes à déployer

---

## ✅ Ce qui a été fait

### 1. Initialisation Supabase CLI
- ✅ `supabase init` exécuté
- ✅ Dossier `supabase/` créé avec `config.toml`
- ✅ Dossier `supabase/migrations/` créé

### 2. Migrations SQL créées (8 fichiers)

#### Migration 1: Fondations (`20260324000001_core_schema_setup.sql`)
- Extensions PostgreSQL activées : `uuid-ossp`, `pgcrypto`, `pg_trgm`
- Types ENUM créés :
  - `user_role` : OWNER, ADMIN, MANAGER, CASHIER
  - `payment_type` : cash, card, mvola, orange_money, other
  - `sold_by_type` : piece, weight
  - `tax_type` : added, included
  - `discount_type` : percentage, amount
- Fonctions utilitaires :
  - `update_updated_at_column()` — Auto-trigger pour updated_at
  - `auth.store_id()` — Extrait store_id du JWT
  - `auth.user_role()` — Extrait role du JWT
  - `auth.is_owner_or_admin()` — Vérifie si OWNER/ADMIN
  - `auth.is_manager_or_above()` — Vérifie si OWNER/ADMIN/MANAGER

#### Migration 2: Table `stores` (`20260324000002_create_stores_table.sql`)
- 10 colonnes (id, name, address, phone, logo_url, currency, timezone, created_at, updated_at, deleted_at)
- 2 index (deleted_at, created_by)
- RLS activé avec 4 politiques :
  1. SELECT : Voir uniquement son magasin
  2. UPDATE : OWNER/ADMIN seulement
  3. INSERT : Service role (pour inscription)
  4. SOFT DELETE : OWNER seulement

#### Migration 3: Table `users` (`20260324000003_create_users_table.sql`)
- 12 colonnes (id, store_id, name, email, phone, role, pin_hash, email_verified, active, etc.)
- 5 index (store_id, email, role, active, deleted_at)
- RLS activé avec 5 politiques :
  1. SELECT : Voir collègues du même magasin
  2. INSERT : OWNER/ADMIN seulement
  3. UPDATE (own profile) : Chaque user peut modifier son profil (sauf role/store_id)
  4. UPDATE (by admin) : OWNER/ADMIN peuvent modifier tous les users
  5. SOFT DELETE : OWNER seulement

#### Migration 4: Table `store_settings` (`20260324000004_create_store_settings_table.sql`)
- 14 colonnes (store_id PK, 11 toggles booléens, cash_rounding_unit, receipt_footer)
- Modules Loyverse-compatibles :
  - shifts_enabled, time_clock_enabled, open_tickets_enabled
  - predefined_tickets_enabled, kitchen_printers_enabled
  - customer_display_enabled, dining_options_enabled
  - low_stock_notifications, negative_stock_alerts
  - weight_barcodes_enabled
- RLS activé avec 3 politiques
- **Trigger auto-create** : Création automatique lors de l'insertion dans `stores`

#### Migration 5: Table `categories` (`20260324000005_create_categories_table.sql`)
- 8 colonnes (id, store_id, name, color, sort_order, created_at, updated_at, deleted_at)
- 3 index (store_id, sort_order, deleted_at)
- Contrainte : UNIQUE (store_id, name, deleted_at)
- RLS activé avec 4 politiques (SELECT tous, INSERT/UPDATE MANAGER+, DELETE ADMIN+)

#### Migration 6: Table `items` (`20260324000006_create_items_table.sql`)
- 22 colonnes (produits complets avec gestion stock)
- **DIFFÉRENCIATEUR vs Loyverse** : `cost_is_percentage` (coût en % du prix)
- Prix en INTEGER (Ariary, zéro décimale)
- 8 index dont :
  - GIN trigram sur `name` (recherche floue)
  - Index sur `low_stock` (WHERE in_stock <= low_stock_threshold)
- RLS activé avec 4 politiques (SELECT tous, INSERT/UPDATE MANAGER+, DELETE ADMIN+)

#### Migration 7: Auth Custom Claims (`20260324000007_auth_custom_claims.sql`)
- **CRITIQUE pour RLS**
- Fonction `public.handle_new_user()` :
  - Trigger sur `auth.users` (BEFORE INSERT/UPDATE)
  - Injecte `store_id` et `role` dans `raw_app_meta_data` du JWT
- Fonction `public.sync_user_claims()` :
  - Trigger sur `public.users` (AFTER UPDATE)
  - Met à jour JWT quand role ou store_id change

#### Migration 8: Helper Functions (`20260324000008_helper_functions.sql`)
- `get_next_receipt_number(store_id)` — Génère numéro reçu : YYYYMMDD-0001
- `calculate_average_cost()` — Coût moyen pondéré (formule docs/formulas.md)
- `is_sku_unique()` — Vérifie unicité SKU dans le magasin

### 3. Configuration Flutter

#### Fichier 1: `lib/core/data/remote/supabase_client.dart`
- Singleton SupabaseService
- Initialisation avec credentials depuis `.env.local`
- Auth flow PKCE configuré

#### Fichier 2: `lib/core/data/remote/sync_service.dart`
- Architecture offline-first (Drift = source de vérité)
- Skeleton implémenté (sera complété avec les DAOs)
- Pattern : Write to Drift → Sync to Supabase → Mark as synced

#### Fichier 3: `lib/main.dart`
- Initialisation Supabase au démarrage
- Chargement `.env.local` via `flutter_dotenv`

#### Fichier 4: `pubspec.yaml`
- Ajout `flutter_dotenv: ^5.1.0`
- Asset `.env.local` configuré

### 4. Analyse du code
- ✅ `flutter pub get` : Dépendances installées
- ✅ `flutter analyze` : **3 warnings** (normaux, pas d'erreurs)

---

## 🔲 Prochaines étapes

### Étape 1: Déployer les migrations sur Supabase

#### ✅ Statut CLI Supabase (mise à jour)

- ✅ **CLI authentifié avec succès** via Personal Access Token
- ✅ **Projet lié** : `ofrbxqxhtnizdwipqdls`
- ❌ **`supabase db push` échoue** : Erreur réseau (firewall bloque port PostgreSQL 5432)

**Erreur rencontrée** :
```
dial tcp 54.247.26.119:5432: connect: no route to host
```

#### 🚀 Solution : Déployer via Dashboard Supabase

**Fichier créé** : `supabase/combined_migration.sql` (736 lignes, contient les 8 migrations)

**Instructions simplifiées** :

1. **Ouvrir** : `supabase/combined_migration.sql`
2. **Copier tout le contenu** (Cmd+A, Cmd+C)
3. **Aller sur** : https://supabase.com/dashboard/project/ofrbxqxhtnizdwipqdls/sql
4. **SQL Editor** → **New query** → **Coller** → **Run** (Cmd+Enter)

**Guide complet** : Voir `DEPLOY_MIGRATIONS.md` pour :
- Instructions détaillées
- 7 tests de vérification post-déploiement
- Test d'isolation multi-tenant

### Étape 2: Vérifier les migrations

#### Test 1: Tables créées
```sql
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;
```
**Attendu** : 5 tables (stores, users, store_settings, categories, items)

#### Test 2: RLS activé
```sql
SELECT tablename, rowsecurity
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY tablename;
```
**Attendu** : Toutes les tables avec `rowsecurity = true`

#### Test 3: Politiques RLS
```sql
SELECT tablename, policyname, cmd
FROM pg_policies
WHERE schemaname = 'public'
ORDER BY tablename, policyname;
```
**Attendu** : ~20 policies au total

#### Test 4: Fonctions créées
```sql
SELECT routine_name, routine_type
FROM information_schema.routines
WHERE routine_schema = 'public'
OR routine_schema = 'auth'
ORDER BY routine_name;
```
**Attendu** : Toutes les fonctions définies dans les migrations

### Étape 3: Tester l'isolation multi-tenant

Créer 2 stores de test et vérifier qu'un user ne voit que son magasin :

```sql
BEGIN;

INSERT INTO stores (id, name) VALUES
  ('11111111-1111-1111-1111-111111111111', 'Store A'),
  ('22222222-2222-2222-2222-222222222222', 'Store B');

INSERT INTO auth.users (id, email) VALUES
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'user-a@store-a.com'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'user-b@store-b.com');

INSERT INTO users (id, store_id, name, role) VALUES
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '11111111-1111-1111-1111-111111111111', 'User A', 'ADMIN'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '22222222-2222-2222-2222-222222222222', 'User B', 'ADMIN');

INSERT INTO items (store_id, name, price) VALUES
  ('11111111-1111-1111-1111-111111111111', 'Item A', 1000),
  ('22222222-2222-2222-2222-222222222222', 'Item B', 2000);

-- Simuler JWT pour User A
SET LOCAL request.jwt.claims = '{"sub": "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa", "app_metadata": {"store_id": "11111111-1111-1111-1111-111111111111", "role": "ADMIN"}}';

-- User A doit voir uniquement Item A
SELECT COUNT(*) = 1 AS test_passed FROM items;

ROLLBACK;
```

**Attendu** : `test_passed = TRUE`

### Étape 4: Créer les DAOs Drift

Pour compléter la synchronisation, il faut créer les DAOs avec les méthodes manquantes :

```dart
// lib/core/data/local/daos/stores_dao.dart
@DriftAccessor(include: {'tables/stores.drift'})
class StoresDao extends DatabaseAccessor<AppDatabase> with _$StoresDaoMixin {
  StoresDao(AppDatabase db) : super(db);

  // Requêtes pour sync
  Future<List<Store>> getUnsyncedStores() =>
      (select(stores)..where((s) => s.synced.equals(false))).get();

  Future<void> markStoreSynced(String storeId) =>
      (update(stores)..where((s) => s.id.equals(storeId)))
          .write(const StoresCompanion(synced: Value(true)));

  // Autres requêtes...
}
```

Répéter pour :
- `users_dao.dart`
- `categories_dao.dart`
- `items_dao.dart`
- `store_settings_dao.dart`

Ensuite mettre à jour `app_database.dart` pour inclure les DAOs.

### Étape 5: Tester la synchronisation Flutter

```dart
void testOfflineSync() async {
  final db = AppDatabase();
  final sync = SyncService(db, SupabaseService.client);

  // 1. Créer item localement
  await db.into(db.items).insert(ItemsCompanion(
    storeId: Value('store-uuid'),
    name: Value('Test Item'),
    price: Value(1000),
    synced: Value(false),
  ));

  // 2. Synchroniser
  await sync.syncToRemote();

  // 3. Vérifier dans Supabase
  final remoteItem = await SupabaseService.client
      .from('items')
      .select()
      .eq('name', 'Test Item')
      .single();

  print('✅ Sync OK: $remoteItem');
}
```

---

## 📋 Checklist de validation

- [ ] Migrations appliquées sur Supabase
- [ ] 5 tables créées (stores, users, store_settings, categories, items)
- [ ] RLS activé sur toutes les tables
- [ ] ~20 policies RLS créées
- [ ] Fonctions et triggers créés
- [ ] Test d'isolation multi-tenant réussi
- [ ] Test de permissions par rôle réussi
- [ ] DAOs Drift créés
- [ ] Synchronisation Drift ↔ Supabase testée

---

## 🚨 Problèmes connus

### 1. Link CLI Supabase a échoué

**Erreur** :
```
Your account does not have the necessary privileges to access this endpoint
```

**Solution** : Utiliser le Dashboard Supabase pour appliquer les migrations manuellement (Option A ci-dessus)

**Cause probable** : Permissions insuffisantes sur le compte Supabase ou token expiré

### 2. Warnings dans `flutter analyze`

**Warnings** :
1. `override_on_non_overriding_member` dans `app_database.dart:50` — Normal, généré par Drift
2. `unused_field` pour `_localDb` et `_supabase` dans `sync_service.dart` — Normal, seront utilisés quand DAOs seront créés

**Action** : Aucune, ces warnings disparaîtront automatiquement

---

## 📂 Fichiers créés

### Migrations SQL (8 fichiers)
```
supabase/migrations/
├── 20260324000001_core_schema_setup.sql
├── 20260324000002_create_stores_table.sql
├── 20260324000003_create_users_table.sql
├── 20260324000004_create_store_settings_table.sql
├── 20260324000005_create_categories_table.sql
├── 20260324000006_create_items_table.sql
├── 20260324000007_auth_custom_claims.sql
└── 20260324000008_helper_functions.sql
```

### Code Flutter (3 fichiers)
```
lib/core/data/remote/
├── supabase_client.dart   — Singleton Supabase
└── sync_service.dart       — Service de synchronisation (skeleton)

lib/main.dart               — Initialisation Supabase au démarrage
```

### Configuration (2 fichiers)
```
pubspec.yaml               — Ajout flutter_dotenv
supabase/config.toml       — Configuration Supabase CLI
```

---

## 📖 Références

- **Plan complet** : `~/.claude/plans/velvety-watching-nest.md`
- **Documentation base de données** : `docs/database.md`
- **Credentials** : `.env.local`
- **Supabase Dashboard** : https://supabase.com/dashboard/project/ofrbxqxhtnizdwipqdls

---

**Prochaine grande étape** : Créer les DAOs Drift pour activer la synchronisation complète

# 🚀 Guide de Déploiement des Migrations Supabase

**Date** : 2026-03-24
**Statut** : Prêt à déployer (problème de connexion CLI résolu en utilisant le Dashboard)

---

## 🔥 Problème rencontré avec CLI

La commande `supabase db push` échoue avec :
```
dial tcp 54.247.26.119:5432: connect: no route to host
```

**Cause** : Firewall/réseau bloque le port PostgreSQL 5432.

**Solution** : Déployer manuellement via le Dashboard Supabase.

---

## ✅ Instructions de Déploiement (5 minutes)

### Étape 1 : Ouvrir le SQL Editor

1. Va sur : **https://supabase.com/dashboard/project/ofrbxqxhtnizdwipqdls**
2. Clique sur **"SQL Editor"** dans le menu de gauche

### Étape 2 : Copier le SQL

Le fichier `supabase/combined_migration.sql` contient **toutes les 8 migrations** (736 lignes).

**Ouvre ce fichier et copie tout son contenu.**

### Étape 3 : Exécuter dans le Dashboard

1. Dans le SQL Editor, clique sur **"New query"**
2. **Colle** tout le contenu de `combined_migration.sql`
3. Clique sur **"Run"** (ou Cmd/Ctrl + Enter)

### Étape 4 : Vérifier le Succès

Si tout s'est bien passé, tu verras :
```
Success. No rows returned.
```

---

## 🧪 Vérifications Post-Déploiement

### Test 1 : Tables créées

Exécute cette requête dans le SQL Editor :

```sql
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;
```

**Attendu** : 5 tables
- `categories`
- `items`
- `store_settings`
- `stores`
- `users`

---

### Test 2 : RLS activé

```sql
SELECT tablename, rowsecurity
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY tablename;
```

**Attendu** : Toutes les tables avec `rowsecurity = true`

---

### Test 3 : Politiques RLS créées

```sql
SELECT tablename, policyname, cmd
FROM pg_policies
WHERE schemaname = 'public'
ORDER BY tablename, policyname;
```

**Attendu** : ~20 policies au total

---

### Test 4 : Extensions activées

```sql
SELECT extname, extversion
FROM pg_extension
WHERE extname IN ('uuid-ossp', 'pgcrypto', 'pg_trgm');
```

**Attendu** : 3 extensions activées

---

### Test 5 : Types ENUM créés

```sql
SELECT typname
FROM pg_type
WHERE typname IN ('user_role', 'payment_type', 'sold_by_type', 'tax_type', 'discount_type');
```

**Attendu** : 5 types ENUM

---

### Test 6 : Fonctions créées

```sql
SELECT routine_name, routine_type
FROM information_schema.routines
WHERE routine_schema IN ('public', 'auth')
  AND routine_name IN (
    'update_updated_at_column',
    'store_id',
    'user_role',
    'is_owner_or_admin',
    'is_manager_or_above',
    'handle_new_user',
    'sync_user_claims',
    'get_next_receipt_number',
    'calculate_average_cost',
    'is_sku_unique'
  )
ORDER BY routine_name;
```

**Attendu** : 10 fonctions

---

### Test 7 : Triggers créés

```sql
SELECT trigger_name, event_object_table, action_timing, event_manipulation
FROM information_schema.triggers
WHERE trigger_schema = 'public'
ORDER BY trigger_name;
```

**Attendu** : ~7 triggers (update_updated_at sur chaque table + create_default_store_settings + auth triggers)

---

## 🧪 Test d'Isolation Multi-Tenant

Pour vérifier que le RLS fonctionne correctement, exécute ce test :

```sql
BEGIN;

-- Créer 2 stores de test
INSERT INTO stores (id, name) VALUES
  ('11111111-1111-1111-1111-111111111111', 'Store A'),
  ('22222222-2222-2222-2222-222222222222', 'Store B');

-- Créer 2 users dans auth.users
INSERT INTO auth.users (id, email, encrypted_password, email_confirmed_at) VALUES
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'user-a@store-a.com', crypt('password', gen_salt('bf')), NOW()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'user-b@store-b.com', crypt('password', gen_salt('bf')), NOW());

-- Créer 2 users dans public.users
INSERT INTO users (id, store_id, name, role) VALUES
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '11111111-1111-1111-1111-111111111111', 'User A', 'ADMIN'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '22222222-2222-2222-2222-222222222222', 'User B', 'ADMIN');

-- Créer 2 items (1 par store)
INSERT INTO items (store_id, name, price) VALUES
  ('11111111-1111-1111-1111-111111111111', 'Item A', 1000),
  ('22222222-2222-2222-2222-222222222222', 'Item B', 2000);

-- Simuler JWT pour User A
SET LOCAL request.jwt.claims = '{"sub": "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa", "app_metadata": {"store_id": "11111111-1111-1111-1111-111111111111", "role": "ADMIN"}}';

-- User A doit voir uniquement Item A
SELECT COUNT(*) = 1 AS test_passed FROM items;

-- Nettoyer
ROLLBACK;
```

**Attendu** : `test_passed = TRUE`

---

## 📋 Checklist de Validation

Après avoir exécuté les migrations, vérifie :

- [ ] ✅ Migrations SQL exécutées sans erreur
- [ ] ✅ 5 tables créées (stores, users, store_settings, categories, items)
- [ ] ✅ RLS activé sur toutes les tables
- [ ] ✅ ~20 policies RLS créées
- [ ] ✅ 3 extensions PostgreSQL activées (uuid-ossp, pgcrypto, pg_trgm)
- [ ] ✅ 5 types ENUM créés
- [ ] ✅ 10 fonctions créées
- [ ] ✅ ~7 triggers créés
- [ ] ✅ Test d'isolation multi-tenant réussi

---

## 🎯 Prochaines Étapes

Une fois les migrations déployées :

1. **Créer les DAOs Drift** → Pour activer la synchronisation
2. **Implémenter SyncService** → Compléter lib/core/data/remote/sync_service.dart
3. **Tester la synchronisation** → Drift ↔ Supabase

---

## 📖 Références

- **Plan complet** : `~/.claude/plans/velvety-watching-nest.md`
- **Migrations SQL** : `supabase/migrations/`
- **Fichier combiné** : `supabase/combined_migration.sql`
- **Documentation détaillée** : `SUPABASE_SETUP.md`
- **Supabase Dashboard** : https://supabase.com/dashboard/project/ofrbxqxhtnizdwipqdls

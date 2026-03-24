# 🚀 Guide de Déploiement des Migrations — VERSION CORRIGÉE

**Date** : 2026-03-24
**Problème résolu** : `permission denied for schema auth`

---

## ⚠️ Problème Rencontré

**Erreur** :
```
ERROR: 42501: permission denied for schema auth
```

**Cause** : Le fichier `combined_migration.sql` contient des fonctions dans le schéma `auth` (lignes 45-72) qui nécessitent des privilèges de super-utilisateur. Le SQL Editor standard n'a pas ces permissions.

**Solution** : Utiliser `combined_migration_safe.sql` qui évite le schéma `auth`.

---

## ✅ ÉTAPE 1 : Déployer les Migrations (Version Sécurisée)

### Instructions

1. **Ouvrir le fichier** : `supabase/combined_migration_safe.sql`
2. **Copier tout le contenu** (Cmd+A, Cmd+C)
3. **Aller sur** : https://supabase.com/dashboard/project/ofrbxqxhtnizdwipqdls/sql
4. **SQL Editor** → **New query** → **Coller** → **Run** (Cmd+Enter)

### Qu'est-ce qui a changé ?

| Fichier Original | Fichier Safe | Changement |
|-----------------|--------------|------------|
| `auth.store_id()` | `get_jwt_store_id()` | Fonction dans `public` au lieu de `auth` |
| `auth.user_role()` | `get_jwt_user_role()` | Fonction dans `public` au lieu de `auth` |
| `auth.is_owner_or_admin()` | `is_owner_or_admin()` | Fonction dans `public` au lieu de `auth` |
| `auth.is_manager_or_above()` | `is_manager_or_above()` | Fonction dans `public` au lieu de `auth` |
| Triggers sur `auth.users` | ❌ RETIRÉS | Seront ajoutés plus tard via CLI |

### Pourquoi ça fonctionne maintenant ?

- **Toutes les fonctions sont dans le schéma `public`** (permission accordée par défaut)
- **Utilise `current_setting('request.jwt.claims', true)::jsonb`** au lieu de `auth.jwt()`
- **SECURITY DEFINER** sur les fonctions pour garantir l'accès au JWT

---

## ✅ ÉTAPE 2 : Vérifier le Succès

### Test 1 : Tables créées

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

### Test 2 : Types ENUM créés

```sql
SELECT typname
FROM pg_type
WHERE typname IN ('user_role', 'payment_type', 'sold_by_type', 'tax_type', 'discount_type')
ORDER BY typname;
```

**Attendu** : 5 types

---

### Test 3 : Fonctions créées (schéma public)

```sql
SELECT routine_name
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name IN (
    'get_jwt_store_id',
    'get_jwt_user_role',
    'is_owner_or_admin',
    'is_manager_or_above',
    'calculate_average_cost',
    'get_next_receipt_number',
    'is_sku_unique'
  )
ORDER BY routine_name;
```

**Attendu** : 7 fonctions

---

### Test 4 : RLS activé

```sql
SELECT tablename, rowsecurity
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename IN ('stores', 'users', 'store_settings', 'categories', 'items')
ORDER BY tablename;
```

**Attendu** : Toutes les tables avec `rowsecurity = true`

---

### Test 5 : Politiques RLS

```sql
SELECT tablename, policyname, cmd
FROM pg_policies
WHERE schemaname = 'public'
ORDER BY tablename, policyname;
```

**Attendu** : ~20 policies

---

### Test 6 : Extensions PostgreSQL

```sql
SELECT extname, extversion
FROM pg_extension
WHERE extname IN ('uuid-ossp', 'pgcrypto', 'pg_trgm')
ORDER BY extname;
```

**Attendu** : 3 extensions

---

### Test 7 : Triggers

```sql
SELECT trigger_name, event_object_table
FROM information_schema.triggers
WHERE trigger_schema = 'public'
ORDER BY trigger_name;
```

**Attendu** : ~6 triggers (update_updated_at sur chaque table + auto_create_store_settings)

---

## ⚠️ ÉTAPE 3 : Configuration Auth Custom Claims (OPTIONNEL pour l'instant)

**Note** : Les triggers pour synchroniser `store_id` et `role` dans le JWT ne sont **PAS** inclus dans la version safe.

**Impact** : Le RLS fonctionnera, mais vous devrez définir manuellement les custom claims JWT lors de l'inscription des users.

**Solutions** :

### Option A : Via Supabase CLI (plus tard)

Une fois que le problème de connexion réseau au port 5432 sera résolu, vous pourrez exécuter :

```bash
cd /Users/neaskol/Downloads/AGENTIC\ WORKFLOW/POS
supabase db push
```

Cela appliquera la migration complète incluant les triggers auth.

---

### Option B : Définir les claims manuellement via API

Lors de la création d'un user, définir les custom claims via l'API Supabase :

```typescript
// Lors de l'inscription d'un nouveau user
const { data: authData, error: authError } = await supabase.auth.signUp({
  email: 'user@example.com',
  password: 'password',
});

if (!authError && authData.user) {
  // Créer l'entrée dans public.users
  await supabase.from('users').insert({
    id: authData.user.id,
    store_id: 'uuid-du-magasin',
    name: 'Nom User',
    role: 'CASHIER',
  });

  // Mettre à jour les custom claims via l'Admin API
  await supabase.auth.admin.updateUserById(authData.user.id, {
    app_metadata: {
      store_id: 'uuid-du-magasin',
      role: 'CASHIER',
    },
  });
}
```

---

### Option C : Attendre le développement du flow d'authentification

Les custom claims seront configurés automatiquement quand vous implémenterez le flow d'inscription complet dans Flutter.

---

## 📋 Checklist de Validation

Après avoir exécuté `combined_migration_safe.sql` :

- [ ] ✅ SQL exécuté sans erreur `permission denied`
- [ ] ✅ 5 tables créées
- [ ] ✅ 5 types ENUM créés
- [ ] ✅ 7 fonctions créées (schéma public)
- [ ] ✅ RLS activé sur toutes les tables
- [ ] ✅ ~20 policies RLS créées
- [ ] ✅ 3 extensions PostgreSQL activées
- [ ] ✅ ~6 triggers créés

---

## 🔄 Différences entre les 2 Versions

| Aspect | `combined_migration.sql` | `combined_migration_safe.sql` |
|--------|-------------------------|-------------------------------|
| **Schéma auth** | ✅ Utilise `auth.store_id()`, etc. | ❌ Évite le schéma auth |
| **Fonctions publiques** | ❌ Certaines dans auth | ✅ Toutes dans public |
| **Triggers auth.users** | ✅ Inclus | ❌ Retirés (à ajouter plus tard) |
| **Permissions requises** | Super-utilisateur | SQL Editor standard |
| **Fonctionne via Dashboard** | ❌ Permission denied | ✅ Oui |
| **Custom JWT claims auto** | ✅ Oui | ❌ Non (manuel pour l'instant) |

---

## 🎯 Prochaines Étapes

Une fois les migrations déployées :

1. **Vérifier les 7 tests** ci-dessus
2. **Créer les DAOs Drift** pour activer la synchronisation
3. **Implémenter le flow d'authentification Flutter**
4. **Configurer les custom claims JWT** (Option B ou C ci-dessus)

---

## 📖 Références

- **Fichier à déployer** : `supabase/combined_migration_safe.sql`
- **Plan complet** : `~/.claude/plans/velvety-watching-nest.md`
- **Troubleshooting** : `TROUBLESHOOTING.md`
- **Dashboard Supabase** : https://supabase.com/dashboard/project/ofrbxqxhtnizdwipqdls

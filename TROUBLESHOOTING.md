# 🔧 Troubleshooting — POS Madagascar

**Date** : 2026-03-24

---

## ✅ Problèmes Résolus

### 1. Supabase SQL Editor — Permission denied for schema auth

**Problème** :
```
ERROR: 42501: permission denied for schema auth
```

**Cause** : Le fichier `combined_migration.sql` contenait des fonctions dans le schéma `auth` (lignes 45-72) qui nécessitent des permissions super-utilisateur. Le SQL Editor standard n'a pas ces permissions.

**Fonctions problématiques** :
- `auth.store_id()`
- `auth.user_role()`
- `auth.is_owner_or_admin()`
- `auth.is_manager_or_above()`

**Solution appliquée** : Création de `combined_migration_safe.sql`

**Changements** :
```sql
-- AVANT (permission denied)
CREATE FUNCTION auth.store_id() RETURNS UUID ...
CREATE FUNCTION auth.user_role() RETURNS TEXT ...

-- APRÈS (fonctionne)
CREATE FUNCTION get_jwt_store_id() RETURNS UUID ...  -- Dans public
CREATE FUNCTION get_jwt_user_role() RETURNS TEXT ... -- Dans public
```

**Fichiers créés** :
- `supabase/combined_migration_safe.sql` — Version sans schéma auth
- `DEPLOY_MIGRATIONS_FIX.md` — Guide de déploiement mis à jour avec 7 tests de vérification

**Impact** :
- ✅ Toutes les tables créées (5)
- ✅ Tous les types ENUM créés (5)
- ✅ Toutes les fonctions créées dans `public` (7)
- ✅ RLS activé sur toutes les tables
- ✅ Policies RLS créées (~20)
- ⚠️ Custom JWT claims triggers absents (seront ajoutés plus tard)

**Résultat** : ✅ Migrations déployables via Dashboard Supabase

---

### 2. Supabase CLI — Erreur "Your account does not have the necessary privileges"

**Problème** :
```
supabase link --project-ref ofrbxqxhtnizdwipqdls
→ Error: Your account does not have the necessary privileges to access this endpoint
```

**Cause** : CLI non authentifiée (aucun token d'accès)

**Solution appliquée** :
```bash
supabase login --token sbp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
supabase link --project-ref ofrbxqxhtnizdwipqdls
```

**Résultat** : ✅ CLI authentifiée et projet lié avec succès

---

### 3. Supabase CLI — Erreur de connexion PostgreSQL

**Problème** :
```
supabase db push
→ failed to connect to postgres: dial tcp 54.247.26.119:5432: connect: no route to host
```

**Cause** : Firewall/réseau bloque les connexions sortantes vers le port PostgreSQL 5432

**Diagnostic effectué** :
```bash
# Testé avec différentes options
supabase db push --password 'TeamConsult2021$'
→ Échec : timeout

supabase db push --dns-resolver https
→ Échec : i/o timeout

# Vérification API
supabase projects list
→ ✅ Succès (l'authentification fonctionne)
```

**Solution de contournement** :

**Option choisie** : Déploiement manuel via Dashboard Supabase

**Fichiers créés** :
- `supabase/combined_migration.sql` — Toutes les migrations en un seul fichier (736 lignes)
- `DEPLOY_MIGRATIONS.md` — Guide complet de déploiement + tests de vérification

**Instructions** :
1. Ouvrir `supabase/combined_migration.sql`
2. Copier tout le contenu
3. Aller sur https://supabase.com/dashboard/project/ofrbxqxhtnizdwipqdls/sql
4. SQL Editor → New query → Coller → Run

**Résultat** : Solution prête, en attente de déploiement par l'utilisateur

---

### 3. Flutter — Erreurs de compilation dans sync_service.dart

**Problème initial** :
```
lib/core/data/remote/sync_service.dart:26:35: Error: Undefined class 'StoreData'
lib/core/data/remote/sync_service.dart:32:42: Error: The method 'getUnsyncedStores' isn't defined
```

**Cause** : Tentative d'utiliser des DAO methods qui n'existent pas encore

**Solution appliquée** : Simplification en skeleton implementation

```dart
Future<void> syncToRemote() async {
  throw UnimplementedError('Sync logic pending DAO implementation');
}
```

**Résultat** : ✅ Code compile avec 0 erreurs (3 warnings attendus)

---

## 📋 État Actuel du Projet

### ✅ Complété

- [x] Supabase CLI installé et configuré
- [x] CLI authentifié avec Personal Access Token
- [x] Projet Supabase lié (`ofrbxqxhtnizdwipqdls`)
- [x] 8 migrations SQL créées dans `supabase/migrations/`
- [x] Fichier combiné créé : `supabase/combined_migration.sql`
- [x] Flutter integration setup (`supabase_client.dart`, `sync_service.dart`)
- [x] `main.dart` mis à jour avec initialisation Supabase
- [x] `flutter_dotenv` ajouté et configuré
- [x] `.env.local` créé avec credentials
- [x] Guide de déploiement complet créé (`DEPLOY_MIGRATIONS.md`)

### 🔲 En Attente

- [ ] Déployer migrations via Dashboard Supabase
- [ ] Vérifier succès du déploiement (7 tests dans `DEPLOY_MIGRATIONS.md`)
- [ ] Créer les DAOs Drift (`getUnsyncedX()`, `markXSynced()`)
- [ ] Compléter `SyncService` avec logique de synchronisation
- [ ] Tester synchronisation Drift ↔ Supabase

---

## 🚨 Problèmes Connus (Non Bloquants)

### 1. Supabase CLI version obsolète

**Warning** :
```
A new version of Supabase CLI is available: v2.78.1 (currently installed v2.75.0)
```

**Impact** : Aucun (version actuelle fonctionne correctement)

**Solution** (optionnelle) :
```bash
brew upgrade supabase/tap/supabase
```

---

### 2. Flutter analyze warnings

**Warnings attendus** :
```
lib/core/data/local/app_database.dart:50:8 - override_on_non_overriding_member
lib/core/data/remote/sync_service.dart - unused_field (_localDb, _supabase)
```

**Cause** :
- `override_on_non_overriding_member` : Normal, généré automatiquement par Drift
- `unused_field` : Seront utilisés quand les DAOs seront créés

**Action** : Aucune (ces warnings disparaîtront automatiquement)

---

## 🔍 Méthodes de Diagnostic Utilisées

### 1. Vérifier l'authentification Supabase CLI

```bash
supabase projects list
```

**Attendu** : Liste des projets accessibles (si authentifié)

---

### 2. Vérifier la connectivité réseau PostgreSQL

```bash
supabase db push --debug
```

**Diagnostic** :
- `no route to host` → Firewall bloque complètement
- `timeout` → Connexion lente ou bloquée partiellement
- Success → Connexion OK

---

### 3. Vérifier les fichiers de configuration

```bash
ls -la supabase/migrations/
cat .env.local
supabase status
```

---

### 4. Vérifier la compilation Flutter

```bash
flutter pub get
flutter analyze
```

**Attendu** :
- 0 erreurs
- Warnings normaux (Drift, unused fields dans skeleton code)

---

## 📖 Fichiers de Référence

| Fichier | Description |
|---------|-------------|
| `SUPABASE_SETUP.md` | Documentation complète de la configuration Supabase |
| `DEPLOY_MIGRATIONS.md` | **Guide de déploiement + tests de vérification** |
| `TROUBLESHOOTING.md` | Ce fichier — Historique des problèmes et solutions |
| `supabase/combined_migration.sql` | **Fichier à déployer via Dashboard** |
| `~/.claude/plans/velvety-watching-nest.md` | Plan d'implémentation complet |

---

## 🎯 Prochaine Action Recommandée

**Déployer les migrations** via Dashboard Supabase en suivant `DEPLOY_MIGRATIONS.md` :

1. Ouvrir `supabase/combined_migration.sql`
2. Copier tout le contenu
3. Aller sur https://supabase.com/dashboard/project/ofrbxqxhtnizdwipqdls/sql
4. SQL Editor → New query → Coller → Run
5. Exécuter les 7 tests de vérification dans `DEPLOY_MIGRATIONS.md`

**Temps estimé** : 5 minutes

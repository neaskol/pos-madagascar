# Leçons apprises — POS Madagascar

**Relire ce fichier en début de chaque session.**

Après chaque correction ou bug résolu, ajouter une entrée ici pour éviter de répéter les mêmes erreurs.

---

## Format d'une leçon

```markdown
## [DATE] — [Titre court du problème]

**Contexte** : [Qu'est-ce qui s'est passé ?]
**Erreur** : [Qu'est-ce qui était faux ?]
**Solution** : [Comment l'avons-nous corrigé ?]
**Règle** : [Principe général à retenir]
```

---

## 2026-03-24 — Initialisation du projet

**Contexte** : Démarrage du projet POS Madagascar avec documentation complète disponible.

**Règle** :
- TOUJOURS lire les fichiers `docs/` correspondants avant de coder une feature
- TOUJOURS tester en mode offline après chaque feature (couper le wifi)
- TOUJOURS tester en rôle CASHIER, pas seulement ADMIN
- TOUJOURS formater les montants en `int` Ariary avec `NumberFormat('#,###', 'fr')`
- JAMAIS de string hardcodée dans les widgets (utiliser `app_fr.arb` et `app_mg.arb`)
- TOUJOURS utiliser la palette Obsidian/Lin naturel + police Sora (voir `docs/design.md`)
- TOUJOURS utiliser Lucide Icons, jamais d'emoji comme icône
- TOUJOURS vérifier que les features offline corrigent bien les gaps Loyverse (voir `docs/differences.md`)

---

## 2026-03-24 — Implémentation des DAOs Drift et SyncService

**Contexte** : Création de la couche d'accès aux données locale (DAOs) et du service de synchronisation avec Supabase.

**Solution** :
- Créé 5 DAOs complets (StoreDao, UserDao, StoreSettingsDao, CategoryDao, ItemDao)
- Chaque DAO inclut : CRUD complet, soft delete, sync tracking, streams réactifs, helpers métier
- SyncService implémenté avec synchronisation unidirectionnelle Drift → Supabase
- Ordre de synchronisation respecte les foreign keys (stores → users → settings → categories → items)
- Génération réussie du code avec `dart run build_runner build --delete-conflicting-outputs`

**Règle** :
- TOUJOURS synchroniser dans l'ordre des foreign keys pour éviter les erreurs d'intégrité référentielle
- TOUJOURS marquer `synced: false` lors des insertions/updates locales
- TOUJOURS auto-update `updatedAt` lors des modifications (fait dans les DAOs)
- TOUJOURS utiliser `copyWith()` dans les updates pour forcer `synced: false`
- TOUJOURS faire le soft delete (`deleted_at`) plutôt que le hard delete
- Les warnings Drift sur les foreign keys sont normaux et n'affectent pas le fonctionnement
- Utiliser les Streams (`watchXxx`) pour les UI réactives plutôt que les `Future` (`getXxx`)
- Ne JAMAIS bloquer l'UI en attendant la synchronisation — utiliser `unawaited()` ou `.catchError()`
- TOUJOURS vérifier la connexion internet avant de tenter une synchro (évite les timeouts)

---

## 2026-03-25 — Audit complet du codebase et corrections

**Contexte** : Audit systématique de toute la base de code : navigation, BLoC, Drift, localisation, logique UX.

**Erreurs trouvées** :
- Hardcoded `'store-1'` dans product_form_screen.dart empêchait la création/modification de produits
- Hardcoded strings en français dans cart_panel.dart, pos_screen.dart, setup_wizard_screen.dart
- Duplicate key `cancel` dans les fichiers ARB (FR et MG)
- `Navigator.pop(context)` dans product_form_screen au lieu de `context.pop()` (GoRouter)
- Aucun route guard dans GoRouter — n'importe qui pouvait naviguer vers /pos, /products etc.
- PIN screen ne gérait pas l'état `AuthStoreEmployeesLoaded` (retour depuis POS)
- Foreign keys manquantes dans modifiers.drift et item_variants.drift (store_id)
- Foreign keys manquantes dans custom_pages.drift (page_id, item_id, category_id)
- `updated_at` manquant dans custom_page_items et custom_page_category_grids
- DAO custom_page_dao n'incluait pas `updatedAt` dans les Companion.insert()
- Aucun index sur customers.name, credits.status, credits.due_date

**Règle** :
- TOUJOURS récupérer le `storeId` depuis `context.read<AuthBloc>().state` — jamais de placeholder
- TOUJOURS utiliser `context.pop()` (GoRouter) dans les écrans, `Navigator.pop()` uniquement dans les dialogs
- TOUJOURS définir les route guards dans GoRouter redirect pour protéger les routes authentifiées
- TOUJOURS ajouter foreign keys dans Drift pour les colonnes `_id` qui référencent d'autres tables
- TOUJOURS ajouter `updated_at` dans les tables Drift qui participent à la synchro
- TOUJOURS ajouter des indexes sur les colonnes utilisées dans WHERE et ORDER BY
- JAMAIS de clé dupliquée dans les fichiers ARB (le JSON prend la dernière valeur silencieusement)

---

## Leçons à venir...

Les prochaines leçons seront ajoutées ici au fur et à mesure du développement.

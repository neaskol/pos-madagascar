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

## 2026-03-25 — Phase 3 Development (10 sub-phases in 1 day)

**Contexte** : Développement rapide des features avancées POS en 10 sous-phases.

**Erreurs trouvées** :
- Mobile Money merchant numbers non configurées par défaut — il faut un UI Settings pour les saisir
- Phase 3.9 (Customers/Credits) démarré backend-first sans UI — backend prêt mais inutilisable sans écrans
- Compilation errors accumulées sur Phases 3.8 & 3.9 (37 erreurs) — correction en batch nécessaire

**Règle** :
- TOUJOURS créer au minimum un écran UI basique pour chaque feature backend, même un placeholder
- TOUJOURS compiler après chaque phase, pas attendre d'avoir accumulé plusieurs phases
- Pour les services de paiement tiers (MVola, Orange Money) : toujours prévoir un fallback USSD
- Les deep links peuvent ne pas être installés — toujours avoir un fallback (web URL ou USSD)
- Les références de transaction mobile money doivent être validées côté client (format uniquement)
- Les taxes "added" vs "included" ont des formules différentes (voir docs/formulas.md)
- Les modifiers obligatoires (forced) doivent bloquer la validation du panier si non sélectionnés
- Les variants max 3 options, 200 combinaisons — limite Loyverse à respecter
- Les custom pages sont liées au store_id — ne jamais oublier cette FK

---

## 2026-03-25 — Build Android Release impossible

**Contexte** : `flutter build apk --release` échoue avec erreur CMake/NDK.

**Erreur** : Incompatibilité NDK 28.x / CMake 3.22.1, aggravée par les espaces dans le chemin du projet ("AGENTIC WORKFLOW").

**Solution** : Utiliser `flutter build apk --debug` en attendant. 3 options pour fix permanent :
1. Renommer le dossier sans espaces
2. Downgrade NDK vers 25.x ou 26.x
3. Upgrade CMake vers 3.28+

**Règle** :
- JAMAIS d'espaces dans les chemins de projets Flutter/Android
- NDK 28.x est trop récent pour Flutter 3.x — rester sur 25.x ou 26.x
- Toujours tester `--release` build tôt dans le projet

---

## 2026-03-25 — Supabase port 5432 bloqué

**Contexte** : `supabase db push` échoue — port PostgreSQL 5432 bloqué par le réseau.

**Solution** : Utiliser l'API Management Supabase (HTTPS 443) pour toutes les opérations SQL. Ne jamais perdre de temps avec les connexions directes PostgreSQL.

**Règle** :
- Sur les réseaux restreints, utiliser l'API Management Supabase via HTTPS (port 443)
- Ne JAMAIS attendre que le port 5432 soit débloqué — contourner immédiatement
- Les migrations peuvent être appliquées via le SQL Editor du dashboard ou l'API REST

---

## 2026-03-26 — P0-13 : PIN setup onboarding bloqué (3 causes racines)

**Contexte** : Après signup + setup wizard, l'écran PIN setup ne fonctionnait pas. 3h de debug.

**Erreur 1 — Route guard bloquait /pin-setup** :
Le GoRouter redirect forçait TOUTES les routes vers `/pin` quand le state était `AuthAuthenticatedWithStore`, y compris `/pin-setup`.

**Erreur 2 — signUpWithEmail() ne sauvegardait pas l'user dans Drift** :
`signUpWithEmail()` créait l'user dans Supabase mais ne le sauvegardait JAMAIS dans la base locale Drift. Ensuite `getCurrentUser()` (qui lit Drift) retournait `null`.

**Erreur 3 — createInitialStore() faisait updateUser au lieu de upsertUser** :
Comme l'user n'existait pas dans Drift, `getUserById()` retournait `null` et le `updateUser()` ne faisait rien. L'user restait absent de Drift.

**Solution** :
1. Route guard : ajouté `|| currentPath == '/pin-setup'` dans la condition d'exemption
2. Route guard : ajouté bloc `AuthStoreCreated` → autorise `/pin-setup`
3. `createInitialStore()` : remplacé `updateUser` par `upsertUser` avec fetch complet depuis Supabase
4. BLoC : supprimé l'emit intermédiaire `AuthStoreCreated`, émet directement `AuthAuthenticatedWithStore`

**Règle** :
- **TOUJOURS sauvegarder l'user dans Drift après signup** — `getCurrentUser()` lit Drift, pas Supabase
- **TOUJOURS utiliser `upsertUser` au lieu de `updateUser`** quand l'user peut ne pas exister localement
- **TOUJOURS vérifier les route guards** quand on ajoute une nouvelle route — ils peuvent bloquer silencieusement
- **JAMAIS appeler context.read<AuthBloc>() dans un setState()** — le faire APRÈS setState
- **TOUJOURS tracer le data flow complet** : Supabase Auth → Drift local → BLoC state → UI read → résultat
- Les emits intermédiaires dans BLoC (ex: `AuthStoreCreated` avant `AuthAuthenticatedWithStore`) causent des race conditions avec la navigation

---

## 2026-03-26 — PIN keypad layout hors écran

**Contexte** : Lors du login par PIN, certains chiffres du pavé numérique apparaissaient hors écran.

**Erreur** : Le `GridView` du pavé numérique était wrappé dans un `Expanded` sans `childAspectRatio`, causant des débordements.

**Solution** :
- Supprimé le widget `Expanded` autour du `GridView`
- Ajouté `childAspectRatio: 1.2` pour des proportions correctes
- Remplacé par un simple `Padding` avec `shrinkWrap: true`

**Règle** :
- **TOUJOURS définir `childAspectRatio`** dans GridView pour contrôler les proportions
- **NE PAS utiliser `Expanded` avec GridView** si on utilise `shrinkWrap: true`
- **TOUJOURS tester les layouts** sur plusieurs tailles d'écran
- Les boutons circulaires nécessitent un aspect ratio > 1.0 pour rester visibles

---

## 2026-03-26 — Perte de données après réinstallation app

**Contexte** : Produits et clients créés disparaissaient après désinstallation/réinstallation de l'app.

**Erreur** :
1. Sync périodique toutes les 5 minutes trop lente
2. Désinstallation supprime la base Drift locale avant la sync
3. Aucun pull depuis Supabase au login (sync unidirectionnelle seulement)

**Solution** :
**Partie 1 - Sync immédiate (Push)** :
- Réduit intervalle sync de 5 minutes → 30 secondes
- Ajouté sync forcée immédiate après création/modification/suppression
- Throttling intelligent (10s minimum entre syncs auto)
- ItemBloc et CustomerBloc déclenchent `forceSyncNow()` après opérations

**Partie 2 - Récupération données (Pull)** :
- Implémenté `syncFromRemote(storeId)` dans SyncService
- Méthodes `_pullCategories()`, `_pullItems()`, `_pullCustomers()`
- Ajouté `upsertCategory()` et `upsertItem()` dans DAOs
- AuthBloc appelle `syncFromRemote()` après login réussi
- Données marquées `synced: 1` après pull pour éviter re-push

**Règle** :
- **TOUJOURS synchroniser immédiatement** après les opérations critiques (create/update/delete)
- **NE JAMAIS attendre > 1 minute** pour la première sync — risque de perte de données
- **TOUJOURS implémenter sync bidirectionnelle** : Push ET Pull
- **TOUJOURS récupérer les données au login** pour multi-device et recovery
- **TOUJOURS utiliser `upsert` (insertOnConflictUpdate)** pour le pull sync
- **TOUJOURS marquer `synced: 1`** les données pullées depuis Supabase
- La sync périodique est un filet de sécurité, PAS la stratégie principale
- Tester la perte de données : créer → désinstaller → réinstaller → login → vérifier

---

## Leçons à venir...

Sprint 1 complété avec sync bidirectionnelle. Les prochaines leçons seront ajoutées au fil du Sprint 2+.

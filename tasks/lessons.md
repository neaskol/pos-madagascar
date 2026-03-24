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

## Leçons à venir...

Les prochaines leçons seront ajoutées ici au fur et à mesure du développement.

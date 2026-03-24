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

## Leçons à venir...

Les prochaines leçons seront ajoutées ici au fur et à mesure du développement.

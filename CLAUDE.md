# POS Madagascar — Flutter App

Concurrent principal : **Loyverse** (1M+ users, 170 pays, 4.8★, gratuit).
Objectif phase 1 : reproduire Loyverse exactement. Puis le dépasser.

---

## AVANT TOUTE CHOSE — Lis les bons fichiers

Avant de coder quoi que ce soit, lis les fichiers correspondants à ta tâche :

**Tu crées ou modifies une table, une migration, du RLS, un modèle Drift ?**
→ Lis d'abord `docs/database.md`
→ Utilise `.claude/skills/supabase.md` pour toutes les commandes CLI Supabase
→ N'utilise jamais le MCP Supabase — uniquement `supabase ...` via bash

**Tu utilises un package Flutter dont tu n'es pas sûr de l'API actuelle ?**
→ Utilise `.claude/skills/context7.md` pour fetcher la doc à jour via curl
→ N'utilise jamais le MCP Context7 — uniquement curl/bash directement

**Tu codes un calcul (taxes, marge, coût moyen, arrondi caisse, remises) ?**
→ Lis d'abord `docs/formulas.md`

**Tu démarres un sprint ou planifies des tâches ?**
→ Lis d'abord `docs/sprints.md`

**Tu implémentes une feature POS (caisse, tickets, remboursements, clients...) ?**
→ Lis d'abord `docs/loyverse-features.md` pour savoir exactement comment Loyverse se comporte

**Tu veux vérifier qu'on fait mieux que Loyverse, ou implémenter un de nos différenciants ?**
→ Lis d'abord `docs/differences.md`

**Tu crées ou modifies un écran Flutter (layout, contenu, composants) ?**
→ Lis d'abord `docs/screens.md`

**Tu travailles sur le design, couleurs, typographie, animations, composants UI ?**
→ Lis d'abord `docs/design.md` — il t'explique comment utiliser le skill UI UX Pro Max installé dans `.claude/skills/ui-ux-pro-max/`

**En début de session**, lis aussi `tasks/lessons.md` pour éviter de répéter les erreurs passées.

---

## Comportement obligatoire

1. **Plan d'abord** — écrire dans `tasks/todo.md` avant tout code. Valider avec l'utilisateur.
2. **Sous-agents** — les utiliser librement pour garder le contexte propre.
3. **Leçons** — après toute correction : mettre à jour `tasks/lessons.md`. Relire en début de session.
4. **Vérification** — jamais marquer une tâche complète sans prouver que ça fonctionne.
5. **Élégance** — pour les changements non triviaux : "y a-t-il une façon plus élégante ?"
6. **Bugs autonomes** — corriger sans demander de guidage. Pointer les logs, résoudre.
7. **Simplicité** — impact minimal sur le code. Causes racines, pas de fixes temporaires.

---

## Stack

| Couche | Outil |
|--------|-------|
| Framework | Flutter 3.x + Dart |
| State | flutter_bloc |
| Navigation | go_router (guards par rôle) |
| Backend | Supabase (PostgreSQL + Auth + Storage + Realtime) |
| Offline | Drift (SQLite local) |
| Graphiques | fl_chart |
| Scan | mobile_scanner |
| Impression | blue_thermal_printer (ESC/POS) |
| Localisation | flutter_localizations + intl |
| Paiements locaux | MVola API + Orange Money API |
| Reçu client | url_launcher (WhatsApp wa.me) |
| Export | pdf + excel packages |

---

## Conventions — à respecter sur chaque ligne de code

- **Ariary** : toujours `int`, jamais `double`. Format : `1 500 Ar`. Utiliser `NumberFormat('#,###','fr')`. Formules complètes dans `docs/formulas.md`.
- **Langues** : Français (`fr`) + Malagasy (`mg`). Zéro string hardcodée — tout dans `lib/l10n/app_fr.arb` et `app_mg.arb`.
- **Offline-first** : écrire dans Drift EN PREMIER, Supabase en arrière-plan. Chaque table Drift a `synced: bool` et `updatedAt: DateTime`. Schéma complet dans `docs/database.md`.
- **Pattern** : `DataSource` → `Repository` → `BLoC`. Models avec `fromJson/toJson/copyWith`.
- **Rôles** : toujours protéger deux fois — go_router guard (UI) + Supabase RLS (données).

---

## Rôles utilisateurs

| Rôle | Accès |
|------|-------|
| `OWNER` | Tout, non modifiable |
| `ADMIN` | Tout sauf suppression compte |
| `MANAGER` | Stock + rapports (pas paramètres users) |
| `CASHIER` | Caisse + permissions configurables par le gérant |

Permissions CASHIER configurables (liste complète dans `docs/differences.md`) :
voir tous les reçus, remises restreintes, modifier taxes, accepter paiements, remboursements, gérer tous les tickets, voir rapport shift, annuler items sauvegardés, **voir stock depuis caisse** (gap Loyverse).

---

## Les 10 différenciants vs Loyverse

Détail complet + implémentation dans `docs/differences.md`.

1. **Offline 100%** — remboursements et nouveaux clients offline (bloqués chez Loyverse p.67, p.81)
2. **Multi-users gratuit** — Loyverse facture $25/mois
3. **Vente à crédit** — inexistant chez tous les concurrents
4. **MVola & Orange Money** — aucun POS mondial ne les supporte
5. **Interface Malagasy** — première app POS en Malagasy
6. **Marge correcte** — prix d'achat en % possible (impossible chez Loyverse)
7. **Photos dans la liste stock** — Loyverse : caisse seulement (p.83)
8. **Forced modifiers** — Loyverse : optionnels seulement (p.65-66)
9. **Inventaire avancé gratuit** — Loyverse facture $25/mois
10. **Export/impression inventaire** — impossible chez Loyverse

---

## Architecture modulaire (StoreSettings)

Chaque feature est un toggle dans les réglages — reproduire exactement Loyverse (p.11) :
`shiftsEnabled`, `timeClockEnabled`, `openTicketsEnabled`, `predefinedTicketsEnabled`,
`kitchenPrintersEnabled`, `customerDisplayEnabled`, `diningOptionsEnabled`,
`lowStockNotifications`, `negativeStockAlerts`, `weightBarcodesEnabled`.

---

## Checklist avant tout commit

- [ ] Fonctionne online
- [ ] Fonctionne offline (couper wifi et tester)
- [ ] Testé en rôle CASHIER (pas seulement ADMIN)
- [ ] Montants en `int` Ariary, zéro décimale
- [ ] Zéro string hardcodée dans les widgets
- [ ] Logs d'activité enregistrés si action importante
- [ ] `tasks/todo.md` mis à jour

---

## Commandes fréquentes

```bash
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
supabase db push
supabase db diff -f nom_migration
flutter test
```

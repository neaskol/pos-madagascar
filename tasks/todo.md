# Sprint 1 — Fondation
**Semaine** : 1
**Objectif** : Infrastructure de base + Auth + Multi-utilisateurs
**Référence manuel Loyverse** : p.9-12 (Getting Started), p.139-149 (Employees), p.236-242 (Multi-stores)
**Différenciants couverts** : Multi-users gratuit (#2)

---

## À faire

### Infrastructure
- [x] Configuration initiale Flutter (pubspec.yaml, l10n, structure dossiers)
- [x] Thème complet (AppColors, AppTheme, AppTypography avec Sora)
- [x] Configuration go_router avec guards par rôle
- [x] Configuration Supabase (tables core + RLS)
- [x] Configuration Drift (offline-first)
- [x] DAOs Drift créés pour les 5 tables core
- [x] SyncService complété avec synchronisation Drift → Supabase

### Auth
- [x] Écran Splash
- [x] Écran Onboarding (3 slides)
- [x] Écran Login (email/password)
- [x] Écran Inscription
- [x] Setup Wizard magasin (4 étapes)
- [x] Écran PIN Caisse (4 chiffres)

### Multi-utilisateurs & Rôles
- [x] Tables Supabase : users, stores, pos_devices, store_settings
- [x] Tables Drift correspondantes + DAO
- [x] Repositories créés (Store, User, StoreSettings, Category, Item)
- [x] BLoCs créés avec Events et States (Store, User, StoreSettings, Category, Item)
- [x] Repository + BLoC pour auth
- [x] Système de rôles (OWNER/ADMIN/MANAGER/CASHIER)
- [ ] Permissions configurables par rôle (à implémenter dans les écrans réglages)
- [x] Changer d'utilisateur sans fermer la session (via écran PIN)

### Vérifications (Tests manuels - voir tasks/manual-test-guide.md)
- [ ] Fonctionne online
- [ ] Fonctionne offline (couper wifi et tester)
- [ ] Testé en rôle CASHIER
- [ ] Montants en `int` Ariary formatés correctement
- [ ] Zéro string hardcodée dans les widgets
- [ ] Tests unitaires des repositories

---

## Résultat Sprint 1

✅ **CODE COMPLET** — Prêt pour tests manuels (build iOS en cours)

**Guide de test** : `tasks/manual-test-guide.md` (8 scénarios détaillés)

---

## En cours

**Sprint 2 - POS & Produits** (démarrage immédiat)

---

## Terminé (aujourd'hui, 2026-03-25)
- [x] Génération des fichiers de localisation (flutter gen-l10n)
- [x] Correction de 38 erreurs de compilation
- [x] Ajout de la méthode upsertUser dans UserDao
- [x] Correction des imports AppLocalizations dans tous les écrans auth
- [x] Correction des types User vs UsersTableData
- [x] Correction des types Drift Companions (Value<T> vs T)
- [x] Suppression du test par défaut invalide
- [x] Projet compile sans erreur (13 infos de style uniquement)
- [x] Intégration complète : main.dart + BLoCs + go_router
- [x] Documentation de test créée (manual-test-guide.md + test-report.md)
- [x] 2 commits : fix compilation + integration

## Terminé (précédemment)
- [x] Lecture de toute la documentation
- [x] Création du projet Flutter
- [x] Structure de dossiers créée
- [x] pubspec.yaml configuré avec toutes les dépendances
- [x] Fichiers de localisation FR/MG initialisés
- [x] Dossier tasks/ créé
- [x] Migrations Supabase créées et déployées (8 migrations combinées)
- [x] Schéma Drift créé avec 5 tables (.drift files)
- [x] DAOs Drift implémentés (StoreDao, UserDao, StoreSettingsDao, CategoryDao, ItemDao)
- [x] SyncService complété avec logique de synchronisation Drift → Supabase
- [x] Code Drift généré avec build_runner (app_database.g.dart + tous les DAOs)
- [x] Repositories créés pour les 5 entités core (pattern DataSource → Repository)
- [x] BLoCs créés avec Events et States pour les 5 entités core
- [x] Correction des signatures de méthodes Drift (Selectable vs Future)
- [x] Code compile sans erreur (5 suggestions de style uniquement)
- [x] Repository AuthRepository créé avec login/register/PIN/setup wizard
- [x] BLoC d'authentification avec Events et States complets
- [x] Écran Splash avec redirection automatique
- [x] Écran Onboarding avec 3 slides (PageView + dots)
- [x] Écran Login avec validation formulaire
- [x] Écran Inscription avec confirmation mot de passe
- [x] Setup Wizard 4 étapes (infos magasin, devise/arrondi, langues, type commerce)
- [x] Écran PIN avec grille employés et pavé numérique 4 chiffres
- [x] Configuration go_router avec toutes les routes auth
- [x] Fichiers de localisation FR/MG avec toutes les traductions auth

---

## Résultat

En attente de démarrage...

---

## Problèmes rencontrés

Aucun pour l'instant.

---
---

# Sprint 2 — POS & Gestion des Produits
**Semaine** : 1-2
**Objectif** : Écran de caisse fonctionnel + Gestion complète des produits
**Référence manuel Loyverse** : p.13-29 (Using the Register), p.52-90 (Items & Inventory)
**Différenciants couverts** : Photos dans liste stock (#7), Forced modifiers (#8)

---

## À faire

### Écran POS (Caisse)
- [ ] Layout principal POS (grille catégories + panier + pavé numérique)
- [ ] Affichage grilles de catégories avec compteur items
- [ ] Sélection catégorie → grille items (nom, prix, photo)
- [ ] Ajout item au panier avec quantité
- [ ] Calcul automatique des totaux (sous-total, taxes, remises, total)
- [ ] Pavé numérique pour quantités et montants
- [ ] Gestion des variants (taille, couleur, etc.)
- [ ] Gestion des modifiers (obligatoires et optionnels) - **Différenciant #8**
- [ ] Recherche rapide par nom ou code-barre
- [ ] Scanner code-barre (mobile_scanner)

### Gestion des Produits
- [ ] Écran liste des items avec photos - **Différenciant #7**
- [ ] Écran création/édition item
- [ ] Upload photo item (Supabase Storage)
- [ ] Gestion des catégories (CRUD)
- [ ] Gestion des variants (créer, modifier, prix différents)
- [ ] Gestion des modifiers (créer, assigner aux items)
- [ ] Gestion des codes-barres multiples par item
- [ ] Import CSV/Excel items (optionnel)

### Inventaire
- [ ] Écran liste stock avec photos
- [ ] Filtres : catégorie, stock faible, rupture
- [ ] Ajustement stock manuel
- [ ] Historique des mouvements de stock
- [ ] Alertes stock faible (configurable par item)
- [ ] Export inventaire (CSV/PDF) - **Différenciant #10**
- [ ] Impression inventaire - **Différenciant #10**

### Calculs & Business Logic
- [ ] Calcul correct de la marge (prix d'achat en % supporté) - **Différenciant #6**
- [ ] Calcul des taxes (TVA configurable par item)
- [ ] Gestion arrondi caisse (0/50/100/200 Ar)
- [ ] Remises (montant fixe ou %)
- [ ] Coût moyen pondéré (CUMP) pour valorisation stock

---

## En cours

---

## Terminé

(Sera rempli au fur et à mesure)

---

## Résultat

En attente de démarrage...

---

## Problèmes rencontrés

(À documenter)

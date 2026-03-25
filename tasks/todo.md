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

### Vérifications
- [ ] Fonctionne online
- [ ] Fonctionne offline (couper wifi et tester)
- [ ] Testé en rôle CASHIER
- [ ] Montants en `int` Ariary formatés correctement
- [ ] Zéro string hardcodée dans les widgets
- [ ] Tests unitaires des repositories

---

## En cours

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

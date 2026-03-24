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
- [ ] Configuration go_router avec guards par rôle
- [x] Configuration Supabase (tables core + RLS)
- [x] Configuration Drift (offline-first)
- [x] DAOs Drift créés pour les 5 tables core
- [x] SyncService complété avec synchronisation Drift → Supabase

### Auth
- [ ] Écran Splash
- [ ] Écran Onboarding (3 slides)
- [ ] Écran Login (email/password)
- [ ] Écran Inscription
- [ ] Setup Wizard magasin (4 étapes)
- [ ] Écran PIN Caisse (4 chiffres)

### Multi-utilisateurs & Rôles
- [x] Tables Supabase : users, stores, pos_devices, store_settings
- [x] Tables Drift correspondantes + DAO
- [ ] Repository + BLoC pour auth
- [ ] Système de rôles (OWNER/ADMIN/MANAGER/CASHIER)
- [ ] Permissions configurables par rôle
- [ ] Changer d'utilisateur sans fermer la session

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

## Terminé
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

---

## Résultat

En attente de démarrage...

---

## Problèmes rencontrés

Aucun pour l'instant.

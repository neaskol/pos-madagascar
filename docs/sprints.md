# Plan de sprints — POS Madagascar

Charger ce fichier quand : démarrage d'un sprint, planification, `/start-sprint`.

---

## Vue d'ensemble

| Phase | Sprints | Objectif |
|-------|---------|----------|
| 1 | 1–4 | Reproduire Loyverse exactement |
| 2 | 5–6 | Dépasser Loyverse (features payantes, gratuites chez nous) |
| 3 | 7–8 | Différenciants exclusifs Madagascar |

---

## Phase 1 — Reproduire Loyverse (Sprints 1–4)

### Sprint 1 — Fondation ✅ COMPLÉTÉ (2026-03-26)
**Référence manuel** : p.9-12 (Getting Started), p.139-149 (Employees), p.236-242 (Multi-stores)

- [x] Projet Flutter : structure dossiers, pubspec.yaml, thème, go_router
- [x] Supabase : tables `stores`, `users`, `pos_devices`, `store_settings`
- [x] Auth : inscription email, connexion, session persistante
- [x] PIN caisse : connexion rapide par PIN 4 chiffres à la caisse
- [x] Setup magasin guidé : nom, devise (Ariary), langue (FR/MG), logo
- [x] Multi-utilisateurs + rôles (OWNER/ADMIN/MANAGER/CASHIER) — **GRATUIT**
- [x] Permissions configurables par rôle (toutes les permissions du manuel p.143-145)
- [x] Changer d'utilisateur sans fermer la session (juste saisir son PIN)
- [x] Multi-magasins sous un compte
- [x] Architecture modulaire : `StoreSettings` avec tous les toggles
- [x] Navigation go_router avec guards par rôle
- [x] **Sync bidirectionnelle complète** : Push (Drift → Supabase) + Pull (Supabase → Drift)
- [x] **Protection perte de données** : sync immédiate après création/modification + sync périodique 30s
- [x] **Récupération auto des données** au login (pull depuis Supabase)
- [x] UI/UX : écran PIN layout corrigé (clavier numérique complet visible)

### Sprint 2 — Produits, Taxes & Stock
**Référence manuel** : p.13-25 (Items, Categories, Taxes), p.65-66 (Modifiers), p.86-100 (Variants, CSV)

**Phase 1 - Product Management UI** ✅ TERMINÉ (2026-03-25)
- [x] CRUD items : nom, prix, coût, SKU (auto max 40 chars), barcode, catégorie
- [x] Coût en montant fixe OU en % du prix de vente — **gap Loyverse**
- [x] Champ "disponible à la vente" (masquer sans supprimer)
- [x] "Vendu au poids" ou "à la pièce"
- [x] Photos items : upload, crop carré auto, miniatures dans **liste stock** — **gap Loyverse**
- [x] Catégories avec couleurs
- [x] Suivi stock par item, seuil d'alerte
- [x] Liste produits avec recherche/filtres
- [x] Formulaire création/édition complet
- [x] Upload photos vers Supabase Storage avec RLS
- [x] Localisation FR/MG complète (57 nouvelles clés)
- [x] Tests end-to-end préparés

**Phase 2 - Taxes, Variants & Modifiers**
- [x] Variants : jusqu'à 3 options, 200 combinaisons max, stock/prix/coût par variant
- [x] Modifiers : options avec prix additionnels, optionnels ET obligatoires — **gap Loyverse**
- [x] Taxes : incluse ou ajoutée au prix, par item, plusieurs taxes cumulables
- [x] Discounts configurables : % ou montant, sur ticket ou par article, accès restreint
- [ ] Notification push à seuil stock bas

### Sprint 3 — Écran caisse
**Référence manuel** : p.26-50 (Sales, Barcodes, Weight, Split Payment)

- [x] Grille caisse : pages personnalisées, recherche + filtre catégorie + navigation pages
- [x] Panier : ajout, modifier quantité, supprimer, vider ticket
- [x] Remises pendant la vente (ticket ou par article, restreintes ou non)
- [ ] Alerte stock négatif avec possibilité de forcer
- [ ] Types de paiement configurables dans réglages (infrastructure ready)
- [x] Paiement cash : montants suggérés, calcul monnaie rendue
- [x] Split payment : N paiements partiels, type différent par part
- [x] **MVola & Orange Money** (deep links + référence transaction) — **exclusif Madagascar**
- [x] Reçus Bluetooth ESC/POS
- [x] Envoi reçu WhatsApp — **gap Loyverse**
- [x] Scan barcode caméra (UPC-A, EAN-8, EAN-13, Code 39, Code 128, QR)

### Sprint 4 — Opérations
**Référence manuel** : p.51-73 (Open Tickets, Shifts), p.159-175 (Customers, Loyalty), p.67-68 (Refunds)

- [ ] Open tickets : sauvegarder, nommer, commenter, reprendre (table exists, no UI)
- [ ] Tickets prédéfinis : noms de tables pour restaurants
- [ ] Impression de l'addition (Bill) — distinct du reçu (pas de numéro, titre "BILL")
- [ ] Remboursements depuis l'historique — **offline aussi** — **gap Loyverse**
- [ ] Shifts : ouverture, Pay In/Out, fermeture avec montant réel vs attendu (table exists, no UI)
- [ ] Rapport de shift depuis le POS
- [ ] Clients : inscription à la caisse, identification par téléphone (backend done, no UI)
- [ ] Programme de fidélité : points, conversion en remise, cartes barcode
- [ ] Envoi reçu par email + WhatsApp (WhatsApp done, email not done)
- [x] Enregistrement client offline — **gap Loyverse** (backend done)
- [ ] Logo magasin sur les reçus (manuel p.243)

---

## Phase 2 — Dépasser Loyverse (Sprints 5–6)

### Sprint 5 — POS avancé + Hardware
**Référence manuel** : p.54-59 (Merge/Split tickets), p.74-76 (Dining), p.151-154 (Time Clock)

- [ ] Fusion de tickets (Merge) : items + remises + taxes suivent
- [ ] Division de ticket (Split) : jusqu'à 20 tickets, impression bill par ticket
- [ ] Sync tickets temps réel entre appareils (Supabase Realtime)
- [ ] Dining options : Sur place / À emporter / Livraison (configurable)
- [ ] Pointage employés (Time Clock) : arrivée, départ, rapport d'heures
- [ ] Import/Export CSV items (max 10 000 items, 5 MB)
- [ ] Import/Export CSV clients
- [ ] Identification client par scan barcode carte fidélité
- [ ] Scanner Bluetooth externe (keyboard emulation — plug & play)
- [ ] Tiroir-caisse automatique (via imprimante, port RJ11)
- [ ] Imprimante Ethernet (connexion par IP réseau local)

### Sprint 6 — Inventaire avancé GRATUIT
**Référence manuel** : p.101-137 (Advanced Inventory) — $25/mois chez Loyverse

- [ ] Gestion des fournisseurs (nom unique, coordonnées, email)
- [ ] Bons de commande : statuts (Draft/Pending/Partial/Closed), envoi email fournisseur
- [ ] Réception BdC : MAJ stock + recalcul coût moyen pondéré
- [ ] Autofill BdC : stock optimal - stock actuel - incoming
- [ ] Coûts additionnels (port, douane) répartis proportionnellement sur les items
- [ ] Transferts entre magasins : statuts (Draft/InTransit/Transferred)
- [ ] Ajustements de stock manuels : Receive / Loss / Damage / Count
- [ ] Inventaire physique : partiel ou complet, scan barcode, sauvegarde auto 30s
- [ ] Impression étiquettes produits (Code-128, nom, SKU, prix) — **gap Loyverse** (payant)
- [ ] Historique mouvements de stock (filtrable par période, magasin, employé, raison)
- [ ] Rapport valorisation inventaire (coût total, retail, profit potentiel, marge %)
- [ ] Export données complètes (items, clients, reçus, rapports)

---

## Phase 3 — Différenciants exclusifs (Sprints 7–8)

### Sprint 7 — Analytics & Modules spéciaux

- [ ] Dashboard graphiques : CA, profit, tendances, alertes stock (fl_chart)
- [ ] Rapport ventes résumé (jour/semaine/mois/custom) par magasin
- [ ] Rapport ventes par item et par catégorie
- [ ] Rapport shifts, rapport modifiers, rapport remises
- [ ] Export Excel / CSV / PDF — **gap Loyverse** (impression inventaire impossible)
- [ ] **Vente à crédit** : enregistrement, date limite, rappels SMS/WhatsApp — **UNIQUE**
- [ ] Module Production : fabriquer des composites, déduire composants automatiquement
- [ ] Imprimante cuisine (Kitchen Printer) avec stations configurables
- [ ] Vente au poids + barcodes à poids intégré (format EAN-13 YYCCCCCWWWWWX)
- [ ] Items composites complets avec cascade de stock

### Sprint 8 — Finalisation & Publication

- [ ] **IA prédictive via Claude API** : conseils stock, tendances, alertes intelligentes
- [ ] Interface Malagasy complète (première app POS en Malagasy — **UNIQUE**)
- [ ] Écran client (Customer Display) sur 2ème appareil
- [ ] Onboarding guidé (setup wizard pour premier lancement)
- [ ] Tests complets : online, offline, tous les rôles, grands montants Ariary
- [ ] Performance : ListView.builder partout, images cachées, pagination requêtes
- [ ] Publication Play Store (APK)
- [ ] Publication App Store (IPA)

---

## Template tasks/todo.md

```markdown
# Sprint X — [Nom]
**Semaine** : X
**Objectif** : [une phrase]
**Référence manuel Loyverse** : p.XX-XX
**Différenciants couverts** : [liste]

## À faire
- [ ] Tables Supabase + migrations
- [ ] Tables Drift + DAO
- [ ] Repository + BLoC
- [ ] Écran Flutter
- [ ] Vérification offline (couper wifi)
- [ ] Vérification rôles (tester en CASHIER)
- [ ] Tests unitaires
- [ ] Commit

## En cours
## Terminé
## Résultat
## Problèmes rencontrés
```

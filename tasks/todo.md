# Sprint 1 — Fondation ✅ TERMINÉ

**Semaine** : 1
**Objectif** : Infrastructure de base + Auth + Multi-utilisateurs
**Référence manuel Loyverse** : p.9-12 (Getting Started), p.139-149 (Employees), p.236-242 (Multi-stores)
**Différenciants couverts** : Multi-users gratuit (#2), Interface Malagasy (#5)

---

## Résultat Sprint 1

✅ **100% COMPLET** — Infrastructure, auth, rôles, offline-first, localisation FR/MG opérationnels

**Commits clés** :
- Infrastructure complète + auth screens
- Système de rôles OWNER/ADMIN/MANAGER/CASHIER
- Drift + Supabase configurés avec sync offline-first
- Localisation FR/MG complète

---

# Sprint 2 — POS & Gestion des Produits

**Semaine** : 2-4
**Objectif** : Écran de caisse fonctionnel + Gestion complète des produits
**Référence manuel Loyverse** : p.13-29 (Using the Register), p.52-90 (Items & Inventory)
**Différenciants couverts** : #6 (Marge %), #7 (Photos stock), #8 (Forced modifiers)

---

## Terminé

### Écran POS (Caisse)
- [x] Layout principal POS (grille catégories + panier + pavé numérique)
- [x] Affichage grilles de catégories avec compteur items
- [x] Sélection catégorie → grille items (nom, prix, photo)
- [x] Ajout item au panier avec quantité
- [x] Calcul automatique des totaux (sous-total, taxes, remises, total)
- [x] Pavé numérique pour quantités et montants
- [x] Gestion des variants (taille, couleur, etc.)
- [x] Gestion des modifiers (obligatoires et optionnels) - **Différenciant #8**
- [x] Recherche rapide par nom ou code-barre
- [x] Scanner code-barre (mobile_scanner, 6 formats) - **Phase 3.4**
- [x] UX panier avancée (+/-, swipe-to-delete) - **Phase 3.5**
- [x] Pages produits personnalisées - **Phase 3.7**

### Paiement & Reçus
- [x] Paiement cash simple
- [x] Multi-paiement (split payments) - **Phase 3.2**
- [x] Génération reçus PDF
- [x] Envoi reçu WhatsApp (wa.me)
- [x] Impression thermique ESC/POS Bluetooth - **Phase 3.3**
- [x] Notes de vente - **Phase 3.10**

### Gestion des Produits
- [x] Écran liste des items avec photos - **Différenciant #7**
- [x] Écran création/édition item
- [x] Upload photo item (Supabase Storage)
- [x] Gestion des catégories (CRUD)
- [x] Gestion des variants (créer, modifier, prix différents)
- [x] Gestion des modifiers (créer, assigner aux items)
- [x] Gestion des codes-barres multiples par item

### Calculs & Business Logic
- [x] Calcul correct de la marge (prix d'achat en % supporté) - **Différenciant #6**
- [x] Calcul des taxes (TVA configurable par item) - **Phase 3.1**
- [x] Gestion arrondi caisse (0/50/100/200 Ar)
- [x] Remises (montant fixe ou %) - **Phase 3.1**

## En cours / Bloqué

### Inventaire (0% fait)
- [ ] Écran liste stock avec photos (filtrable/searchable)
- [ ] Filtres : catégorie, stock faible, rupture
- [ ] Ajustement stock manuel
- [ ] Historique des mouvements de stock
- [ ] Alertes stock faible (configurable par item)
- [ ] Export inventaire (CSV/PDF) - **Différenciant #10**
- [ ] Impression inventaire - **Différenciant #10**
- [ ] Coût moyen pondéré (CUMP) pour valorisation stock
- [ ] Import CSV/Excel items

### Mobile Money ✅ 100%
- [x] Backend MVola & Orange Money - **Différenciant #4**
- [x] Tables DB + migrations
- [x] Écran réglages MVola/OM (toggle + merchant numbers)

### Clients & Crédits ✅ 90% (manque vente à crédit depuis POS)
- [x] Tables customers, credit_sales, credit_payments
- [x] Migrations + RLS
- [x] BLoCs (CustomerBloc, CreditBloc)
- [x] Écran liste clients (recherche, filtre crédit)
- [x] Écran créer/éditer client
- [x] Écran détail client (onglets historique + crédits)
- [x] Dialog paiement crédit (montants rapides, multi-paiement)
- [ ] Écran vente à crédit depuis POS - **Différenciant #3** (Sprint 3)

---

## Résultat Sprint 2

✅ **95% COMPLET** — POS opérationnel, clients/crédits UI complet, mobile money settings complet. Manque : inventaire (Sprint 3)

**Commits récents** :
- Sprint 2 final : UI Clients (liste, form, detail, crédits) + Mobile Money Settings
- `cde6a4f` — Drift tables + DAOs offline POS sales
- `c1f2473` — Audit complet : 17 fixes, migrations appliquées
- `e1ebbd6` — Correction 37 erreurs critiques Phases 3.8 & 3.9
- `da703fe` — Sécurisation PIN hashing + désactivation logs debug
- `e7b9f2e` — Phase 3.10 : Notes de vente

---

# Phase 3 — Features Avancées (Phases individuelles)

## Phase 3.1 — Taxes & Remises ✅ 100%
- [x] TVA configurable par item
- [x] Remises fixes et %
- [x] Calculs corrects avec arrondi Ariary

## Phase 3.2 — Multi-paiement ✅ 100%
- [x] Split payments (cash + carte + mobile money)
- [x] UI liste paiements dans écran checkout
- [x] Enregistrement multiple payment_methods par sale

## Phase 3.3 — Impression thermique ✅ 100%
- [x] Bluetooth ESC/POS (blue_thermal_printer)
- [x] Format 58mm/80mm
- [x] Logo magasin + infos complètes

## Phase 3.4 — Scanner code-barre ✅ 100%
- [x] mobile_scanner
- [x] 6 formats supportés (EAN-13, UPC-A, Code128, etc.)
- [x] Recherche automatique item après scan

## Phase 3.5 — UX panier avancée ✅ 100%
- [x] Boutons +/- quantité
- [x] Swipe-to-delete items
- [x] Animations fluides

## Phase 3.6 — Variants & Modifiers ✅ 100%
- [x] Variants (taille, couleur)
- [x] Modifiers optionnels
- [x] Modifiers obligatoires (forced) - **Différenciant #8**
- [x] UI sélection dans POS

## Phase 3.7 — Pages produits personnalisées ✅ 100%
- [x] Custom product pages
- [x] Layout configuré par catégorie
- [x] Affichage conditionnel dans grille POS

## Phase 3.8 — MVola & Orange Money ✅ 100%
- [x] Tables DB + migrations
- [x] Backend intégration API
- [x] Support multi-paiement
- [x] UI écran settings (toggle + merchant numbers)

## Phase 3.9 — Clients & Crédits ✅ 90%
- [x] Tables customers, credit_sales, credit_payments
- [x] Migrations + RLS
- [x] Backend logic
- [x] BLoCs (CustomerBloc, CreditBloc)
- [x] UI screens (liste, créer/éditer, détail avec onglets, paiement crédit dialog)
- [ ] Vente à crédit depuis POS (Sprint 3)

## Phase 3.10 — Notes de vente ✅ 100%
- [x] Champ notes dans sales
- [x] UI input note dans POS
- [x] Affichage dans reçus

---

# Sprint 3 — Inventaire Avancé & Clients (À FAIRE)

**Objectif** : Compléter inventaire + UI clients/crédits + mobile money settings
**Différenciants couverts** : #1 (Offline refunds/clients), #3 (Vente à crédit), #4 (Mobile money), #9 (Inventaire avancé), #10 (Export inventaire)

## À faire

### Inventaire - **Différenciants #9 & #10**
- [ ] Écran liste stock (photos, search, filtres)
- [ ] Ajustement stock manuel
- [ ] Historique mouvements
- [ ] Alertes stock faible
- [ ] Export CSV/PDF
- [ ] Impression inventaire
- [ ] CUMP (coût moyen pondéré)
- [ ] Import CSV/Excel

### Clients & Crédits - **Différenciant #3**
- [x] Écran liste clients ✅
- [x] Créer/éditer client (offline capable) ✅
- [ ] Vente à crédit depuis POS
- [x] Écran paiement crédit (dialog) ✅
- [x] Historique crédits par client ✅

### Mobile Money Settings - **Différenciant #4** ✅
- [x] Écran réglages MVola/Orange Money (toggle + merchant numbers) ✅

### Refunds - **Différenciant #1 (partie)**
- [ ] Écran liste ventes (searchable)
- [ ] Sélection vente → détails
- [ ] Remboursement total
- [ ] Remboursement partiel (items sélectionnables)
- [ ] Offline-capable (sync après)

---

# Sprint 4 — Tickets & Shifts (À FAIRE)

**Objectif** : Open tickets + Shifts + Customer display
**Référence Loyverse** : p.30-34 (Open Tickets), p.35-43 (Shifts), p.151-155 (Dining Options)

## À faire

### Open Tickets
- [x] Table open_tickets (DB existe)
- [ ] Écran liste tickets ouverts
- [ ] Sauvegarder panier comme ticket
- [ ] Rouvrir ticket → restaurer panier
- [ ] Supprimer ticket
- [ ] Permission CASHIER (annuler items sauvegardés)

### Shifts
- [x] Table shifts (DB existe)
- [ ] Écran démarrer shift (montant caisse début)
- [ ] Écran clôturer shift (comptage espèces)
- [ ] Rapport shift (ventes, paiements, écarts)
- [ ] Historique shifts
- [ ] Permission CASHIER (voir rapport shift)

### Predefined Tickets
- [ ] Templates tickets récurrents
- [ ] Sauvegarder panier comme template
- [ ] Charger template → panier

### Dining Options
- [ ] Dine-in / Takeaway / Delivery
- [ ] Gestion tables (si dine-in)
- [ ] UI sélection option dans POS

---

# Sprint 5 — Loyalty & Reports (À FAIRE)

**Objectif** : Programme fidélité + Rapports avancés
**Référence Loyverse** : p.91-108 (Customers & Loyalty), p.186-235 (Analytics)

## À faire

### Loyalty Program
- [ ] Points par Ariary dépensé
- [ ] Récompenses configurables
- [ ] Application automatique lors vente
- [ ] Historique points client

### Reports & Analytics
- [ ] Dashboard Vue d'ensemble
- [ ] Rapports ventes (jour/semaine/mois)
- [ ] Rapports items vendus (top produits)
- [ ] Rapports employés (ventes par cashier)
- [ ] Rapports paiements (cash/carte/mobile money)
- [ ] Export PDF/Excel
- [ ] Graphiques fl_chart

---

# Sprint 6 — Settings & Polish (À FAIRE)

**Objectif** : Écrans réglages + permissions CASHIER + polish final

## À faire

### Settings
- [ ] Écran Store Settings
- [ ] Écran Employees (liste, créer, permissions)
- [ ] Écran POS Devices
- [ ] Écran Receipt Settings (logo, footer)
- [ ] Écran Printer Settings
- [ ] Écran Notifications

### Permissions CASHIER configurables
- [ ] Voir tous les reçus
- [ ] Remises restreintes (max %)
- [ ] Modifier taxes
- [ ] Accepter paiements
- [ ] Remboursements
- [ ] Gérer tous les tickets
- [ ] Voir rapport shift
- [ ] Annuler items sauvegardés
- [ ] Voir stock depuis caisse

### Polish
- [ ] Animations polish
- [ ] Feedback tactile
- [ ] Loading states
- [ ] Error handling UX
- [ ] Tests E2E
- [ ] Tests unitaires coverage 80%+

---

# Différenciants — État Global

| # | Différenciant | État | Notes |
|---|---------------|------|-------|
| 1 | Offline 100% | 🟡 70% | POS offline OK, refunds/clients manquent |
| 2 | Multi-users gratuit | ✅ 100% | Système rôles opérationnel |
| 3 | Vente à crédit | 🟡 90% | UI clients/crédits fait, manque vente crédit depuis POS |
| 4 | MVola & Orange Money | ✅ 100% | Backend + Settings UI complet |
| 5 | Interface Malagasy | ✅ 100% | FR/MG complet |
| 6 | Marge correcte (coût %) | ✅ 100% | Implémenté |
| 7 | Photos liste stock | ✅ 100% | Écran items avec photos |
| 8 | Forced modifiers | ✅ 100% | Implémenté |
| 9 | Inventaire avancé gratuit | ⚪ 0% | À faire Sprint 3 |
| 10 | Export/impression inventaire | ⚪ 0% | À faire Sprint 3 |

---

# État Général — 2026-03-26

**Sprint actuel** : Sprint 2 (95% complet — manque inventaire)
**Prochain sprint** : Sprint 3 — Inventaire + Refunds + Vente a credit POS

**Priorite immediate** :
1. Ecran inventaire (liste stock, filtres, ajustements) - **Differenciants #9 & #10**
2. Export/impression inventaire
3. Vente a credit depuis POS (differenciant #3)
4. UI refunds offline (differenciant #1)

**Bloqueurs** : Aucun
**Dépendances** : Aucune

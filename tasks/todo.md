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

# Sprint 3 — Inventaire, Remboursements & Vente à Crédit

**Semaine** : 5-7
**Objectif** : Inventaire avancé gratuit + Remboursements offline + Vente à crédit depuis POS
**Référence manuel Loyverse** : p.52-90 (Items & Inventory), p.67-68 (Refunds), p.101-137 (Advanced Inventory)
**Différenciants couverts** : #1 (Offline refunds), #3 (Vente à crédit), #9 (Inventaire avancé gratuit), #10 (Export/impression inventaire)

---

## État du code existant (audit pré-sprint)

### Ce qui EXISTE déjà
- ✅ Tables Drift : `refunds`, `refund_items` (complètes avec queries)
- ✅ DAO : `RefundDao` (insertFullRefund, watchRefundsByStore, markSynced)
- ✅ Tables Drift : `credits`, `credit_payments` (complètes)
- ✅ DAOs : `CreditDao`, `CustomerDao` (complets)
- ✅ BLoCs : `CustomerBloc`, `CreditBloc` (complets)
- ✅ Écrans clients : liste, form, détail, paiement crédit dialog
- ✅ `PaymentType.credit` enum dans sale.dart (existe mais pas exposé en UI)
- ✅ Tables Supabase : refunds, refund_items (dans migration 002)
- ✅ Tables Supabase : customers, credits, credit_payments (migration 006)
- ✅ Champs items : `track_stock`, `in_stock`, `low_stock_threshold`, `average_cost`

### Ce qui MANQUE
- ❌ Drift tables inventaire : stock_adjustments, stock_adjustment_items, inventory_counts, inventory_count_items, inventory_history
- ❌ DAOs inventaire : aucun
- ❌ BLoC refunds : aucun
- ❌ Repository refunds : aucun
- ❌ Migrations Supabase inventaire : aucune
- ❌ Écrans inventaire : aucun (0 sur 5 prévus)
- ❌ Écrans refunds : aucun
- ❌ Bouton "Vente à crédit" dans PaymentScreen

---

## Phase 3.11 — Vente à Crédit depuis POS ⬜ (1-2 jours)

**Pourquoi en premier** : 90% du code existe déjà. Impact immédiat, effort minimal. Différenciant #3 unique.

### Tâches

#### 3.11.1 — Bouton crédit dans PaymentScreen
- [ ] Ajouter `PaymentType.credit` dans `_buildPaymentTypeGrid()` de PaymentScreen
- [ ] Icône : `Icons.account_balance_wallet`, label : `l10n.creditSale`
- [ ] Condition : visible uniquement si un client est sélectionné (ou prompt sélection)

#### 3.11.2 — Flow sélection client
- [ ] Si crédit sélectionné et aucun client attaché → ouvrir CustomerPickerDialog
- [ ] CustomerPickerDialog : recherche par nom/téléphone, bouton "Nouveau client"
- [ ] Résultat : customer_id attaché à la vente

#### 3.11.3 — Création du crédit à la validation
- [ ] Quand paiement type = credit, créer un enregistrement `credits` via CreditBloc
- [ ] Dialog date d'échéance (DatePicker avec suggestions : 7j, 15j, 30j, custom)
- [ ] Note optionnelle sur le crédit
- [ ] Statut initial : `pending`
- [ ] Montant du crédit = total de la vente (ou montant partiel si split payment)

#### 3.11.4 — Écran Ventes à Crédit (Écran 34)
- [ ] Route `/customers/credits`
- [ ] Résumé en haut : total dettes en cours + nb en retard (rouge)
- [ ] Filtres : En attente / Partiel / Payé / En retard
- [ ] Chaque ligne : client, montant total, payé, restant, date limite, statut coloré
- [ ] Tap → enregistrer paiement (réutiliser CreditPaymentDialog existant)
- [ ] Bouton WhatsApp rappel en 1 tap (`wa.me/{phone}?text={message}`)

#### 3.11.5 — Localisation
- [ ] Clés FR : `creditSale`, `selectCustomerForCredit`, `dueDate`, `dueDateSuggestion7d`, `dueDateSuggestion15d`, `dueDateSuggestion30d`, `totalDebts`, `overdueDebts`, `creditSaleConfirmation`
- [ ] Clés MG : idem traduit
- [ ] Vérifier zéro string hardcodée

#### 3.11.6 — Vérification
- [ ] Test : créer vente à crédit → vérifie crédit créé dans DB
- [ ] Test : paiement partiel via dialog → statut passe à `partial`
- [ ] Test : paiement total → statut passe à `paid`
- [ ] Test offline : vente à crédit sans connexion → sync après
- [ ] Test rôle CASHIER

---

## Phase 3.12 — Remboursements Offline 🟡 80% (2-3 jours)

**Pourquoi en second** : Infrastructure Drift/DAO existe. Différenciant #1 fort (Loyverse bloque les refunds offline).

### Tâches

#### 3.12.1 — Repository + BLoC Refunds ✅
- [x] `RefundRepository` (lib/features/pos/data/repositories/refund_repository.dart)
  - `createRefund(refund, items)` → Drift local + sync Supabase background
  - `getRefundsBySale(saleId)` → stream depuis Drift
  - `getRefundsByStore(storeId)` → stream depuis Drift
- [x] `RefundBloc` (lib/features/pos/presentation/bloc/refund_bloc.dart)
  - Events : `LoadRefunds`, `CreateRefund`, `LoadRefundsBySale`
  - States : `RefundInitial`, `RefundLoading`, `RefundLoaded`, `RefundCreated`, `RefundError`
- [x] Enregistrer dans main.dart (DI)

#### 3.12.2 — Écran Liste des Reçus (Écran 12) ✅
- [x] Route `/pos/receipts`
- [x] AppBar : "Historique ventes"
- [x] Filtres : Tous / Aujourd'hui / Cette semaine + filtre employé + filtre paiement
- [x] Chaque reçu : numéro, heure, nb items (résumé), total, mode paiement, employé
- [x] Badge "Remboursé" en rouge si refund existe
- [x] Badge "Non synchronisé" orange si synced=false
- [x] Pull-to-refresh + pagination (ListView.builder)
- [x] Barre de recherche par numéro de reçu ou nom client

#### 3.12.3 — Écran Détail Reçu (Écran 13) ✅
- [x] Route `/pos/receipts/:id`
- [x] Header : numéro reçu, date/heure, employé, caisse
- [x] Liste items : nom, qté, prix unitaire, remise, total ligne
- [x] Pied : sous-total, taxes, remises, TOTAL
- [x] Modes de paiement avec montants
- [x] Boutons : "Rembourser" · "Imprimer" · "WhatsApp"
- [x] Si déjà remboursé : afficher résumé du refund, bouton "Rembourser" désactivé

#### 3.12.4 — Écran Remboursement (Écran 14) ✅
- [x] Route `/pos/receipts/:id/refund`
- [x] Deux colonnes (tablette) ou scroll vertical (mobile)
- [x] Colonne gauche : items du reçu original (photo, nom, qté, prix)
- [x] Tap sur item → passe à droite avec qté sélectionnable (spinner 1 à qté originale)
- [x] "Tout rembourser" : sélectionne tous les items d'un coup
- [x] Champ raison (obligatoire) : dropdown (Défectueux / Erreur / Client insatisfait / Autre)
- [x] Total à rembourser mis à jour en temps réel
- [x] Bouton "Confirmer le remboursement" (rouge, avec confirmation dialog)
- [x] **Fonctionne offline** (synced=false, sync background)

#### 3.12.5 — Mise à jour stock après refund ⚠️ (reporté à Phase 3.14)
- [ ] Si item a `track_stock=true`, réincrémenter `in_stock` dans Drift
- [ ] Enregistrer dans `inventory_history` (table n'existe pas encore → Phase 3.14)
- [ ] Mise à jour locale immédiate, sync Supabase en background

#### 3.12.6 — Routes + Navigation ✅
- [x] Ajouter routes dans app_router.dart : `/pos/receipts`, `/pos/receipts/:id`, `/pos/receipts/:id/refund`
- [ ] Accès depuis menu POS (...) → "Historique ventes" (placeholder dans écran TODO)
- [x] Accès depuis détail reçu → "Rembourser"
- [ ] Guard : refund accessible OWNER/ADMIN/MANAGER + CASHIER si permission activée (TODO permissions)

#### 3.12.7 — Localisation ✅
- [x] Clés FR/MG : `salesHistory`, `receiptDetail`, `refund`, `refundAll`, `refundReason`, `reasonDefective`, `reasonError`, `reasonDissatisfied`, `reasonOther`, `confirmRefund`, `refundSuccess`, `alreadyRefunded`, `notSynced`

#### 3.12.8 — Vérification ⬜
- [ ] Test : remboursement total → stock réincrémenté, reçu marqué "Remboursé"
- [ ] Test : remboursement partiel (2 items sur 5) → montant correct
- [ ] Test offline : remboursement sans connexion → synced=false, sync après reconnexion
- [ ] Test CASHIER : vérifie que la permission bloque si non autorisé
- [ ] Test : double remboursement impossible sur le même reçu

**Note** : Les écrans sont créés avec placeholders pour les données réelles. L'intégration complète avec SaleBloc nécessitera de charger les ventes depuis Drift. Stock update après refund reporté à Phase 3.14 (dépend de inventory_history).

---

## Phase 3.13 — Vue d'ensemble Stock & Alertes ✅ (2-3 jours)

**Pourquoi** : Base nécessaire avant les ajustements et l'inventaire physique. Différenciant #9.

### Tâches

#### 3.13.1 — Écran Vue d'ensemble Stock (Écran 24) ✅
- [x] Route `/inventory`
- [x] Métriques en haut (3 cards) :
  - Ruptures : nb items avec in_stock=0 et track_stock=true (fond rouge)
  - Alertes : nb items avec in_stock ≤ low_stock_threshold (fond amber)
  - Valeur stock : Σ(average_cost × in_stock) formaté en Ariary (fond bleu)
- [x] Liste items triée par urgence : ruptures d'abord, puis alertes, puis OK
- [x] Chaque item : photo (44px), nom, catégorie, stock actuel (coloré), prix
- [x] Filtre chips : Tous / Bas stock / Rupture
- [x] Tap item → dialog quick edit stock (simple stock update)
- [ ] Recherche par nom/SKU/barcode (future enhancement)
- [ ] Filtre par catégorie (future enhancement)
- [ ] FAB menu : Ajustement / Export / Impression (Phase 3.15)

#### 3.13.2 — Repository Inventaire ✅
- [x] Réutilise `ItemDao` et `ItemRepository` existants
- [x] `UpdateItemStockEvent` existant utilisé pour quick edit

#### 3.13.3 — BLoC Inventaire ✅
- [x] Réutilise `ItemBloc` existant
- [x] Filtrage côté UI (performant pour données locales)

#### 3.13.4 — Quick Edit Stock (dialog) ✅
- [x] Dialog avec :
  - Nom item + stock actuel
  - Champ numérique nouveau stock
  - Bouton "Valider" → met à jour in_stock via ItemBloc

#### 3.13.5 — Alertes stock faible
- [ ] Notification locale quand stock passe sous le seuil (Phase 3.14)
- [ ] Badge rouge sur l'onglet Produits dans la bottom nav (future)
- [ ] Section alertes dans le dashboard (Sprint 5)

#### 3.13.6 — Routes + Navigation ✅
- [x] Route `/inventory` ajoutée dans app_router.dart
- [x] Import écran dans router
- [ ] Onglet "Stock" dans la bottom nav (future - Phase 3.14)

#### 3.13.7 — Localisation ✅
- [x] Clés FR/MG ajoutées : `inventoryTitle`, `inventoryMetrics`, `inventoryOutOfStock`, `inventoryLowStock`, `inventoryTotalValue`, `inventoryFilterAll`, `inventoryFilterLow`, `inventoryFilterOut`, `inventoryEmpty`, `inventoryQuickEdit`, `inventoryCurrentStock`, `inventoryNewStock`, `inventoryStockUpdated`, `inventoryUnitsRemaining`

#### 3.13.8 — Vérification ✅
- [x] Filtres Rupture/Bas stock/Tous fonctionnent
- [x] Quick edit → stock mis à jour via UpdateItemStockEvent
- [x] Métriques correctes (comptage out of stock, low stock, valeur)
- [x] Offline-first : utilise Drift local
- [x] Montants en int Ariary, formatage correct
- [x] Compilation sans erreurs

---

## Phase 3.14 — Ajustements de Stock & Historique ⬜ (3-4 jours)

**Pourquoi** : Fondation pour le suivi stock sérieux. Différenciants #9 et #10.

### Tâches

#### 3.14.1 — Tables Drift inventaire
- [ ] `stock_adjustments.drift` : id, store_id, reason (enum), notes, created_by, synced, created_at, updated_at
- [ ] `stock_adjustment_items.drift` : id, adjustment_id, item_id, item_variant_id, quantity_before, quantity_change, quantity_after, cost, synced, created_at, updated_at
- [ ] `inventory_history.drift` : id, store_id, item_id, item_variant_id, reason (enum), reference_id, quantity_change, quantity_after, cost, employee_id, synced, created_at, updated_at
- [ ] Regenerer : `dart run build_runner build --delete-conflicting-outputs`

#### 3.14.2 — Migration Supabase inventaire
- [ ] Migration `20260326000001_create_inventory_tables.sql`
  - `stock_adjustments` + `stock_adjustment_items` + `inventory_history`
  - RLS par store_id
  - Index sur item_id, created_at, reason
  - Trigger auto-update `updated_at`
- [ ] Appliquer via API Management (HTTPS 443)

#### 3.14.3 — DAOs inventaire
- [ ] `StockAdjustmentDao` (lib/core/data/local/daos/stock_adjustment_dao.dart)
  - `insertFullAdjustment(adjustment, items)` → transaction
  - `watchAdjustmentsByStore(storeId)` → stream
  - `getAdjustmentById(id)` → single
  - `markSynced(id)`
- [ ] `InventoryHistoryDao` (lib/core/data/local/daos/inventory_history_dao.dart)
  - `insertMovement(movement)` → single
  - `watchMovementsByItem(itemId)` → stream
  - `watchMovementsByStore(storeId, {dateFrom, dateTo})` → stream filtré
  - `markSynced(id)`
- [ ] Enregistrer DAOs dans AppDatabase

#### 3.14.4 — Écran Ajustement de Stock (Écran 25)
- [ ] Route `/inventory/adjustments/new`
- [ ] Sélecteur raison : Réception / Perte / Dommage / Inventaire / Autre (radio buttons)
- [ ] Note optionnelle
- [ ] Zone recherche items → ajouter à la liste
- [ ] Pour chaque item ajouté :
  - Photo + nom + SKU
  - Stock actuel (lecture seule, grisé)
  - Champ "Variation" (+/- numérique)
  - Stock après (calculé live, coloré vert/rouge)
- [ ] Bouton "Valider" → insère ajustement + met à jour in_stock de chaque item + enregistre dans inventory_history
- [ ] **Offline-capable** : tout dans Drift, sync background

#### 3.14.5 — Écran Liste des Ajustements (Écran 26)
- [ ] Route `/inventory/adjustments`
- [ ] Liste : date, raison (badge coloré), nb articles, employé, total variation (+/-)
- [ ] Filtres par raison (chips)
- [ ] Filtres par date (date range picker)
- [ ] Tap → détail avec tous les articles ajustés

#### 3.14.6 — Écran Historique Mouvements (intégré dans Écran 24)
- [ ] Onglet "Historique" dans la vue stock (ou route `/inventory/history`)
- [ ] Liste chronologique : date, item, raison, variation, stock après, employé
- [ ] Filtre par item, par raison, par période
- [ ] Icône par raison : sale (→), refund (←), adjustment (⟳), etc.
- [ ] Pull-to-refresh + pagination

#### 3.14.7 — Logique business : mise à jour stock en cascade
- [ ] Après vente (sale) : décrémenter stock items (si track_stock) + log inventory_history
- [ ] Après refund : incrémenter stock + log
- [ ] Après ajustement : +/- stock + log
- [ ] Toutes les opérations dans une transaction Drift pour atomicité

#### 3.14.8 — Routes + Navigation
- [ ] Routes : `/inventory/adjustments`, `/inventory/adjustments/new`, `/inventory/history`
- [ ] Accès depuis FAB de l'écran stock
- [ ] Accès depuis menu contextuel d'un item

#### 3.14.9 — Localisation
- [ ] Clés FR/MG : `stockAdjustment`, `newAdjustment`, `adjustmentList`, `adjustmentDetail`, `reason`, `variation`, `stockAfter`, `stockBefore`, `movementHistory`, `sale`, `refund`, `purchaseOrder`, `transfer`, `noMovements`

#### 3.14.10 — Vérification
- [ ] Test : ajustement +10 → stock augmente de 10, historique enregistré
- [ ] Test : ajustement -5 → stock diminue, alerte si passe sous seuil
- [ ] Test : vente → stock décrémenté + mouvement "sale" dans historique
- [ ] Test : refund → stock incrémenté + mouvement "refund" dans historique
- [ ] Test offline : tout fonctionne sans connexion
- [ ] Test atomicité : si erreur pendant l'ajustement, rien n'est modifié

---

## Phase 3.15 — Export & Impression Inventaire ⬜ (1-2 jours)

**Pourquoi** : Différenciant #10 — impossible chez Loyverse. Forte demande utilisateurs.

### Tâches

#### 3.15.1 — Export CSV
- [ ] Bouton "Export CSV" dans l'écran stock (FAB menu)
- [ ] Colonnes : Nom, SKU, Barcode, Catégorie, Prix vente, Coût, Stock, Seuil alerte, Valeur stock
- [ ] Séparateur `;` (standard français)
- [ ] Encodage UTF-8 avec BOM (Excel FR)
- [ ] Partage via `share_plus` (ou `path_provider` + `open_file`)

#### 3.15.2 — Export PDF
- [ ] Bouton "Export PDF" dans l'écran stock
- [ ] En-tête : nom magasin, date, logo
- [ ] Tableau : même colonnes que CSV
- [ ] Pied : totaux (nb items, valeur stock totale, valeur retail)
- [ ] Package `pdf` (déjà dans pubspec)
- [ ] Partage ou ouverture directe

#### 3.15.3 — Feuille d'inventaire physique (imprimable)
- [ ] Bouton "Feuille d'inventaire" dans FAB
- [ ] PDF avec colonnes : Nom | SKU | Stock système | Stock compté (vide) | Différence (vide)
- [ ] Trié par catégorie puis par nom
- [ ] Format A4, lignes alternées pour lisibilité
- [ ] Impression directe Bluetooth ESC/POS (réutiliser service existant) + PDF

#### 3.15.4 — Impression sur imprimante thermique
- [ ] Format 58mm/80mm (adapter colonnes)
- [ ] Résumé : ruptures, alertes, top 10 items bas stock
- [ ] Réutiliser `PrinterService` existant (Phase 3.3)

#### 3.15.5 — Localisation
- [ ] Clés FR/MG : `exportCsv`, `exportPdf`, `inventorySheet`, `printInventory`, `exportSuccess`, `totalItems`, `totalStockValue`, `totalRetailValue`

#### 3.15.6 — Vérification
- [ ] Test : CSV ouvre correctement dans Excel (séparateur, encodage, accents)
- [ ] Test : PDF contient toutes les colonnes et totaux corrects
- [ ] Test : feuille inventaire a les bonnes colonnes vides
- [ ] Test : impression thermique lisible
- [ ] Montants en int Ariary formatés correctement

---

## Phase 3.16 — Import Items CSV/Excel ⬜ (2-3 jours)

**Pourquoi** : Permet aux commerçants de migrer leur catalogue existant rapidement.

### Tâches

#### 3.16.1 — Écran Import (Écran 23 — onglet Import)
- [ ] Route `/products/import`
- [ ] Bouton "Choisir fichier" (file_picker)
- [ ] Formats : CSV (`;` ou `,` auto-détecté), Excel (.xlsx)
- [ ] Aperçu 5 premières lignes dans un tableau
- [ ] Mapping colonnes : dropdown pour associer chaque colonne du fichier aux champs items

#### 3.16.2 — Validation et preview
- [ ] Validation par ligne : prix est un int, SKU max 40 chars, catégorie existe ou créer
- [ ] Tableau d'erreurs : numéro ligne + message explicatif
- [ ] Compteur : X items valides / Y erreurs
- [ ] Option "Ignorer les erreurs" ou "Corriger et réessayer"

#### 3.16.3 — Insertion batch
- [ ] Insertion batch dans Drift (transaction pour atomicité)
- [ ] Créer catégories manquantes automatiquement
- [ ] Si SKU existe déjà : option "Mettre à jour" ou "Ignorer"
- [ ] Barre de progression pendant l'import
- [ ] Max 10 000 items par import (limite Loyverse respectée)
- [ ] Sync Supabase en background après

#### 3.16.4 — Template CSV téléchargeable
- [ ] Bouton "Télécharger le modèle CSV"
- [ ] Colonnes : Nom*, Catégorie, Prix*, Coût, SKU, Barcode, Stock, Seuil alerte, Description
- [ ] (* = obligatoire)
- [ ] 2 lignes d'exemple pré-remplies

#### 3.16.5 — Localisation
- [ ] Clés FR/MG : `importItems`, `chooseFile`, `preview`, `columnMapping`, `validItems`, `importErrors`, `lineNumber`, `importSuccess`, `downloadTemplate`, `updateExisting`, `skipExisting`

#### 3.16.6 — Vérification
- [ ] Test : import CSV 10 items → tous créés correctement
- [ ] Test : import avec erreurs → erreurs affichées, items valides importés
- [ ] Test : SKU doublon → comportement correct selon option choisie
- [ ] Test : catégorie inexistante → créée automatiquement
- [ ] Test offline : import fonctionne localement

---

## Phase 3.17 — Inventaire Physique ⬜ (2-3 jours)

**Pourquoi** : Feature inventaire avancé ($25/mois chez Loyverse). Différenciant #9.

### Tâches

#### 3.17.1 — Tables Drift inventaire physique
- [ ] `inventory_counts.drift` : id, store_id, type (full/partial), status (pending/in_progress/completed), notes, created_by, completed_at, synced, created_at, updated_at
- [ ] `inventory_count_items.drift` : id, count_id, item_id, item_variant_id, expected_stock, counted_stock, difference, synced, created_at, updated_at
- [ ] Regenerer build_runner

#### 3.17.2 — Migration Supabase
- [ ] Migration `20260326000002_create_inventory_count_tables.sql`
  - `inventory_counts` + `inventory_count_items`
  - RLS par store_id
  - Index sur count_id, status

#### 3.17.3 — DAO inventaire physique
- [ ] `InventoryCountDao`
  - `insertCount(count)` + `updateCount(count)`
  - `insertCountItem(item)` + `updateCountItem(item)`
  - `watchCountsByStore(storeId)` → stream
  - `getCountById(id)` avec items
  - `autoSave(countId)` → sauvegarde incrémentale

#### 3.17.4 — Écran Liste Inventaires (Écran 27)
- [ ] Route `/inventory/counts`
- [ ] Liste : date, type (badge Complet/Partiel), statut (coloré), nb articles comptés
- [ ] FAB "Nouveau comptage"
- [ ] Tap → ouvrir/reprendre le comptage

#### 3.17.5 — Écran Comptage (flow)
- [ ] Étape 1 : Type (Complet = tous items, Partiel = sélection catégorie)
- [ ] Étape 2 : Note optionnelle → démarrer
- [ ] Étape 3 : Mode comptage
  - Liste items avec : nom, SKU, stock attendu (masqué option), champ "Compté"
  - Scan barcode → remplit automatiquement la ligne correspondante
  - Colonne différence calculée live (colorée vert=ok, rouge=écart)
  - Option "Masquer stock attendu" pour comptage à l'aveugle
  - Sauvegarde auto toutes les 30 secondes
  - Compteur progression : "X / Y items comptés"
- [ ] Étape 4 : Aperçu écarts
  - Tableau résumé : items avec différences uniquement
  - Total surplus / Total manquant
  - Bouton "Terminer et ajuster le stock" → crée un stock_adjustment automatique
  - Bouton "Sauvegarder sans ajuster" → conserve le comptage en état

#### 3.17.6 — Localisation
- [ ] Clés FR/MG : `inventoryCount`, `newCount`, `fullCount`, `partialCount`, `countProgress`, `expectedStock`, `countedStock`, `difference`, `surplus`, `shortage`, `finishAndAdjust`, `saveWithoutAdjust`, `autoSaved`, `hideExpected`

#### 3.17.7 — Vérification
- [ ] Test : comptage complet → tous les items track_stock présents
- [ ] Test : comptage partiel → seulement la catégorie sélectionnée
- [ ] Test : scan barcode → bonne ligne sélectionnée
- [ ] Test : "Terminer et ajuster" → stock_adjustment créé avec les écarts
- [ ] Test : auto-save → reprendre un comptage interrompu
- [ ] Test offline : tout le flow fonctionne sans connexion

---

## Résumé Sprint 3 — Ordre d'exécution

| Phase | Feature | Effort | Dépendances | Différenciants |
|-------|---------|--------|-------------|----------------|
| 3.11 | Vente à crédit POS | 1-2j | Aucune (90% prêt) | #3 |
| 3.12 | Remboursements offline | 2-3j | Aucune (DAO prêt) | #1 |
| 3.13 | Vue stock + alertes | 2-3j | Aucune | #9 |
| 3.14 | Ajustements + historique | 3-4j | Phase 3.13 | #9 |
| 3.15 | Export/impression stock | 1-2j | Phase 3.13 | #10 |
| 3.16 | Import CSV/Excel | 2-3j | Phase 3.13 | — |
| 3.17 | Inventaire physique | 2-3j | Phase 3.14 | #9 |
| **TOTAL** | | **13-20 jours** | | |

### Dépendances entre phases
```
3.11 (Crédit POS) ──────────────────────── indépendant
3.12 (Refunds) ─────────────────────────── indépendant
3.13 (Vue stock) ───┬── 3.14 (Ajustements) ──── 3.17 (Inventaire physique)
                    ├── 3.15 (Export)
                    └── 3.16 (Import)
```

### Phases parallélisables
- **Vague 1** : 3.11 + 3.12 + 3.13 (indépendants, peuvent être faits en parallèle)
- **Vague 2** : 3.14 + 3.15 + 3.16 (dépendent de 3.13)
- **Vague 3** : 3.17 (dépend de 3.14)

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

**Sprint actuel** : Sprint 3 — Inventaire, Remboursements & Vente à Crédit
**Sprint précédent** : Sprint 2 (95% complet)

**Ordre d'exécution Sprint 3** :
1. Phase 3.11 — Vente à crédit POS (1-2j) — **Différenciant #3** — 90% prêt
2. Phase 3.12 — Remboursements offline (2-3j) — **Différenciant #1** — DAO prêt
3. Phase 3.13 — Vue d'ensemble stock + alertes (2-3j) — **Différenciant #9**
4. Phase 3.14 — Ajustements stock + historique (3-4j) — **Différenciants #9 & #10**
5. Phase 3.15 — Export/impression inventaire (1-2j) — **Différenciant #10**
6. Phase 3.16 — Import CSV/Excel (2-3j)
7. Phase 3.17 — Inventaire physique (2-3j) — **Différenciant #9**

**Bloqueurs** : Aucun
**Dépendances** : Phases 3.14-3.17 dépendent de 3.13

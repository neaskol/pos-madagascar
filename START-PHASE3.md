# 🚀 Démarrer Phase 3 - Features Avancées Caisse

**Phase précédente** : Phase 2 - POS Screen ✅ VALIDÉE ET TESTÉE
**Phase actuelle** : Phase 3 - Advanced POS Features
**Date de début** : 2026-03-25

---

## 🎯 Objectif Phase 3

Étendre l'écran de caisse avec les fonctionnalités avancées pour atteindre la parité complète avec Loyverse et ajouter nos différenciants.

**Référence** : Manuel Loyverse p.37-68 (Discounts, Split Payment, Open Tickets, Refunds)

---

## 📋 Fonctionnalités à Implémenter

### 1. Multi-Paiement (Split Payment)
- [ ] Interface paiement multi-méthode
- [ ] Cash + Carte combinés
- [ ] Cash + MVola combinés
- [ ] Cash + Orange Money combinés
- [ ] Division montants personnalisée
- [ ] Validation montant total = total vente
- [ ] Génération reçu multi-paiement

### 2. Méthodes de Paiement Supplémentaires
- [ ] **Carte bancaire** (offline = note "Carte", online = intégration future)
- [ ] **MVola** 🇲🇬 - API Madagascar (différenciant #4)
- [ ] **Orange Money** 🇲🇬 - API Madagascar (différenciant #4)
- [ ] **Crédit** (différenciant #3 - inexistant chez concurrents)
- [ ] Sélection méthode dans écran paiement
- [ ] Référence paiement (ex: numéro transaction MVola)

### 3. Remises (Discounts)
- [ ] **Remise %** sur ticket entier
- [ ] **Remise %** par item
- [ ] **Remise montant fixe** sur ticket entier
- [ ] Plusieurs remises cumulées (ordre: plus petite → plus grande)
- [ ] Remises "Restricted access" (permission CASHIER)
- [ ] UI: dropdown "All items" → "Discounts"
- [ ] UI: tap item dans panier → section Discounts
- [ ] Affichage remises dans panier et reçu

### 4. Taxes
- [ ] Configuration taxes par magasin (table `taxes`)
- [ ] Taxes par défaut sur tous produits
- [ ] Taxes spécifiques par produit (override)
- [ ] Calcul automatique dans panier
- [ ] Affichage subtotal + taxes + total
- [ ] Taxes dans reçu détaillé

### 5. Clients sur Vente
- [ ] Recherche client rapide dans POS
- [ ] "Nouveau client rapide" (nom + téléphone)
- [ ] Associer client à vente
- [ ] Affichage client dans panier
- [ ] Client dans reçu
- [ ] Historique achats client (Phase 4)

### 6. Tickets Sauvegardés (Open Tickets)
- [ ] Bouton "Sauvegarder ticket" dans POS
- [ ] Dialogue: nom ticket + commentaire optionnel
- [ ] Tickets prédéfinis (Tables 1-20) si activé dans settings
- [ ] Liste tickets ouverts (bouton dans AppBar)
- [ ] Recherche et tri tickets (nom, montant, heure, employé)
- [ ] Reprendre ticket → charge dans panier
- [ ] Fusion tickets (merge)
- [ ] Division tickets (split)
- [ ] Sync temps réel entre appareils (Supabase Realtime)
- [ ] **Offline complet** (Drift local, sync auto)

### 7. Historique Ventes (Receipts)
- [ ] Écran liste ventes
- [ ] Filtres: date, employé, type paiement, client
- [ ] Recherche par numéro reçu
- [ ] Détail vente (tap sur ligne)
- [ ] Réimprimer reçu
- [ ] Envoyer reçu par email/WhatsApp
- [ ] Remboursements marqués en rouge

### 8. Remboursements (Refunds)
- [ ] Bouton "Rembourser" dans détail vente
- [ ] Écran: liste items à gauche, sélection → droite
- [ ] Remboursement partiel (quelques items)
- [ ] Remboursement total
- [ ] Réintégration stock automatique
- [ ] Type remboursement (cash, carte, crédit magasin)
- [ ] **Offline complet** (différenciant #1 - impossible chez Loyverse p.67)
- [ ] Génération reçu remboursement

### 9. Scanner Barcode
- [ ] Intégration `mobile_scanner`
- [ ] Bouton scan dans AppBar POS
- [ ] Caméra fullscreen + overlay
- [ ] Détection barcode → ajout automatique au panier
- [ ] Support barcodes poids (préfixe 22 ou 23)
- [ ] Beep + vibration succès
- [ ] Message si produit non trouvé

### 10. Données Magasin Réelles
- [ ] Charger `stores` table
- [ ] Charger `store_settings` table
- [ ] Nom magasin dans AppBar et reçus
- [ ] Logo magasin dans reçus
- [ ] Adresse et téléphone dans reçus
- [ ] Footer personnalisé reçus
- [ ] Nom employé courant (depuis AuthBloc)
- [ ] Arrondi caisse selon settings

---

## 🗄️ Tables Database Nécessaires

### Nouvelles tables à créer

```sql
-- Taxes configurables
taxes (
  id, store_id, name, rate DECIMAL(5,2),
  is_default BOOLEAN, active BOOLEAN,
  created_at, updated_at
)

-- Lien items ↔ taxes (M2M)
item_taxes (
  item_id, tax_id,
  PRIMARY KEY (item_id, tax_id)
)

-- Tickets sauvegardés (open tickets)
open_tickets (
  id, store_id, pos_device_id,
  name VARCHAR(100), -- ex: "Table 5" ou "Client Sophie 14h32"
  comment TEXT,
  items JSONB,  -- [{itemId, quantity, price, discounts}]
  employee_id,
  created_at, updated_at
)

-- Clients
customers (
  id, store_id, name, email, phone,
  total_spent INT DEFAULT 0,
  visits_count INT DEFAULT 0,
  last_visit_at TIMESTAMPTZ,
  notes TEXT,
  created_at, updated_at
)

-- Remboursements
refunds (
  id, store_id, original_sale_id,
  receipt_number VARCHAR(50),
  items JSONB,  -- [{itemId, quantity, price}]
  total INT,
  refund_type ENUM('cash', 'card', 'store_credit'),
  employee_id,
  created_at
)
```

### Tables existantes à modifier

```sql
-- Ajouter dans sales
ALTER TABLE sales ADD COLUMN customer_id UUID REFERENCES customers(id);
ALTER TABLE sales ADD COLUMN discount_amount INT DEFAULT 0;
ALTER TABLE sales ADD COLUMN tax_amount INT DEFAULT 0;
ALTER TABLE sales ADD COLUMN is_refunded BOOLEAN DEFAULT false;
ALTER TABLE sales ADD COLUMN refund_id UUID REFERENCES refunds(id);

-- Ajouter dans sale_items
ALTER TABLE sale_items ADD COLUMN discount_amount INT DEFAULT 0;
ALTER TABLE sale_items ADD COLUMN discount_percentage DECIMAL(5,2);
ALTER TABLE sale_items ADD COLUMN tax_amount INT DEFAULT 0;

-- Ajouter dans sale_payments (déjà existe Phase 2)
ALTER TABLE sale_payments ADD COLUMN payment_reference VARCHAR(100);  -- ex: numéro transaction MVola
```

---

## 📐 Architecture Technique

### BLoC à créer ou modifier

```dart
CartBloc  // MODIFIER
├── ApplyDiscountToCart
├── ApplyDiscountToItem
├── RemoveDiscount
├── SetCustomer
└── CalculateTaxes

SaleBloc  // MODIFIER
├── ProcessMultiPayment
├── ProcessRefund
└── LoadSaleHistory

OpenTicketsBloc  // NOUVEAU
├── SaveTicket
├── LoadTickets
├── ResumeTicket
├── MergeTickets
├── SplitTicket
└── DeleteTicket

CustomerBloc  // NOUVEAU
├── SearchCustomers
├── CreateQuickCustomer
├── LoadCustomerById
└── LoadCustomerHistory
```

### Repositories

```dart
CustomerRepository  // NOUVEAU
├── searchCustomers(query)
├── createCustomer()
├── getCustomerById()
└── updateCustomerStats()

OpenTicketRepository  // NOUVEAU
├── saveTicket()
├── getOpenTickets(storeId)
├── deleteTicket()
└── mergeTickets()

RefundRepository  // NOUVEAU
├── createRefund()
├── getRefunds(filters)
└── restockItems()

TaxRepository  // NOUVEAU
├── getTaxes(storeId)
├── getDefaultTax()
└── getTaxesForItem(itemId)
```

### Services

```dart
BarcodeService  // NOUVEAU
├── scanBarcode()
├── parseBarcode()
└── findProductByBarcode()

PaymentService  // NOUVEAU
├── processMVolaPayment()
├── processOrangeMoneyPayment()
└── validatePaymentReference()

DiscountService  // NOUVEAU
├── calculateItemDiscount()
├── calculateCartDiscount()
└── validateRestrictedDiscount()
```

### Screens Nouveaux

```dart
/pos/receipts          // Liste ventes historique
/pos/receipt/:id       // Détail vente + remboursement
/pos/open-tickets      // Liste tickets sauvegardés
/pos/barcode-scanner   // Scanner fullscreen
/customers             // Liste clients (Phase 4)
```

---

## 📖 Documentation à Lire AVANT de Commencer

### Obligatoire

1. **[docs/loyverse-features.md](docs/loyverse-features.md)** - p.37-68
   - Remises (p.37-39)
   - Split Payment (p.49-50)
   - Open Tickets (p.51-63)
   - Merge & Split Tickets (p.54-58)
   - Remboursements (p.67-68)

2. **[docs/database.md](docs/database.md)** - Sections nouvelles tables
   - Tables taxes, customers, open_tickets, refunds
   - Relations et contraintes
   - RLS policies

3. **[docs/formulas.md](docs/formulas.md)** - Calculs avancés
   - Remises cumulées
   - Taxes multiples
   - Arrondi caisse

4. **[docs/differences.md](docs/differences.md)** - Nos différenciants
   - #1: Remboursements offline
   - #3: Vente à crédit
   - #4: MVola & Orange Money

### Recommandé

- **[docs/screens.md](docs/screens.md)** - Nouveaux écrans
- **[PHASE2-COMPLETE.md](PHASE2-COMPLETE.md)** - État Phase 2
- **[docs/design.md](docs/design.md)** - Design system

---

## 🎨 UI/UX Considerations

### Écran Paiement Amélioré
```
┌──────────────────────────────────────┐
│ Payer 15 000 Ar                      │
├──────────────────────────────────────┤
│                                      │
│ ┌────────────┐  ┌────────────┐      │
│ │   💵       │  │   💳       │      │
│ │   Cash     │  │   Carte    │      │
│ └────────────┘  └────────────┘      │
│                                      │
│ ┌────────────┐  ┌────────────┐      │
│ │  📱 MVola  │  │ 🍊 Orange  │      │
│ │            │  │   Money    │      │
│ └────────────┘  └────────────┘      │
│                                      │
│ ┌────────────┐                       │
│ │ 🏪 Crédit  │                       │
│ │  magasin   │                       │
│ └────────────┘                       │
│                                      │
│ ──────────────────────────────       │
│                                      │
│ ☑️ Paiement divisé (Split)           │
│                                      │
│ [Annuler]         [Continuer] →     │
└──────────────────────────────────────┘
```

### Panier avec Remises
```
┌──────────────────────┐
│ Pain        x2       │
│ 1000 Ar     2000 Ar  │
│ 🏷️ -10%     -200 Ar  │  ← Remise item
├──────────────────────┤
│ Café        x3       │
│ 500 Ar      1500 Ar  │
├──────────────────────┤
│ Subtotal   3 500 Ar  │
│ Remise 5%   -175 Ar  │  ← Remise globale
│ TVA 20%      665 Ar  │
│ Arrondi       10 Ar  │
├══════════════════════┤
│ TOTAL      4 000 Ar  │
└──────────────────────┘
```

---

## 🔧 Commandes Préparatoires

### 1. Continuer sur branche existante ou nouvelle
```bash
cd /Users/neaskol/Downloads/AGENTIC\ WORKFLOW/POS

# Option A: Continuer sur feature/pos-screen
git checkout feature/pos-screen

# Option B: Nouvelle branche depuis main
git checkout main
git pull origin main
git checkout -b feature/advanced-pos
```

### 2. Créer migrations Phase 3
```bash
cd supabase
# Créer: migrations/20260325000003_create_taxes_customers.sql
# Créer: migrations/20260325000004_create_open_tickets.sql
# Créer: migrations/20260325000005_create_refunds.sql
# Créer: migrations/20260325000006_alter_sales_discounts_taxes.sql
```

### 3. Installer packages supplémentaires
```bash
# Scanner barcode
flutter pub add mobile_scanner

# API MVola/Orange Money (si disponible sur pub.dev, sinon custom)
# flutter pub add mvola_sdk
# flutter pub add orange_money_sdk
```

---

## 📝 Plan d'Implémentation Suggéré

### Phase 3.1 - Remises & Taxes (2 jours)
1. Migration taxes + configuration
2. UI remise sur item (dialog)
3. UI remise sur ticket (dropdown)
4. Calcul taxes automatique
5. Affichage détaillé panier
6. Tests calculs

### Phase 3.2 - Multi-Paiement (2 jours)
1. UI sélection méthode paiement
2. Interface split payment
3. Validation montants
4. Sauvegarde multi-paiement
5. Reçu multi-paiement
6. Tests combinaisons

### Phase 3.3 - Clients (1 jour)
1. Migration customers
2. Recherche client dans POS
3. Nouveau client rapide
4. Association client → vente
5. Affichage dans reçu

### Phase 3.4 - Tickets Sauvegardés (3 jours)
1. Migration open_tickets
2. UI sauvegarder ticket (dialog)
3. Liste tickets ouverts
4. Reprendre ticket
5. Merge tickets
6. Split tickets
7. Sync Realtime Supabase
8. Tests offline

### Phase 3.5 - Historique & Remboursements (2 jours)
1. Écran liste ventes
2. Filtres et recherche
3. Détail vente
4. UI remboursement
5. Réintégration stock
6. **Tests offline remboursement**
7. Reçu remboursement

### Phase 3.6 - Scanner Barcode (1 jour)
1. Intégration mobile_scanner
2. UI scanner fullscreen
3. Détection + ajout panier
4. Barcodes poids
5. Tests

### Phase 3.7 - Données Magasin (1 jour)
1. Charger stores + store_settings
2. Intégrer dans POS
3. Intégrer dans reçus
4. Nom employé depuis Auth
5. Arrondi caisse

### Phase 3.8 - MVola & Orange Money (3 jours)
1. Étude APIs MVola/Orange Money
2. Service paiement mobile
3. UI références paiement
4. Validation transactions
5. Tests sandbox
6. Documentation

### Phase 3.9 - Vente à Crédit (2 jours)
1. Logique crédit magasin
2. UI paiement crédit
3. Solde client
4. Historique crédits
5. Rappels paiement (Phase 4)

### Phase 3.10 - Polish & Tests (2 jours)
1. Tests end-to-end complets
2. Tests offline chaque feature
3. Bugs & optimisations
4. Documentation utilisateur
5. Vidéos démo

**Total estimé** : 19 jours (4 semaines)

---

## ✅ Critères de Réussite Phase 3

### Must Have (Parité Loyverse)
- ✅ Remises % et montant fixe
- ✅ Multi-paiement (split)
- ✅ Méthodes: Cash, Carte
- ✅ Taxes calculées automatiquement
- ✅ Clients sur vente
- ✅ Tickets sauvegardés
- ✅ Merge & Split tickets
- ✅ Historique ventes
- ✅ Remboursements
- ✅ Scanner barcode
- ✅ Données magasin réelles

### Nice to Have (Différenciants)
- ✅ MVola intégré
- ✅ Orange Money intégré
- ✅ Vente à crédit
- ✅ Remboursements offline
- ✅ Tickets offline complets

---

## 🚀 Commencer Maintenant

### Étape 1 : Lire la doc (1 heure)
```bash
# Ouvrir dans éditeur
code docs/loyverse-features.md  # p.37-68
code docs/database.md           # Tables nouvelles
code docs/formulas.md           # Calculs
code docs/differences.md        # Nos différenciants
```

### Étape 2 : Choisir branche
```bash
# Décider: continuer feature/pos-screen OU nouvelle branche
git checkout feature/pos-screen
# OU
git checkout -b feature/advanced-pos
```

### Étape 3 : Planifier dans todo.md
```bash
code tasks/todo.md
```

Ajouter les tâches Phase 3.1 à 3.10

### Étape 4 : Créer migrations
```bash
code supabase/migrations/20260325000003_create_taxes_customers.sql
```

### Étape 5 : Installer packages
```bash
flutter pub add mobile_scanner
```

### Étape 6 : GO ! 🚀
Commencer par Phase 3.1 - Remises & Taxes

---

## 📞 Questions Fréquentes

**Q: Par où commencer ?**
A: Remises et taxes (Phase 3.1), car impactent tous les autres calculs.

**Q: Combien de temps ça prend ?**
A: 3-4 semaines pour version complète, 2 semaines pour MVP (sans MVola/Orange/Crédit).

**Q: Tester Phase 2 avant ?**
A: Recommandé ! Valider que Phase 2 fonctionne bien avant d'ajouter complexité.

**Q: MVola/Orange Money prioritaires ?**
A: Non, peuvent être Phase 3.11 séparée. Focus d'abord parité Loyverse.

**Q: Crédit magasin complexe ?**
A: Oui. Peut être reporté à Phase 4 si manque de temps.

---

## 🎯 Prêt ?

**Phase 1** : ✅ Validée (Product Management)
**Phase 2** : ✅ Validée et testée (POS Screen)
**Phase 3** : 🚀 Prêt à démarrer

**Let's build the best POS in Madagascar! 💪🇲🇬**

---

**Première action** : Lire [docs/loyverse-features.md](docs/loyverse-features.md) p.37-68

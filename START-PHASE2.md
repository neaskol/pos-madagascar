# 🚀 Démarrer Phase 2 - Écran POS (Caisse)

**Phase précédente** : Phase 1 - Product Management ✅ VALIDÉE
**Phase actuelle** : Phase 2 - POS Screen
**Date de début** : 2026-03-25

---

## 🎯 Objectif Phase 2

Implémenter l'écran de caisse (Point of Sale) - Reproduire Loyverse exactement.

**Référence** : Manuel Loyverse p.26-50 (Sales, Receipts, Payments)

---

## 📋 Fonctionnalités à Implémenter

### 1. Interface Caisse de Base
- [ ] Layout principal : panier à gauche, produits à droite
- [ ] Liste des items dans le panier
- [ ] Total en temps réel
- [ ] Boutons actions : Annuler, Ticket, Paiement

### 2. Ajout Produits
- [ ] Grid de catégories (navigation rapide)
- [ ] Barre de recherche produits
- [ ] Scan barcode
- [ ] Tap sur produit = ajout au panier

### 3. Gestion Panier
- [ ] Quantité ajustable (+ / -)
- [ ] Prix unitaire affiché
- [ ] Subtotal par ligne
- [ ] Supprimer item du panier
- [ ] Vider tout le panier

### 4. Calculs
- [ ] Subtotal (somme items)
- [ ] Taxes (si configurées)
- [ ] Remises (si appliquées)
- [ ] Total final
- [ ] Arrondi caisse (si configuré)

### 5. Paiement (Cash uniquement pour commencer)
- [ ] Écran paiement
- [ ] Saisie montant reçu
- [ ] Calcul monnaie à rendre
- [ ] Validation paiement
- [ ] Génération reçu

### 6. Reçu
- [ ] Génération PDF/texte
- [ ] Numéro de reçu unique
- [ ] Date/heure
- [ ] Liste items
- [ ] Total et paiement
- [ ] Footer personnalisable

### 7. Tickets Sauvegardés (Optional - Phase 2.1)
- [ ] Sauvegarder ticket en cours
- [ ] Reprendre ticket sauvegardé
- [ ] Nom de ticket (ex: "Table 5")

---

## 🗄️ Tables Database Nécessaires

### Nouvelles tables à créer

```sql
-- Ventes finalisées
sales (
  id, store_id, pos_device_id,
  receipt_number, employee_id, customer_id,
  subtotal, tax_amount, discount_amount, total,
  change_due, note, created_at
)

-- Lignes de vente
sale_items (
  id, sale_id, item_id, item_variant_id,
  item_name, quantity, unit_price, cost,
  discount_amount, tax_amount, total
)

-- Paiements (multi-paiement)
sale_payments (
  id, sale_id, payment_type, amount,
  payment_reference, payment_status
)

-- Tickets sauvegardés (optionnel Phase 2.1)
open_tickets (
  id, store_id, pos_device_id,
  name, items JSONB, employee_id, created_at
)
```

---

## 📐 Architecture Technique

### BLoC à créer
```dart
CartBloc
├── CartState (empty, loaded, paying)
├── AddItemToCart
├── RemoveItemFromCart
├── UpdateItemQuantity
├── ClearCart
├── ApplyDiscount
└── ProcessPayment

SaleBloc
├── SaleState
├── CreateSale
├── LoadSales
└── GetReceiptData
```

### Repositories
```dart
SaleRepository
├── createSale()
├── getSales(storeId, filters)
├── getSaleById()
└── generateReceiptNumber()

CartService (en mémoire)
├── addItem()
├── updateQuantity()
├── calculateSubtotal()
├── calculateTax()
└── calculateTotal()
```

### Screens
```dart
/pos
├── PosScreen (main)
├── PaymentScreen
├── ReceiptScreen
└── SavedTicketsScreen (optionnel)
```

---

## 📖 Documentation à Lire AVANT de Commencer

### Obligatoire
1. **[docs/screens.md](docs/screens.md)** - Section "POS Screen"
   - Layout exact
   - Composants UI
   - Interactions

2. **[docs/loyverse-features.md](docs/loyverse-features.md)** - p.26-50
   - Flow complet de vente
   - Comportements précis
   - Cas d'usage

3. **[docs/database.md](docs/database.md)** - Section "Tables ventes"
   - Schéma sales, sale_items, sale_payments
   - Relations
   - Contraintes

4. **[docs/formulas.md](docs/formulas.md)** - Section "Calculs caisse"
   - Calcul taxes
   - Arrondi caisse
   - Monnaie à rendre

### Recommandé
- **[docs/design.md](docs/design.md)** - Design system
- **[docs/sprints.md](docs/sprints.md)** - Sprint 3 plan

---

## 🎨 Design Considerations

### Layout Principal
```
┌─────────────────────────────────────────┐
│         [Catégories Pills]              │
├──────────────┬──────────────────────────┤
│              │                          │
│   PANIER     │    GRID PRODUITS        │
│   (gauche)   │    (droite)             │
│              │                          │
│ ┌─────────┐  │  [🔍 Recherche]         │
│ │ Item 1  │  │  ┌────┬────┬────┬────┐  │
│ │ x2      │  │  │Prod│Prod│Prod│Prod│  │
│ │ 5000 Ar │  │  │ 1  │ 2  │ 3  │ 4  │  │
│ └─────────┘  │  └────┴────┴────┴────┘  │
│              │  ┌────┬────┬────┬────┐  │
│ ┌─────────┐  │  │    │    │    │    │  │
│ │ Item 2  │  │  └────┴────┴────┴────┘  │
│ │ x1      │  │                          │
│ │ 2500 Ar │  │                          │
│ └─────────┘  │                          │
│              │                          │
├──────────────┤                          │
│ Subtotal     │                          │
│ 7 500 Ar     │                          │
│              │                          │
│ [Annuler]    │                          │
│ [Paiement]   │                          │
└──────────────┴──────────────────────────┘
```

### Couleurs & Thème
- Utiliser design system existant (docs/design.md)
- Bouton paiement : Primary color
- Bouton annuler : Secondary
- Total : Grand, visible, police Sora Bold

---

## 🔧 Commandes Préparatoires

### 1. Créer nouvelle branche
```bash
cd /Users/neaskol/Downloads/AGENTIC\ WORKFLOW/POS
git checkout -b feature/pos-screen
```

### 2. Créer migration sales
```bash
cd supabase
# Créer fichier: migrations/20260325000002_create_sales_tables.sql
```

### 3. Créer structure fichiers
```bash
mkdir -p lib/features/pos/{data,domain,presentation}
mkdir -p lib/features/pos/presentation/{screens,widgets,bloc}
```

---

## 📝 Plan d'Implémentation Suggéré

### Phase 2.1 - Layout & Navigation (1 jour)
1. Créer PosScreen avec layout de base
2. Grille produits (statique)
3. Zone panier (vide)
4. Navigation /pos dans router

### Phase 2.2 - Panier (1 jour)
1. CartBloc + CartState
2. Ajouter items au panier
3. Ajuster quantités
4. Supprimer items
5. Calcul subtotal

### Phase 2.3 - Paiement Cash (1 jour)
1. SaleBloc + SaleRepository
2. Migration sales tables
3. PaymentScreen
4. Calcul monnaie
5. Validation et sauvegarde

### Phase 2.4 - Reçu (1 jour)
1. Génération PDF
2. Numéro de reçu unique
3. Affichage reçu
4. Partage/impression

### Phase 2.5 - Polish & Tests (1 jour)
1. Recherche produits
2. Scan barcode (placeholder)
3. Tests end-to-end
4. Bugs & optimisations

---

## ✅ Critères de Réussite Phase 2

### Minimum Viable (Must Have)
- ✅ Ajouter produits au panier
- ✅ Ajuster quantités
- ✅ Voir total en temps réel
- ✅ Payer en cash
- ✅ Générer reçu
- ✅ Sauvegarder vente en DB

### Nice to Have (Phase 2+)
- ⏳ Tickets sauvegardés
- ⏳ Multi-paiement (cash + carte)
- ⏳ Remises sur vente
- ⏳ Client sur vente
- ⏳ Impression reçu

---

## 🚀 Commencer Maintenant

### Étape 1 : Lire la doc (30 min)
```bash
# Ouvrir dans éditeur
code docs/screens.md
code docs/loyverse-features.md
code docs/database.md
```

### Étape 2 : Créer branche
```bash
git checkout -b feature/pos-screen
```

### Étape 3 : Planifier dans todo.md
```bash
code tasks/todo.md
```

Ajouter les tâches Phase 2.1 à 2.5

### Étape 4 : Créer migration
```bash
code supabase/migrations/20260325000002_create_sales_tables.sql
```

### Étape 5 : GO ! 🚀
Commencer l'implémentation

---

## 📞 Besoin d'Aide ?

### Questions Fréquentes
**Q: Par où commencer ?**
A: Layout de base + navigation, puis panier, puis paiement.

**Q: Combien de temps ça prend ?**
A: 3-5 jours pour version de base fonctionnelle.

**Q: Tester Phase 1 avant ?**
A: Optionnel, Phase 2 est indépendante.

### Documentation
- [PHASE1-VALIDATION.md](PHASE1-VALIDATION.md) - État Phase 1
- [docs/screens.md](docs/screens.md) - Design référence
- [CLAUDE.md](CLAUDE.md) - Instructions projet

---

## 🎯 Prêt ?

**Phase 1** : ✅ Validée et committée
**Phase 2** : 🚀 Prêt à démarrer

**Let's build the POS screen! 💪**

---

**Première action** : Lire [docs/screens.md](docs/screens.md) section POS

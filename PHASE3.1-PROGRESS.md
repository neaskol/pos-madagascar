# 🚧 Phase 3.1 - Remises & Taxes (EN COURS)

**Date de démarrage**: 2026-03-25 12:29
**Status**: 🟡 Backend & BLoC complétés - UI en cours

---

## ✅ Completé (Backend & Business Logic)

### 1. Migration Database ✅
**Fichier**: `supabase/migrations/20260325000003_create_taxes_and_discounts.sql`

- ✅ Table `taxes` (id, store_id, name, rate, tax_type, is_default, active)
- ✅ Table `item_taxes` (M2M relation items ↔ taxes)
- ✅ Champs discount/tax ajoutés à `sales` table
- ✅ Champs discount/tax ajoutés à `sale_items` table
- ✅ RLS policies configurées
- ✅ Indexes optimisés
- ✅ Triggers auto-update timestamp

### 2. Domain Entities ✅
**Fichiers créés**:

#### Tax Entity (`lib/features/pos/domain/entities/tax.dart`)
- ✅ Enum `TaxType` (added, included)
- ✅ Class `Tax` avec toutes propriétés
- ✅ Méthode `calculateTaxAmount()` - Type added
- ✅ Méthode `calculateTaxAmount()` - Type included
- ✅ Méthode `calculateTotalWithTax()`
- ✅ Méthode `calculatePriceExcludingTax()`
- ✅ Function `calculateTotalTaxAmount()` pour taxes multiples
- ✅ Formules conformes à `docs/formulas.md`

#### Discount Entity (`lib/features/pos/domain/entities/discount.dart`)
- ✅ Enum `DiscountType` (percentage, fixedAmount)
- ✅ Enum `DiscountTarget` (item, cart)
- ✅ Class `Discount` avec toutes propriétés
- ✅ Méthode `calculateAmount()` - Type percentage
- ✅ Méthode `calculateAmount()` - Type fixedAmount
- ✅ Méthode `applyTo()` avec clamping
- ✅ Helper class `AppliedDiscount`
- ✅ Function `sortDiscountsByAmount()` - ordre Loyverse (plus petit → plus grand)
- ✅ Function `applyMultipleDiscounts()` - remises cumulées

#### CartItem Entity Updated ✅
**Fichier**: `lib/features/pos/domain/entities/cart_item.dart`

- ✅ Remplacé `int discountAmount` → `List<Discount> discounts`
- ✅ Remplacé `int taxAmount` → `List<Tax> taxes`
- ✅ Getter `subtotal` (quantité × prix)
- ✅ Getter `totalDiscountAmount` (calcul avec `applyMultipleDiscounts`)
- ✅ Getter `totalTaxAmount` (taxes après remises)
- ✅ Getter `lineTotal` (subtotal - remises + taxes)
- ✅ Imports ajoutés pour `discount.dart` et `tax.dart`

### 3. Repositories ✅
**Fichiers créés**:

#### TaxRepository Interface (`lib/features/pos/domain/repositories/tax_repository.dart`)
- ✅ `getTaxes(storeId)` - Liste taxes actives
- ✅ `getDefaultTax(storeId)` - Taxe par défaut
- ✅ `getTaxesForItem(itemId)` - Taxes spécifiques item
- ✅ `saveTax(tax)` - Create/Update
- ✅ `deleteTax(taxId)`
- ✅ `setAsDefault(taxId, storeId)` - Définir taxe par défaut

#### TaxRepository Implementation (`lib/features/pos/data/repositories/tax_repository_impl.dart`)
- ✅ Toutes méthodes implémentées avec Supabase
- ✅ Gestion erreurs avec try/catch
- ✅ Queries optimisées avec filtres
- ✅ Logic transaction-like pour `setAsDefault()`

### 4. Services ✅
**Fichier**: `lib/features/pos/data/services/discount_service.dart`

- ✅ `calculateItemDiscount(item)` - Remises cumulées sur item
- ✅ `calculateCartDiscount(items, cartDiscounts)` - Remises sur panier
- ✅ `canApplyRestrictedDiscount(discount, userRole)` - Validation permissions
- ✅ `getDiscountPreview(price, discount)` - Preview montant
- ✅ `validateDiscount(discount, price)` - Validation valeur remise

### 5. CartBloc Updated ✅
**Fichier**: `lib/features/pos/presentation/bloc/cart_bloc.dart`

#### Events Ajoutés ✅
- ✅ `ApplyDiscountToItem(cartItemId, discount)`
- ✅ `RemoveDiscountFromItem(cartItemId, discount)`
- ✅ `ApplyDiscountToCart(discount)`
- ✅ `RemoveDiscountFromCart(discount)`
- ✅ `SetCartTaxes(taxes)`

#### State CartLoaded Extended ✅
- ✅ Ajouté `List<Discount> cartDiscounts`
- ✅ Ajouté `List<Tax> cartTaxes`
- ✅ Getter `grossSubtotal` - Total brut avant remises
- ✅ Getter `itemDiscountsTotal` - Somme remises items
- ✅ Getter `subtotalAfterItemDiscounts` - Après remises items
- ✅ Getter `cartDiscountAmount` - Montant remises panier
- ✅ Getter `subtotalAfterAllDiscounts` - Après toutes remises
- ✅ Getter `totalTaxAmount` - Somme taxes
- ✅ Getter `total` - Total final
- ✅ Getter `totalDiscountAmount` - Total toutes remises
- ✅ Méthode `copyWith()` pour state immutabilité

#### Event Handlers ✅
- ✅ `_onApplyDiscountToItem()` - Ajoute remise à un item
- ✅ `_onRemoveDiscountFromItem()` - Retire remise d'un item
- ✅ `_onApplyDiscountToCart()` - Ajoute remise au panier
- ✅ `_onRemoveDiscountFromCart()` - Retire remise du panier
- ✅ `_onSetCartTaxes()` - Applique taxes à tous les items

### 6. UI Updated ✅
**Fichier**: `lib/features/pos/presentation/widgets/cart_panel.dart`

- ✅ Utilise `state.grossSubtotal` au lieu de `state.subtotal`
- ✅ Passe `state.totalTaxAmount` à PaymentScreen
- ✅ Passe `state.totalDiscountAmount` à PaymentScreen
- ✅ Passe `state.subtotalAfterAllDiscounts` à PaymentScreen

---

## 🚧 En Cours (UI pour Remises)

### 7. Discount UI - Item Level
**Statut**: 🔄 À créer

Fichiers à créer:
- `lib/features/pos/presentation/widgets/item_discount_dialog.dart`

Fonctionnalités:
- [ ] Dialog ouvert en tap sur item dans panier
- [ ] Toggle: Remise % / Montant fixe
- [ ] Input montant avec validation
- [ ] Preview calcul en temps réel
- [ ] Liste remises déjà appliquées
- [ ] Bouton supprimer remise existante
- [ ] Check permission "Restricted access"

### 8. Discount UI - Cart Level
**Statut**: ⏳ À créer

Fichiers à créer:
- `lib/features/pos/presentation/widgets/cart_discount_dialog.dart`

Fonctionnalités:
- [ ] Accès via dropdown "All items" dans POS
- [ ] Toggle: Remise % / Montant fixe (% uniquement pour panier)
- [ ] Input montant avec validation
- [ ] Preview calcul sur subtotal actuel
- [ ] Liste remises panier actives
- [ ] Bouton supprimer remise

---

## ⏳ À Faire (Prochaines Étapes)

### 9. Tax Calculation Auto
**Fichiers à modifier**:
- `lib/features/pos/presentation/screens/pos_screen.dart`
- Charger taxes magasin au chargement POS
- Dispatcher `SetCartTaxes()` automatiquement
- Appliquer taxes spécifiques aux items si configuré

### 10. Cart Panel Display Enhanced
**Fichier**: `lib/features/pos/presentation/widgets/cart_panel.dart`

Affichage détaillé:
```
Sous-total brut     15 000 Ar
Remise item (-10%)  -1 500 Ar
Remise panier (-5%)   -675 Ar
─────────────────────────────
Sous-total net      12 825 Ar
TVA 20%              2 565 Ar
─────────────────────────────
TOTAL               15 390 Ar
```

### 11. Receipt Updated
**Fichier**: `lib/features/pos/presentation/screens/receipt_screen.dart`

- [ ] Afficher remises par item
- [ ] Afficher remises panier
- [ ] Afficher taxes détaillées
- [ ] Section breakdown complet

### 12. Tests
- [ ] Tests calcul remise %
- [ ] Tests calcul remise montant fixe
- [ ] Tests remises cumulées (ordre correct)
- [ ] Tests taxes added
- [ ] Tests taxes included
- [ ] Tests taxes multiples
- [ ] Tests remises + taxes combinés
- [ ] Tests edge cases (remise > prix, etc.)

---

## 📊 Métriques

### Code Créé
- **Migrations**: 1 fichier (140 lignes SQL)
- **Entities**: 2 fichiers (Tax: 107 lignes, Discount: 146 lignes)
- **Repositories**: 2 fichiers (Interface: 18 lignes, Impl: 96 lignes)
- **Services**: 1 fichier (58 lignes)
- **CartItem**: Modifié (ajout 25 lignes)
- **CartBloc**: Modifié (ajout 120 lignes events/handlers/getters)
- **CartPanel**: Modifié (3 propriétés updated)

**Total lignes**: ~700 lignes (backend complet)

### Temps Écoulé
- Documentation: 10 min
- Migration & Entities: 30 min
- Repositories & Services: 25 min
- CartBloc refactoring: 35 min
- Debug & fixes: 15 min

**Total**: ~2 heures (backend & business logic)

---

## 🎯 Prochaine Session

### Priorité 1: UI Remises
1. Créer `item_discount_dialog.dart`
2. Créer `cart_discount_dialog.dart`
3. Intégrer dans cart_panel.dart et pos_screen.dart
4. Tester flow complet

### Priorité 2: Taxes Auto
1. Charger taxes magasin au init POS
2. Dispatcher SetCartTaxes automatiquement
3. Gérer taxes spécifiques items

### Priorité 3: UI Enhancement
1. Améliorer affichage cart_panel avec breakdown
2. Mettre à jour receipt_screen
3. Tester visuellement

---

## ✅ Critères de Succès Phase 3.1

### Backend ✅ (Complété)
- [x] Migration taxes créée et valide
- [x] Entities Tax & Discount implémentées
- [x] Repository taxes fonctionnel
- [x] Service calcul remises fonctionnel
- [x] CartBloc supporte remises et taxes
- [x] CartItem supporte remises et taxes multiples
- [x] Formules conformes à Loyverse (docs/formulas.md)

### UI 🚧 (En cours)
- [ ] Dialog remise item fonctionnel
- [ ] Dialog remise panier fonctionnel
- [ ] Cart panel affiche breakdown détaillé
- [ ] Reçu affiche remises et taxes

### Tests ⏳ (À faire)
- [ ] Calculs remises validés
- [ ] Calculs taxes validés
- [ ] Flow end-to-end remise + taxe

---

## 📝 Notes Techniques

### Formules Implémentées (Conformes à Loyverse)

#### Taxes
```dart
// Tax added: tax = basePrice × rate / 100
taxAddedAmount(1000, 20.0) → 200 Ar

// Tax included: tax = price × rate / (100 + rate)
taxIncludedAmount(1200, 20.0) → 200 Ar

// Multiple taxes: chaque taxe s'applique au PRIX DE BASE
```

#### Remises
```dart
// Multiple discounts: ordre croissant de valeur effective
discounts = [10% sur 10000, 500 fixe]
→ effectiveAmounts = [1000, 500]
→ ordre application: 500 fixe d'abord, puis 10%

// Remise % sur item
discount10Percent.calculateAmount(5000) → 500 Ar

// Remise fixe sur panier
discountFixed1000.applyTo(15000) → 14000 Ar
```

### Architecture
```
UI (Widgets)
    ↓ Events
CartBloc (Business Logic)
    ↓ Uses
DiscountService + Tax calculations
    ↓ Stores in
CartState (items + cartDiscounts + cartTaxes)
```

---

**Prochaine étape**: Créer les dialogues UI pour appliquer les remises

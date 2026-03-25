# 📋 Phase 3.1 - E2E Test Plan (Remises & Taxes)

**Date**: 2026-03-25
**Phase**: 3.1 - Discounts & Taxes System
**Status**: Ready for execution

---

## 🎯 Test Objectives

Validate that:
1. Discount calculations are correct (% and fixed amount)
2. Tax calculations are correct (added and included types)
3. Cumulative discounts work in the right order
4. Cart discounts apply after item discounts
5. Taxes apply on discounted amounts
6. Receipt displays all breakdowns correctly
7. Formulas match `docs/formulas.md` exactly

---

## 🔧 Test Setup

### Prerequisites
- ✅ Phase 3.1 backend deployed
- ✅ Tax auto-loading implemented
- ✅ Enhanced receipt completed
- ✅ App running on test device

### Test Data Required

Create in Supabase:
1. **Default Tax**: "TVA 20%" (rate: 20, type: added, is_default: true)
2. **Test Product**: "Coca-Cola" (price: 2500 Ar)
3. **Test Product 2**: "Pain" (price: 1000 Ar)

---

## ✅ Test Cases

### TC-DISC-001: Item Percentage Discount
**Objective**: Validate percentage discount on single item
**Preconditions**: Cart is empty

**Steps**:
1. Launch POS screen
2. Add "Coca-Cola" (2500 Ar) to cart
3. Tap on item in cart
4. Select "Pourcentage (%)"
5. Enter "10"
6. Verify preview shows:
   - Montant remise: -250 Ar
   - Nouveau prix: 2250 Ar
7. Tap "Appliquer"
8. Verify cart panel shows:
   - Item line: 2250 Ar (with discount icon)
   - Remises items: -250 Ar
9. Process payment and check receipt

**Expected Results**:
- ✅ Discount calculation: 2500 × 10% = 250 Ar
- ✅ New price: 2500 - 250 = 2250 Ar
- ✅ Receipt shows discount details
- ✅ Formula matches `docs/formulas.md`

---

### TC-DISC-002: Item Fixed Amount Discount
**Objective**: Validate fixed amount discount on item
**Preconditions**: Cart is empty

**Steps**:
1. Add "Coca-Cola" (2500 Ar) to cart
2. Tap item → open discount dialog
3. Select "Montant fixe (Ar)"
4. Enter "500"
5. Verify preview: -500 Ar, new price: 2000 Ar
6. Apply and verify cart shows -500 Ar

**Expected Results**:
- ✅ Discount amount: 500 Ar
- ✅ New price: 2500 - 500 = 2000 Ar
- ✅ Receipt breakdown correct

---

### TC-DISC-003: Cumulative Item Discounts
**Objective**: Validate multiple discounts stack correctly
**Preconditions**: Cart is empty

**Steps**:
1. Add "Pain" (1000 Ar) to cart
2. Apply 10% discount
   - Expected: -100 Ar, price: 900 Ar
3. Apply 200 Ar fixed discount
   - Expected: -200 Ar additional
4. Verify total discounts: -300 Ar
5. Verify final price: 700 Ar

**Expected Results**:
- ✅ Discounts sorted smallest to largest
- ✅ First discount: 10% of 1000 = 100 Ar
- ✅ Second discount: 200 Ar fixed
- ✅ Total discount: 100 + 200 = 300 Ar
- ✅ Final: 1000 - 300 = 700 Ar

**Formula Validation** (`docs/formulas.md`):
```
Base: 1000 Ar
Discount 1 (10%): 1000 × 0.10 = 100 Ar
Discount 2 (200 Ar): 200 Ar
Total discounts: 100 + 200 = 300 Ar
Final: 1000 - 300 = 700 Ar
```

---

### TC-DISC-004: Cart Discount (Percentage)
**Objective**: Validate cart-level discount
**Preconditions**: Cart has 2 items

**Steps**:
1. Add "Coca-Cola" x1 (2500 Ar)
2. Add "Pain" x1 (1000 Ar)
3. Subtotal should be: 3500 Ar
4. Tap "Remise panier" button
5. Select "Pourcentage (%)"
6. Enter "5"
7. Verify preview: -175 Ar, new total: 3325 Ar
8. Apply

**Expected Results**:
- ✅ Cart discount: 3500 × 5% = 175 Ar
- ✅ New subtotal: 3325 Ar
- ✅ Receipt shows "Remise panier: -175 Ar"

---

### TC-DISC-005: Cart Discount After Item Discounts
**Objective**: Validate cart discount applies after item discounts
**Preconditions**: Cart is empty

**Steps**:
1. Add "Coca-Cola" (2500 Ar)
2. Apply 10% item discount
   - Item price becomes: 2250 Ar
3. Add "Pain" (1000 Ar) - no discount
4. Subtotal after item discounts: 2250 + 1000 = 3250 Ar
5. Apply 5% cart discount
6. Verify cart discount: 3250 × 5% = 162.5 → 163 Ar (rounded)
7. Final subtotal: 3250 - 163 = 3087 Ar

**Expected Results**:
- ✅ Cart discount applies to subtotal AFTER item discounts
- ✅ Calculation correct per `docs/formulas.md`

---

### TC-TAX-001: Tax Auto-Loading
**Objective**: Validate default tax loads on POS init
**Preconditions**: Default tax exists in database

**Steps**:
1. Navigate to POS screen
2. Verify InitializeCart event dispatched
3. Add any item to cart
4. Verify item has default tax applied

**Expected Results**:
- ✅ Tax repository called with storeId
- ✅ Default tax retrieved and set
- ✅ Items added to cart have tax

---

### TC-TAX-002: Added Tax Calculation
**Objective**: Validate "added" tax type calculation
**Preconditions**: Default tax "TVA 20%" (type: added)

**Steps**:
1. Add "Coca-Cola" (2500 Ar) to cart
2. Verify tax calculation:
   - Base price: 2500 Ar
   - Tax (20% added): 2500 × 0.20 = 500 Ar
   - Line total: 2500 + 500 = 3000 Ar

**Expected Results**:
- ✅ Tax amount: 500 Ar
- ✅ Total: 3000 Ar
- ✅ Formula: `taxAmount = basePrice × rate / 100`

---

### TC-TAX-003: Tax on Discounted Amount
**Objective**: Validate taxes apply AFTER discounts
**Preconditions**: Default tax "TVA 20%", Cart is empty

**Steps**:
1. Add "Coca-Cola" (2500 Ar)
2. Apply 10% discount
   - Discount: -250 Ar
   - Price after discount: 2250 Ar
3. Verify tax calculation:
   - Tax base: 2250 Ar (discounted price)
   - Tax (20%): 2250 × 0.20 = 450 Ar
4. Line total: 2250 + 450 = 2700 Ar

**Expected Results**:
- ✅ Tax applies to discounted amount
- ✅ Tax: 450 Ar (not 500 Ar)
- ✅ Total: 2700 Ar

**Formula Validation**:
```
Base: 2500 Ar
Discount (10%): -250 Ar
Subtotal after discount: 2250 Ar
Tax (20% on 2250): 450 Ar
Final: 2250 + 450 = 2700 Ar
```

---

### TC-TAX-004: Item-Specific Tax Override
**Objective**: Validate item-specific taxes override default
**Preconditions**:
- Default tax: "TVA 20%"
- Item "Pain" has specific tax: "TVA Réduite 5.5%"

**Steps**:
1. Add "Coca-Cola" → should use TVA 20%
2. Add "Pain" → should use TVA 5.5%
3. Verify:
   - Coca-Cola tax: 2500 × 0.20 = 500 Ar
   - Pain tax: 1000 × 0.055 = 55 Ar
4. Total tax: 555 Ar

**Expected Results**:
- ✅ Item-specific tax overrides default
- ✅ Calculations correct per item

---

### TC-FULL-001: Complete Flow with All Features
**Objective**: End-to-end test with discounts + taxes
**Preconditions**: Fresh cart, default tax enabled

**Steps**:
1. Add "Coca-Cola" x2 (2500 Ar each)
   - Subtotal: 5000 Ar
2. Apply 10% discount to Coca-Cola
   - Discount: -500 Ar
   - Item subtotal: 4500 Ar
3. Add "Pain" x1 (1000 Ar) - no item discount
4. Apply 5% cart discount
   - Cart discount on (4500 + 1000): 5500 × 5% = 275 Ar
   - Subtotal after all discounts: 5225 Ar
5. Taxes (20% added):
   - Tax on Coca-Cola (after discount): 4500 × 0.20 = 900 Ar
   - Tax on Pain: 1000 × 0.20 = 200 Ar
   - Total tax: 1100 Ar
6. Final total: 5225 + 1100 = 6325 Ar

**Expected Cart Panel Display**:
```
Sous-total            6 000 Ar
Remises items          -500 Ar
Remise panier          -275 Ar

Taxes                1 100 Ar
─────────────────────────────
TOTAL                6 325 Ar
```

**Expected Receipt**:
```
Articles
──────────────────────────────
Coca-Cola              4 500 Ar
  2 x 2 500 Ar
  🏷️ Remise 10%         -500 Ar
  TVA 20%                +900 Ar

Pain                   1 200 Ar
  1 x 1 000 Ar
  TVA 20%                +200 Ar

──────────────────────────────
Sous-total             6 000 Ar
Remises articles        -500 Ar
Remise panier           -275 Ar
Taxes                 1 100 Ar
──────────────────────────────
TOTAL                 6 325 Ar
```

**Verification Checklist**:
- ✅ All amounts match expected
- ✅ Discount order correct
- ✅ Tax on discounted amounts
- ✅ Receipt breakdown complete
- ✅ Formulas validated

---

### TC-EDGE-001: Discount Validation - Percentage > 100%
**Objective**: Validate discount input validation

**Steps**:
1. Try to apply 150% discount
2. Verify error message shown
3. Verify discount not applied

**Expected**: ✅ Validation prevents invalid input

---

### TC-EDGE-002: Discount Validation - Fixed Amount > Price
**Objective**: Validate fixed discount cannot exceed price

**Steps**:
1. Item price: 2500 Ar
2. Try to apply 3000 Ar discount
3. Verify error shown

**Expected**: ✅ Validation blocks excessive discount

---

### TC-EDGE-003: Zero Discount
**Objective**: Validate zero discount rejected

**Steps**:
1. Try to apply 0% or 0 Ar discount
2. Verify validation error

**Expected**: ✅ Zero discount blocked

---

## 📊 Test Execution Checklist

- [ ] TC-DISC-001: Item Percentage Discount
- [ ] TC-DISC-002: Item Fixed Amount Discount
- [ ] TC-DISC-003: Cumulative Item Discounts
- [ ] TC-DISC-004: Cart Discount (Percentage)
- [ ] TC-DISC-005: Cart Discount After Item Discounts
- [ ] TC-TAX-001: Tax Auto-Loading
- [ ] TC-TAX-002: Added Tax Calculation
- [ ] TC-TAX-003: Tax on Discounted Amount
- [ ] TC-TAX-004: Item-Specific Tax Override
- [ ] TC-FULL-001: Complete Flow
- [ ] TC-EDGE-001: Validation - % > 100
- [ ] TC-EDGE-002: Validation - Amount > Price
- [ ] TC-EDGE-003: Validation - Zero Discount

---

## 🐛 Bug Reporting Template

If a test fails, document:

```markdown
### Bug #XXX: [Short description]

**Test Case**: TC-XXX
**Expected**: [What should happen]
**Actual**: [What actually happened]
**Steps to Reproduce**:
1. ...
2. ...

**Screenshots**: [Attach if applicable]
**Priority**: High/Medium/Low
**Files affected**: [List files]
```

---

## ✅ Acceptance Criteria

Phase 3.1 is validated when:
- ✅ All 13 test cases pass
- ✅ Calculations match `docs/formulas.md`
- ✅ Receipt displays correctly
- ✅ No critical bugs found
- ✅ Edge cases handled

---

## 📝 Test Results

**Executed by**: _____________
**Date**: _____________
**Pass rate**: ___/13
**Status**: ⬜ PASS  ⬜ FAIL

**Notes**:
```
[Record any observations, edge cases discovered, or improvements needed]
```

---

**Ready to execute!** 🚀

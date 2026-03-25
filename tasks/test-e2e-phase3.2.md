# 📋 Phase 3.2 - E2E Test Plan (Multi-Payment / Paiement Divisé)

**Date**: 2026-03-25
**Phase**: 3.2 - Multi-Payment Implementation
**Status**: Ready for execution

---

## 🎯 Test Objectives

Validate that:
1. Single payment mode works correctly (backwards compatibility)
2. Split payment mode allows multiple payment methods
3. Partial payments can be added, viewed, and removed
4. Payment validation works correctly (must equal total)
5. All payment methods are enabled (Cash, Card, MVola, Orange Money)
6. References are required for MVola and Orange Money
7. Receipt displays payment breakdown correctly
8. Backend correctly creates multiple SalePayment records
9. Mode switching clears state properly

---

## 🔧 Test Setup

### Prerequisites
- ✅ Phase 3.2 UI implementation complete
- ✅ AddPaymentDialog widget created
- ✅ SaleRepository supports multi-payment
- ✅ SaleBloc updated with payments parameter
- ✅ Receipt enhanced for payment breakdown
- ✅ App running on test device

### Test Data Required

Create in Supabase/App:
1. **Test Product**: "Coca-Cola" (price: 2500 Ar)
2. **Test Product 2**: "Pain" (price: 1000 Ar)
3. **Default Tax**: "TVA 20%" (rate: 20, type: added)

### Test Cart Setup
For most tests, use this cart:
- Coca-Cola x1 (2500 Ar)
- Pain x1 (1000 Ar)
- Subtotal: 3500 Ar
- Tax (20%): 700 Ar
- **Total: 4200 Ar**

---

## ✅ Test Cases - Single Payment Mode

### TC-SINGLE-001: Cash Payment (Original Flow)
**Objective**: Validate single payment mode with cash works correctly
**Preconditions**: Cart total = 4200 Ar

**Steps**:
1. Navigate to PaymentScreen
2. Verify mode is "Paiement unique" (default)
3. Verify "Espèces" is selected (default)
4. Tap "5 000 Ar" suggested amount
5. Verify "Montant reçu" shows 5000 Ar
6. Verify "Monnaie à rendre" shows 800 Ar (green box)
7. Tap "Valider le paiement"
8. Verify success dialog appears
9. Check receipt

**Expected Results**:
- ✅ Amount received: 5000 Ar
- ✅ Change due: 800 Ar
- ✅ Payment processed successfully
- ✅ Receipt shows: "Espèces: 5 000 Ar", "Monnaie: 800 Ar"

---

### TC-SINGLE-002: Card Payment
**Objective**: Validate card payment in single mode
**Preconditions**: Cart total = 4200 Ar

**Steps**:
1. Navigate to PaymentScreen
2. Verify mode is "Paiement unique"
3. Select "Carte bancaire" (should be enabled now)
4. Verify no "Montant reçu" field appears (exact payment)
5. Verify "Valider le paiement" button is enabled
6. Tap "Valider le paiement"
7. Check receipt

**Expected Results**:
- ✅ Card payment option enabled (Phase 3.2)
- ✅ No amount input required
- ✅ Payment processes correctly
- ✅ Receipt shows: "Carte bancaire: 4 200 Ar"

---

### TC-SINGLE-003: MVola Payment with Reference
**Objective**: Validate MVola payment requires reference
**Preconditions**: Cart total = 4200 Ar

**Steps**:
1. Navigate to PaymentScreen
2. Select "MVola" (should be enabled)
3. Verify no amount input (exact payment)
4. Note: Reference input should appear if implemented
5. Tap "Valider le paiement"
6. Check receipt

**Expected Results**:
- ✅ MVola payment option enabled (Phase 3.2)
- ✅ Payment processes
- ✅ Receipt shows: "MVola: 4 200 Ar"

---

### TC-SINGLE-004: Orange Money Payment
**Objective**: Validate Orange Money payment
**Preconditions**: Cart total = 4200 Ar

**Steps**:
1. Navigate to PaymentScreen
2. Select "Orange Money" (should be enabled)
3. Verify button enabled
4. Process payment
5. Check receipt

**Expected Results**:
- ✅ Orange Money option enabled (Phase 3.2)
- ✅ Payment successful
- ✅ Receipt shows: "Orange Money: 4 200 Ar"

---

## ✅ Test Cases - Split Payment Mode

### TC-SPLIT-001: Switch to Split Payment Mode
**Objective**: Validate mode switching works correctly
**Preconditions**: PaymentScreen open, single mode active

**Steps**:
1. Verify current mode is "Paiement unique"
2. Tap dropdown in AppBar
3. Verify two options visible:
   - "Paiement unique" (with payment icon)
   - "Multi-paiement" (with splitscreen icon)
4. Select "Multi-paiement"
5. Verify UI changes to split payment mode
6. Verify state reset:
   - Amount received cleared
   - Partial payments list empty
   - Remaining amount = total (4200 Ar)

**Expected Results**:
- ✅ Mode dropdown visible in AppBar
- ✅ Mode switches to "Multi-paiement"
- ✅ UI shows split payment interface
- ✅ Remaining amount displayed: 4200 Ar (orange box)
- ✅ Empty state message: "Divisez le paiement en plusieurs méthodes"
- ✅ "Ajouter un paiement" button visible

---

### TC-SPLIT-002: Add First Partial Payment (Cash)
**Objective**: Validate adding first partial payment
**Preconditions**: Split mode active, cart total = 4200 Ar

**Steps**:
1. Verify remaining amount shows: 4200 Ar
2. Tap "Ajouter un paiement"
3. Verify AddPaymentDialog opens
4. Verify dialog title: "Ajouter un paiement"
5. Verify "Espèces" is selected (default)
6. Verify amount field pre-filled with: 4200
7. Change amount to: 2000
8. Tap "Ajouter"
9. Verify dialog closes
10. Verify partial payment appears in list:
    - Icon: payments (cash icon)
    - Label: "Espèces"
    - Amount: "2 000 Ar"
    - Delete button (X) visible
11. Verify remaining amount updates: 2200 Ar (orange)
12. Verify paid amount shows: "Payé: 2 000 Ar / 4 200 Ar"

**Expected Results**:
- ✅ Dialog opens with correct defaults
- ✅ Amount can be modified
- ✅ Payment added to list
- ✅ Remaining amount calculated correctly: 4200 - 2000 = 2200
- ✅ "Valider le paiement" button disabled (not complete)

---

### TC-SPLIT-003: Add Second Partial Payment (Card)
**Objective**: Validate adding second payment method
**Preconditions**: Split mode, first payment added (2000 Ar cash)

**Steps**:
1. Verify remaining amount: 2200 Ar
2. Tap "Ajouter un paiement"
3. Select "Carte bancaire"
4. Verify amount pre-filled with: 2200 (suggested amount)
5. Keep amount as 2200
6. Tap "Ajouter"
7. Verify second payment in list:
    - "Carte bancaire: 2 200 Ar"
8. Verify remaining amount: 0 Ar (green box)
9. Verify "Paiement complet" displayed
10. Verify "Valider le paiement" button enabled

**Expected Results**:
- ✅ Second payment added successfully
- ✅ List shows 2 payments
- ✅ Remaining = 0 Ar (green)
- ✅ Status: "Paiement complet"
- ✅ Payment button enabled

---

### TC-SPLIT-004: Complete Split Payment (Cash + Card)
**Objective**: Validate processing complete split payment
**Preconditions**: Two payments added (2000 cash + 2200 card)

**Steps**:
1. Verify remaining amount = 0 Ar
2. Verify "Valider le paiement" button enabled
3. Tap "Valider le paiement"
4. Verify success dialog appears
5. Tap "Voir le reçu"
6. Verify receipt displays:
   - Section title: "Paiements" (plural)
   - Payment 1: 💳 Espèces - 2 000 Ar
   - Payment 2: 💳 Carte bancaire - 2 200 Ar
   - Divider
   - "Total payé: 4 200 Ar"

**Expected Results**:
- ✅ Payment processes successfully
- ✅ Sale created with 2 SalePayment records
- ✅ Receipt shows payment breakdown
- ✅ Icons displayed for each payment
- ✅ Total paid matches sale total

---

### TC-SPLIT-005: Remove Partial Payment
**Objective**: Validate removing a partial payment
**Preconditions**: Split mode, 2 payments added

**Steps**:
1. Verify 2 payments in list (2000 + 2200)
2. Tap X button on first payment (2000 Ar cash)
3. Verify payment removed from list
4. Verify remaining amount updates: 2000 Ar (orange)
5. Verify paid amount: "Payé: 2 200 Ar / 4 200 Ar"
6. Verify "Valider le paiement" button disabled

**Expected Results**:
- ✅ Payment removed successfully
- ✅ Remaining recalculated: 4200 - 2200 = 2000
- ✅ Button disabled (incomplete)

---

### TC-SPLIT-006: Three Payment Methods (Cash + Card + MVola)
**Objective**: Validate 3+ payment methods
**Preconditions**: Split mode, cart total = 4200 Ar

**Steps**:
1. Add payment 1: Espèces - 1500 Ar
2. Verify remaining: 2700 Ar
3. Add payment 2: Carte bancaire - 1000 Ar
4. Verify remaining: 1700 Ar
5. Add payment 3: MVola - 1700 Ar
   - Enter reference: "TXN123456"
6. Verify remaining: 0 Ar (green)
7. Process payment
8. Check receipt shows all 3 payments with reference

**Expected Results**:
- ✅ All 3 payments visible in list
- ✅ Remaining = 0 Ar
- ✅ Payment successful
- ✅ Receipt breakdown:
  - Espèces: 1 500 Ar
  - Carte bancaire: 1 000 Ar
  - MVola: 1 700 Ar
    Réf: TXN123456
  - Total payé: 4 200 Ar

---

### TC-SPLIT-007: MVola with Required Reference
**Objective**: Validate MVola requires reference in split mode
**Preconditions**: Split mode, remaining = 1700 Ar

**Steps**:
1. Tap "Ajouter un paiement"
2. Select "MVola"
3. Enter amount: 1700
4. Verify "Référence *" field visible
5. Verify hint: "Ex: Transaction #12345"
6. Verify "Ajouter" button disabled (empty reference)
7. Verify error text: "Référence obligatoire pour MVola"
8. Enter reference: "MVL-98765"
9. Verify "Ajouter" button enabled
10. Add payment
11. Verify payment shows with reference in list

**Expected Results**:
- ✅ Reference field required for MVola
- ✅ Validation prevents adding without reference
- ✅ Reference stored with payment
- ✅ Reference displayed in payment list

---

### TC-SPLIT-008: Orange Money with Reference
**Objective**: Validate Orange Money requires reference
**Preconditions**: Split mode, remaining amount > 0

**Steps**:
1. Open add payment dialog
2. Select "Orange Money"
3. Verify reference field required
4. Verify hint: "Ex: Référence OM #67890"
5. Try to add without reference → blocked
6. Enter reference: "OM-54321"
7. Add payment successfully

**Expected Results**:
- ✅ Reference required for Orange Money
- ✅ Validation works
- ✅ Reference stored and displayed

---

### TC-SPLIT-009: Card with Optional Reference
**Objective**: Validate card reference is optional
**Preconditions**: Split mode, remaining amount > 0

**Steps**:
1. Open add payment dialog
2. Select "Carte bancaire"
3. Verify reference field shows: "Référence (optionnelle)"
4. Verify hint: "Ex: 4 derniers chiffres (optionnel)"
5. Enter amount without reference
6. Verify "Ajouter" button enabled (reference not required)
7. Add payment successfully

**Expected Results**:
- ✅ Reference optional for card
- ✅ Can add payment without reference
- ✅ Reference field still available if needed

---

## ✅ Test Cases - Validation

### TC-VAL-001: Cannot Complete with Remaining Amount
**Objective**: Validate button disabled when incomplete
**Preconditions**: Split mode, cart total = 4200 Ar

**Steps**:
1. Add payment: 2000 Ar cash
2. Verify remaining: 2200 Ar (orange)
3. Verify "Valider le paiement" button disabled
4. Try to tap button → nothing happens

**Expected Results**:
- ✅ Button disabled when remaining > 0
- ✅ Visual feedback (button grayed out)

---

### TC-VAL-002: Amount Exceeds Remaining
**Objective**: Validate partial payment cannot exceed remaining
**Preconditions**: Split mode, remaining = 2200 Ar

**Steps**:
1. Open add payment dialog
2. Enter amount: 3000
3. Verify error message: "Montant supérieur au restant"
4. Verify "Ajouter" button disabled
5. Change amount to 2200
6. Verify error disappears
7. Verify button enabled

**Expected Results**:
- ✅ Validation prevents excessive amount
- ✅ Real-time error display
- ✅ Button state reflects validation

---

### TC-VAL-003: Zero Amount Rejected
**Objective**: Validate zero amount blocked
**Preconditions**: Add payment dialog open

**Steps**:
1. Clear amount field (or enter 0)
2. Verify "Ajouter" button disabled
3. Enter valid amount
4. Verify button enabled

**Expected Results**:
- ✅ Zero amount rejected
- ✅ Button disabled for invalid input

---

### TC-VAL-004: Suggested Amount Button
**Objective**: Validate suggested amount auto-fills remaining
**Preconditions**: Remaining = 1700 Ar

**Steps**:
1. Open add payment dialog
2. Verify amount pre-filled: 1700
3. Change amount to 1000
4. Tap "Montant suggéré: 1 700 Ar" button
5. Verify amount resets to 1700

**Expected Results**:
- ✅ Button displays correct suggestion
- ✅ Clicking sets exact remaining amount
- ✅ Helpful for completing payment quickly

---

## ✅ Test Cases - Mode Switching

### TC-MODE-001: Switch from Single to Split (State Reset)
**Objective**: Validate switching clears state properly
**Preconditions**: Single mode, amount entered

**Steps**:
1. Single mode active
2. Select "Espèces"
3. Enter amount received: 5000 Ar
4. Switch to "Multi-paiement"
5. Verify:
   - Amount received cleared
   - Partial payments list empty
   - Remaining = total
6. Switch back to "Paiement unique"
7. Verify:
   - Amount cleared
   - Back to single mode UI

**Expected Results**:
- ✅ Mode switch resets all state
- ✅ No data carries over between modes
- ✅ Clean slate for each mode

---

### TC-MODE-002: Switch During Split Payment (Data Loss Warning)
**Objective**: Validate switching with partial payments entered
**Preconditions**: Split mode, 1 payment added

**Steps**:
1. Split mode with 2000 Ar cash added
2. Switch to "Paiement unique"
3. Verify partial payments cleared
4. Switch back to "Multi-paiement"
5. Verify list is empty (data not preserved)

**Expected Results**:
- ✅ Data cleared on mode switch
- ✅ No confusion between modes
- ⚠️ Future improvement: Add confirmation dialog if data exists

---

## ✅ Test Cases - Receipt Display

### TC-RECEIPT-001: Single Payment Receipt
**Objective**: Validate single payment displays correctly
**Preconditions**: Single cash payment processed (5000 Ar on 4200 Ar total)

**Steps**:
1. View receipt
2. Verify "Paiement" section (singular)
3. Verify shows:
   - "Espèces: 5 000 Ar"
   - "Monnaie: 800 Ar"
4. Verify no payment breakdown section

**Expected Results**:
- ✅ Single payment format (singular)
- ✅ Change displayed for cash
- ✅ No multi-payment UI elements

---

### TC-RECEIPT-002: Multiple Payments Receipt
**Objective**: Validate multi-payment breakdown
**Preconditions**: Split payment processed (2000 cash + 2200 card)

**Steps**:
1. View receipt
2. Verify section title: "Paiements" (plural)
3. Verify each payment has:
   - Icon (if multiple payments)
   - Payment type label
   - Amount
4. Verify divider line
5. Verify "Total payé: 4 200 Ar"
6. Verify no "Monnaie" (split payments are exact)

**Expected Results**:
- ✅ "Paiements" plural title
- ✅ Icons displayed for each method
- ✅ Total paid calculated correctly
- ✅ No change due (split = exact)

---

### TC-RECEIPT-003: Payment with References
**Objective**: Validate references display on receipt
**Preconditions**: Payment with MVola (reference: TXN123)

**Steps**:
1. Process payment with MVola reference
2. View receipt
3. Verify payment shows:
   - "MVola: 1 700 Ar"
   - Indented line: "Réf: TXN123"
4. Verify reference in gray, smaller text

**Expected Results**:
- ✅ Reference displayed below payment
- ✅ Proper formatting (indented, gray)
- ✅ Only shown when reference exists

---

## ✅ Test Cases - Edge Cases

### TC-EDGE-001: Exact Total in Single Mode (No Change)
**Objective**: Validate exact cash payment
**Preconditions**: Cart total = 4200 Ar

**Steps**:
1. Single mode, cash selected
2. Enter amount: 4200
3. Verify "Monnaie à rendre" shows: 0 Ar (green)
4. Process payment
5. Check receipt shows: "Espèces: 4 200 Ar", "Monnaie: 0 Ar"

**Expected Results**:
- ✅ Zero change handled correctly
- ✅ Payment processes normally

---

### TC-EDGE-002: Insufficient Cash Amount
**Objective**: Validate insufficient amount blocked
**Preconditions**: Cart total = 4200 Ar

**Steps**:
1. Single mode, cash
2. Enter amount: 3000
3. Verify "Monnaie à rendre" shows: -1200 Ar (red box)
4. Verify error text: "Montant insuffisant"
5. Verify "Valider le paiement" button disabled

**Expected Results**:
- ✅ Negative change shown in red
- ✅ Error message displayed
- ✅ Button disabled

---

### TC-EDGE-003: Very Large Total with Split Payments
**Objective**: Test split payment with large total
**Preconditions**: Cart total = 150,000 Ar (simulate large order)

**Steps**:
1. Split mode
2. Add 4 different payments to reach 150,000
3. Verify calculations correct
4. Process payment
5. Check receipt formatting

**Expected Results**:
- ✅ Large amounts formatted correctly (spacing)
- ✅ Multiple payments sum correctly
- ✅ Receipt readable

---

### TC-EDGE-004: All Payment Methods in One Sale
**Objective**: Validate using all 4 payment types
**Preconditions**: Cart total = 10,000 Ar

**Steps**:
1. Split mode
2. Add: Cash 2000, Card 3000, MVola 2500, Orange Money 2500
3. Verify total = 10,000
4. Process payment
5. Check receipt shows all 4 methods

**Expected Results**:
- ✅ All 4 payment types work together
- ✅ Icons distinct for each type
- ✅ Receipt clear and organized

---

## ✅ Test Cases - Backend Validation

### TC-BACKEND-001: Multiple SalePayment Records Created
**Objective**: Validate database records for split payment
**Preconditions**: Split payment processed (2 payments)

**Steps**:
1. Process split payment (2000 cash + 2200 card)
2. Check Supabase `sale_payments` table
3. Verify 2 records created:
   - Record 1: type=cash, amount=2000, status=completed
   - Record 2: type=card, amount=2200, status=completed
4. Verify both have same `sale_id`
5. Verify sale record shows `change_due = 0` (not null)

**Expected Results**:
- ✅ 2 separate payment records
- ✅ Both linked to same sale
- ✅ Amounts correct
- ✅ Status = completed
- ✅ No change due in split mode

---

### TC-BACKEND-002: Payment References Stored
**Objective**: Validate references saved to database
**Preconditions**: Payment with MVola reference

**Steps**:
1. Process payment with MVola (ref: "TXN123")
2. Check `sale_payments` table
3. Verify `payment_reference` column = "TXN123"

**Expected Results**:
- ✅ Reference stored correctly
- ✅ Null for payments without reference

---

### TC-BACKEND-003: Backwards Compatibility (Single Payment)
**Objective**: Validate old single payment flow still works
**Preconditions**: Single mode, cash payment

**Steps**:
1. Process single cash payment (5000 on 4200)
2. Check database
3. Verify single `sale_payments` record created
4. Verify sale record shows `change_due = 800`

**Expected Results**:
- ✅ Single payment record (backwards compatible)
- ✅ Change due calculated
- ✅ No breaking changes to existing flow

---

## 📊 Test Execution Checklist

### Single Payment Mode (Backwards Compatibility)
- [ ] TC-SINGLE-001: Cash Payment (Original Flow)
- [ ] TC-SINGLE-002: Card Payment
- [ ] TC-SINGLE-003: MVola Payment
- [ ] TC-SINGLE-004: Orange Money Payment

### Split Payment Mode (New Feature)
- [ ] TC-SPLIT-001: Switch to Split Payment Mode
- [ ] TC-SPLIT-002: Add First Partial Payment (Cash)
- [ ] TC-SPLIT-003: Add Second Partial Payment (Card)
- [ ] TC-SPLIT-004: Complete Split Payment (Cash + Card)
- [ ] TC-SPLIT-005: Remove Partial Payment
- [ ] TC-SPLIT-006: Three Payment Methods (Cash + Card + MVola)
- [ ] TC-SPLIT-007: MVola with Required Reference
- [ ] TC-SPLIT-008: Orange Money with Reference
- [ ] TC-SPLIT-009: Card with Optional Reference

### Validation
- [ ] TC-VAL-001: Cannot Complete with Remaining Amount
- [ ] TC-VAL-002: Amount Exceeds Remaining
- [ ] TC-VAL-003: Zero Amount Rejected
- [ ] TC-VAL-004: Suggested Amount Button

### Mode Switching
- [ ] TC-MODE-001: Switch from Single to Split (State Reset)
- [ ] TC-MODE-002: Switch During Split Payment

### Receipt Display
- [ ] TC-RECEIPT-001: Single Payment Receipt
- [ ] TC-RECEIPT-002: Multiple Payments Receipt
- [ ] TC-RECEIPT-003: Payment with References

### Edge Cases
- [ ] TC-EDGE-001: Exact Total in Single Mode
- [ ] TC-EDGE-002: Insufficient Cash Amount
- [ ] TC-EDGE-003: Very Large Total with Split Payments
- [ ] TC-EDGE-004: All Payment Methods in One Sale

### Backend Validation
- [ ] TC-BACKEND-001: Multiple SalePayment Records Created
- [ ] TC-BACKEND-002: Payment References Stored
- [ ] TC-BACKEND-003: Backwards Compatibility

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

Phase 3.2 is validated when:
- ✅ All 27 test cases pass
- ✅ Single payment mode works (backwards compatibility)
- ✅ Split payment mode fully functional
- ✅ All payment methods enabled (Cash, Card, MVola, Orange Money)
- ✅ Validation prevents invalid payments
- ✅ Receipt displays correctly for both modes
- ✅ Backend creates correct payment records
- ✅ No critical bugs found
- ✅ No regressions in Phase 3.1 functionality

---

## 📝 Test Results

**Executed by**: _____________
**Date**: _____________
**Pass rate**: ___/27
**Status**: ⬜ PASS  ⬜ FAIL

**Notes**:
```
[Record any observations, edge cases discovered, or improvements needed]
```

---

## 🎯 Key Features to Validate

| Feature | Description | Test Cases |
|---------|-------------|------------|
| **Mode Switching** | Toggle between single/split payment | TC-MODE-001, TC-MODE-002 |
| **Partial Payments** | Add/remove multiple payments | TC-SPLIT-002 to TC-SPLIT-006 |
| **Payment Methods** | All 4 types enabled | TC-SINGLE-002 to 004, TC-SPLIT-006 |
| **References** | Required for MVola/Orange Money | TC-SPLIT-007, TC-SPLIT-008 |
| **Validation** | Prevent invalid payments | TC-VAL-001 to TC-VAL-004 |
| **Receipt** | Payment breakdown display | TC-RECEIPT-001 to TC-RECEIPT-003 |
| **Backend** | Multiple SalePayment records | TC-BACKEND-001 to TC-BACKEND-003 |

---

## 🔍 Testing Tips

1. **Clear App State**: Between tests, clear the cart to start fresh
2. **Check Console**: Monitor for any errors during payment processing
3. **Database Verification**: After payments, check Supabase for correct records
4. **Screenshot Everything**: Capture UI states for documentation
5. **Test Both Modes**: Don't skip single payment mode (backwards compatibility critical)
6. **Real Devices**: Test on both iOS and Android if possible
7. **Network States**: Test with WiFi on/off (offline functionality)

---

**Ready to execute!** 🚀

**Madagascar-Specific Note**: MVola and Orange Money are the primary digital payment methods in Madagascar. Proper reference handling is critical for reconciliation and customer support.

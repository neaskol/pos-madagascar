# Phase 3.3 - Receipt Printing & Sharing

**Status:** 🟡 In Progress
**Started:** 2026-03-25
**Target Completion:** 2026-03-25

---

## Overview

Enhance receipt printing and sharing capabilities with thermal printer support (ESC/POS), PDF generation, and multi-channel sharing (WhatsApp, Email, Share).

**Loyverse Behavior (p.78-79):**
- Print receipt after sale completion
- Email receipt (offline queued until online)
- No direct thermal printer support in mobile app (only via separate printer app)
- Actions on receipt: view detail, refund, print, send email

**Our Differentiators:**
- ✅ Direct ESC/POS thermal printer support (no separate app needed)
- ✅ WhatsApp sharing with formatted text receipt
- ✅ PDF generation and sharing via any app
- ✅ Native print dialog for standard printers
- ✅ All features work offline (email/WhatsApp queued)

---

## Objectives

### Core Features
1. **Thermal Printer Support (ESC/POS)**
   - Auto-discover Bluetooth thermal printers
   - Print 80mm receipt format
   - Support standard ESC/POS commands
   - Logo/image printing capability

2. **PDF Receipt Enhancement**
   - Already implemented in Phase 2.4
   - Include store logo and branding
   - Support for discounts and taxes breakdown
   - Multi-payment display

3. **Multi-Channel Sharing**
   - ✅ WhatsApp (already implemented)
   - ✅ PDF Share (already implemented)
   - ✅ Native print dialog (already implemented)
   - ➕ Thermal printer selection and printing

4. **Printer Settings**
   - Store preferred printer
   - Paper width configuration (58mm/80mm)
   - Auto-print after sale (toggle)
   - Print copy count

---

## Implementation Checklist

### Sub-phase 3.3a: Thermal Printer Package Integration
- [ ] Add `esc_pos_utils` package (ESC/POS commands)
- [ ] Add `esc_pos_printer` package (network printers)
- [ ] Add `esc_pos_bluetooth` package (Bluetooth printers)
- [ ] Add `flutter_bluetooth_serial` for device discovery

### Sub-phase 3.3b: Thermal Receipt Service
- [ ] Create `ThermalReceiptService` class
- [ ] Implement ESC/POS receipt formatting
  - [ ] Header (store name, address, phone)
  - [ ] Receipt info (number, date, cashier)
  - [ ] Items table with quantities and prices
  - [ ] Discounts and taxes breakdown
  - [ ] Payment details (multi-payment support)
  - [ ] Change amount
  - [ ] Footer (thank you message, QR code optional)
- [ ] Add logo/image printing support
- [ ] Implement 58mm and 80mm paper formats

### Sub-phase 3.3c: Printer Discovery & Connection
- [ ] Create `PrinterManager` class
- [ ] Implement Bluetooth printer scanning
- [ ] Implement network printer discovery
- [ ] Store selected printer in local settings
- [ ] Handle connection states (connected, disconnected, error)

### Sub-phase 3.3d: UI Integration
- [ ] Update `ReceiptScreen` with printer selection button
- [ ] Add thermal print option alongside PDF print
- [ ] Create printer selection dialog
- [ ] Show printer connection status
- [ ] Add "Auto-print after sale" toggle in settings

### Sub-phase 3.3e: Settings Integration
- [ ] Add printer settings to `StoreSettings`
  - `defaultPrinterId: String?`
  - `autoPrintReceipts: bool`
  - `receiptPaperWidth: int` (58 or 80)
  - `receiptCopies: int`
- [ ] Create printer settings screen
- [ ] Persist printer preferences

### Sub-phase 3.3f: Testing & Polish
- [ ] Test thermal printing with real device
- [ ] Test Bluetooth connection reliability
- [ ] Test offline queuing
- [ ] Test multi-payment receipt formatting
- [ ] Verify all receipt elements display correctly
- [ ] Create E2E test documentation

---

## Technical Architecture

### New Files
```
lib/features/pos/data/services/
  ├── thermal_receipt_service.dart    (ESC/POS formatting)
  └── printer_manager.dart            (Device discovery & connection)

lib/features/pos/presentation/widgets/
  └── printer_selection_dialog.dart   (Printer picker)

lib/features/settings/domain/entities/
  └── printer_settings.dart           (Printer preferences)
```

### Dependencies to Add
```yaml
dependencies:
  esc_pos_utils: ^1.1.0         # ESC/POS command utilities
  esc_pos_bluetooth: ^0.4.1     # Bluetooth printing
  flutter_bluetooth_serial: ^0.4.0  # Bluetooth device discovery
  image: ^4.0.0                 # Image processing for logo
```

---

## Receipt Format (80mm Thermal)

```
           STORE NAME
      Store Address Line 1
      Store Address Line 2
       Tel: 0XX XX XXX XX
=====================================

Reçu N°: RECEIPT-20260325-001
Date: 25/03/2026 14:30
Caissier: Jean Rakoto

-------------------------------------
Articles
-------------------------------------
Coca-Cola 1.5L
  2 x 2 500 Ar          5 000 Ar

Pain
  5 x 800 Ar            4 000 Ar
  🏷️ Promo -10%         -400 Ar

-------------------------------------
Sous-total              9 000 Ar
Remise articles          -400 Ar
Remise panier            -500 Ar
TVA 20%                 1 620 Ar
-------------------------------------
TOTAL                   9 720 Ar
=====================================

Paiements:
  💵 Espèces            5 000 Ar
  📱 MVola              4 720 Ar
-------------------------------------
Total payé              9 720 Ar

Monnaie rendue              0 Ar

=====================================
      Merci de votre visite !
   Retrouvez-nous sur Facebook
=====================================
```

---

## Success Criteria

1. ✅ Thermal printer connects via Bluetooth successfully
2. ✅ Receipt prints with all elements (items, discounts, taxes, payments)
3. ✅ Multi-payment transactions display correctly
4. ✅ Logo/header prints clearly
5. ✅ Both 58mm and 80mm formats supported
6. ✅ Auto-print after sale works when enabled
7. ✅ Printer settings persist across sessions
8. ✅ Works offline (prints immediately, no cloud dependency)

---

## Risk Mitigation

| Risk | Mitigation |
|------|------------|
| Thermal printer compatibility issues | Test with multiple common ESC/POS printer models |
| Bluetooth connection instability | Implement retry logic and clear error messages |
| Receipt formatting issues | Provide both 58mm and 80mm templates |
| Image printing quality | Optimize logo size and format for thermal printing |

---

## Phase Dependencies

**Depends on:**
- ✅ Phase 2.4 - PDF Receipt generation already implemented
- ✅ Phase 3.1 - Discount and tax calculation
- ✅ Phase 3.2 - Multi-payment support

**Enables:**
- Phase 4.x - Kitchen printer support
- Phase 4.x - Customer display integration
- Phase 5.x - Receipt customization per store

---

## Timeline

| Sub-phase | Duration | Status |
|-----------|----------|--------|
| 3.3a - Package Integration | 30 min | 🔴 Not Started |
| 3.3b - Thermal Service | 2 hours | 🔴 Not Started |
| 3.3c - Printer Discovery | 1 hour | 🔴 Not Started |
| 3.3d - UI Integration | 1 hour | 🔴 Not Started |
| 3.3e - Settings Integration | 1 hour | 🔴 Not Started |
| 3.3f - Testing & Polish | 1 hour | 🔴 Not Started |
| **Total** | **6.5 hours** | 🟡 In Progress |

---

## Notes

- Thermal printing is a key differentiator vs web-based POS systems
- ESC/POS is the universal standard for receipt printers
- Bluetooth printing allows cable-free operation
- Must maintain offline-first capability (no cloud printing dependencies)
- Consider adding QR code on receipt for digital receipt lookup

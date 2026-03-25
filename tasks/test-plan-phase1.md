# Test Plan - Phase 1.7: Product Management End-to-End Testing

**Date**: 2026-03-25
**Sprint**: Sprint 2 - Phase 1
**Testing Scope**: Product creation and editing with photos

---

## Prerequisites

- [ ] Supabase project is running locally or connected to remote
- [ ] Storage buckets migration applied (`20260325000001_create_storage_buckets.sql`)
- [ ] Flutter app compiles without errors (`flutter analyze` passed)
- [ ] Localizations generated (`flutter gen-l10n`)
- [ ] Test device/simulator available (iOS or Android)

---

## Test Scenarios

### 1. Product Creation - Basic (No Photo)

**Test ID**: TC-PROD-001
**Objective**: Create a new product with basic information only

**Steps**:
1. Launch the app
2. Complete authentication flow (register/login)
3. Navigate to Products screen (`/products`)
4. Tap "Add Product" button (FAB)
5. Fill in basic fields:
   - Name: "Coca-Cola 1.5L"
   - Category: Select "Boissons" (if exists)
   - Sale Price: 2500 Ar
   - Leave photo section empty
6. Tap "Save" button

**Expected Results**:
- ✅ Product is saved successfully
- ✅ Snackbar shows "Produit enregistré"
- ✅ App navigates back to products list
- ✅ New product appears in the list with fallback color avatar
- ✅ Product shows correct price: "2 500 Ar"
- ✅ Product shows "Hors vente" badge if not available for sale

**Verification Points**:
- Check Drift database: Product exists in local DB with `synced=false`
- Check Supabase: Product synced to cloud (after sync delay)
- Check that auto-generated SKU is unique

---

### 2. Product Creation - With Photo

**Test ID**: TC-PROD-002
**Objective**: Create a new product with a photo

**Steps**:
1. Navigate to Products screen
2. Tap "Add Product" button
3. Tap on photo selection area
4. Grant photo permissions if prompted
5. Select an image from gallery
6. Wait for upload progress
7. Fill in basic fields:
   - Name: "Pizza Margherita"
   - Category: "Plats"
   - Sale Price: 15000 Ar
8. Tap "Save"

**Expected Results**:
- ✅ Image picker opens successfully
- ✅ Selected image appears in form preview
- ✅ Image is uploaded to Supabase Storage
- ✅ Upload shows loading indicator
- ✅ Product is saved with `image_url` field populated
- ✅ Product list shows uploaded photo
- ✅ Photo loads from Supabase public URL

**Verification Points**:
- Check Supabase Storage bucket `product-images`
- Verify file path: `{storeId}/{itemId}.{extension}`
- Verify public URL is accessible
- Check image dimensions ≤ 1024x1024
- Check file size is optimized (quality 85%)

---

### 3. Product Editing - Change Photo

**Test ID**: TC-PROD-003
**Objective**: Edit an existing product and change its photo

**Steps**:
1. Navigate to Products screen
2. Tap on an existing product with a photo
3. Tap on the photo area
4. Select a different image
5. Wait for upload
6. Tap "Save"

**Expected Results**:
- ✅ New photo replaces old photo in preview
- ✅ Old photo is deleted from Storage (if implemented)
- ✅ New photo is uploaded with same file path (upsert=true)
- ✅ Product list reflects updated photo
- ✅ No duplicate files in Storage bucket

---

### 4. Product Editing - All Fields

**Test ID**: TC-PROD-004
**Objective**: Edit all fields of an existing product

**Steps**:
1. Tap on an existing product
2. Modify all fields:
   - Name: "Updated Name"
   - Description: "New description"
   - SKU: "CUSTOM-SKU-001"
   - Barcode: "1234567890123"
   - Sale Price: 5000 Ar
   - Cost: 3000 Ar
   - Toggle "Available for sale"
   - Toggle "Track stock"
   - Current Stock: 50
   - Low Stock Threshold: 10
3. Tap "Save"

**Expected Results**:
- ✅ All changes are saved
- ✅ Product list reflects updates
- ✅ Stock badge shows "50 en stock" with green color
- ✅ Margin calculation is correct: (5000-3000)/5000 = 40%

---

### 5. Stock Indicators

**Test ID**: TC-PROD-005
**Objective**: Verify stock level indicators work correctly

**Test Cases**:

**5.1 - Stock Tracking Disabled**
- Create product with `trackStock=false`
- Expected: No stock badge shown

**5.2 - In Stock (Normal)**
- Create product with `inStock=100`, `lowStockThreshold=10`
- Expected: "100 en stock" badge with green color

**5.3 - Low Stock**
- Create product with `inStock=5`, `lowStockThreshold=10`
- Expected: "5 stock bas" badge with orange/warning color

**5.4 - Out of Stock**
- Create product with `inStock=0`, `trackStock=true`
- Expected: "rupture" badge with red/danger color

---

### 6. Form Validation

**Test ID**: TC-PROD-006
**Objective**: Verify form validation works correctly

**Test Cases**:

**6.1 - Required Fields**
- Try to save without entering Name
- Expected: Validation error "Le nom est obligatoire"

**6.2 - Price Required**
- Try to save without entering Sale Price
- Expected: Validation error "Le prix est obligatoire"

**6.3 - Numeric Fields**
- Try to enter letters in price field
- Expected: Only numbers accepted (keyboard type should be numeric)

---

### 7. Category Integration

**Test ID**: TC-PROD-007
**Objective**: Verify category dropdown and filtering

**Steps**:
1. Create multiple categories using CategoryBloc
2. Create products in different categories
3. Verify category dropdown shows all categories
4. Select a category filter in products list
5. Verify only products from that category are shown

**Expected Results**:
- ✅ Category dropdown populated correctly
- ✅ Category filter works in products list
- ✅ Category chips displayed in product cards

---

### 8. Offline Functionality

**Test ID**: TC-PROD-008
**Objective**: Verify offline-first architecture works

**Steps**:
1. Turn OFF WiFi/mobile data
2. Create a new product with all fields
3. Edit an existing product
4. Check products list
5. Turn ON WiFi/mobile data
6. Wait for background sync

**Expected Results**:
- ✅ Products can be created offline
- ✅ Products can be edited offline
- ✅ Products list shows offline changes immediately
- ✅ Data is saved to Drift with `synced=false`
- ✅ When online, data syncs to Supabase
- ✅ After sync, `synced=true` in Drift

**Note**: Photo upload requires online connection - should show appropriate error message when offline.

---

### 9. Multi-Language Support

**Test ID**: TC-PROD-009
**Objective**: Verify French and Malagasy translations

**Steps**:
1. Change device language to French
2. Navigate to product form
3. Verify all labels are in French
4. Change device language to Malagasy
5. Verify all labels are in Malagasy

**Expected Results**:
- ✅ All strings use AppLocalizations
- ✅ No hardcoded strings visible
- ✅ French translations correct
- ✅ Malagasy translations correct

---

### 10. Permission and RLS

**Test ID**: TC-PROD-010
**Objective**: Verify Row Level Security and Storage policies

**Steps**:
1. Create products as Store A user
2. Try to upload photo
3. Switch to Store B user (different storeId)
4. Try to access Store A's products
5. Try to access Store A's photos

**Expected Results**:
- ✅ Users only see products from their store
- ✅ Photo uploads organized by storeId folder
- ✅ Users cannot access other stores' photos for write/delete
- ✅ Public read access works for product images

---

## Automated Tests Checklist

- [ ] Unit tests for StorageService methods
- [ ] Unit tests for ItemRepository CRUD operations
- [ ] Widget tests for ProductFormScreen
- [ ] Widget tests for ProductsListScreen
- [ ] Integration tests for full product flow
- [ ] BLoC tests for ItemBloc events and states

---

## Known Issues / Limitations

1. **Photo Upload Offline**: Currently requires internet connection
   - Future enhancement: Queue uploads for when online

2. **Photo Compression**: Fixed at 1024x1024, 85% quality
   - Future enhancement: Configurable quality settings

3. **Barcode Scanner**: Not yet implemented (placeholder button)
   - Planned for later phase

4. **Category Creation**: Cannot create categories from product form
   - Must use separate category management screen (to be implemented)

---

## Success Criteria

All test scenarios (TC-PROD-001 to TC-PROD-010) must pass without critical errors.

Minor UI/UX issues can be documented for future sprints.

---

## Manual Testing Results

**Tester**: _________________
**Date**: _________________
**Device**: _________________
**OS Version**: _________________

| Test ID | Status | Notes |
|---------|--------|-------|
| TC-PROD-001 | ⬜ | |
| TC-PROD-002 | ⬜ | |
| TC-PROD-003 | ⬜ | |
| TC-PROD-004 | ⬜ | |
| TC-PROD-005 | ⬜ | |
| TC-PROD-006 | ⬜ | |
| TC-PROD-007 | ⬜ | |
| TC-PROD-008 | ⬜ | |
| TC-PROD-009 | ⬜ | |
| TC-PROD-010 | ⬜ | |

**Overall Status**: ⬜ Pass / ⬜ Pass with minor issues / ⬜ Fail

**Notes**:

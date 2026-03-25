# Pre-Test Checklist - Phase 1.7

Before running the end-to-end tests, ensure all prerequisites are met:

## ✅ Development Environment

- [x] Flutter 3.41.5 installed and working
- [x] Xcode 26.3 configured
- [x] Android SDK 36.1.0 configured
- [x] iPhone (iOS 18.2) connected wirelessly
- [x] Chrome browser available for web testing

## ✅ Code Readiness

- [x] Code compiles without errors (`flutter analyze` passed - 0 errors)
- [x] Only minor info warnings present (deprecation warnings, style suggestions)
- [x] Localizations generated successfully
- [x] All dependencies installed (`flutter pub get`)

## ✅ Backend Configuration

### Supabase Connection
- [x] `.env.local` file exists with credentials
- [x] SUPABASE_URL configured: `https://ofrbxqxhtnizdwipqdls.supabase.co`
- [x] SUPABASE_ANON_KEY configured
- [x] PROJECT_ID: `ofrbxqxhtnizdwipqdls`

### Database Migrations
**Action Required**: Verify the following migrations are applied on remote Supabase:

```bash
# Check migration status (run from project root)
supabase db remote list --project-ref ofrbxqxhtnizdwipqdls

# Or check via Supabase Dashboard:
# https://supabase.com/dashboard/project/ofrbxqxhtnizdwipqdls/editor
```

Required migrations:
1. ✅ `20260324000001_create_stores_table.sql`
2. ✅ `20260324000002_create_users_table.sql`
3. ✅ `20260324000003_create_pos_devices_table.sql`
4. ✅ `20260324000004_create_store_settings_table.sql`
5. ✅ `20260324000005_create_categories_table.sql`
6. ✅ `20260324000006_create_items_table.sql`
7. ✅ `20260324000007_auth_custom_claims.sql`
8. ✅ `20260324000008_helper_functions.sql`
9. ⚠️ `20260325000001_create_storage_buckets.sql` **← NEEDS VERIFICATION**

### Storage Buckets
**Action Required**: Verify storage buckets exist on remote Supabase:

```bash
# Check via Supabase Dashboard:
# https://supabase.com/dashboard/project/ofrbxqxhtnizdwipqdls/storage/buckets
```

Required buckets:
- [ ] `product-images` (public: true)
- [ ] `store-logos` (public: true)

### RLS Policies
**Action Required**: Verify RLS policies exist for storage:

Navigate to: Storage → product-images → Policies

Expected policies:
- [ ] "Public read access for product images" (SELECT)
- [ ] "Authenticated users can upload product images" (INSERT)
- [ ] "Store owners can update their product images" (UPDATE)
- [ ] "Store owners can delete their product images" (DELETE)

## 🔧 Manual Setup Steps (If Not Applied)

### Apply Storage Migration

```bash
# Option 1: Via CLI (if connection works)
cd /Users/neaskol/Downloads/AGENTIC\ WORKFLOW/POS
supabase db push --project-ref ofrbxqxhtnizdwipqdls

# Option 2: Via Dashboard SQL Editor
# 1. Go to: https://supabase.com/dashboard/project/ofrbxqxhtnizdwipqdls/editor
# 2. Copy contents of: supabase/migrations/20260325000001_create_storage_buckets.sql
# 3. Paste and execute in SQL editor
```

### Create Test Data (Optional)

If no categories exist yet, create some test categories:

```sql
-- Execute in Supabase SQL Editor
INSERT INTO categories (store_id, name, color, sort_order)
VALUES
  ((SELECT id FROM stores LIMIT 1), 'Boissons', '#4CAF50', 1),
  ((SELECT id FROM stores LIMIT 1), 'Plats', '#FF5722', 2),
  ((SELECT id FROM stores LIMIT 1), 'Desserts', '#FFC107', 3);
```

## 📱 Test Device Preparation

### iOS Device (iPhone)
- [ ] Device unlocked and trusted
- [ ] Developer mode enabled
- [ ] Wireless debugging enabled
- [ ] Network connected (same network as dev machine)

### Photo Permissions
- [ ] Grant photo library access when prompted
- [ ] Have 2-3 test images ready in Photos app

## 🚀 Ready to Test

Once all items above are checked, proceed with test execution:

```bash
# Run on iPhone
flutter run -d 00008110-001E59D43E01801E

# Or run on Chrome for quick UI testing (Storage upload requires device/simulator)
flutter run -d chrome
```

## 📊 Test Documentation

- [ ] Test plan reviewed: `tasks/test-plan-phase1.md`
- [ ] Test results document prepared for recording findings
- [ ] Screen recording tools ready (if needed)

---

**Next Step**: Review this checklist and execute manual verification steps, then proceed with running the app and executing test scenarios from `test-plan-phase1.md`.

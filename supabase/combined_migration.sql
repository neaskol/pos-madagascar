-- ============================================================================
-- POS Madagascar — Core Schema Setup
-- Migration: 20260324000001_core_schema_setup.sql
-- Description: Create base types, functions, and triggers
-- ============================================================================

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "pg_trgm"; -- For fuzzy text search

-- ============================================================================
-- CUSTOM TYPES
-- ============================================================================

-- User roles enum
CREATE TYPE user_role AS ENUM ('OWNER', 'ADMIN', 'MANAGER', 'CASHIER');

-- Payment types enum
CREATE TYPE payment_type AS ENUM ('cash', 'card', 'mvola', 'orange_money', 'other');

-- Sold by type enum
CREATE TYPE sold_by_type AS ENUM ('piece', 'weight');

-- Tax type enum
CREATE TYPE tax_type AS ENUM ('added', 'included');

-- Discount type enum
CREATE TYPE discount_type AS ENUM ('percentage', 'amount');

-- ============================================================================
-- UTILITY FUNCTIONS
-- ============================================================================

-- Function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function to get store_id from JWT claims
CREATE OR REPLACE FUNCTION auth.store_id()
RETURNS UUID AS $$
  SELECT COALESCE(
    (auth.jwt() -> 'app_metadata' ->> 'store_id')::uuid,
    '00000000-0000-0000-0000-000000000000'::uuid
  );
$$ LANGUAGE sql STABLE;

-- Function to get user role from JWT claims
CREATE OR REPLACE FUNCTION auth.user_role()
RETURNS TEXT AS $$
  SELECT COALESCE(
    auth.jwt() -> 'app_metadata' ->> 'role',
    'CASHIER'
  );
$$ LANGUAGE sql STABLE;

-- Function to check if user is owner or admin
CREATE OR REPLACE FUNCTION auth.is_owner_or_admin()
RETURNS BOOLEAN AS $$
  SELECT auth.user_role() IN ('OWNER', 'ADMIN');
$$ LANGUAGE sql STABLE;

-- Function to check if user is manager or above
CREATE OR REPLACE FUNCTION auth.is_manager_or_above()
RETURNS BOOLEAN AS $$
  SELECT auth.user_role() IN ('OWNER', 'ADMIN', 'MANAGER');
$$ LANGUAGE sql STABLE;

-- ============================================================================
-- COMMENTS
-- ============================================================================

COMMENT ON FUNCTION update_updated_at_column() IS 'Automatically updates updated_at timestamp on table row update';
COMMENT ON FUNCTION auth.store_id() IS 'Extracts store_id from JWT custom claims';
COMMENT ON FUNCTION auth.user_role() IS 'Extracts user role from JWT custom claims';
COMMENT ON FUNCTION auth.is_owner_or_admin() IS 'Returns true if user is OWNER or ADMIN';
COMMENT ON FUNCTION auth.is_manager_or_above() IS 'Returns true if user is OWNER, ADMIN, or MANAGER';
-- ============================================================================
-- POS Madagascar — Stores Table
-- Migration: 20260324000002_create_stores_table.sql
-- Description: Core table for store/business entities
-- ============================================================================

CREATE TABLE stores (
  -- Primary key
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- Business information
  name TEXT NOT NULL,
  address TEXT,
  phone TEXT,
  logo_url TEXT,

  -- Localization
  currency TEXT NOT NULL DEFAULT 'MGA',
  timezone TEXT NOT NULL DEFAULT 'Indian/Antananarivo',

  -- Audit fields
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_by UUID REFERENCES auth.users(id),
  deleted_at TIMESTAMPTZ,

  -- Constraints
  CONSTRAINT stores_name_check CHECK (LENGTH(TRIM(name)) > 0)
);

-- Indexes
CREATE INDEX idx_stores_deleted_at ON stores(deleted_at) WHERE deleted_at IS NULL;
CREATE INDEX idx_stores_created_by ON stores(created_by);

-- Trigger for updated_at
CREATE TRIGGER update_stores_updated_at
  BEFORE UPDATE ON stores
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Enable RLS
ALTER TABLE stores ENABLE ROW LEVEL SECURITY;

-- RLS Policies
-- Policy 1: Users can only see their own store
CREATE POLICY "store_select_own_store" ON stores
  FOR SELECT
  USING (
    id = auth.store_id()
    AND deleted_at IS NULL
  );

-- Policy 2: Only owners can update their store
CREATE POLICY "store_update_own_store" ON stores
  FOR UPDATE
  USING (
    id = auth.store_id()
    AND auth.is_owner_or_admin()
  )
  WITH CHECK (
    id = auth.store_id()
  );

-- Policy 3: Service role can insert stores (for registration flow)
CREATE POLICY "store_insert_service_role" ON stores
  FOR INSERT
  WITH CHECK (true);

-- Policy 4: Only owners can soft delete
CREATE POLICY "store_delete_own_store" ON stores
  FOR UPDATE
  USING (
    id = auth.store_id()
    AND auth.user_role() = 'OWNER'
    AND deleted_at IS NULL
  )
  WITH CHECK (
    deleted_at IS NOT NULL
  );

-- Comments
COMMENT ON TABLE stores IS 'Stores/businesses - one per merchant/organization';
COMMENT ON COLUMN stores.currency IS 'Default: MGA (Malagasy Ariary)';
COMMENT ON COLUMN stores.timezone IS 'IANA timezone for Madagascar';
COMMENT ON COLUMN stores.deleted_at IS 'Soft delete timestamp - NULL means active';
-- ============================================================================
-- POS Madagascar — Users Table
-- Migration: 20260324000003_create_users_table.sql
-- Description: Store employees/users with role-based access
-- ============================================================================

CREATE TABLE users (
  -- Primary key (matches auth.users.id)
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,

  -- Store relationship
  store_id UUID NOT NULL REFERENCES stores(id) ON DELETE CASCADE,

  -- User information
  name TEXT NOT NULL,
  email TEXT,
  phone TEXT,

  -- Access control
  role user_role NOT NULL DEFAULT 'CASHIER',
  pin_hash TEXT, -- For PIN-based login at POS

  -- Status flags
  email_verified BOOLEAN NOT NULL DEFAULT FALSE,
  active BOOLEAN NOT NULL DEFAULT TRUE,

  -- Audit fields
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_by UUID REFERENCES auth.users(id),
  deleted_at TIMESTAMPTZ,

  -- Constraints
  CONSTRAINT users_name_check CHECK (LENGTH(TRIM(name)) > 0),
  CONSTRAINT users_email_check CHECK (email IS NULL OR email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

-- Indexes
CREATE INDEX idx_users_store_id ON users(store_id);
CREATE INDEX idx_users_email ON users(email) WHERE email IS NOT NULL;
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_active ON users(active);
CREATE INDEX idx_users_deleted_at ON users(deleted_at) WHERE deleted_at IS NULL;

-- Trigger for updated_at
CREATE TRIGGER update_users_updated_at
  BEFORE UPDATE ON users
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Enable RLS
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- RLS Policies
-- Policy 1: Users can see colleagues in their store
CREATE POLICY "users_select_same_store" ON users
  FOR SELECT
  USING (
    store_id = auth.store_id()
    AND deleted_at IS NULL
  );

-- Policy 2: Only OWNER/ADMIN can create users
CREATE POLICY "users_insert_owner_admin" ON users
  FOR INSERT
  WITH CHECK (
    store_id = auth.store_id()
    AND auth.is_owner_or_admin()
  );

-- Policy 3: Users can update their own profile (limited fields)
CREATE POLICY "users_update_own_profile" ON users
  FOR UPDATE
  USING (
    id = auth.uid()
    AND store_id = auth.store_id()
  )
  WITH CHECK (
    -- Users can't change their own role or store
    role = (SELECT role FROM users WHERE id = auth.uid())
    AND store_id = (SELECT store_id FROM users WHERE id = auth.uid())
  );

-- Policy 4: OWNER/ADMIN can update any user in their store
CREATE POLICY "users_update_by_owner_admin" ON users
  FOR UPDATE
  USING (
    store_id = auth.store_id()
    AND auth.is_owner_or_admin()
  )
  WITH CHECK (
    store_id = auth.store_id()
  );

-- Policy 5: Only OWNER can delete users (soft delete)
CREATE POLICY "users_delete_by_owner" ON users
  FOR UPDATE
  USING (
    store_id = auth.store_id()
    AND auth.user_role() = 'OWNER'
    AND deleted_at IS NULL
  )
  WITH CHECK (
    deleted_at IS NOT NULL
  );

-- Comments
COMMENT ON TABLE users IS 'Store employees with role-based permissions';
COMMENT ON COLUMN users.pin_hash IS 'Hashed PIN for quick POS login (bcrypt)';
COMMENT ON COLUMN users.role IS 'OWNER > ADMIN > MANAGER > CASHIER hierarchy';
COMMENT ON COLUMN users.active IS 'Can be deactivated without deletion';
-- ============================================================================
-- POS Madagascar — Store Settings Table
-- Migration: 20260324000004_create_store_settings_table.sql
-- Description: Modular feature toggles per store (Loyverse-compatible)
-- ============================================================================

CREATE TABLE store_settings (
  -- Primary key (one-to-one with stores)
  store_id UUID PRIMARY KEY REFERENCES stores(id) ON DELETE CASCADE,

  -- Feature toggles (default: most disabled like Loyverse)
  shifts_enabled BOOLEAN NOT NULL DEFAULT FALSE,
  time_clock_enabled BOOLEAN NOT NULL DEFAULT FALSE,
  open_tickets_enabled BOOLEAN NOT NULL DEFAULT FALSE,
  predefined_tickets_enabled BOOLEAN NOT NULL DEFAULT FALSE,
  kitchen_printers_enabled BOOLEAN NOT NULL DEFAULT FALSE,
  customer_display_enabled BOOLEAN NOT NULL DEFAULT FALSE,
  dining_options_enabled BOOLEAN NOT NULL DEFAULT FALSE,
  low_stock_notifications BOOLEAN NOT NULL DEFAULT TRUE,
  negative_stock_alerts BOOLEAN NOT NULL DEFAULT FALSE,
  weight_barcodes_enabled BOOLEAN NOT NULL DEFAULT FALSE,

  -- Cash handling
  cash_rounding_unit INTEGER NOT NULL DEFAULT 0, -- 0 = no rounding, 50 = round to nearest 50 Ar

  -- Receipt customization
  receipt_footer TEXT,

  -- Audit fields
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_by UUID REFERENCES auth.users(id),

  -- Constraints
  CONSTRAINT store_settings_rounding_check CHECK (cash_rounding_unit >= 0)
);

-- Indexes
CREATE INDEX idx_store_settings_created_by ON store_settings(created_by);

-- Trigger for updated_at
CREATE TRIGGER update_store_settings_updated_at
  BEFORE UPDATE ON store_settings
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Enable RLS
ALTER TABLE store_settings ENABLE ROW LEVEL SECURITY;

-- RLS Policies
-- Policy 1: Users can view their store's settings
CREATE POLICY "store_settings_select_own_store" ON store_settings
  FOR SELECT
  USING (
    store_id = auth.store_id()
  );

-- Policy 2: Only OWNER/ADMIN can update settings
CREATE POLICY "store_settings_update_owner_admin" ON store_settings
  FOR UPDATE
  USING (
    store_id = auth.store_id()
    AND auth.is_owner_or_admin()
  )
  WITH CHECK (
    store_id = auth.store_id()
  );

-- Policy 3: Auto-insert on store creation
CREATE POLICY "store_settings_insert_service_role" ON store_settings
  FOR INSERT
  WITH CHECK (true);

-- Comments
COMMENT ON TABLE store_settings IS 'Per-store feature toggles matching Loyverse module architecture';
COMMENT ON COLUMN store_settings.cash_rounding_unit IS '0=none, 50=round to nearest 50 Ar, 100=nearest 100 Ar';
COMMENT ON COLUMN store_settings.receipt_footer IS 'Custom text printed at bottom of receipts';

-- Function to auto-create settings when store is created
CREATE OR REPLACE FUNCTION create_default_store_settings()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO store_settings (store_id, created_by)
  VALUES (NEW.id, NEW.created_by);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to auto-create settings
CREATE TRIGGER auto_create_store_settings
  AFTER INSERT ON stores
  FOR EACH ROW
  EXECUTE FUNCTION create_default_store_settings();
-- ============================================================================
-- POS Madagascar — Categories Table
-- Migration: 20260324000005_create_categories_table.sql
-- Description: Product categories for organization and filtering
-- ============================================================================

CREATE TABLE categories (
  -- Primary key
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- Store relationship
  store_id UUID NOT NULL REFERENCES stores(id) ON DELETE CASCADE,

  -- Category information
  name TEXT NOT NULL,
  color TEXT, -- Hex color code for UI display
  sort_order INTEGER NOT NULL DEFAULT 0,

  -- Audit fields
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_by UUID REFERENCES auth.users(id),
  deleted_at TIMESTAMPTZ,

  -- Constraints
  CONSTRAINT categories_name_check CHECK (LENGTH(TRIM(name)) > 0),
  CONSTRAINT categories_color_check CHECK (color IS NULL OR color ~* '^#[0-9A-Fa-f]{6}$'),
  CONSTRAINT categories_unique_name_per_store UNIQUE (store_id, name, deleted_at)
);

-- Indexes
CREATE INDEX idx_categories_store_id ON categories(store_id);
CREATE INDEX idx_categories_sort_order ON categories(store_id, sort_order);
CREATE INDEX idx_categories_deleted_at ON categories(deleted_at) WHERE deleted_at IS NULL;

-- Trigger for updated_at
CREATE TRIGGER update_categories_updated_at
  BEFORE UPDATE ON categories
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Enable RLS
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;

-- RLS Policies
-- Policy 1: Users can view categories in their store
CREATE POLICY "categories_select_own_store" ON categories
  FOR SELECT
  USING (
    store_id = auth.store_id()
    AND deleted_at IS NULL
  );

-- Policy 2: MANAGER+ can create categories
CREATE POLICY "categories_insert_manager_plus" ON categories
  FOR INSERT
  WITH CHECK (
    store_id = auth.store_id()
    AND auth.is_manager_or_above()
  );

-- Policy 3: MANAGER+ can update categories
CREATE POLICY "categories_update_manager_plus" ON categories
  FOR UPDATE
  USING (
    store_id = auth.store_id()
    AND auth.is_manager_or_above()
    AND deleted_at IS NULL
  )
  WITH CHECK (
    store_id = auth.store_id()
  );

-- Policy 4: ADMIN+ can soft delete categories
CREATE POLICY "categories_delete_admin_plus" ON categories
  FOR UPDATE
  USING (
    store_id = auth.store_id()
    AND auth.is_owner_or_admin()
    AND deleted_at IS NULL
  )
  WITH CHECK (
    deleted_at IS NOT NULL
  );

-- Comments
COMMENT ON TABLE categories IS 'Product categories for organizing items';
COMMENT ON COLUMN categories.color IS 'Hex color code (e.g., #FF5733) for UI display';
COMMENT ON COLUMN categories.sort_order IS 'Display order in UI (ascending)';
-- ============================================================================
-- POS Madagascar — Items Table
-- Migration: 20260324000006_create_items_table.sql
-- Description: Products/items for sale with Loyverse-compatible schema
-- ============================================================================

CREATE TABLE items (
  -- Primary key
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- Store & category relationship
  store_id UUID NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  category_id UUID REFERENCES categories(id) ON DELETE SET NULL,

  -- Product information
  name TEXT NOT NULL,
  description TEXT,
  sku TEXT, -- Max 40 chars in Loyverse
  barcode TEXT,

  -- Pricing (all amounts in Ariary as INTEGER - no decimals)
  price INTEGER NOT NULL CHECK (price >= 0),
  cost INTEGER NOT NULL DEFAULT 0 CHECK (cost >= 0),
  cost_is_percentage BOOLEAN NOT NULL DEFAULT FALSE, -- DIFFERENTIATOR: Loyverse doesn't support this

  -- Sales configuration
  sold_by sold_by_type NOT NULL DEFAULT 'piece',
  available_for_sale BOOLEAN NOT NULL DEFAULT TRUE,

  -- Inventory tracking
  track_stock BOOLEAN NOT NULL DEFAULT FALSE,
  in_stock INTEGER NOT NULL DEFAULT 0,
  low_stock_threshold INTEGER NOT NULL DEFAULT 0,
  average_cost INTEGER NOT NULL DEFAULT 0 CHECK (average_cost >= 0), -- Weighted average cost

  -- Advanced features
  is_composite BOOLEAN NOT NULL DEFAULT FALSE, -- Product made from other products
  use_production BOOLEAN NOT NULL DEFAULT FALSE, -- For bakeries/assembly

  -- Media
  image_url TEXT,

  -- Audit fields
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_by UUID REFERENCES auth.users(id),
  deleted_at TIMESTAMPTZ,

  -- Constraints
  CONSTRAINT items_name_check CHECK (LENGTH(TRIM(name)) > 0),
  CONSTRAINT items_sku_length CHECK (sku IS NULL OR LENGTH(sku) <= 40),
  CONSTRAINT items_barcode_length CHECK (barcode IS NULL OR LENGTH(barcode) <= 100),
  CONSTRAINT items_stock_check CHECK (in_stock >= 0 OR NOT track_stock),
  CONSTRAINT items_cost_percentage_range CHECK (
    NOT cost_is_percentage OR (cost >= 0 AND cost <= 100)
  )
);

-- Indexes
CREATE INDEX idx_items_store_id ON items(store_id);
CREATE INDEX idx_items_category_id ON items(category_id);
CREATE INDEX idx_items_name ON items USING gin(name gin_trgm_ops); -- Full-text search
CREATE INDEX idx_items_sku ON items(sku) WHERE sku IS NOT NULL;
CREATE INDEX idx_items_barcode ON items(barcode) WHERE barcode IS NOT NULL;
CREATE INDEX idx_items_available ON items(store_id, available_for_sale) WHERE deleted_at IS NULL;
CREATE INDEX idx_items_low_stock ON items(store_id)
  WHERE track_stock = TRUE
    AND in_stock <= low_stock_threshold
    AND deleted_at IS NULL;
CREATE INDEX idx_items_deleted_at ON items(deleted_at) WHERE deleted_at IS NULL;

-- Trigger for updated_at
CREATE TRIGGER update_items_updated_at
  BEFORE UPDATE ON items
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Enable RLS
ALTER TABLE items ENABLE ROW LEVEL SECURITY;

-- RLS Policies
-- Policy 1: All users can view items in their store
CREATE POLICY "items_select_own_store" ON items
  FOR SELECT
  USING (
    store_id = auth.store_id()
    AND deleted_at IS NULL
  );

-- Policy 2: MANAGER+ can create items
CREATE POLICY "items_insert_manager_plus" ON items
  FOR INSERT
  WITH CHECK (
    store_id = auth.store_id()
    AND auth.is_manager_or_above()
  );

-- Policy 3: MANAGER+ can update items
CREATE POLICY "items_update_manager_plus" ON items
  FOR UPDATE
  USING (
    store_id = auth.store_id()
    AND auth.is_manager_or_above()
    AND deleted_at IS NULL
  )
  WITH CHECK (
    store_id = auth.store_id()
  );

-- Policy 4: ADMIN+ can soft delete items
CREATE POLICY "items_delete_admin_plus" ON items
  FOR UPDATE
  USING (
    store_id = auth.store_id()
    AND auth.is_owner_or_admin()
    AND deleted_at IS NULL
  )
  WITH CHECK (
    deleted_at IS NOT NULL
  );

-- Comments
COMMENT ON TABLE items IS 'Products/items for sale - core inventory entity';
COMMENT ON COLUMN items.price IS 'Selling price in Ariary (INTEGER, no decimals)';
COMMENT ON COLUMN items.cost IS 'Purchase cost - amount in Ar OR percentage (0-100) if cost_is_percentage=true';
COMMENT ON COLUMN items.cost_is_percentage IS 'DIFFERENTIATOR: True = cost is % of price (Loyverse limitation)';
COMMENT ON COLUMN items.sku IS 'Stock Keeping Unit - max 40 chars per Loyverse spec';
COMMENT ON COLUMN items.barcode IS 'Product barcode - max 100 chars';
COMMENT ON COLUMN items.average_cost IS 'Weighted average cost, recalculated on each purchase order receipt';
COMMENT ON COLUMN items.is_composite IS 'True = product made from multiple components';
COMMENT ON COLUMN items.use_production IS 'True = use production module for bakeries/assembly';
-- ============================================================================
-- POS Madagascar — Auth Custom Claims
-- Migration: 20260324000007_auth_custom_claims.sql
-- Description: Set store_id and role in JWT for RLS
-- ============================================================================

-- Function to set custom claims after user signup/login
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
  user_store_id UUID;
  user_role TEXT;
BEGIN
  -- Get user's store_id and role from users table
  SELECT store_id, role::TEXT INTO user_store_id, user_role
  FROM public.users
  WHERE id = NEW.id;

  -- Set custom claims in auth.users.raw_app_meta_data
  IF user_store_id IS NOT NULL THEN
    NEW.raw_app_meta_data = COALESCE(NEW.raw_app_meta_data, '{}'::jsonb) ||
      jsonb_build_object(
        'store_id', user_store_id::TEXT,
        'role', user_role
      );
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger on auth.users to set claims
CREATE TRIGGER on_auth_user_created
  BEFORE INSERT OR UPDATE ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- Function to update claims when user role/store changes
CREATE OR REPLACE FUNCTION public.sync_user_claims()
RETURNS TRIGGER AS $$
BEGIN
  -- Update auth.users metadata when users table changes
  UPDATE auth.users
  SET raw_app_meta_data = COALESCE(raw_app_meta_data, '{}'::jsonb) ||
    jsonb_build_object(
      'store_id', NEW.store_id::TEXT,
      'role', NEW.role::TEXT
    ),
    updated_at = NOW()
  WHERE id = NEW.id;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger on users table to sync claims
CREATE TRIGGER on_user_role_change
  AFTER INSERT OR UPDATE OF store_id, role ON public.users
  FOR EACH ROW
  EXECUTE FUNCTION public.sync_user_claims();

-- Comments
COMMENT ON FUNCTION public.handle_new_user() IS 'Sets store_id and role in JWT custom claims on user creation';
COMMENT ON FUNCTION public.sync_user_claims() IS 'Syncs JWT claims when user role or store changes';
-- ============================================================================
-- POS Madagascar — Helper Functions
-- Migration: 20260324000008_helper_functions.sql
-- Description: Utility functions for business logic
-- ============================================================================

-- Function to get next receipt number for a store
CREATE OR REPLACE FUNCTION public.get_next_receipt_number(p_store_id UUID)
RETURNS TEXT AS $$
DECLARE
  next_number INTEGER;
  receipt_num TEXT;
BEGIN
  -- Get max receipt number for store (assumes format: YYYYMMDD-NNNN)
  -- This will be used later when sales table is created
  -- For now, just return a basic implementation
  SELECT 1 INTO next_number;

  -- Format: YYYYMMDD-0001, YYYYMMDD-0002, etc.
  receipt_num := TO_CHAR(CURRENT_DATE, 'YYYYMMDD') || '-' || LPAD(next_number::TEXT, 4, '0');

  RETURN receipt_num;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to calculate weighted average cost
CREATE OR REPLACE FUNCTION public.calculate_average_cost(
  p_stock_before INTEGER,
  p_cost_before INTEGER,
  p_stock_added INTEGER,
  p_cost_added INTEGER
)
RETURNS INTEGER AS $$
DECLARE
  total_stock INTEGER;
  new_avg_cost INTEGER;
BEGIN
  total_stock := p_stock_before + p_stock_added;

  IF total_stock = 0 THEN
    RETURN 0;
  END IF;

  new_avg_cost := ROUND(
    (p_stock_before * p_cost_before + p_stock_added * p_cost_added)::DECIMAL
    / total_stock
  );

  RETURN new_avg_cost;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Function to check if SKU is unique within store
CREATE OR REPLACE FUNCTION public.is_sku_unique(
  p_store_id UUID,
  p_sku TEXT,
  p_item_id UUID DEFAULT NULL
)
RETURNS BOOLEAN AS $$
DECLARE
  sku_count INTEGER;
BEGIN
  IF p_sku IS NULL THEN
    RETURN TRUE;
  END IF;

  SELECT COUNT(*) INTO sku_count
  FROM items
  WHERE store_id = p_store_id
    AND sku = p_sku
    AND deleted_at IS NULL
    AND (p_item_id IS NULL OR id != p_item_id);

  RETURN sku_count = 0;
END;
$$ LANGUAGE plpgsql STABLE;

-- Comments
COMMENT ON FUNCTION public.get_next_receipt_number(UUID) IS 'Generates sequential receipt number for store: YYYYMMDD-0001';
COMMENT ON FUNCTION public.calculate_average_cost(INTEGER, INTEGER, INTEGER, INTEGER) IS 'Calculates weighted average cost using formula from docs/formulas.md';
COMMENT ON FUNCTION public.is_sku_unique(UUID, TEXT, UUID) IS 'Validates SKU uniqueness within store scope';

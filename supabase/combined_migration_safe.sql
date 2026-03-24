-- ============================================================================
-- POS Madagascar — Core Schema Setup (SAFE VERSION)
-- Migration: Combined migrations with auth schema workaround
-- Description: All 8 migrations in one file, avoiding auth schema permissions
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
-- UTILITY FUNCTIONS (PUBLIC SCHEMA ONLY)
-- ============================================================================

-- Function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function to get store_id from JWT claims (PUBLIC SCHEMA)
CREATE OR REPLACE FUNCTION get_jwt_store_id()
RETURNS UUID AS $$
  SELECT COALESCE(
    (current_setting('request.jwt.claims', true)::jsonb -> 'app_metadata' ->> 'store_id')::uuid,
    '00000000-0000-0000-0000-000000000000'::uuid
  );
$$ LANGUAGE sql STABLE SECURITY DEFINER;

-- Function to get user role from JWT claims (PUBLIC SCHEMA)
CREATE OR REPLACE FUNCTION get_jwt_user_role()
RETURNS TEXT AS $$
  SELECT COALESCE(
    current_setting('request.jwt.claims', true)::jsonb -> 'app_metadata' ->> 'role',
    'CASHIER'
  );
$$ LANGUAGE sql STABLE SECURITY DEFINER;

-- Function to check if user is owner or admin
CREATE OR REPLACE FUNCTION is_owner_or_admin()
RETURNS BOOLEAN AS $$
  SELECT get_jwt_user_role() IN ('OWNER', 'ADMIN');
$$ LANGUAGE sql STABLE SECURITY DEFINER;

-- Function to check if user is manager or above
CREATE OR REPLACE FUNCTION is_manager_or_above()
RETURNS BOOLEAN AS $$
  SELECT get_jwt_user_role() IN ('OWNER', 'ADMIN', 'MANAGER');
$$ LANGUAGE sql STABLE SECURITY DEFINER;

-- Comments
COMMENT ON FUNCTION update_updated_at_column() IS 'Automatically updates updated_at timestamp on table row update';
COMMENT ON FUNCTION get_jwt_store_id() IS 'Extracts store_id from JWT custom claims';
COMMENT ON FUNCTION get_jwt_user_role() IS 'Extracts user role from JWT custom claims';
COMMENT ON FUNCTION is_owner_or_admin() IS 'Returns true if user is OWNER or ADMIN';
COMMENT ON FUNCTION is_manager_or_above() IS 'Returns true if user is OWNER, ADMIN, or MANAGER';

-- ============================================================================
-- STORES TABLE
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
  created_by UUID,
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
CREATE POLICY "store_select_own_store" ON stores
  FOR SELECT
  USING (
    id = get_jwt_store_id()
    AND deleted_at IS NULL
  );

CREATE POLICY "store_update_own_store" ON stores
  FOR UPDATE
  USING (
    id = get_jwt_store_id()
    AND is_owner_or_admin()
  )
  WITH CHECK (
    id = get_jwt_store_id()
  );

CREATE POLICY "store_insert_service_role" ON stores
  FOR INSERT
  WITH CHECK (true);

CREATE POLICY "store_delete_own_store" ON stores
  FOR UPDATE
  USING (
    id = get_jwt_store_id()
    AND get_jwt_user_role() = 'OWNER'
    AND deleted_at IS NULL
  )
  WITH CHECK (
    deleted_at IS NOT NULL
  );

COMMENT ON TABLE stores IS 'Stores/businesses - one per merchant/organization';

-- ============================================================================
-- USERS TABLE
-- ============================================================================

CREATE TABLE users (
  -- Primary key
  id UUID PRIMARY KEY,

  -- Store relationship
  store_id UUID NOT NULL REFERENCES stores(id) ON DELETE CASCADE,

  -- User information
  name TEXT NOT NULL,
  email TEXT,
  phone TEXT,

  -- Access control
  role user_role NOT NULL DEFAULT 'CASHIER',
  pin_hash TEXT,

  -- Status flags
  email_verified BOOLEAN NOT NULL DEFAULT FALSE,
  active BOOLEAN NOT NULL DEFAULT TRUE,

  -- Audit fields
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_by UUID,
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
CREATE POLICY "users_select_same_store" ON users
  FOR SELECT
  USING (
    store_id = get_jwt_store_id()
    AND deleted_at IS NULL
  );

CREATE POLICY "users_insert_owner_admin" ON users
  FOR INSERT
  WITH CHECK (
    store_id = get_jwt_store_id()
    AND is_owner_or_admin()
  );

CREATE POLICY "users_update_own_profile" ON users
  FOR UPDATE
  USING (
    id = (current_setting('request.jwt.claims', true)::jsonb ->> 'sub')::uuid
    AND store_id = get_jwt_store_id()
  )
  WITH CHECK (
    role = (SELECT role FROM users WHERE id = (current_setting('request.jwt.claims', true)::jsonb ->> 'sub')::uuid)
    AND store_id = (SELECT store_id FROM users WHERE id = (current_setting('request.jwt.claims', true)::jsonb ->> 'sub')::uuid)
  );

CREATE POLICY "users_update_by_owner_admin" ON users
  FOR UPDATE
  USING (
    store_id = get_jwt_store_id()
    AND is_owner_or_admin()
  )
  WITH CHECK (
    store_id = get_jwt_store_id()
  );

CREATE POLICY "users_delete_by_owner" ON users
  FOR UPDATE
  USING (
    store_id = get_jwt_store_id()
    AND get_jwt_user_role() = 'OWNER'
    AND deleted_at IS NULL
  )
  WITH CHECK (
    deleted_at IS NOT NULL
  );

COMMENT ON TABLE users IS 'Store employees with role-based permissions';

-- ============================================================================
-- STORE SETTINGS TABLE
-- ============================================================================

CREATE TABLE store_settings (
  -- Primary key
  store_id UUID PRIMARY KEY REFERENCES stores(id) ON DELETE CASCADE,

  -- Feature toggles
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
  cash_rounding_unit INTEGER NOT NULL DEFAULT 0,

  -- Receipt customization
  receipt_footer TEXT,

  -- Audit fields
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_by UUID,

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
CREATE POLICY "store_settings_select_own_store" ON store_settings
  FOR SELECT
  USING (
    store_id = get_jwt_store_id()
  );

CREATE POLICY "store_settings_update_owner_admin" ON store_settings
  FOR UPDATE
  USING (
    store_id = get_jwt_store_id()
    AND is_owner_or_admin()
  )
  WITH CHECK (
    store_id = get_jwt_store_id()
  );

CREATE POLICY "store_settings_insert_service_role" ON store_settings
  FOR INSERT
  WITH CHECK (true);

COMMENT ON TABLE store_settings IS 'Per-store feature toggles matching Loyverse module architecture';

-- Auto-create settings when store is created
CREATE OR REPLACE FUNCTION create_default_store_settings()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO store_settings (store_id, created_by)
  VALUES (NEW.id, NEW.created_by);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER auto_create_store_settings
  AFTER INSERT ON stores
  FOR EACH ROW
  EXECUTE FUNCTION create_default_store_settings();

-- ============================================================================
-- CATEGORIES TABLE
-- ============================================================================

CREATE TABLE categories (
  -- Primary key
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- Store relationship
  store_id UUID NOT NULL REFERENCES stores(id) ON DELETE CASCADE,

  -- Category information
  name TEXT NOT NULL,
  color TEXT,
  sort_order INTEGER NOT NULL DEFAULT 0,

  -- Audit fields
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_by UUID,
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
CREATE POLICY "categories_select_own_store" ON categories
  FOR SELECT
  USING (
    store_id = get_jwt_store_id()
    AND deleted_at IS NULL
  );

CREATE POLICY "categories_insert_manager_plus" ON categories
  FOR INSERT
  WITH CHECK (
    store_id = get_jwt_store_id()
    AND is_manager_or_above()
  );

CREATE POLICY "categories_update_manager_plus" ON categories
  FOR UPDATE
  USING (
    store_id = get_jwt_store_id()
    AND is_manager_or_above()
    AND deleted_at IS NULL
  )
  WITH CHECK (
    store_id = get_jwt_store_id()
  );

CREATE POLICY "categories_delete_admin_plus" ON categories
  FOR UPDATE
  USING (
    store_id = get_jwt_store_id()
    AND is_owner_or_admin()
    AND deleted_at IS NULL
  )
  WITH CHECK (
    deleted_at IS NOT NULL
  );

COMMENT ON TABLE categories IS 'Product categories for organizing items';

-- ============================================================================
-- ITEMS TABLE
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
  sku TEXT,
  barcode TEXT,

  -- Pricing (INTEGER = Ariary, no decimals)
  price INTEGER NOT NULL CHECK (price >= 0),
  cost INTEGER NOT NULL DEFAULT 0 CHECK (cost >= 0),
  cost_is_percentage BOOLEAN NOT NULL DEFAULT FALSE,

  -- Sales configuration
  sold_by sold_by_type NOT NULL DEFAULT 'piece',
  available_for_sale BOOLEAN NOT NULL DEFAULT TRUE,

  -- Inventory tracking
  track_stock BOOLEAN NOT NULL DEFAULT FALSE,
  in_stock INTEGER NOT NULL DEFAULT 0,
  low_stock_threshold INTEGER NOT NULL DEFAULT 0,
  average_cost INTEGER NOT NULL DEFAULT 0 CHECK (average_cost >= 0),

  -- Advanced features
  is_composite BOOLEAN NOT NULL DEFAULT FALSE,
  use_production BOOLEAN NOT NULL DEFAULT FALSE,

  -- Media
  image_url TEXT,

  -- Audit fields
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_by UUID,
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
CREATE INDEX idx_items_name ON items USING gin(name gin_trgm_ops);
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
CREATE POLICY "items_select_own_store" ON items
  FOR SELECT
  USING (
    store_id = get_jwt_store_id()
    AND deleted_at IS NULL
  );

CREATE POLICY "items_insert_manager_plus" ON items
  FOR INSERT
  WITH CHECK (
    store_id = get_jwt_store_id()
    AND is_manager_or_above()
  );

CREATE POLICY "items_update_manager_plus" ON items
  FOR UPDATE
  USING (
    store_id = get_jwt_store_id()
    AND is_manager_or_above()
    AND deleted_at IS NULL
  )
  WITH CHECK (
    store_id = get_jwt_store_id()
  );

CREATE POLICY "items_delete_admin_plus" ON items
  FOR UPDATE
  USING (
    store_id = get_jwt_store_id()
    AND is_owner_or_admin()
    AND deleted_at IS NULL
  )
  WITH CHECK (
    deleted_at IS NOT NULL
  );

COMMENT ON TABLE items IS 'Products/items for sale - core inventory entity';

-- ============================================================================
-- HELPER FUNCTIONS
-- ============================================================================

-- Function to get next receipt number for a store
CREATE OR REPLACE FUNCTION get_next_receipt_number(p_store_id UUID)
RETURNS TEXT AS $$
DECLARE
  next_number INTEGER;
  receipt_num TEXT;
BEGIN
  SELECT 1 INTO next_number;
  receipt_num := TO_CHAR(CURRENT_DATE, 'YYYYMMDD') || '-' || LPAD(next_number::TEXT, 4, '0');
  RETURN receipt_num;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to calculate weighted average cost
CREATE OR REPLACE FUNCTION calculate_average_cost(
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
CREATE OR REPLACE FUNCTION is_sku_unique(
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

COMMENT ON FUNCTION get_next_receipt_number(UUID) IS 'Generates sequential receipt number for store: YYYYMMDD-0001';
COMMENT ON FUNCTION calculate_average_cost(INTEGER, INTEGER, INTEGER, INTEGER) IS 'Calculates weighted average cost using formula from docs/formulas.md';
COMMENT ON FUNCTION is_sku_unique(UUID, TEXT, UUID) IS 'Validates SKU uniqueness within store scope';

-- ============================================================================
-- NOTE: AUTH CUSTOM CLAIMS SETUP
-- ============================================================================
-- The auth.users triggers cannot be created via SQL Editor due to permissions.
-- These will need to be added manually via Supabase Dashboard later or via CLI.
--
-- Required:
-- 1. Function: public.handle_new_user() - sets JWT claims on user creation
-- 2. Trigger: on_auth_user_created on auth.users
-- 3. Function: public.sync_user_claims() - syncs claims when role/store changes
-- 4. Trigger: on_user_role_change on public.users
--
-- For now, JWT claims will need to be set manually or via API.
-- ============================================================================

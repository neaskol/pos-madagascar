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

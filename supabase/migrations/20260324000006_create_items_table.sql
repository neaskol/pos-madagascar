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

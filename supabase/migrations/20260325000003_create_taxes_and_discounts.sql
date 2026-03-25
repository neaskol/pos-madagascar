-- Migration: Phase 3.1 - Taxes and Discounts Support
-- Description: Create tables for tax configuration and add discount/tax fields to sales

-- ============================================================================
-- TAXES TABLE
-- ============================================================================

-- Taxes configured per store
CREATE TABLE IF NOT EXISTS taxes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  name VARCHAR(100) NOT NULL,
  rate DECIMAL(5,2) NOT NULL CHECK (rate >= 0 AND rate <= 100),
  tax_type VARCHAR(20) NOT NULL DEFAULT 'added' CHECK (tax_type IN ('added', 'included')),
  is_default BOOLEAN DEFAULT false,
  active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  created_by UUID REFERENCES users(id)
);

-- Index for fast lookup
CREATE INDEX idx_taxes_store_id ON taxes(store_id);
CREATE INDEX idx_taxes_active ON taxes(store_id, active) WHERE active = true;

-- Only one default tax per store
CREATE UNIQUE INDEX idx_taxes_default_per_store
  ON taxes(store_id)
  WHERE is_default = true;

-- RLS policies
ALTER TABLE taxes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "store_isolation_taxes" ON taxes
  USING (store_id IN (
    SELECT store_id FROM users WHERE id = auth.uid()
  ));

-- Auto-update timestamp trigger
CREATE TRIGGER update_taxes_updated_at
  BEFORE UPDATE ON taxes
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- ITEM_TAXES JUNCTION TABLE (Many-to-Many)
-- ============================================================================

-- Link items to specific taxes (overrides default tax)
CREATE TABLE IF NOT EXISTS item_taxes (
  item_id UUID NOT NULL REFERENCES items(id) ON DELETE CASCADE,
  tax_id UUID NOT NULL REFERENCES taxes(id) ON DELETE CASCADE,
  PRIMARY KEY (item_id, tax_id)
);

-- Index for fast lookup
CREATE INDEX idx_item_taxes_item_id ON item_taxes(item_id);
CREATE INDEX idx_item_taxes_tax_id ON item_taxes(tax_id);

-- RLS policies
ALTER TABLE item_taxes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "store_isolation_item_taxes" ON item_taxes
  USING (
    item_id IN (
      SELECT id FROM items WHERE store_id IN (
        SELECT store_id FROM users WHERE id = auth.uid()
      )
    )
  );

-- ============================================================================
-- ADD DISCOUNT AND TAX FIELDS TO SALES
-- ============================================================================

-- Add discount and tax tracking to sales table
ALTER TABLE sales
  ADD COLUMN IF NOT EXISTS discount_amount INT DEFAULT 0,
  ADD COLUMN IF NOT EXISTS discount_percentage DECIMAL(5,2),
  ADD COLUMN IF NOT EXISTS tax_amount INT DEFAULT 0;

-- Add discount and tax tracking to sale_items table
ALTER TABLE sale_items
  ADD COLUMN IF NOT EXISTS discount_amount INT DEFAULT 0,
  ADD COLUMN IF NOT EXISTS discount_percentage DECIMAL(5,2),
  ADD COLUMN IF NOT EXISTS tax_amount INT DEFAULT 0;

-- ============================================================================
-- COMMENTS
-- ============================================================================

COMMENT ON TABLE taxes IS 'Tax configuration per store (VAT, sales tax, etc.)';
COMMENT ON COLUMN taxes.tax_type IS 'added = tax added to price | included = tax already in price';
COMMENT ON COLUMN taxes.is_default IS 'Default tax applied to all items unless overridden';

COMMENT ON TABLE item_taxes IS 'Many-to-many: items can have multiple taxes';

COMMENT ON COLUMN sales.discount_amount IS 'Total discount amount in Ariary (sum of all discounts)';
COMMENT ON COLUMN sales.discount_percentage IS 'If cart-wide % discount applied';
COMMENT ON COLUMN sales.tax_amount IS 'Total tax amount in Ariary (sum of all taxes)';

COMMENT ON COLUMN sale_items.discount_amount IS 'Discount on this line item in Ariary';
COMMENT ON COLUMN sale_items.discount_percentage IS 'If % discount applied to this item';
COMMENT ON COLUMN sale_items.tax_amount IS 'Tax amount for this line item in Ariary';

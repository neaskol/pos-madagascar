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

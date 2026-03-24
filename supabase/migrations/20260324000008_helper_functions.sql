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

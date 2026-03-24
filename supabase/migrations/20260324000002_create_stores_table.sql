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

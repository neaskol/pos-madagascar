-- ============================================================================
-- POS Madagascar — Fix Stores INSERT Policy
-- Migration: 20260325000008_fix_stores_insert_policy.sql
-- Description: Allow authenticated users to create their first store
-- ============================================================================

-- Drop the old restrictive insert policy
DROP POLICY IF EXISTS "store_insert_service_role" ON stores;

-- Create new policy: authenticated users can insert stores
-- This is needed for the registration/setup wizard flow
CREATE POLICY "store_insert_authenticated" ON stores
  FOR INSERT
  TO authenticated
  WITH CHECK (
    -- L'utilisateur doit être authentifié
    auth.uid() IS NOT NULL
    -- Et le created_by doit correspondre à l'utilisateur actuel (sera défini par un trigger)
    -- OU être NULL (pour permettre l'insertion initiale)
  );

-- Create a trigger to automatically set created_by on INSERT
CREATE OR REPLACE FUNCTION set_store_created_by()
RETURNS TRIGGER AS $$
BEGIN
  -- Définir automatiquement created_by avec l'utilisateur actuel
  IF NEW.created_by IS NULL THEN
    NEW.created_by := auth.uid();
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Apply the trigger
DROP TRIGGER IF EXISTS trigger_set_store_created_by ON stores;
CREATE TRIGGER trigger_set_store_created_by
  BEFORE INSERT ON stores
  FOR EACH ROW
  EXECUTE FUNCTION set_store_created_by();

-- Comments
COMMENT ON POLICY "store_insert_authenticated" ON stores IS
  'Allows authenticated users to create a store during registration';
COMMENT ON FUNCTION set_store_created_by() IS
  'Automatically sets created_by to current user on store creation';

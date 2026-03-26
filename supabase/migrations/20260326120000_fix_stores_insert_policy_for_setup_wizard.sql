-- ============================================================================
-- POS Madagascar — Fix Stores INSERT Policy for Setup Wizard
-- Migration: 20260326120000_fix_stores_insert_policy_for_setup_wizard.sql
-- Description: Allow authenticated users to create their first store without store_id in JWT
-- ============================================================================

-- Drop the restrictive policy
DROP POLICY IF EXISTS "store_insert_authenticated" ON stores;

-- Create new permissive policy for first store creation
-- This allows any authenticated user to create a store during onboarding
CREATE POLICY "store_insert_during_onboarding" ON stores
  FOR INSERT
  TO authenticated
  WITH CHECK (
    -- User must be authenticated
    auth.uid() IS NOT NULL
  );

-- Comments
COMMENT ON POLICY "store_insert_during_onboarding" ON stores IS
  'Allows authenticated users to create their first store during setup wizard without requiring store_id in JWT';

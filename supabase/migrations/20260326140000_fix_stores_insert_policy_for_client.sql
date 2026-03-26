-- ============================================================================
-- POS Madagascar — Fix Stores INSERT Policy for Client Requests
-- Migration: 20260326140000_fix_stores_insert_policy_for_client.sql
-- Description: Allow authenticated users to create stores via client requests
-- ============================================================================

-- Drop the current policy
DROP POLICY IF EXISTS "store_insert_during_onboarding" ON stores;

-- Create new policy without role restriction
-- This allows any request where auth.uid() is not null (user is logged in)
CREATE POLICY "store_insert_during_onboarding" ON stores
  FOR INSERT
  WITH CHECK (
    -- User must be authenticated (has a valid JWT)
    auth.uid() IS NOT NULL
  );

-- Comments
COMMENT ON POLICY "store_insert_during_onboarding" ON stores IS
  'Allows authenticated users to create their first store during setup wizard. Works with client requests using anon key + JWT.';

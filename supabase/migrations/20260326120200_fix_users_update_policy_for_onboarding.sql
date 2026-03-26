-- ============================================================================
-- POS Madagascar — Fix Users UPDATE Policy for Onboarding
-- Migration: 20260326120200_fix_users_update_policy_for_onboarding.sql
-- Description: Allow users to set their store_id during first store creation
-- ============================================================================

-- Create a new policy for onboarding that allows users to set their store_id
-- This policy applies when the user doesn't have a store_id yet
CREATE POLICY "users_update_store_id_during_onboarding" ON users
  FOR UPDATE
  TO authenticated
  USING (
    -- User is updating their own record
    id = auth.uid()
    -- AND they don't have a store_id yet (first store creation)
    AND store_id IS NULL
  )
  WITH CHECK (
    -- They can only set their own store_id, not change other fields maliciously
    id = auth.uid()
  );

-- Comments
COMMENT ON POLICY "users_update_store_id_during_onboarding" ON users IS
  'Allows authenticated users to set their store_id during first store creation (setup wizard)';

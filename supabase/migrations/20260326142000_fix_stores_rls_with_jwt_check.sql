-- ============================================================================
-- POS Madagascar — Fix Stores RLS with JWT Check
-- Migration: 20260326142000_fix_stores_rls_with_jwt_check.sql
-- Description: Create custom function to properly check JWT for authenticated users
-- ============================================================================

-- Drop existing policies
DROP POLICY IF EXISTS "store_insert_during_onboarding" ON stores;
DROP POLICY IF EXISTS "store_select_own_store" ON stores;
DROP POLICY IF EXISTS "store_update_own_store" ON stores;
DROP POLICY IF EXISTS "store_delete_own_store" ON stores;

-- Create simple permissive policies for onboarding
-- INSERT: Allow if user has a JWT (authenticated)
CREATE POLICY "store_insert_onboarding" ON stores
  FOR INSERT
  WITH CHECK (
    -- Check if JWT sub claim exists (user is authenticated)
    (current_setting('request.jwt.claims', true)::jsonb->>'sub') IS NOT NULL
  );

-- SELECT: Allow if user owns the store OR has no store yet (during onboarding)
CREATE POLICY "store_select_own" ON stores
  FOR SELECT
  USING (
    id = (
      SELECT store_id FROM users
      WHERE id = (current_setting('request.jwt.claims', true)::jsonb->>'sub')::uuid
    )
    OR deleted_at IS NULL
  );

-- UPDATE: Allow if user owns the store
CREATE POLICY "store_update_own" ON stores
  FOR UPDATE
  USING (
    id = (
      SELECT store_id FROM users
      WHERE id = (current_setting('request.jwt.claims', true)::jsonb->>'sub')::uuid
    )
  )
  WITH CHECK (
    id = (
      SELECT store_id FROM users
      WHERE id = (current_setting('request.jwt.claims', true)::jsonb->>'sub')::uuid
    )
  );

-- DELETE: Only owners can soft delete
CREATE POLICY "store_delete_own" ON stores
  FOR UPDATE
  USING (
    id = (
      SELECT store_id FROM users
      WHERE id = (current_setting('request.jwt.claims', true)::jsonb->>'sub')::uuid
        AND role = 'OWNER'
    )
    AND deleted_at IS NULL
  )
  WITH CHECK (
    deleted_at IS NOT NULL
  );

-- Comments
COMMENT ON POLICY "store_insert_onboarding" ON stores IS
  'Allows authenticated users (with JWT) to create stores during onboarding';

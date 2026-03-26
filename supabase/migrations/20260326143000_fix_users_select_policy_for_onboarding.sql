-- ============================================================================
-- POS Madagascar — Fix Users SELECT Policy for Onboarding
-- Migration: 20260326143000_fix_users_select_policy_for_onboarding.sql
-- Description: Allow users to read their own profile even without store_id
-- ============================================================================

-- Add policy to allow users to read their own profile
CREATE POLICY "users_select_own_profile" ON public.users
  FOR SELECT
  USING (
    -- User can read their own profile
    id = (current_setting('request.jwt.claims', true)::jsonb->>'sub')::uuid
  );

-- Comments
COMMENT ON POLICY "users_select_own_profile" ON public.users IS
  'Allows users to read their own profile, even during onboarding without store_id';

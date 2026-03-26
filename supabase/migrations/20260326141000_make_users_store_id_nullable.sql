-- ============================================================================
-- POS Madagascar — Make users.store_id Nullable
-- Migration: 20260326141000_make_users_store_id_nullable.sql
-- Description: Allow store_id to be NULL during onboarding (set later in setup wizard)
-- ============================================================================

-- Make store_id nullable to allow user creation before store setup
ALTER TABLE public.users
  ALTER COLUMN store_id DROP NOT NULL;

-- Comments
COMMENT ON COLUMN public.users.store_id IS
  'Store ID - can be NULL during onboarding, set during setup wizard';

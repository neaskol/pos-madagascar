-- ============================================================================
-- POS Madagascar — Drift Schema Alignment
-- Migration: 20260326144000_drift_schema_alignment.sql
-- Description: Document that Drift schema was aligned with PostgreSQL schema
--              users.store_id is now nullable to support onboarding flow
-- ============================================================================

-- No database changes needed - this migration documents that:
-- 1. PostgreSQL users.store_id was already made nullable in migration 20260326141000
-- 2. Drift schema (lib/core/data/local/tables/users.drift) was updated to match
-- 3. Auth repository code was updated to handle nullable store_id with Value()

-- This prevents "type null is not a subtype of type 'string'" error during login

COMMENT ON COLUMN public.users.store_id IS
  'Store ID - nullable during onboarding, set during setup wizard. Drift schema aligned 26/03/2026 14:40.';

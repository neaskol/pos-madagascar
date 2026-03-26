-- ============================================================================
-- POS Madagascar — Fix Store Settings Trigger RLS Issue
-- Migration: 20260326120100_fix_store_settings_trigger_rls.sql
-- Description: Make trigger bypass RLS when creating default store settings
-- ============================================================================

-- Drop existing trigger function
DROP FUNCTION IF EXISTS create_default_store_settings() CASCADE;

-- Recreate with SET search_path to bypass RLS properly
CREATE OR REPLACE FUNCTION create_default_store_settings()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  -- Use postgres role to bypass RLS completely
  INSERT INTO store_settings (store_id, created_by)
  VALUES (NEW.id, NEW.created_by);
  RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN
    -- Log error but don't fail the store creation
    RAISE WARNING 'Failed to create store_settings for store %: %', NEW.id, SQLERRM;
    RETURN NEW;
END;
$$;

-- Recreate the trigger
DROP TRIGGER IF EXISTS auto_create_store_settings ON stores;
CREATE TRIGGER auto_create_store_settings
  AFTER INSERT ON stores
  FOR EACH ROW
  EXECUTE FUNCTION create_default_store_settings();

-- Comments
COMMENT ON FUNCTION create_default_store_settings() IS
  'Creates default store_settings row when a new store is created. Uses SECURITY DEFINER to bypass RLS.';

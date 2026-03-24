-- ============================================================================
-- POS Madagascar — Auth Custom Claims
-- Migration: 20260324000007_auth_custom_claims.sql
-- Description: Set store_id and role in JWT for RLS
-- ============================================================================

-- Function to set custom claims after user signup/login
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
  user_store_id UUID;
  user_role TEXT;
BEGIN
  -- Get user's store_id and role from users table
  SELECT store_id, role::TEXT INTO user_store_id, user_role
  FROM public.users
  WHERE id = NEW.id;

  -- Set custom claims in auth.users.raw_app_meta_data
  IF user_store_id IS NOT NULL THEN
    NEW.raw_app_meta_data = COALESCE(NEW.raw_app_meta_data, '{}'::jsonb) ||
      jsonb_build_object(
        'store_id', user_store_id::TEXT,
        'role', user_role
      );
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger on auth.users to set claims
CREATE TRIGGER on_auth_user_created
  BEFORE INSERT OR UPDATE ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- Function to update claims when user role/store changes
CREATE OR REPLACE FUNCTION public.sync_user_claims()
RETURNS TRIGGER AS $$
BEGIN
  -- Update auth.users metadata when users table changes
  UPDATE auth.users
  SET raw_app_meta_data = COALESCE(raw_app_meta_data, '{}'::jsonb) ||
    jsonb_build_object(
      'store_id', NEW.store_id::TEXT,
      'role', NEW.role::TEXT
    ),
    updated_at = NOW()
  WHERE id = NEW.id;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger on users table to sync claims
CREATE TRIGGER on_user_role_change
  AFTER INSERT OR UPDATE OF store_id, role ON public.users
  FOR EACH ROW
  EXECUTE FUNCTION public.sync_user_claims();

-- Comments
COMMENT ON FUNCTION public.handle_new_user() IS 'Sets store_id and role in JWT custom claims on user creation';
COMMENT ON FUNCTION public.sync_user_claims() IS 'Syncs JWT claims when user role or store changes';

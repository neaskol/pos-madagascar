-- ============================================================================
-- POS Madagascar — Create User Trigger on Signup
-- Migration: 20260326140500_create_user_trigger_on_signup.sql
-- Description: Automatically create user in public.users when auth.users is created
-- ============================================================================

-- Drop existing trigger and function if they exist
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user();

-- Create function to handle new user creation
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  -- Insert into public.users table
  INSERT INTO public.users (
    id,
    store_id,
    name,
    email,
    phone,
    role,
    active,
    email_verified,
    created_at,
    updated_at
  )
  VALUES (
    NEW.id,
    NULL,  -- No store_id yet, will be set during setup wizard
    COALESCE(NEW.raw_user_meta_data->>'name', NEW.email),
    NEW.email,
    NEW.raw_user_meta_data->>'phone',
    'OWNER',  -- First user is always OWNER
    TRUE,
    NEW.email_confirmed_at IS NOT NULL,
    NOW(),
    NOW()
  );

  RETURN NEW;
END;
$$;

-- Create trigger on auth.users INSERT
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- Comments
COMMENT ON FUNCTION public.handle_new_user() IS
  'Automatically creates a user in public.users when a new auth.users record is created';
COMMENT ON TRIGGER on_auth_user_created ON auth.users IS
  'Trigger to create public.users entry on signup';

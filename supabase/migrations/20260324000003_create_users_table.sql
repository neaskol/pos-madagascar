-- ============================================================================
-- POS Madagascar — Users Table
-- Migration: 20260324000003_create_users_table.sql
-- Description: Store employees/users with role-based access
-- ============================================================================

CREATE TABLE users (
  -- Primary key (matches auth.users.id)
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,

  -- Store relationship
  store_id UUID NOT NULL REFERENCES stores(id) ON DELETE CASCADE,

  -- User information
  name TEXT NOT NULL,
  email TEXT,
  phone TEXT,

  -- Access control
  role user_role NOT NULL DEFAULT 'CASHIER',
  pin_hash TEXT, -- For PIN-based login at POS

  -- Status flags
  email_verified BOOLEAN NOT NULL DEFAULT FALSE,
  active BOOLEAN NOT NULL DEFAULT TRUE,

  -- Audit fields
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_by UUID REFERENCES auth.users(id),
  deleted_at TIMESTAMPTZ,

  -- Constraints
  CONSTRAINT users_name_check CHECK (LENGTH(TRIM(name)) > 0),
  CONSTRAINT users_email_check CHECK (email IS NULL OR email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

-- Indexes
CREATE INDEX idx_users_store_id ON users(store_id);
CREATE INDEX idx_users_email ON users(email) WHERE email IS NOT NULL;
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_active ON users(active);
CREATE INDEX idx_users_deleted_at ON users(deleted_at) WHERE deleted_at IS NULL;

-- Trigger for updated_at
CREATE TRIGGER update_users_updated_at
  BEFORE UPDATE ON users
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Enable RLS
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- RLS Policies
-- Policy 1: Users can see colleagues in their store
CREATE POLICY "users_select_same_store" ON users
  FOR SELECT
  USING (
    store_id = auth.store_id()
    AND deleted_at IS NULL
  );

-- Policy 2: Only OWNER/ADMIN can create users
CREATE POLICY "users_insert_owner_admin" ON users
  FOR INSERT
  WITH CHECK (
    store_id = auth.store_id()
    AND auth.is_owner_or_admin()
  );

-- Policy 3: Users can update their own profile (limited fields)
CREATE POLICY "users_update_own_profile" ON users
  FOR UPDATE
  USING (
    id = auth.uid()
    AND store_id = auth.store_id()
  )
  WITH CHECK (
    -- Users can't change their own role or store
    role = (SELECT role FROM users WHERE id = auth.uid())
    AND store_id = (SELECT store_id FROM users WHERE id = auth.uid())
  );

-- Policy 4: OWNER/ADMIN can update any user in their store
CREATE POLICY "users_update_by_owner_admin" ON users
  FOR UPDATE
  USING (
    store_id = auth.store_id()
    AND auth.is_owner_or_admin()
  )
  WITH CHECK (
    store_id = auth.store_id()
  );

-- Policy 5: Only OWNER can delete users (soft delete)
CREATE POLICY "users_delete_by_owner" ON users
  FOR UPDATE
  USING (
    store_id = auth.store_id()
    AND auth.user_role() = 'OWNER'
    AND deleted_at IS NULL
  )
  WITH CHECK (
    deleted_at IS NOT NULL
  );

-- Comments
COMMENT ON TABLE users IS 'Store employees with role-based permissions';
COMMENT ON COLUMN users.pin_hash IS 'Hashed PIN for quick POS login (bcrypt)';
COMMENT ON COLUMN users.role IS 'OWNER > ADMIN > MANAGER > CASHIER hierarchy';
COMMENT ON COLUMN users.active IS 'Can be deactivated without deletion';

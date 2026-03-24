-- ============================================================================
-- POS Madagascar — Core Schema Setup
-- Migration: 20260324000001_core_schema_setup.sql
-- Description: Create base types, functions, and triggers
-- ============================================================================

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "pg_trgm"; -- For fuzzy text search

-- ============================================================================
-- CUSTOM TYPES
-- ============================================================================

-- User roles enum
CREATE TYPE user_role AS ENUM ('OWNER', 'ADMIN', 'MANAGER', 'CASHIER');

-- Payment types enum
CREATE TYPE payment_type AS ENUM ('cash', 'card', 'mvola', 'orange_money', 'other');

-- Sold by type enum
CREATE TYPE sold_by_type AS ENUM ('piece', 'weight');

-- Tax type enum
CREATE TYPE tax_type AS ENUM ('added', 'included');

-- Discount type enum
CREATE TYPE discount_type AS ENUM ('percentage', 'amount');

-- ============================================================================
-- UTILITY FUNCTIONS
-- ============================================================================

-- Function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function to get store_id from JWT claims
CREATE OR REPLACE FUNCTION auth.store_id()
RETURNS UUID AS $$
  SELECT COALESCE(
    (auth.jwt() -> 'app_metadata' ->> 'store_id')::uuid,
    '00000000-0000-0000-0000-000000000000'::uuid
  );
$$ LANGUAGE sql STABLE;

-- Function to get user role from JWT claims
CREATE OR REPLACE FUNCTION auth.user_role()
RETURNS TEXT AS $$
  SELECT COALESCE(
    auth.jwt() -> 'app_metadata' ->> 'role',
    'CASHIER'
  );
$$ LANGUAGE sql STABLE;

-- Function to check if user is owner or admin
CREATE OR REPLACE FUNCTION auth.is_owner_or_admin()
RETURNS BOOLEAN AS $$
  SELECT auth.user_role() IN ('OWNER', 'ADMIN');
$$ LANGUAGE sql STABLE;

-- Function to check if user is manager or above
CREATE OR REPLACE FUNCTION auth.is_manager_or_above()
RETURNS BOOLEAN AS $$
  SELECT auth.user_role() IN ('OWNER', 'ADMIN', 'MANAGER');
$$ LANGUAGE sql STABLE;

-- ============================================================================
-- COMMENTS
-- ============================================================================

COMMENT ON FUNCTION update_updated_at_column() IS 'Automatically updates updated_at timestamp on table row update';
COMMENT ON FUNCTION auth.store_id() IS 'Extracts store_id from JWT custom claims';
COMMENT ON FUNCTION auth.user_role() IS 'Extracts user role from JWT custom claims';
COMMENT ON FUNCTION auth.is_owner_or_admin() IS 'Returns true if user is OWNER or ADMIN';
COMMENT ON FUNCTION auth.is_manager_or_above() IS 'Returns true if user is OWNER, ADMIN, or MANAGER';

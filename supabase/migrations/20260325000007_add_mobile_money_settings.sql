-- Migration: Add mobile money merchant settings
-- Description: Add MVola and Orange Money merchant numbers to store settings
-- Date: 2026-03-25
-- Phase: 3.8 - MVola & Orange Money (Différenciant #4)

-- Add merchant numbers to store_settings
ALTER TABLE store_settings
  ADD COLUMN IF NOT EXISTS mvola_merchant_number TEXT,
  ADD COLUMN IF NOT EXISTS orange_money_merchant_number TEXT,
  ADD COLUMN IF NOT EXISTS mobile_money_enabled BOOLEAN DEFAULT true;

-- Add indexes for merchant number lookups
CREATE INDEX IF NOT EXISTS idx_store_settings_mvola ON store_settings(mvola_merchant_number) WHERE mvola_merchant_number IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_store_settings_orange ON store_settings(orange_money_merchant_number) WHERE orange_money_merchant_number IS NOT NULL;

-- Migration: Create pos_devices table
-- Description: POS devices (multiple registers per store)
-- Date: 2026-03-24
-- Note: This table was missing from the original migrations but referenced by sales tables

CREATE TABLE IF NOT EXISTS pos_devices (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id uuid NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  name text NOT NULL,
  active boolean DEFAULT true,
  last_seen_at timestamptz,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  created_by uuid REFERENCES users(id) ON DELETE SET NULL
);

-- Index
CREATE INDEX IF NOT EXISTS idx_pos_devices_store_id ON pos_devices(store_id);

-- Trigger updated_at
CREATE TRIGGER update_pos_devices_updated_at
  BEFORE UPDATE ON pos_devices
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- RLS
ALTER TABLE pos_devices ENABLE ROW LEVEL SECURITY;

CREATE POLICY "store_isolation_pos_devices" ON pos_devices
  USING (store_id IN (
    SELECT store_id FROM users WHERE id = auth.uid()
  ));

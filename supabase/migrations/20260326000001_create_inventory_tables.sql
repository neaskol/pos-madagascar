-- Migration pour les tables d'inventaire : ajustements de stock et historique des mouvements
-- Date: 2026-03-26
-- Phase 3.14 — Ajustements de Stock & Historique

-- ============================================================================
-- TABLE: stock_adjustments
-- ============================================================================
CREATE TABLE IF NOT EXISTS stock_adjustments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  reason TEXT NOT NULL CHECK (reason IN ('receive', 'loss', 'damage', 'inventory_count', 'other')),
  notes TEXT,
  created_by UUID NOT NULL REFERENCES users(id),
  synced BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index pour améliorer les performances de recherche
CREATE INDEX idx_stock_adjustments_store_id ON stock_adjustments(store_id);
CREATE INDEX idx_stock_adjustments_created_at ON stock_adjustments(created_at DESC);
CREATE INDEX idx_stock_adjustments_reason ON stock_adjustments(reason);
CREATE INDEX idx_stock_adjustments_created_by ON stock_adjustments(created_by);

-- RLS (Row Level Security)
ALTER TABLE stock_adjustments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "store_isolation_stock_adjustments" ON stock_adjustments
  USING (store_id = (auth.jwt() ->> 'store_id')::uuid);

-- Trigger pour auto-update du updated_at
CREATE TRIGGER update_stock_adjustments_updated_at
  BEFORE UPDATE ON stock_adjustments
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- TABLE: stock_adjustment_items
-- ============================================================================
CREATE TABLE IF NOT EXISTS stock_adjustment_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  adjustment_id UUID NOT NULL REFERENCES stock_adjustments(id) ON DELETE CASCADE,
  item_id UUID NOT NULL REFERENCES items(id) ON DELETE CASCADE,
  item_variant_id UUID REFERENCES item_variants(id) ON DELETE CASCADE,
  quantity_before DECIMAL(10,4) NOT NULL,
  quantity_change DECIMAL(10,4) NOT NULL,
  quantity_after DECIMAL(10,4) NOT NULL,
  cost INTEGER DEFAULT 0,
  synced BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index
CREATE INDEX idx_stock_adjustment_items_adjustment_id ON stock_adjustment_items(adjustment_id);
CREATE INDEX idx_stock_adjustment_items_item_id ON stock_adjustment_items(item_id);

-- RLS (hérite de stock_adjustments via FK)
ALTER TABLE stock_adjustment_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "store_isolation_stock_adjustment_items" ON stock_adjustment_items
  USING (
    EXISTS (
      SELECT 1 FROM stock_adjustments
      WHERE stock_adjustments.id = stock_adjustment_items.adjustment_id
      AND stock_adjustments.store_id = (auth.jwt() ->> 'store_id')::uuid
    )
  );

-- Trigger pour auto-update du updated_at
CREATE TRIGGER update_stock_adjustment_items_updated_at
  BEFORE UPDATE ON stock_adjustment_items
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- TABLE: inventory_history
-- ============================================================================
CREATE TABLE IF NOT EXISTS inventory_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  item_id UUID NOT NULL REFERENCES items(id) ON DELETE CASCADE,
  item_variant_id UUID REFERENCES item_variants(id) ON DELETE CASCADE,
  reason TEXT NOT NULL CHECK (reason IN ('sale', 'refund', 'purchase_order', 'transfer_in', 'transfer_out', 'adjustment', 'inventory_count', 'production', 'disassembly')),
  reference_id UUID,
  quantity_change DECIMAL(10,4) NOT NULL,
  quantity_after DECIMAL(10,4) NOT NULL,
  cost INTEGER DEFAULT 0,
  employee_id UUID REFERENCES users(id),
  synced BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index pour améliorer les performances de recherche
CREATE INDEX idx_inventory_history_store_id ON inventory_history(store_id);
CREATE INDEX idx_inventory_history_item_id ON inventory_history(item_id);
CREATE INDEX idx_inventory_history_created_at ON inventory_history(created_at DESC);
CREATE INDEX idx_inventory_history_reason ON inventory_history(reason);
CREATE INDEX idx_inventory_history_reference_id ON inventory_history(reference_id);

-- RLS (Row Level Security)
ALTER TABLE inventory_history ENABLE ROW LEVEL SECURITY;

CREATE POLICY "store_isolation_inventory_history" ON inventory_history
  USING (store_id = (auth.jwt() ->> 'store_id')::uuid);

-- ============================================================================
-- COMMENTAIRES
-- ============================================================================

COMMENT ON TABLE stock_adjustments IS 'Ajustements manuels de stock (réception, perte, dommage, inventaire, autre)';
COMMENT ON TABLE stock_adjustment_items IS 'Lignes de détail des ajustements de stock par item';
COMMENT ON TABLE inventory_history IS 'Historique global de tous les mouvements de stock (ventes, refunds, ajustements, etc.)';

COMMENT ON COLUMN stock_adjustments.reason IS 'Raison de l''ajustement: receive, loss, damage, inventory_count, other';
COMMENT ON COLUMN stock_adjustment_items.quantity_change IS 'Quantité ajoutée (+) ou retirée (-) du stock';
COMMENT ON COLUMN inventory_history.reason IS 'Raison du mouvement: sale, refund, purchase_order, transfer_in, transfer_out, adjustment, inventory_count, production, disassembly';
COMMENT ON COLUMN inventory_history.reference_id IS 'ID de référence vers la transaction source (sale_id, adjustment_id, etc.)';

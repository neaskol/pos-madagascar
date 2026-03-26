-- Migration pour les tables de comptage d'inventaire physique
-- Date: 2026-03-26
-- Phase 3.17 — Inventaire Physique

-- ============================================================================
-- TABLE: inventory_counts
-- ============================================================================
CREATE TABLE IF NOT EXISTS inventory_counts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  type TEXT NOT NULL CHECK (type IN ('full', 'partial')),
  status TEXT NOT NULL CHECK (status IN ('pending', 'in_progress', 'completed')),
  notes TEXT,
  created_by UUID NOT NULL REFERENCES users(id),
  completed_at TIMESTAMPTZ,
  synced BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index pour améliorer les performances de recherche
CREATE INDEX idx_inventory_counts_store_id ON inventory_counts(store_id);
CREATE INDEX idx_inventory_counts_status ON inventory_counts(status);
CREATE INDEX idx_inventory_counts_created_at ON inventory_counts(created_at DESC);
CREATE INDEX idx_inventory_counts_created_by ON inventory_counts(created_by);

-- RLS (Row Level Security)
ALTER TABLE inventory_counts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "store_isolation_inventory_counts" ON inventory_counts
  USING (store_id = (auth.jwt() ->> 'store_id')::uuid);

-- Trigger pour auto-update du updated_at
CREATE TRIGGER update_inventory_counts_updated_at
  BEFORE UPDATE ON inventory_counts
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- TABLE: inventory_count_items
-- ============================================================================
CREATE TABLE IF NOT EXISTS inventory_count_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  count_id UUID NOT NULL REFERENCES inventory_counts(id) ON DELETE CASCADE,
  item_id UUID NOT NULL REFERENCES items(id) ON DELETE CASCADE,
  item_variant_id UUID REFERENCES item_variants(id) ON DELETE CASCADE,
  expected_stock DECIMAL(10,4) NOT NULL,
  counted_stock DECIMAL(10,4),
  difference DECIMAL(10,4),
  synced BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index
CREATE INDEX idx_inventory_count_items_count_id ON inventory_count_items(count_id);
CREATE INDEX idx_inventory_count_items_item_id ON inventory_count_items(item_id);

-- RLS (hérite de inventory_counts via FK)
ALTER TABLE inventory_count_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "store_isolation_inventory_count_items" ON inventory_count_items
  USING (
    EXISTS (
      SELECT 1 FROM inventory_counts
      WHERE inventory_counts.id = inventory_count_items.count_id
      AND inventory_counts.store_id = (auth.jwt() ->> 'store_id')::uuid
    )
  );

-- Trigger pour auto-update du updated_at
CREATE TRIGGER update_inventory_count_items_updated_at
  BEFORE UPDATE ON inventory_count_items
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- COMMENTAIRES
-- ============================================================================

COMMENT ON TABLE inventory_counts IS 'Comptages d''inventaire physique (complet ou partiel)';
COMMENT ON TABLE inventory_count_items IS 'Lignes de détail des comptages d''inventaire par item';

COMMENT ON COLUMN inventory_counts.type IS 'Type de comptage: full (tous les items) ou partial (catégorie sélectionnée)';
COMMENT ON COLUMN inventory_counts.status IS 'Statut: pending (créé), in_progress (en cours), completed (terminé)';
COMMENT ON COLUMN inventory_count_items.expected_stock IS 'Stock attendu selon le système';
COMMENT ON COLUMN inventory_count_items.counted_stock IS 'Stock compté physiquement';
COMMENT ON COLUMN inventory_count_items.difference IS 'Différence = counted_stock - expected_stock (calculé)';

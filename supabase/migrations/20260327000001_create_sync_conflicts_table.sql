-- Migration pour la gestion des conflits de synchronisation
-- Date: 2026-03-27
-- Phase 4 — Gestion des Conflits de Sync

-- ============================================================================
-- TABLE: sync_conflicts
-- ============================================================================
-- Stocke les conflits détectés lors de la synchronisation bidirectionnelle
-- pour permettre une résolution manuelle par le gérant si nécessaire

CREATE TABLE IF NOT EXISTS sync_conflicts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID NOT NULL REFERENCES stores(id) ON DELETE CASCADE,

  -- Identification du conflit
  table_name TEXT NOT NULL,
  record_id TEXT NOT NULL,
  field_name TEXT,  -- NULL si conflit sur plusieurs champs

  -- Valeurs en conflit
  local_value JSONB NOT NULL,
  remote_value JSONB NOT NULL,
  local_updated_at TIMESTAMPTZ NOT NULL,
  remote_updated_at TIMESTAMPTZ NOT NULL,

  -- Résolution
  status TEXT NOT NULL CHECK (status IN ('pending', 'resolved_local', 'resolved_remote', 'resolved_manual')),
  resolved_at TIMESTAMPTZ,
  resolved_by UUID REFERENCES users(id),
  resolution_notes TEXT,

  -- Métadonnées
  detected_at TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index pour améliorer les performances
CREATE INDEX idx_sync_conflicts_store_id ON sync_conflicts(store_id);
CREATE INDEX idx_sync_conflicts_status ON sync_conflicts(status);
CREATE INDEX idx_sync_conflicts_table_record ON sync_conflicts(table_name, record_id);
CREATE INDEX idx_sync_conflicts_detected_at ON sync_conflicts(detected_at DESC);

-- RLS (Row Level Security)
ALTER TABLE sync_conflicts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "store_isolation_sync_conflicts" ON sync_conflicts
  USING (store_id = (auth.jwt() ->> 'store_id')::uuid);

-- Trigger pour auto-update du updated_at
CREATE TRIGGER update_sync_conflicts_updated_at
  BEFORE UPDATE ON sync_conflicts
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- COMMENTAIRES
-- ============================================================================

COMMENT ON TABLE sync_conflicts IS 'Conflits de synchronisation détectés entre Drift et Supabase';

COMMENT ON COLUMN sync_conflicts.table_name IS 'Nom de la table où le conflit a été détecté';
COMMENT ON COLUMN sync_conflicts.record_id IS 'ID du record en conflit';
COMMENT ON COLUMN sync_conflicts.field_name IS 'Nom du champ en conflit (NULL si plusieurs champs)';
COMMENT ON COLUMN sync_conflicts.local_value IS 'Valeur locale (Drift) au moment du conflit';
COMMENT ON COLUMN sync_conflicts.remote_value IS 'Valeur distante (Supabase) au moment du conflit';
COMMENT ON COLUMN sync_conflicts.status IS 'Statut: pending (non résolu), resolved_local (local garde), resolved_remote (remote garde), resolved_manual (intervention manuelle)';

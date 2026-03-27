-- Migration pour renommer table_name en conflict_table_name
-- Date: 2026-03-27 11:50 AM
-- Raison: Conflit avec Table.tableName de Drift

-- Renommer la colonne
ALTER TABLE sync_conflicts
RENAME COLUMN table_name TO conflict_table_name;

-- Mettre à jour l'index existant
DROP INDEX IF EXISTS idx_sync_conflicts_table_record;
CREATE INDEX idx_sync_conflicts_table_record ON sync_conflicts(conflict_table_name, record_id);

-- Mettre à jour le commentaire
COMMENT ON COLUMN sync_conflicts.conflict_table_name IS 'Nom de la table où le conflit a été détecté';

-- Migration: Phase 3.6 - Variants & Modifiers Support
-- Description: Create tables for item variants and modifiers (forced modifiers = gap Loyverse)

-- ============================================================================
-- ITEM VARIANTS TABLE
-- ============================================================================

-- Variants (taille, couleur...) pour un item
-- Max 3 options (option1, option2, option3), 200 combinaisons par item (limite Loyverse)
CREATE TABLE IF NOT EXISTS item_variants (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  item_id UUID NOT NULL REFERENCES items(id) ON DELETE CASCADE,
  store_id UUID NOT NULL REFERENCES stores(id) ON DELETE CASCADE,

  -- Option 1 (ex: Taille)
  option1_name VARCHAR(50),
  option1_value VARCHAR(100),

  -- Option 2 (ex: Couleur)
  option2_name VARCHAR(50),
  option2_value VARCHAR(100),

  -- Option 3 (ex: Matériau)
  option3_name VARCHAR(50),
  option3_value VARCHAR(100),

  -- SKU et barcode spécifiques au variant
  sku VARCHAR(40) UNIQUE,
  barcode VARCHAR(100),

  -- Prix et coût (null = hérite du parent item)
  price INT,
  cost INT,

  -- Stock tracking (si parent item a track_stock = true)
  in_stock INT DEFAULT 0,
  low_stock_threshold INT DEFAULT 0,

  -- Image spécifique (null = utilise celle du parent)
  image_url TEXT,

  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  created_by UUID REFERENCES users(id),

  -- Contrainte : au moins une option doit être remplie
  CHECK (
    (option1_name IS NOT NULL AND option1_value IS NOT NULL) OR
    (option2_name IS NOT NULL AND option2_value IS NOT NULL) OR
    (option3_name IS NOT NULL AND option3_value IS NOT NULL)
  )
);

-- Index pour performance
CREATE INDEX idx_item_variants_item_id ON item_variants(item_id);
CREATE INDEX idx_item_variants_store_id ON item_variants(store_id);
CREATE INDEX idx_item_variants_sku ON item_variants(sku) WHERE sku IS NOT NULL;
CREATE INDEX idx_item_variants_barcode ON item_variants(barcode) WHERE barcode IS NOT NULL;

-- RLS policies
ALTER TABLE item_variants ENABLE ROW LEVEL SECURITY;

CREATE POLICY "store_isolation_item_variants" ON item_variants
  USING (store_id IN (
    SELECT store_id FROM users WHERE id = auth.uid()
  ));

-- Auto-update timestamp trigger
CREATE TRIGGER update_item_variants_updated_at
  BEFORE UPDATE ON item_variants
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- MODIFIERS TABLE (Ensembles d'options)
-- ============================================================================

-- Modifiers (ex: "Taille boisson", "Garniture pizza")
CREATE TABLE IF NOT EXISTS modifiers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  name VARCHAR(100) NOT NULL,

  -- Forced modifier = différenciant vs Loyverse (qui n'a que des modifiers optionnels)
  is_required BOOLEAN DEFAULT false,

  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  created_by UUID REFERENCES users(id)
);

-- Index pour performance
CREATE INDEX idx_modifiers_store_id ON modifiers(store_id);

-- RLS policies
ALTER TABLE modifiers ENABLE ROW LEVEL SECURITY;

CREATE POLICY "store_isolation_modifiers" ON modifiers
  USING (store_id IN (
    SELECT store_id FROM users WHERE id = auth.uid()
  ));

-- Auto-update timestamp trigger
CREATE TRIGGER update_modifiers_updated_at
  BEFORE UPDATE ON modifiers
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- MODIFIER OPTIONS TABLE (Options d'un modifier)
-- ============================================================================

-- Options d'un modifier (ex: "Petit", "Moyen", "Grand" pour "Taille boisson")
CREATE TABLE IF NOT EXISTS modifier_options (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  modifier_id UUID NOT NULL REFERENCES modifiers(id) ON DELETE CASCADE,
  name VARCHAR(100) NOT NULL,

  -- Prix additionnel en Ariary (0 = gratuit)
  price_addition INT DEFAULT 0 CHECK (price_addition >= 0),

  -- Ordre d'affichage
  sort_order INT DEFAULT 0,

  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Index pour performance
CREATE INDEX idx_modifier_options_modifier_id ON modifier_options(modifier_id);
CREATE INDEX idx_modifier_options_sort ON modifier_options(modifier_id, sort_order);

-- RLS policies (via modifier parent)
ALTER TABLE modifier_options ENABLE ROW LEVEL SECURITY;

CREATE POLICY "store_isolation_modifier_options" ON modifier_options
  USING (
    modifier_id IN (
      SELECT id FROM modifiers WHERE store_id IN (
        SELECT store_id FROM users WHERE id = auth.uid()
      )
    )
  );

-- Auto-update timestamp trigger
CREATE TRIGGER update_modifier_options_updated_at
  BEFORE UPDATE ON modifier_options
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- ITEM_MODIFIERS JUNCTION TABLE (Many-to-Many)
-- ============================================================================

-- Liaison item <-> modifier (un item peut avoir plusieurs modifiers)
CREATE TABLE IF NOT EXISTS item_modifiers (
  item_id UUID NOT NULL REFERENCES items(id) ON DELETE CASCADE,
  modifier_id UUID NOT NULL REFERENCES modifiers(id) ON DELETE CASCADE,
  sort_order INT DEFAULT 0,
  PRIMARY KEY (item_id, modifier_id)
);

-- Index pour performance
CREATE INDEX idx_item_modifiers_item_id ON item_modifiers(item_id);
CREATE INDEX idx_item_modifiers_modifier_id ON item_modifiers(modifier_id);

-- RLS policies
ALTER TABLE item_modifiers ENABLE ROW LEVEL SECURITY;

CREATE POLICY "store_isolation_item_modifiers" ON item_modifiers
  USING (
    item_id IN (
      SELECT id FROM items WHERE store_id IN (
        SELECT store_id FROM users WHERE id = auth.uid()
      )
    )
  );

-- ============================================================================
-- COMMENTS
-- ============================================================================

COMMENT ON TABLE item_variants IS 'Variants of items (size, color, etc.). Max 3 options, 200 combinations per item.';
COMMENT ON COLUMN item_variants.option1_name IS 'Example: "Taille"';
COMMENT ON COLUMN item_variants.option1_value IS 'Example: "Grande"';
COMMENT ON COLUMN item_variants.price IS 'NULL = inherits from parent item';

COMMENT ON TABLE modifiers IS 'Modifier groups (e.g., "Drink Size", "Pizza Toppings")';
COMMENT ON COLUMN modifiers.is_required IS 'Forced modifier (gap vs Loyverse) - must select one option';

COMMENT ON TABLE modifier_options IS 'Options within a modifier group (e.g., "Small", "Medium", "Large")';
COMMENT ON COLUMN modifier_options.price_addition IS 'Additional price in Ariary (0 = free)';

COMMENT ON TABLE item_modifiers IS 'Many-to-many: items can have multiple modifier groups';

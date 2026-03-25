-- Phase 3.7 — Custom Product Pages
-- Permet aux utilisateurs de créer des pages personnalisées de produits
-- avec drag & drop pour organiser la grille de caisse

-- Pages personnalisées
CREATE TABLE custom_product_pages (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id uuid NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  name text NOT NULL,
  sort_order integer NOT NULL DEFAULT 0,
  is_default boolean DEFAULT false, -- Page par défaut (All Products alphabétique)
  created_by uuid REFERENCES users(id),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Items placés sur une page personnalisée
CREATE TABLE custom_page_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  page_id uuid NOT NULL REFERENCES custom_product_pages(id) ON DELETE CASCADE,
  item_id uuid NOT NULL REFERENCES items(id) ON DELETE CASCADE,
  position integer NOT NULL, -- Position dans la grille (0-indexed)
  created_at timestamptz DEFAULT now()
);

-- Grilles de catégories placées sur une page personnalisée
CREATE TABLE custom_page_category_grids (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  page_id uuid NOT NULL REFERENCES custom_product_pages(id) ON DELETE CASCADE,
  category_id uuid NOT NULL REFERENCES categories(id) ON DELETE CASCADE,
  position integer NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Indexes pour performance
CREATE INDEX idx_custom_pages_store ON custom_product_pages(store_id);
CREATE INDEX idx_custom_pages_sort ON custom_product_pages(store_id, sort_order);
CREATE INDEX idx_custom_page_items_page ON custom_page_items(page_id);
CREATE INDEX idx_custom_page_items_position ON custom_page_items(page_id, position);
CREATE INDEX idx_custom_page_category_grids_page ON custom_page_category_grids(page_id);

-- Contrainte unique : un item ne peut apparaître qu'une seule fois par page
CREATE UNIQUE INDEX unique_item_per_page ON custom_page_items(page_id, item_id);

-- Contrainte unique : une catégorie ne peut apparaître qu'une seule fois par page
CREATE UNIQUE INDEX unique_category_per_page ON custom_page_category_grids(page_id, category_id);

-- Trigger auto-update updated_at
CREATE TRIGGER update_custom_product_pages_updated_at
  BEFORE UPDATE ON custom_product_pages
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Row Level Security
ALTER TABLE custom_product_pages ENABLE ROW LEVEL SECURITY;
ALTER TABLE custom_page_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE custom_page_category_grids ENABLE ROW LEVEL SECURITY;

-- Policies : isolation par store_id
CREATE POLICY "store_isolation_custom_pages" ON custom_product_pages
  USING (store_id = (auth.jwt() ->> 'store_id')::uuid);

CREATE POLICY "store_isolation_custom_page_items" ON custom_page_items
  USING (
    page_id IN (
      SELECT id FROM custom_product_pages
      WHERE store_id = (auth.jwt() ->> 'store_id')::uuid
    )
  );

CREATE POLICY "store_isolation_custom_page_category_grids" ON custom_page_category_grids
  USING (
    page_id IN (
      SELECT id FROM custom_product_pages
      WHERE store_id = (auth.jwt() ->> 'store_id')::uuid
    )
  );

-- Fonction pour créer la page par défaut "All Products" pour un nouveau magasin
CREATE OR REPLACE FUNCTION create_default_product_page()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO custom_product_pages (store_id, name, is_default, sort_order)
  VALUES (NEW.id, 'All Products', true, 0);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger : créer la page par défaut à la création d'un magasin
-- Note: Ce trigger sera créé après la table stores existe
-- CREATE TRIGGER create_default_page_on_store_creation
--   AFTER INSERT ON stores
--   FOR EACH ROW
--   EXECUTE FUNCTION create_default_product_page();

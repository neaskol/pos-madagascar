# Schéma de base de données — POS Madagascar

Charger ce fichier quand : création de tables Supabase, migrations, RLS, modèles Drift.

---

## Règles communes à toutes les tables

```sql
-- Toujours inclure sur chaque table :
id          uuid PRIMARY KEY DEFAULT gen_random_uuid()
store_id    uuid NOT NULL REFERENCES stores(id) ON DELETE CASCADE
created_at  timestamptz DEFAULT now()
updated_at  timestamptz DEFAULT now()  -- trigger auto-update
created_by  uuid REFERENCES users(id) -- pour les logs d'activité

-- Toujours activer RLS :
ALTER TABLE nom_table ENABLE ROW LEVEL SECURITY;

-- Pattern RLS par store_id :
CREATE POLICY "store_isolation" ON nom_table
  USING (store_id = (auth.jwt() ->> 'store_id')::uuid);
```

Drift : chaque table a aussi `synced BOOLEAN DEFAULT FALSE` et `updatedAt DATETIME`.

---

## Tables core

```sql
-- Magasins
stores (id, name, address, phone, logo_url, currency='MGA', timezone)

-- Utilisateurs
users (id, store_id, name, email, phone, role ENUM('OWNER','ADMIN','MANAGER','CASHIER'),
       pin_hash, email_verified, active)

-- Appareils POS (plusieurs caisses par magasin)
pos_devices (id, store_id, name, active, last_seen_at)

-- Réglages du magasin (modules activables)
store_settings (
  store_id PK,
  shifts_enabled BOOL DEFAULT false,
  time_clock_enabled BOOL DEFAULT false,
  open_tickets_enabled BOOL DEFAULT false,
  predefined_tickets_enabled BOOL DEFAULT false,
  kitchen_printers_enabled BOOL DEFAULT false,
  customer_display_enabled BOOL DEFAULT false,
  dining_options_enabled BOOL DEFAULT false,
  low_stock_notifications BOOL DEFAULT true,
  negative_stock_alerts BOOL DEFAULT false,
  weight_barcodes_enabled BOOL DEFAULT false,
  cash_rounding_unit INT DEFAULT 0,  -- 0 = pas d'arrondi, 50 = arrondi à 50 Ar
  receipt_footer TEXT
)
```

---

## Tables produits

```sql
-- Catégories
categories (id, store_id, name, color, sort_order)

-- Items (produits)
items (
  id, store_id, name, description,
  sku VARCHAR(40) UNIQUE,        -- auto-généré ou manuel, max 40 chars
  barcode VARCHAR(100),
  category_id uuid REFERENCES categories(id),
  price INT NOT NULL,            -- Ariary, jamais décimales
  cost INT DEFAULT 0,            -- prix d'achat
  cost_is_percentage BOOL DEFAULT false,  -- GAP LOYVERSE : coût en %
  sold_by ENUM('piece','weight') DEFAULT 'piece',
  available_for_sale BOOL DEFAULT true,
  track_stock BOOL DEFAULT false,
  in_stock INT DEFAULT 0,
  low_stock_threshold INT DEFAULT 0,
  is_composite BOOL DEFAULT false,
  use_production BOOL DEFAULT false,  -- module production boulangeries
  image_url TEXT,
  average_cost INT DEFAULT 0     -- recalculé à chaque réception (coût moyen pondéré)
)

-- Variants (taille, couleur...)
item_variants (
  id, item_id, store_id,
  option1_name, option1_value,
  option2_name, option2_value,
  option3_name, option3_value,
  sku VARCHAR(40),
  barcode,
  price INT,        -- null = hérite du parent
  cost INT,
  in_stock INT DEFAULT 0,
  low_stock_threshold INT DEFAULT 0,
  image_url TEXT
)
-- Max 3 options, 200 combinaisons par item (limite Loyverse)

-- Items composites — composants d'un item
composite_components (
  id, composite_item_id, component_item_id,
  component_variant_id,   -- null si pas de variant spécifique
  quantity DECIMAL(10,4)  -- quantité du composant par unité composite
)
-- Max 3 niveaux d'imbrication

-- Modifiers (ensembles d'options)
modifiers (id, store_id, name, is_required BOOL DEFAULT false)
-- is_required = forced modifier (GAP LOYVERSE)

modifier_options (
  id, modifier_id, name,
  price_addition INT DEFAULT 0,  -- prix additionnel en Ariary
  sort_order INT
)

-- Liaison item <-> modifier
item_modifiers (item_id, modifier_id, sort_order)

-- Taxes
taxes (
  id, store_id, name,
  rate DECIMAL(5,2),             -- ex: 20.00 pour 20%
  type ENUM('added','included'), -- ajoutée au prix OU incluse dans le prix
  active BOOL DEFAULT true
)

-- Liaison item <-> taxe
item_taxes (item_id, tax_id)

-- Remises configurables
discounts (
  id, store_id, name,
  type ENUM('percentage','amount'),
  value INT,                     -- % ou Ariary
  restricted_access BOOL DEFAULT false,  -- seul manager/admin peut appliquer
  active BOOL DEFAULT true
)
```

---

## Tables ventes

```sql
-- Shifts de caisse
shifts (
  id, store_id, pos_device_id, employee_id,
  opened_at, closed_at,
  opening_cash INT,              -- Ariary
  expected_cash INT,             -- calculé auto
  actual_cash INT,               -- saisi à la fermeture
  cash_difference INT,           -- actual - expected
  status ENUM('open','closed')
)

-- Mouvements de caisse pendant un shift
cash_movements (
  id, shift_id, store_id,
  type ENUM('pay_in','pay_out'),
  amount INT,
  note TEXT,
  employee_id,
  created_at
)

-- Tickets ouverts (sauvegardés)
open_tickets (
  id, store_id, pos_device_id,
  name TEXT,                     -- nom du ticket ou numéro de table
  comment TEXT,
  employee_id,
  is_predefined BOOL DEFAULT false,
  dining_option_id,
  items JSONB,                   -- snapshot des items du ticket
  created_at, updated_at
)

-- Ventes finalisées
sales (
  id, store_id, pos_device_id,
  receipt_number VARCHAR(20),    -- numéro de reçu unique et séquentiel
  employee_id,
  customer_id,
  dining_option_id,
  subtotal INT,
  tax_amount INT,
  discount_amount INT,
  total INT,
  change_due INT,
  note TEXT,
  synced BOOL DEFAULT false,
  created_at
)

-- Lignes d'une vente
sale_items (
  id, sale_id,
  item_id, item_variant_id,
  item_name TEXT,               -- snapshot du nom au moment de la vente
  quantity DECIMAL(10,4),
  unit_price INT,
  cost INT,                     -- snapshot du coût au moment de la vente
  discount_amount INT,
  tax_amount INT,
  total INT,
  modifiers JSONB               -- snapshot des options choisies
)

-- Paiements d'une vente (multi-paiement)
sale_payments (
  id, sale_id,
  payment_type ENUM('cash','card','mvola','orange_money','other'),
  payment_type_name TEXT,       -- nom du type personnalisé
  amount INT,
  payment_reference TEXT,       -- référence transaction Mobile Money
  payment_status ENUM('pending','confirmed') DEFAULT 'confirmed'
)

-- Remboursements
refunds (
  id, sale_id, store_id,
  employee_id,
  total INT,
  reason TEXT,
  created_at
)

refund_items (
  id, refund_id, sale_item_id,
  quantity DECIMAL(10,4),
  amount INT
)

-- Options de service (dining)
dining_options (
  id, store_id, name,
  sort_order INT,
  is_default BOOL DEFAULT false
)
```

---

## Tables clients

```sql
customers (
  id, store_id,
  name TEXT NOT NULL,
  phone VARCHAR(20),
  email TEXT,
  loyalty_card_barcode TEXT,
  total_visits INT DEFAULT 0,
  total_spent INT DEFAULT 0,
  created_at
)

loyalty_points (
  id, customer_id, store_id,
  points INT DEFAULT 0,
  updated_at
)

-- Historique achats : lié via sales.customer_id
```

---

## Tables inventaire avancé

```sql
-- Fournisseurs
suppliers (
  id, store_id,
  name TEXT UNIQUE,             -- unique par magasin
  email TEXT,
  phone TEXT,
  address TEXT,
  notes TEXT
)

-- Bons de commande
purchase_orders (
  id, store_id, supplier_id,
  status ENUM('draft','pending','partial','closed') DEFAULT 'draft',
  order_date DATE,
  expected_date DATE,
  notes TEXT,
  subtotal INT,
  total INT,
  created_by, created_at, updated_at
)

purchase_order_items (
  id, purchase_order_id,
  item_id, item_variant_id,
  quantity_ordered DECIMAL(10,4),
  quantity_received DECIMAL(10,4) DEFAULT 0,
  purchase_cost INT,           -- coût d'achat unitaire
  total INT
)

purchase_order_costs (
  id, purchase_order_id,
  name TEXT,                   -- ex: "Frais de port", "Douane"
  amount INT,                  -- peut être négatif (remise fournisseur)
  applied BOOL DEFAULT true
)

-- Transferts entre magasins
transfer_orders (
  id,
  source_store_id, destination_store_id,
  status ENUM('draft','in_transit','transferred') DEFAULT 'draft',
  transfer_date DATE,
  notes TEXT,
  created_by, created_at, updated_at
)

transfer_order_items (
  id, transfer_order_id,
  item_id, item_variant_id,
  quantity DECIMAL(10,4),
  cost INT
)

-- Ajustements de stock
stock_adjustments (
  id, store_id,
  reason ENUM('receive','loss','damage','inventory_count','other'),
  notes TEXT,
  created_by, created_at
)

stock_adjustment_items (
  id, adjustment_id,
  item_id, item_variant_id,
  quantity_before DECIMAL(10,4),
  quantity_change DECIMAL(10,4),   -- positif = ajout, négatif = retrait
  quantity_after DECIMAL(10,4),
  cost INT
)

-- Inventaires physiques
inventory_counts (
  id, store_id,
  type ENUM('full','partial'),
  status ENUM('pending','in_progress','completed') DEFAULT 'pending',
  notes TEXT,
  created_by, created_at, completed_at
)

inventory_count_items (
  id, count_id,
  item_id, item_variant_id,
  expected_stock DECIMAL(10,4),
  counted_stock DECIMAL(10,4),
  difference DECIMAL(10,4)     -- counted - expected
)

-- Production (boulangeries, assemblage)
productions (
  id, store_id,
  type ENUM('production','disassembly'),
  notes TEXT,
  created_by, created_at
)

production_items (
  id, production_id,
  item_id,                     -- item composite
  quantity DECIMAL(10,4),
  cost INT                     -- coût calculé des composants
)

-- Historique global des mouvements de stock
inventory_history (
  id, store_id,
  item_id, item_variant_id,
  reason ENUM('sale','refund','purchase_order','transfer_in','transfer_out',
              'adjustment','inventory_count','production','disassembly'),
  reference_id uuid,           -- id de la sale, purchase_order, etc.
  quantity_change DECIMAL(10,4),
  quantity_after DECIMAL(10,4),
  cost INT,
  employee_id,
  created_at
)
```

---

## Tables exclusives (non-Loyverse)

```sql
-- Vente à crédit
credits (
  id, store_id,
  customer_id,
  sale_id,                     -- vente liée
  amount_total INT,
  amount_paid INT DEFAULT 0,
  amount_remaining INT,
  due_date DATE,
  status ENUM('pending','partial','paid','overdue') DEFAULT 'pending',
  notes TEXT,
  created_by, created_at, updated_at
)

credit_payments (
  id, credit_id,
  amount INT,
  payment_type TEXT,
  notes TEXT,
  created_by, created_at
)

-- Logs d'activité
activity_logs (
  id, store_id,
  user_id,
  action TEXT,                 -- ex: 'sale.create', 'item.price_changed'
  entity_type TEXT,            -- ex: 'sale', 'item', 'employee'
  entity_id uuid,
  old_value JSONB,
  new_value JSONB,
  created_at
)
```

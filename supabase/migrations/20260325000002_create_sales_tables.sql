-- Migration: Create sales tables
-- Description: Tables for POS sales, payments, receipts, and shifts
-- Date: 2026-03-25

-- Shifts de caisse
CREATE TABLE IF NOT EXISTS shifts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id uuid NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  pos_device_id uuid REFERENCES pos_devices(id) ON DELETE SET NULL,
  employee_id uuid REFERENCES users(id) ON DELETE SET NULL,
  opened_at timestamptz NOT NULL DEFAULT now(),
  closed_at timestamptz,
  opening_cash integer NOT NULL DEFAULT 0,
  expected_cash integer DEFAULT 0,
  actual_cash integer,
  cash_difference integer,
  status text NOT NULL CHECK (status IN ('open', 'closed')) DEFAULT 'open',
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Mouvements de caisse pendant un shift
CREATE TABLE IF NOT EXISTS cash_movements (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  shift_id uuid NOT NULL REFERENCES shifts(id) ON DELETE CASCADE,
  store_id uuid NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  type text NOT NULL CHECK (type IN ('pay_in', 'pay_out')),
  amount integer NOT NULL,
  note text,
  employee_id uuid REFERENCES users(id) ON DELETE SET NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Tickets ouverts (sauvegardés)
CREATE TABLE IF NOT EXISTS open_tickets (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id uuid NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  pos_device_id uuid REFERENCES pos_devices(id) ON DELETE SET NULL,
  name text NOT NULL,
  comment text,
  employee_id uuid REFERENCES users(id) ON DELETE SET NULL,
  is_predefined boolean DEFAULT false,
  dining_option_id uuid,
  items jsonb NOT NULL DEFAULT '[]'::jsonb,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Ventes finalisées
CREATE TABLE IF NOT EXISTS sales (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id uuid NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  pos_device_id uuid REFERENCES pos_devices(id) ON DELETE SET NULL,
  receipt_number text NOT NULL,
  employee_id uuid REFERENCES users(id) ON DELETE SET NULL,
  customer_id uuid REFERENCES customers(id) ON DELETE SET NULL,
  dining_option_id uuid,
  subtotal integer NOT NULL DEFAULT 0,
  tax_amount integer NOT NULL DEFAULT 0,
  discount_amount integer NOT NULL DEFAULT 0,
  total integer NOT NULL,
  change_due integer NOT NULL DEFAULT 0,
  note text,
  synced boolean DEFAULT false,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  created_by uuid REFERENCES users(id) ON DELETE SET NULL,
  UNIQUE(store_id, receipt_number)
);

-- Lignes d'une vente
CREATE TABLE IF NOT EXISTS sale_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  sale_id uuid NOT NULL REFERENCES sales(id) ON DELETE CASCADE,
  item_id uuid REFERENCES items(id) ON DELETE SET NULL,
  item_variant_id uuid REFERENCES item_variants(id) ON DELETE SET NULL,
  item_name text NOT NULL,
  quantity numeric(10,4) NOT NULL DEFAULT 1,
  unit_price integer NOT NULL,
  cost integer NOT NULL DEFAULT 0,
  discount_amount integer NOT NULL DEFAULT 0,
  tax_amount integer NOT NULL DEFAULT 0,
  total integer NOT NULL,
  modifiers jsonb DEFAULT '[]'::jsonb,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Paiements d'une vente (multi-paiement)
CREATE TABLE IF NOT EXISTS sale_payments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  sale_id uuid NOT NULL REFERENCES sales(id) ON DELETE CASCADE,
  payment_type text NOT NULL CHECK (payment_type IN ('cash', 'card', 'mvola', 'orange_money', 'other')),
  payment_type_name text,
  amount integer NOT NULL,
  payment_reference text,
  payment_status text NOT NULL CHECK (payment_status IN ('pending', 'confirmed')) DEFAULT 'confirmed',
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Remboursements
CREATE TABLE IF NOT EXISTS refunds (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  sale_id uuid NOT NULL REFERENCES sales(id) ON DELETE CASCADE,
  store_id uuid NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  employee_id uuid REFERENCES users(id) ON DELETE SET NULL,
  total integer NOT NULL,
  reason text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Items remboursés
CREATE TABLE IF NOT EXISTS refund_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  refund_id uuid NOT NULL REFERENCES refunds(id) ON DELETE CASCADE,
  sale_item_id uuid NOT NULL REFERENCES sale_items(id) ON DELETE CASCADE,
  quantity numeric(10,4) NOT NULL,
  amount integer NOT NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Options de service (dining)
CREATE TABLE IF NOT EXISTS dining_options (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id uuid NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  name text NOT NULL,
  sort_order integer NOT NULL DEFAULT 0,
  is_default boolean DEFAULT false,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Indexes pour performance
CREATE INDEX IF NOT EXISTS idx_shifts_store_id ON shifts(store_id);
CREATE INDEX IF NOT EXISTS idx_shifts_employee_id ON shifts(employee_id);
CREATE INDEX IF NOT EXISTS idx_shifts_status ON shifts(status);
CREATE INDEX IF NOT EXISTS idx_cash_movements_shift_id ON cash_movements(shift_id);
CREATE INDEX IF NOT EXISTS idx_cash_movements_store_id ON cash_movements(store_id);
CREATE INDEX IF NOT EXISTS idx_open_tickets_store_id ON open_tickets(store_id);
CREATE INDEX IF NOT EXISTS idx_open_tickets_employee_id ON open_tickets(employee_id);
CREATE INDEX IF NOT EXISTS idx_sales_store_id ON sales(store_id);
CREATE INDEX IF NOT EXISTS idx_sales_employee_id ON sales(employee_id);
CREATE INDEX IF NOT EXISTS idx_sales_customer_id ON sales(customer_id);
CREATE INDEX IF NOT EXISTS idx_sales_receipt_number ON sales(receipt_number);
CREATE INDEX IF NOT EXISTS idx_sales_created_at ON sales(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_sale_items_sale_id ON sale_items(sale_id);
CREATE INDEX IF NOT EXISTS idx_sale_items_item_id ON sale_items(item_id);
CREATE INDEX IF NOT EXISTS idx_sale_payments_sale_id ON sale_payments(sale_id);
CREATE INDEX IF NOT EXISTS idx_refunds_sale_id ON refunds(sale_id);
CREATE INDEX IF NOT EXISTS idx_refunds_store_id ON refunds(store_id);
CREATE INDEX IF NOT EXISTS idx_refund_items_refund_id ON refund_items(refund_id);
CREATE INDEX IF NOT EXISTS idx_dining_options_store_id ON dining_options(store_id);

-- Triggers pour updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_shifts_updated_at BEFORE UPDATE ON shifts FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_cash_movements_updated_at BEFORE UPDATE ON cash_movements FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_open_tickets_updated_at BEFORE UPDATE ON open_tickets FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_sales_updated_at BEFORE UPDATE ON sales FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_sale_items_updated_at BEFORE UPDATE ON sale_items FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_sale_payments_updated_at BEFORE UPDATE ON sale_payments FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_refunds_updated_at BEFORE UPDATE ON refunds FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_refund_items_updated_at BEFORE UPDATE ON refund_items FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_dining_options_updated_at BEFORE UPDATE ON dining_options FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Enable RLS
ALTER TABLE shifts ENABLE ROW LEVEL SECURITY;
ALTER TABLE cash_movements ENABLE ROW LEVEL SECURITY;
ALTER TABLE open_tickets ENABLE ROW LEVEL SECURITY;
ALTER TABLE sales ENABLE ROW LEVEL SECURITY;
ALTER TABLE sale_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE sale_payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE refunds ENABLE ROW LEVEL SECURITY;
ALTER TABLE refund_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE dining_options ENABLE ROW LEVEL SECURITY;

-- RLS Policies (store_id isolation)
CREATE POLICY "store_isolation_shifts" ON shifts
  USING (store_id IN (
    SELECT store_id FROM users WHERE id = auth.uid()
  ));

CREATE POLICY "store_isolation_cash_movements" ON cash_movements
  USING (store_id IN (
    SELECT store_id FROM users WHERE id = auth.uid()
  ));

CREATE POLICY "store_isolation_open_tickets" ON open_tickets
  USING (store_id IN (
    SELECT store_id FROM users WHERE id = auth.uid()
  ));

CREATE POLICY "store_isolation_sales" ON sales
  USING (store_id IN (
    SELECT store_id FROM users WHERE id = auth.uid()
  ));

CREATE POLICY "store_isolation_sale_items" ON sale_items
  USING (sale_id IN (
    SELECT id FROM sales WHERE store_id IN (
      SELECT store_id FROM users WHERE id = auth.uid()
    )
  ));

CREATE POLICY "store_isolation_sale_payments" ON sale_payments
  USING (sale_id IN (
    SELECT id FROM sales WHERE store_id IN (
      SELECT store_id FROM users WHERE id = auth.uid()
    )
  ));

CREATE POLICY "store_isolation_refunds" ON refunds
  USING (store_id IN (
    SELECT store_id FROM users WHERE id = auth.uid()
  ));

CREATE POLICY "store_isolation_refund_items" ON refund_items
  USING (refund_id IN (
    SELECT id FROM refunds WHERE store_id IN (
      SELECT store_id FROM users WHERE id = auth.uid()
    )
  ));

CREATE POLICY "store_isolation_dining_options" ON dining_options
  USING (store_id IN (
    SELECT store_id FROM users WHERE id = auth.uid()
  ));

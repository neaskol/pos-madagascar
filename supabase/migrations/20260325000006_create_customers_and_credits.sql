-- Migration: Create customers and credits tables
-- Description: Tables for customer management and store credit sales (Phase 3.9)
-- Date: 2026-03-25

-- Clients
CREATE TABLE IF NOT EXISTS customers (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id uuid NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  name text NOT NULL,
  phone text,
  email text,
  loyalty_card_barcode text,
  total_visits integer NOT NULL DEFAULT 0,
  total_spent integer NOT NULL DEFAULT 0,
  credit_balance integer NOT NULL DEFAULT 0, -- Total amount owed by customer (sum of unpaid credits)
  notes text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  created_by uuid REFERENCES users(id) ON DELETE SET NULL
);

-- Programme de fidélité
CREATE TABLE IF NOT EXISTS loyalty_points (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id uuid NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
  store_id uuid NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  points integer NOT NULL DEFAULT 0,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Ventes à crédit - Différenciant #3 (inexistant chez tous les concurrents)
CREATE TABLE IF NOT EXISTS credits (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id uuid NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  customer_id uuid NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
  sale_id uuid REFERENCES sales(id) ON DELETE SET NULL, -- Vente liée (null si crédit sans vente)
  amount_total integer NOT NULL, -- Montant total du crédit
  amount_paid integer NOT NULL DEFAULT 0, -- Montant déjà payé
  amount_remaining integer NOT NULL, -- Montant restant à payer (calculé)
  due_date date, -- Date limite de remboursement
  status text NOT NULL CHECK (status IN ('pending', 'partial', 'paid', 'overdue')) DEFAULT 'pending',
  notes text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  created_by uuid REFERENCES users(id) ON DELETE SET NULL
);

-- Paiements de crédit (remboursements partiels ou totaux)
CREATE TABLE IF NOT EXISTS credit_payments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  credit_id uuid NOT NULL REFERENCES credits(id) ON DELETE CASCADE,
  amount integer NOT NULL, -- Montant du paiement
  payment_type text NOT NULL CHECK (payment_type IN ('cash', 'card', 'mvola', 'orange_money', 'other')),
  payment_reference text, -- Référence transaction (ex: MVola)
  notes text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  created_by uuid REFERENCES users(id) ON DELETE SET NULL
);

-- Indexes pour performance
CREATE INDEX IF NOT EXISTS idx_customers_store_id ON customers(store_id);
CREATE INDEX IF NOT EXISTS idx_customers_phone ON customers(phone);
CREATE INDEX IF NOT EXISTS idx_customers_email ON customers(email);
CREATE INDEX IF NOT EXISTS idx_customers_loyalty_card ON customers(loyalty_card_barcode);
CREATE INDEX IF NOT EXISTS idx_loyalty_points_customer_id ON loyalty_points(customer_id);
CREATE INDEX IF NOT EXISTS idx_loyalty_points_store_id ON loyalty_points(store_id);
CREATE INDEX IF NOT EXISTS idx_credits_store_id ON credits(store_id);
CREATE INDEX IF NOT EXISTS idx_credits_customer_id ON credits(customer_id);
CREATE INDEX IF NOT EXISTS idx_credits_status ON credits(status);
CREATE INDEX IF NOT EXISTS idx_credits_due_date ON credits(due_date);
CREATE INDEX IF NOT EXISTS idx_credit_payments_credit_id ON credit_payments(credit_id);

-- Triggers pour updated_at
CREATE TRIGGER update_customers_updated_at BEFORE UPDATE ON customers
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_loyalty_points_updated_at BEFORE UPDATE ON loyalty_points
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_credits_updated_at BEFORE UPDATE ON credits
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_credit_payments_updated_at BEFORE UPDATE ON credit_payments
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Trigger pour mettre à jour amount_remaining automatiquement
CREATE OR REPLACE FUNCTION update_credit_remaining()
RETURNS TRIGGER AS $$
BEGIN
  NEW.amount_remaining = NEW.amount_total - NEW.amount_paid;

  -- Mettre à jour le statut automatiquement
  IF NEW.amount_remaining = 0 THEN
    NEW.status = 'paid';
  ELSIF NEW.amount_paid > 0 AND NEW.amount_remaining > 0 THEN
    NEW.status = 'partial';
  ELSIF NEW.due_date IS NOT NULL AND NEW.due_date < CURRENT_DATE AND NEW.amount_remaining > 0 THEN
    NEW.status = 'overdue';
  ELSE
    NEW.status = 'pending';
  END IF;

  RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_credit_remaining_trigger
  BEFORE INSERT OR UPDATE ON credits
  FOR EACH ROW EXECUTE FUNCTION update_credit_remaining();

-- Trigger pour mettre à jour credit_balance du client après paiement
CREATE OR REPLACE FUNCTION update_customer_credit_balance()
RETURNS TRIGGER AS $$
DECLARE
  total_owed integer;
BEGIN
  -- Calculer le total des crédits impayés pour ce client
  SELECT COALESCE(SUM(amount_remaining), 0)
  INTO total_owed
  FROM credits
  WHERE customer_id = COALESCE(NEW.customer_id, OLD.customer_id)
    AND status IN ('pending', 'partial', 'overdue');

  -- Mettre à jour le credit_balance du client
  UPDATE customers
  SET credit_balance = total_owed
  WHERE id = COALESCE(NEW.customer_id, OLD.customer_id);

  RETURN COALESCE(NEW, OLD);
END;
$$ language 'plpgsql';

CREATE TRIGGER update_customer_credit_balance_trigger
  AFTER INSERT OR UPDATE OR DELETE ON credits
  FOR EACH ROW EXECUTE FUNCTION update_customer_credit_balance();

-- Enable RLS
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE loyalty_points ENABLE ROW LEVEL SECURITY;
ALTER TABLE credits ENABLE ROW LEVEL SECURITY;
ALTER TABLE credit_payments ENABLE ROW LEVEL SECURITY;

-- RLS Policies (store_id isolation)
CREATE POLICY "store_isolation_customers" ON customers
  USING (store_id IN (
    SELECT store_id FROM users WHERE id = auth.uid()
  ));

CREATE POLICY "store_isolation_loyalty_points" ON loyalty_points
  USING (store_id IN (
    SELECT store_id FROM users WHERE id = auth.uid()
  ));

CREATE POLICY "store_isolation_credits" ON credits
  USING (store_id IN (
    SELECT store_id FROM users WHERE id = auth.uid()
  ));

CREATE POLICY "store_isolation_credit_payments" ON credit_payments
  USING (credit_id IN (
    SELECT id FROM credits WHERE store_id IN (
      SELECT store_id FROM users WHERE id = auth.uid()
    )
  ));

# Migrations Supabase Appliquées — POS Madagascar

**Date** : 26 mars 2026 11:15 AM GMT+3

---

## Migration 1 : Stock Adjustments & Inventory History

**Fichier** : `supabase/migrations/20260326000001_create_inventory_tables.sql`
**Statut** : ✅ APPLIQUÉE (déjà existante avant aujourd'hui)

### Tables créées
- ✅ `stock_adjustments` (ajustements manuels de stock)
- ✅ `stock_adjustment_items` (lignes de détail des ajustements)
- ✅ `inventory_history` (historique global des mouvements)

### RLS Policies
- ✅ `store_isolation_stock_adjustments`
- ✅ `store_isolation_stock_adjustment_items`
- ✅ `store_isolation_inventory_history`

### Indexes créés
- ✅ 11 indexes pour performance sur store_id, created_at, reason, item_id, reference_id

### Vérification
```bash
# Tables existent
SELECT tablename FROM pg_tables
WHERE tablename IN ('stock_adjustments', 'stock_adjustment_items', 'inventory_history');

# Result:
# inventory_history
# stock_adjustment_items
# stock_adjustments
```

---

## Migration 2 : Inventory Counts (Comptage Physique)

**Fichier** : `supabase/migrations/20260326000002_create_inventory_count_tables.sql`
**Statut** : ✅ APPLIQUÉE le 26 mars 2026 11:15 AM

### Tables créées
- ✅ `inventory_counts` (comptages d'inventaire)
- ✅ `inventory_count_items` (lignes de détail des comptages)

### RLS Policies
- ✅ `store_isolation_inventory_counts`
- ✅ `store_isolation_inventory_count_items`

### Indexes créés
- ✅ 7 indexes pour performance sur count_id, store_id, status, created_at, item_id

### Vérification
```bash
# Tables existent
SELECT tablename FROM pg_tables
WHERE tablename IN ('inventory_counts', 'inventory_count_items');

# Result:
# inventory_count_items
# inventory_counts

# Policies existent
SELECT tablename, policyname FROM pg_policies
WHERE tablename IN ('inventory_counts', 'inventory_count_items');

# Result:
# inventory_count_items | store_isolation_inventory_count_items
# inventory_counts      | store_isolation_inventory_counts
```

---

## État Global Supabase

**Total tables** : 33 dans le schéma public

### Tables inventaire (5)
1. `stock_adjustments`
2. `stock_adjustment_items`
3. `inventory_history`
4. `inventory_counts`
5. `inventory_count_items`

### Toutes les tables du projet
stores, users, store_settings, categories, items, pos_devices,
item_variants, modifiers, modifier_options, item_modifiers,
taxes, item_taxes, sales, sale_items, sale_payments,
shifts, cash_movements, open_tickets, refunds, refund_items,
dining_options, customers, loyalty_points, credits, credit_payments,
custom_product_pages, custom_page_items, custom_page_category_grids,
**stock_adjustments, stock_adjustment_items, inventory_history,
inventory_counts, inventory_count_items**

---

## Résultat des Phases

### Phase 3.14 — Ajustements de Stock : **🟢 98% COMPLET**
- ✅ Tables Drift (3/3)
- ✅ DAOs (2/2)
- ✅ Migration Supabase appliquée
- ✅ Repository + BLoC enregistré
- ✅ Écrans UI (2/2)
- ✅ Routes (2/2)
- ⚠️ Tests end-to-end manquants (2%)

### Phase 3.17 — Inventaire Physique : **🟢 98% COMPLET**
- ✅ Tables Drift (2/2)
- ✅ DAO (1/1)
- ✅ Migration Supabase appliquée
- ✅ Repository + BLoC enregistré
- ✅ Écrans UI (3/3)
- ✅ Routes (3/3)
- ⚠️ Tests end-to-end manquants (2%)

---

## Commandes Utilisées

### Vérifier les tables
```bash
TOKEN=$(security find-generic-password -s "Supabase CLI" -a "supabase" -w 2>/dev/null | sed 's/go-keyring-base64://' | base64 -d 2>/dev/null)
PROJECT_ID="ofrbxqxhtnizdwipqdls"
SQL="SELECT tablename FROM pg_tables WHERE schemaname = 'public' ORDER BY tablename;"
curl -s "https://api.supabase.com/v1/projects/$PROJECT_ID/database/query" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -X POST \
  -d "$(jq -n --arg sql "$SQL" '{query: $sql}')" \
  --max-time 30 | jq
```

### Appliquer une migration
```bash
TOKEN=$(security find-generic-password -s "Supabase CLI" -a "supabase" -w 2>/dev/null | sed 's/go-keyring-base64://' | base64 -d 2>/dev/null)
PROJECT_ID="ofrbxqxhtnizdwipqdls"
SQL=$(cat supabase/migrations/MIGRATION_FILE.sql)
curl -s "https://api.supabase.com/v1/projects/$PROJECT_ID/database/query" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -X POST \
  -d "$(jq -n --arg sql "$SQL" '{query: $sql}')" \
  --max-time 30
```

---

**Rapport généré le** : 26 mars 2026 11:15 AM GMT+3

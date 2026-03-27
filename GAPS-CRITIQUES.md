# Gaps Critiques d'Implémentation — POS Madagascar

**Date de l'audit** : 26 mars 2026, 20:10 PM
**Auditeur** : Claude Sonnet 4.5

---

## ❌ GAP #1 : Pull Sync Incomplet (CRITIQUE)

### Problème
Le `SyncService` implémente seulement **3 tables sur 19** pour le pull sync (Supabase → Drift) :
- ✅ Categories
- ✅ Items
- ✅ Customers
- ❌ **Sales** (ventes)
- ❌ **Refunds** (remboursements)
- ❌ **Credits** (ventes à crédit)
- ❌ **SaleItems** (lignes de vente)
- ❌ **SalePayments** (paiements)
- ❌ **RefundItems** (lignes de remboursement)
- ❌ **CreditPayments** (paiements de crédit)
- ❌ **ItemVariants** (variants produits)
- ❌ **Modifiers** (modificateurs)
- ❌ **Taxes** (taxes)
- ❌ **Discounts** (remises)
- ❌ **OpenTickets** (tickets ouverts)
- ❌ **Shifts** (shifts de caisse)
- ❌ **InventoryHistory** (historique stock)
- ❌ **StockAdjustments** (ajustements stock)
- ❌ **InventoryCounts** (inventaires physiques)

### Impact
**Scénario bloquant** :
1. Utilisateur crée une vente sur appareil A → sync push vers Supabase ✅
2. Utilisateur ouvre l'app sur appareil B → **ne voit AUCUNE vente** ❌
3. Utilisateur crée un client sur appareil A → sync push ✅
4. Appareil B → pull sync → voit le client ✅
5. **Incohérence totale** : clients OK, ventes invisibles

### Solution requise
Implémenter `_pullXxx()` pour TOUTES les tables dans `SyncService.syncFromRemote()` :
- `_pullSales()` + `_pullSaleItems()` + `_pullSalePayments()`
- `_pullRefunds()` + `_pullRefundItems()`
- `_pullCredits()` + `_pullCreditPayments()`
- `_pullItemVariants()`
- `_pullModifiers()` + `_pullModifierOptions()`
- `_pullTaxes()`
- `_pullDiscounts()`
- `_pullOpenTickets()`
- `_pullShifts()`
- `_pullInventoryHistory()`
- `_pullStockAdjustments()` + `_pullStockAdjustmentItems()`
- `_pullInventoryCounts()` + `_pullInventoryCountItems()`

### Fichiers concernés
- `lib/core/data/remote/sync_service.dart` — ajouter méthodes pull
- `lib/core/data/local/daos/*.dart` — ajouter méthodes `upsert*()` manquantes

---

## ❌ GAP #2 : Gestion des Conflits de Sync Absente (CRITIQUE)

### Problème
Aucune stratégie de résolution de conflits quand :
- Appareil A modifie un produit offline
- Appareil B modifie le même produit offline
- Les deux se reconnectent et tentent de sync

Actuellement : **last-write-wins** implicite via `upsert()`, mais sans :
- Détection de conflit
- Merge intelligent
- Log des écrasements
- UI pour résoudre manuellement

### Impact
**Scénario de perte de données** :
1. Gérant modifie prix produit X de 5000 → 6000 Ar sur tablette (offline)
2. Caissier modifie stock produit X de 10 → 5 unités sur téléphone (offline)
3. Tablette se reconnecte en premier → push prix 6000 + stock 10 (ancien)
4. Téléphone se reconnecte → **écrase** avec prix 5000 (ancien) + stock 5 (nouveau)
5. Résultat : **prix écrasé silencieusement**, gérant ne le sait jamais

### Solution requise
Implémenter stratégie de merge avec `updated_at` :
```dart
// Pseudo-code
if (remoteUpdatedAt > localUpdatedAt) {
  // Remote plus récent → prendre remote
  await dao.upsertFromRemote(remoteData);
} else if (localUpdatedAt > remoteUpdatedAt && localSynced == false) {
  // Local plus récent ET non synchronisé → conflit !
  await conflictDao.logConflict(localData, remoteData);
  // Option 1 : last-write-wins (local gagne)
  // Option 2 : merge champ par champ
  // Option 3 : alerte gérant pour résolution manuelle
}
```

### Fichiers concernés
- `lib/core/data/remote/sync_service.dart` — ajouter détection conflit
- `lib/core/data/local/daos/conflict_dao.dart` — **nouveau** DAO pour log conflits
- Migration Supabase + Drift pour table `sync_conflicts`

---

## ❌ GAP #3 : RLS Policies Manquantes sur Tables Récentes (BLOQUANT)

### Problème
Les migrations Phase 3 ont créé 6+ nouvelles tables **SANS RLS policies** :
- ✅ `credits` — RLS ajouté
- ✅ `credit_payments` — RLS ajouté
- ❌ `inventory_counts` — **pas de RLS**
- ❌ `inventory_count_items` — **pas de RLS**
- ❌ `stock_adjustments` — **pas de RLS**
- ❌ `stock_adjustment_items` — **pas de RLS**
- ❌ `inventory_history` — **pas de RLS**

### Impact
**Scénario de fuite de données** :
1. Magasin A crée un inventaire physique
2. Magasin B (store_id différent) peut lire/modifier cet inventaire ❌
3. **Isolation par magasin brisée**

Actuellement BLOQUANT pour production multi-tenant.

### Solution requise
Créer migration `add_rls_inventory_tables.sql` :
```sql
-- Activer RLS
ALTER TABLE inventory_counts ENABLE ROW LEVEL SECURITY;
ALTER TABLE inventory_count_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE stock_adjustments ENABLE ROW LEVEL SECURITY;
ALTER TABLE stock_adjustment_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE inventory_history ENABLE ROW LEVEL SECURITY;

-- Policies SELECT
CREATE POLICY "store_isolation_select" ON inventory_counts
  FOR SELECT USING (store_id = (auth.jwt() ->> 'store_id')::uuid);

CREATE POLICY "store_isolation_select" ON inventory_count_items
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM inventory_counts WHERE id = count_id AND store_id = (auth.jwt() ->> 'store_id')::uuid)
  );

-- Idem pour INSERT, UPDATE, DELETE sur chaque table
```

### Fichiers concernés
- Nouvelle migration Supabase à créer
- Appliquer via Management API (port 5432 bloqué)

---

## ⚠️ GAP #4 : Sync Automatique après Refund/Credit Non Implémenté (MOYEN)

### Problème
Les repositories suivants ont des `TODO: Sync vers Supabase` :
- `SaleRepository.createSale()` — ligne 102
- `RefundRepository.createRefund()` — ligne 74

Or, `ItemBloc` et `CustomerBloc` font déjà un `forceSyncNow()` immédiat.
**Incohérence** : produits/clients synced immédiatement, ventes/remboursements non.

### Impact
**Scénario de confusion utilisateur** :
1. Caissier fait une vente → POS dit "Succès"
2. Wifi coupé pendant 2h
3. Gérant consulte dashboard web → **vente absente** (pas encore sync)
4. Gérant pense bug, contacte support

### Solution requise
Injecter `SyncService` dans :
- `SaleRepository` → appeler `forceSyncNow()` après `createSale()`
- `RefundRepository` → appeler `forceSyncNow()` après `createRefund()`
- `CreditRepository` → appeler `forceSyncNow()` après `createCredit()` et `recordCreditPayment()`

Pattern déjà utilisé dans `ItemBloc` et `CustomerBloc`.

### Fichiers concernés
- `lib/features/pos/data/repositories/sale_repository.dart`
- `lib/features/pos/data/repositories/refund_repository.dart`
- `lib/features/customers/data/repositories/credit_repository.dart`
- `lib/main.dart` — ajouter SyncService dans DI

---

## ⚠️ GAP #5 : Aucune Méthode `upsert*()` dans DAOs Critiques (BLOQUANT PULL)

### Problème
Le pull sync utilise `dao.upsert*()` mais beaucoup de DAOs n'ont PAS cette méthode :
- ✅ `CategoryDao.upsertCategory()` — existe
- ✅ `ItemDao.upsertItem()` — existe
- ✅ `CustomerDao.upsertCustomer()` — existe
- ❌ `SaleDao.upsertSale()` — **manquante**
- ❌ `RefundDao.upsertRefund()` — **manquante**
- ❌ `CreditDao.upsertCredit()` — **manquante**
- ❌ `ItemVariantDao.upsertVariant()` — **manquante**
- ❌ `ModifierDao.upsertModifier()` — **manquante**
- ❌ `TaxDao.upsertTax()` — **manquante**
- etc.

### Impact
Impossible d'implémenter GAP #1 (pull sync) sans ces méthodes.

### Solution requise
Ajouter méthode `upsert*()` dans chaque DAO :
```dart
// Pattern standard
Future<void> upsertSale(SalesCompanion sale) async {
  await into(sales).insertOnConflictUpdate(sale);
}
```

### Fichiers concernés
- Tous les `lib/core/data/local/daos/*.dart`

---

## ⚠️ GAP #6 : Push Sync Incomplet pour Tables Phase 3 (MOYEN)

### Problème
`SyncService.syncToRemote()` ne synchronise que :
- ✅ Stores
- ✅ Users
- ✅ StoreSettings
- ✅ Categories
- ✅ Items
- ✅ Customers

**Manquants** :
- ❌ Sales
- ❌ Refunds
- ❌ Credits
- ❌ ItemVariants
- ❌ Modifiers
- ❌ etc.

### Impact
Ventes/remboursements/crédits restent **uniquement locaux** même avec wifi.

### Solution requise
Ajouter méthodes `_syncXxx()` dans `syncToRemote()` pour TOUTES les tables.

---

## ⚠️ GAP #7 : Realtime Subscriptions Non Implémentées (FUTUR)

### Problème
Ligne 494 du `SyncService` :
```dart
Future<void> subscribeToChanges(String storeId) async {
  throw UnimplementedError('Realtime subscriptions not yet implemented');
}
```

### Impact
Actuellement : **polling** toutes les 30 secondes.
Sans Realtime : latence jusqu'à 30s pour voir les changements d'un autre appareil.

### Solution future
Utiliser Supabase Realtime :
```dart
supabase
  .from('sales')
  .stream(primaryKey: ['id'])
  .eq('store_id', storeId)
  .listen((data) {
    // Upsert dans Drift
  });
```

**Priorité : BASSE** (polling suffit pour MVP).

---

## 📊 Résumé des Gaps (Mise à jour : 27 mars 2026, 11:30 AM)

| Gap | Sévérité | Impact | Effort Original | Statut |
|-----|----------|--------|-----------------|--------|
| #1 Pull Sync Incomplet | 🔴 CRITIQUE | Multi-device impossible | 2 jours | ✅ **RÉSOLU** (27/03 10:00 AM) |
| #2 Gestion Conflits | 🔴 CRITIQUE | Perte données silencieuse | 1 jour | ⏳ **10%** (migration créée, logique manquante) |
| #3 RLS Manquantes | 🔴 BLOQUANT PROD | Fuite données multi-tenant | 2h | ✅ **RÉSOLU** (déjà présentes) |
| #4 Sync Sale/Refund | 🟡 MOYEN | Confusion UX | 1h | ✅ **RÉSOLU** (27/03 09:00 AM) |
| #5 Méthodes upsert | 🔴 BLOQUANT PULL | Impossible pull sync | 4h | ✅ **RÉSOLU** (27/03 08:00 AM) |
| #6 Push Sync Incomplet | 🟡 MOYEN | Données locales uniquement | 1 jour | ✅ **RÉSOLU** (27/03 11:30 AM) |
| #7 Realtime | 🟢 FUTUR | Latence 30s | 3 jours | ⏸️ **0%** (MVP peut skip) |

**Progrès global** : 5/7 gaps résolus (71%) — **4/5 gaps critiques résolus (80%)** 🎉

**Effort accompli** : ~12h (Phases 1-5)
**Effort restant** : ~2 jours
- Gap #2 (Gestion Conflits) : 1 jour (optionnel pour MVP)
- Tests multi-device : 1 jour

---

## 🎯 Plan d'Action Recommandé

### Phase 1 : Déblocage immédiat (2h)
1. ✅ Ajouter RLS policies sur tables inventaire (GAP #3)
2. ✅ Ajouter `forceSyncNow()` dans Sale/Refund/Credit repos (GAP #4)

### Phase 2 : Méthodes upsert (4h)
3. ✅ Implémenter `upsertSale()`, `upsertRefund()`, `upsertCredit()` dans DAOs
4. ✅ Implémenter `upsertVariant()`, `upsertModifier()`, `upsertTax()` dans DAOs
5. ✅ Implémenter `upsertShift()`, `upsertOpenTicket()`, etc.

### Phase 3 : Pull Sync Complet (2 jours)
6. ✅ Implémenter `_pullSales()` + `_pullSaleItems()` + `_pullSalePayments()`
7. ✅ Implémenter `_pullRefunds()` + `_pullRefundItems()`
8. ✅ Implémenter `_pullCredits()` + `_pullCreditPayments()`
9. ✅ Implémenter pull pour toutes les autres tables
10. ✅ Tester scénario multi-device complet

### Phase 4 : Gestion Conflits (1 jour)
11. ✅ Créer table `sync_conflicts` (migration + DAO)
12. ✅ Implémenter détection conflit via `updated_at`
13. ✅ Implémenter merge intelligent champ par champ
14. ✅ UI alerte gérant si conflit critique

### Phase 5 : Push Sync Complet (1 jour)
15. ✅ Ajouter `_syncSales()`, `_syncRefunds()`, etc. dans `syncToRemote()`
16. ✅ Tester sync bidirectionnelle complète

---

## 📝 Leçons pour Éviter Cela à l'Avenir

### Règle #1 : "Sync = Bidirectionnel par Défaut"
Quand on crée une nouvelle table :
1. ✅ Migration Supabase + RLS policy
2. ✅ Migration Drift avec `synced` et `updated_at`
3. ✅ DAO avec méthodes `insert`, `update`, `upsert`, `getUnsynced`
4. ✅ Ajout dans `SyncService.syncToRemote()` (push)
5. ✅ Ajout dans `SyncService.syncFromRemote()` (pull)

**Ne JAMAIS considérer une table "terminée" sans les 5 étapes.**

### Règle #2 : Checklist Obligatoire
Ajouter dans `tasks/todo.md` pour chaque nouvelle table :
```markdown
- [ ] Migration Supabase appliquée
- [ ] RLS policy créée
- [ ] Migration Drift appliquée
- [ ] DAO avec upsert() implémenté
- [ ] Push sync ajouté dans SyncService
- [ ] Pull sync ajouté dans SyncService
- [ ] Test multi-device (2 appareils)
```

### Règle #3 : Documenter Architecture Sync
Créer `docs/sync-architecture.md` expliquant :
- Quelles tables sont synchronisées
- Ordre de synchronisation (foreign keys)
- Stratégie de résolution de conflits
- Fréquence de sync (30s polling actuellement)

---

## ✅ Prochaine Étape

**Décision utilisateur requise** :

1. **Option A — Fix complet maintenant** (4 jours)
   - Implémenter Gaps #1 à #6 avant toute nouvelle feature
   - Garantit stabilité multi-device

2. **Option B — Fix progressif** (1 gap/jour en parallèle des features)
   - Jour 1 : GAP #3 (RLS) + GAP #4 (forceSyncNow)
   - Jour 2 : GAP #5 (méthodes upsert)
   - Jours 3-4 : GAP #1 (pull sync complet)
   - Jour 5 : GAP #2 (gestion conflits)

3. **Option C — MVP mono-device** (skip multi-device temporairement)
   - Documenter limitation "1 appareil par magasin pour l'instant"
   - Fixer plus tard quand besoin réel multi-device

**Quelle option préfères-tu ?**

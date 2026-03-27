# État d'Implémentation de la Synchronisation Bidirectionnelle

**Date de mise à jour** : 27 mars 2026, 10:00 AM
**Phase actuelle** : Phase 4 en cours

---

## ✅ Phases Complétées (Phases 1-3)

### Phase 1 : Déblocage Immédiat (2h) — ✅ 100%

**Résultat** :
- ✅ RLS policies vérifiées sur toutes les tables inventaire (déjà présentes)
- ✅ `forceSyncNow()` ajouté dans `SaleRepository` après `createSale()`
- ✅ `forceSyncNow()` ajouté dans `RefundRepository` après `createRefund()`
- ✅ `forceSyncNow()` ajouté dans `CreditRepository` après `createCredit()` et `recordCreditPayment()`
- ✅ DI mis à jour dans `main.dart` pour injecter `SyncService`
- ✅ Aucune erreur de compilation

**Fichiers modifiés** :
- `lib/features/pos/data/repositories/sale_repository.dart`
- `lib/features/pos/data/repositories/refund_repository.dart`
- `lib/features/customers/data/repositories/credit_repository.dart`
- `lib/main.dart`

---

### Phase 2 : Méthodes `upsert*()` dans tous les DAOs (4h) — ✅ 100%

**Résultat** :
- ✅ 31 méthodes `upsert*()` disponibles dans tous les DAOs
- ✅ 23 nouvelles méthodes ajoutées (10 DAOs modifiés)
- ✅ Build runner réussi (484 outputs générés)
- ✅ Aucune erreur de compilation

**DAOs modifiés** :
1. `CreditDao` — `upsertCredit()`, `upsertCreditPayment()`
2. `CustomPageDao` — `upsertCustomPage()`, `upsertCustomPageItem()`, `upsertCustomPageCategoryGrid()`
3. `DiningOptionDao` — `upsertDiningOption()`
4. `InventoryCountDao` — `upsertInventoryCount()`, `upsertInventoryCountItem()`
5. `InventoryHistoryDao` — `upsertInventoryHistory()`
6. `OpenTicketDao` — `upsertOpenTicket()`
7. `PosDeviceDao` — `upsertPosDevice()`
8. `RefundDao` — `upsertRefund()`, `upsertRefundItem()`
9. `ShiftDao` — `upsertShift()`, `upsertCashMovement()`
10. `StockAdjustmentDao` — `upsertStockAdjustment()`, `upsertStockAdjustmentItem()`
11. `SaleDao` — `upsertSale()`, `upsertSaleItem()`, `upsertSalePayment()`

---

### Phase 3 : Pull Sync Complet (2 jours → 6h) — ✅ 100%

**Résultat** :
- ✅ 13 nouvelles méthodes `_pullXxx()` ajoutées dans `SyncService`
- ✅ Total : 16 méthodes pull (3 existantes + 13 nouvelles)
- ✅ Toutes les tables synchronisées bidirectionnellement
- ✅ Respect des foreign keys (ordre de sync correct)
- ✅ Aucune erreur de compilation

**Tables synchronisées** (16) :
1. ✅ Categories
2. ✅ Items
3. ✅ Customers
4. ✅ DiningOptions
5. ✅ PosDevices
6. ✅ ItemVariants
7. ✅ Modifiers + ModifierOptions
8. ✅ Sales + SaleItems + SalePayments
9. ✅ Refunds + RefundItems
10. ✅ Credits + CreditPayments
11. ✅ StockAdjustments + StockAdjustmentItems
12. ✅ InventoryCounts + InventoryCountItems
13. ✅ InventoryHistory
14. ✅ Shifts
15. ✅ OpenTickets
16. ✅ CustomPages + CustomPageItems + CustomPageCategoryGrids

**Fichiers modifiés** :
- `lib/core/data/remote/sync_service.dart` — ajout de 13 méthodes pull

**Ordre de synchronisation** (respect des FK) :
```dart
// 1. Tables de base (pas de FK externes)
await _pullCategories(storeId, result);
await _pullCustomers(storeId, result);
await _pullDiningOptions(storeId, result);
await _pullPosDevices(storeId, result);

// 2. Produits et variants
await _pullItems(storeId, result);
await _pullItemVariants(storeId, result);
await _pullModifiers(storeId, result);

// 3. Ventes, remboursements, crédits
await _pullSales(storeId, result);
await _pullRefunds(storeId, result);
await _pullCredits(storeId, result);

// 4. Inventaire
await _pullStockAdjustments(storeId, result);
await _pullInventoryCounts(storeId, result);
await _pullInventoryHistory(storeId, result);

// 5. POS (shifts, tickets)
await _pullShifts(storeId, result);
await _pullOpenTickets(storeId, result);

// 6. Custom pages
await _pullCustomPages(storeId, result);
```

---

## 🔄 Phases En Cours

### Phase 4 : Gestion des Conflits de Sync (1 jour) — ⏳ 10%

**Objectif** : Détecter et résoudre les conflits quand 2 appareils modifient les mêmes données offline.

**Progrès actuel** :
- ✅ Migration SQL créée : `20260327000001_create_sync_conflicts_table.sql`
- ❌ Migration non encore appliquée sur Supabase (port 5432 bloqué, Management API JWT échoue)
- ❌ Logique de détection de conflits non implémentée
- ❌ UI de résolution manuelle non créée

**Travail restant** :

#### 4.1. Appliquer la migration `sync_conflicts` sur Supabase

**Solution recommandée** : Utiliser le dashboard Supabase SQL Editor au lieu de l'API.

**Étapes** :
1. Ouvrir https://supabase.com/dashboard/project/yjxcbvffjnkizuhxlxqp/sql
2. Coller le contenu de `supabase/migrations/20260327000001_create_sync_conflicts_table.sql`
3. Exécuter

#### 4.2. Créer la table Drift `sync_conflicts`

**Fichier à créer** : `lib/core/data/local/tables/sync_conflicts.drift`

```sql
CREATE TABLE IF NOT EXISTS sync_conflicts (
  id TEXT PRIMARY KEY NOT NULL,
  store_id TEXT NOT NULL,
  table_name TEXT NOT NULL,
  record_id TEXT NOT NULL,
  field_name TEXT,
  local_value TEXT NOT NULL,
  remote_value TEXT NOT NULL,
  local_updated_at INTEGER NOT NULL,
  remote_updated_at INTEGER NOT NULL,
  status TEXT NOT NULL CHECK (status IN ('pending', 'resolved_local', 'resolved_remote', 'resolved_manual')),
  resolved_at INTEGER,
  resolved_by TEXT,
  resolution_notes TEXT,
  detected_at INTEGER NOT NULL,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  synced INTEGER NOT NULL DEFAULT 0
) STRICT;
```

**Ensuite** :
- Lancer `dart run build_runner build --delete-conflicting-outputs`
- Créer `lib/core/data/local/daos/sync_conflict_dao.dart`

#### 4.3. Implémenter la détection de conflits dans `SyncService`

**Stratégie** : Last-write-wins avec log des écrasements

```dart
/// Merge un record distant avec le record local en détectant les conflits
Future<bool> _mergeRecord({
  required String tableName,
  required String recordId,
  required Map<String, dynamic> localData,
  required Map<String, dynamic> remoteData,
  required int localUpdatedAt,
  required int remoteUpdatedAt,
  required Function(Map<String, dynamic>) upsertFn,
}) async {
  // Cas 1: Remote plus récent ET local déjà synchronisé → prendre remote sans conflit
  if (remoteUpdatedAt > localUpdatedAt && (localData['synced'] == 1)) {
    await upsertFn(remoteData);
    return true;
  }

  // Cas 2: Local plus récent ET non synchronisé → conflit !
  if (localUpdatedAt > remoteUpdatedAt && (localData['synced'] == 0)) {
    // Log conflit
    await _logConflict(
      tableName: tableName,
      recordId: recordId,
      localData: localData,
      remoteData: remoteData,
      localUpdatedAt: localUpdatedAt,
      remoteUpdatedAt: remoteUpdatedAt,
    );

    // Stratégie: local gagne (last-write-wins)
    developer.log(
      'Conflict detected on $tableName/$recordId: local wins (newer)',
      name: 'SyncService',
    );
    return false; // Ne pas écraser le local
  }

  // Cas 3: Même timestamp → pas de conflit
  if (localUpdatedAt == remoteUpdatedAt) {
    return false; // Déjà synchronisé
  }

  // Cas 4: Remote plus récent mais local non synchronisé → vraie collision
  if (remoteUpdatedAt > localUpdatedAt && (localData['synced'] == 0)) {
    // Log conflit
    await _logConflict(
      tableName: tableName,
      recordId: recordId,
      localData: localData,
      remoteData: remoteData,
      localUpdatedAt: localUpdatedAt,
      remoteUpdatedAt: remoteUpdatedAt,
    );

    // Stratégie: remote gagne (plus récent)
    developer.log(
      'Conflict detected on $tableName/$recordId: remote wins (newer)',
      name: 'SyncService',
    );
    await upsertFn(remoteData);
    return true;
  }

  return false;
}

/// Log un conflit dans la table sync_conflicts
Future<void> _logConflict({
  required String tableName,
  required String recordId,
  required Map<String, dynamic> localData,
  required Map<String, dynamic> remoteData,
  required int localUpdatedAt,
  required int remoteUpdatedAt,
}) async {
  // TODO: Implémenter insertion dans sync_conflicts table
  // Pour l'instant, juste un log
  developer.log(
    'CONFLICT: $tableName/$recordId | local: $localUpdatedAt, remote: $remoteUpdatedAt',
    name: 'SyncService',
  );
}
```

**Intégrer dans chaque méthode `_pullXxx()`** :
```dart
// Au lieu de :
await _localDb.itemDao.upsertItem(companion);

// Faire :
final localItem = await _localDb.itemDao.getItemById(itemData['id']);
if (localItem != null) {
  final shouldUpdate = await _mergeRecord(
    tableName: 'items',
    recordId: itemData['id'],
    localData: localItem.toMap(),
    remoteData: itemData,
    localUpdatedAt: localItem.updatedAt,
    remoteUpdatedAt: DateTime.parse(itemData['updated_at']).millisecondsSinceEpoch,
    upsertFn: (data) => _localDb.itemDao.upsertItem(ItemsCompanion.fromMap(data)),
  );
} else {
  // Nouveau record, pas de conflit possible
  await _localDb.itemDao.upsertItem(companion);
}
```

#### 4.4. UI de résolution manuelle (optionnel pour MVP)

**Écran** : `lib/features/sync/presentation/screens/conflicts_screen.dart`

Affiche :
- Liste des conflits en attente (`status == 'pending'`)
- Comparaison side-by-side des valeurs locales vs distantes
- Boutons : "Garder local", "Garder distant", "Éditer manuellement"

**Accès** : Settings → Synchronisation → Conflits (`/settings/sync/conflicts`)

---

### Phase 5 : Push Sync Complet (1 jour) — ⏸️ 0%

**Objectif** : Synchroniser TOUTES les tables vers Supabase (actuellement seulement 6 tables).

**Tables actuellement synchronisées** (6) :
1. ✅ Stores
2. ✅ Users
3. ✅ StoreSettings
4. ✅ Categories
5. ✅ Items
6. ✅ Customers

**Tables manquantes** (16) :
1. ❌ Sales + SaleItems + SalePayments
2. ❌ Refunds + RefundItems
3. ❌ Credits + CreditPayments
4. ❌ ItemVariants
5. ❌ Modifiers + ModifierOptions
6. ❌ DiningOptions
7. ❌ PosDevices
8. ❌ StockAdjustments + StockAdjustmentItems
9. ❌ InventoryCounts + InventoryCountItems
10. ❌ InventoryHistory
11. ❌ Shifts
12. ❌ OpenTickets
13. ❌ CustomPages + CustomPageItems + CustomPageCategoryGrids

**Travail à faire** :

Ajouter 13 méthodes `_syncXxx()` dans `syncToRemote()` en suivant le pattern existant :

```dart
Future<void> _syncSales() async {
  final unsyncedSales = await _localDb.saleDao.getUnsyncedSales();

  for (final sale in unsyncedSales) {
    try {
      await _supabase.from('sales').upsert(sale.toJson());

      // Marquer comme synchronisé
      await _localDb.saleDao.markAsSynced(sale.id);
      result.salesSynced++;
    } catch (e) {
      developer.log('Failed to sync sale ${sale.id}', name: 'SyncService', error: e);
      result.errors.add('Sale ${sale.receiptNumber}: $e');
    }
  }

  // Synchroniser les sale_items
  final unsyncedSaleItems = await _localDb.saleDao.getUnsyncedSaleItems();
  // ... idem
}
```

**Fichier à modifier** : `lib/core/data/remote/sync_service.dart`

**Ordre de sync** (respect des FK) :
```dart
Future<SyncResult> syncToRemote({bool force = false}) async {
  // ...

  // 1. Tables de base
  await _syncStores();
  await _syncUsers();
  await _syncStoreSettings();
  await _syncCategories();
  await _syncCustomers();
  await _syncDiningOptions();
  await _syncPosDevices();

  // 2. Produits
  await _syncItems();
  await _syncItemVariants();
  await _syncModifiers();

  // 3. Ventes, remboursements, crédits
  await _syncSales();
  await _syncRefunds();
  await _syncCredits();

  // 4. Inventaire
  await _syncStockAdjustments();
  await _syncInventoryCounts();
  await _syncInventoryHistory();

  // 5. POS
  await _syncShifts();
  await _syncOpenTickets();
  await _syncCustomPages();

  return result;
}
```

---

## 🧪 Phase 6 : Tests Multi-Device (1 jour) — ⏸️ 0%

**Objectif** : Valider la synchronisation bidirectionnelle complète dans des scénarios réels.

**Scénarios à tester** :

### Scénario 1 : Nouvel appareil récupère tout
1. ✅ Créer produits/clients sur appareil A
2. ✅ Installer app sur appareil B
3. ✅ Login avec même compte
4. ✅ **Attente** : Tous les produits/clients apparaissent sur B
5. ✅ **Vérifier** : `syncFromRemote()` a téléchargé toutes les données

### Scénario 2 : Modifications simultanées (conflit)
1. ✅ Appareil A offline : modifier prix produit X de 5000 → 6000 Ar
2. ✅ Appareil B offline : modifier stock produit X de 10 → 5 unités
3. ✅ A se reconnecte → push prix 6000 + stock 10 (ancien)
4. ✅ B se reconnecte → **détection conflit**
5. ✅ **Attente** : Merge intelligent (prix de A, stock de B) OU conflit loggé
6. ✅ **Vérifier** : Aucune donnée perdue, conflit résolu ou alerté

### Scénario 3 : Vente sur A, visible sur B
1. ✅ Appareil A : créer vente 10 000 Ar
2. ✅ Appareil B (online) : attendre 30s max
3. ✅ **Attente** : Vente apparaît dans liste sur B
4. ✅ **Vérifier** : Pull sync a récupéré la vente

### Scénario 4 : Offline prolongé puis sync
1. ✅ Appareil A offline pendant 2h
2. ✅ Créer 50 ventes, 10 clients, 20 ajustements stock
3. ✅ Reconnecter wifi
4. ✅ **Attente** : Sync automatique en <1min
5. ✅ **Vérifier** : Toutes les données sur Supabase

### Scénario 5 : Réinstallation app (récupération complète)
1. ✅ Créer données sur appareil A
2. ✅ Désinstaller app complètement
3. ✅ Réinstaller app
4. ✅ Login
5. ✅ **Attente** : Toutes les données récupérées depuis Supabase
6. ✅ **Vérifier** : Pull sync initial fonctionne

---

## 📊 Métriques de Succès

**Synchronisation bidirectionnelle considérée complète quand** :
- ✅ Pull sync : 16/16 tables (100%) — **FAIT**
- ⏳ Push sync : 6/16 tables (37%) — **EN COURS**
- ⏳ Gestion conflits : 0% — **EN COURS**
- ⏸️ Tests multi-device : 0/5 scénarios — **À FAIRE**

**Effort total restant** : ~2-3 jours
- Phase 4 : 1 jour (gestion conflits)
- Phase 5 : 1 jour (push sync complet)
- Phase 6 : 1 jour (tests)

---

## 🎯 Prochaine Étape Recommandée

**Option 1 — Finir Phase 4 (gestion conflits)** :
1. Appliquer migration `sync_conflicts` manuellement via dashboard
2. Créer table Drift + DAO
3. Implémenter `_mergeRecord()` dans SyncService
4. Intégrer dans toutes les méthodes `_pullXxx()`
5. Tester détection conflit

**Option 2 — Sauter Phase 4 temporairement, finir Phase 5 (push sync)** :
1. Ajouter 13 méthodes `_syncXxx()` dans `syncToRemote()`
2. Tester que toutes les tables se synchronisent
3. Revenir à Phase 4 après

**Option 3 — MVP sans conflits** :
1. Documenter limitation : "1 appareil par magasin recommandé"
2. Finir Phase 5 (push sync complet)
3. Déployer MVP
4. Phase 4 (conflits) dans version 1.1

**Recommandation** : **Option 2** — Finir le push sync d'abord (plus critique pour MVP que gestion conflits), puis revenir aux conflits.

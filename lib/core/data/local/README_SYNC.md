# Guide d'utilisation — DAOs Drift et SyncService

Ce document explique comment utiliser les DAOs Drift et le service de synchronisation pour gérer les données offline-first dans l'application POS Madagascar.

---

## Architecture Offline-First

```
┌─────────────────────────────────────────────────────────┐
│                     Flutter App (UI)                     │
└──────────────────────┬──────────────────────────────────┘
                       │
                       ↓
┌─────────────────────────────────────────────────────────┐
│                  BLoC / Cubit Layer                      │
└──────────────────────┬──────────────────────────────────┘
                       │
                       ↓
┌─────────────────────────────────────────────────────────┐
│                  Repository Layer                        │
└───────┬──────────────────────────────────────┬──────────┘
        │                                      │
        ↓                                      ↓
┌───────────────┐                    ┌────────────────────┐
│  Drift DAOs   │ ←── SyncService ──→│  Supabase Client   │
│   (SQLite)    │                    │     (PostgreSQL)   │
└───────────────┘                    └────────────────────┘
   LOCAL DB                              REMOTE DB
   (SOURCE OF TRUTH)                   (BACKUP & SYNC)
```

### Règles fondamentales

1. **Drift est la source de vérité** — toutes les lectures/écritures passent d'abord par Drift
2. **Écriture locale d'abord** — les modifications sont d'abord enregistrées en local avec `synced: false`
3. **Synchronisation asynchrone** — le SyncService pousse les changements vers Supabase en arrière-plan
4. **Résilience offline** — l'app fonctionne même sans connexion internet

---

## 1. Utilisation des DAOs

### 1.1 Accéder aux DAOs

Les DAOs sont accessibles via l'instance `AppDatabase` :

```dart
final db = AppDatabase();

// Accès aux DAOs
final storeDao = db.storeDao;
final userDao = db.userDao;
final categoryDao = db.categoryDao;
final itemDao = db.itemDao;
final settingsDao = db.storeSettingsDao;
```

### 1.2 Opérations CRUD avec StoreDao

#### Créer un magasin

```dart
final storeId = const Uuid().v4();
await db.storeDao.insertStore(
  StoresCompanion(
    id: Value(storeId),
    name: const Value('Mon Épicerie'),
    address: const Value('123 Rue de la Paix'),
    phone: const Value('+261 34 00 000 00'),
    currency: const Value('MGA'),
    timezone: const Value('Indian/Antananarivo'),
    synced: const Value(false),
    updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
  ),
);
```

#### Lire un magasin

```dart
// Par ID
final store = await db.storeDao.getStoreById(storeId);

// Tous les magasins
final stores = await db.storeDao.getAllStores();

// Stream pour réagir aux changements
db.storeDao.watchStoreById(storeId).listen((store) {
  print('Store updated: ${store?.name}');
});
```

#### Mettre à jour un magasin

```dart
await db.storeDao.updateStore(
  StoresCompanion(
    id: Value(storeId),
    name: const Value('Mon Épicerie — Nouvelle Enseigne'),
    // synced et updatedAt sont automatiquement mis à jour
  ),
);
```

#### Supprimer un magasin (soft delete)

```dart
await db.storeDao.deleteStore(storeId);
// Le magasin est marqué comme supprimé mais reste en base
```

### 1.3 Opérations CRUD avec UserDao

#### Créer un utilisateur

```dart
final userId = const Uuid().v4();
await db.userDao.insertUser(
  UsersCompanion(
    id: Value(userId),
    storeId: Value(storeId),
    name: const Value('Jean Rakoto'),
    email: const Value('jean@example.mg'),
    role: const Value('CASHIER'),
    pinHash: Value(hashPin('1234')), // Utiliser bcrypt
    active: const Value(true),
    synced: const Value(false),
    updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
  ),
);
```

#### Récupérer les utilisateurs actifs

```dart
final activeUsers = await db.userDao.getActiveUsers();
```

#### Activer/désactiver un utilisateur

```dart
await db.userDao.setUserActive(userId, false);
```

### 1.4 Opérations CRUD avec CategoryDao

#### Créer une catégorie

```dart
final categoryId = const Uuid().v4();
final sortOrder = await db.categoryDao.getNextSortOrder(storeId);

await db.categoryDao.insertCategory(
  CategoriesCompanion(
    id: Value(categoryId),
    storeId: Value(storeId),
    name: const Value('Boissons'),
    color: const Value('#FF5722'),
    sortOrder: Value(sortOrder),
    synced: const Value(false),
    updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
  ),
);
```

#### Réorganiser les catégories

```dart
await db.categoryDao.reorderCategories(
  storeId,
  ['cat-id-1', 'cat-id-2', 'cat-id-3'], // Nouvel ordre
);
```

### 1.5 Opérations CRUD avec ItemDao

#### Créer un produit

```dart
final itemId = const Uuid().v4();
await db.itemDao.insertItem(
  ItemsCompanion(
    id: Value(itemId),
    storeId: Value(storeId),
    categoryId: Value(categoryId),
    name: const Value('Coca-Cola 1L'),
    barcode: const Value('5449000000996'),
    price: const Value(2500), // 2 500 Ar
    cost: const Value(1800),   // Coût d'achat
    trackStock: const Value(true),
    inStock: const Value(50),
    lowStockThreshold: const Value(10),
    synced: const Value(false),
    updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
  ),
);
```

#### Rechercher des produits

```dart
// Recherche par nom ou SKU
final results = await db.itemDao.searchItems(storeId, 'coca');

// Par code-barres
final item = await db.itemDao.getItemByBarcode('5449000000996');
```

#### Mettre à jour le stock après une vente

```dart
try {
  await db.itemDao.updateStock(
    itemId: itemId,
    quantityChange: -5, // Vente de 5 unités
  );
} catch (e) {
  print('Stock insuffisant');
}
```

#### Récupérer les produits en stock faible

```dart
final lowStockItems = await db.itemDao.getLowStockItems(storeId);
```

### 1.6 Opérations avec StoreSettingsDao

#### Créer les réglages par défaut

```dart
await db.storeSettingsDao.createDefaultSettings(storeId);
```

#### Activer/désactiver une fonctionnalité

```dart
await db.storeSettingsDao.toggleFeature(
  storeId: storeId,
  shiftsEnabled: true,
  openTicketsEnabled: true,
);
```

---

## 2. Synchronisation avec SyncService

### 2.1 Initialisation

```dart
import 'package:pos_madagascar/core/data/local/app_database.dart';
import 'package:pos_madagascar/core/data/remote/supabase_client.dart';
import 'package:pos_madagascar/core/data/remote/sync_service.dart';

// Initialiser Supabase
await SupabaseService.initialize();

// Créer le service de synchronisation
final db = AppDatabase();
final syncService = SyncService(db, SupabaseService.client);
```

### 2.2 Synchroniser les changements locaux vers Supabase

```dart
// Synchronisation manuelle
final result = await syncService.syncToRemote();

if (result.isSuccess) {
  print('✅ ${result.totalSynced} enregistrements synchronisés');
} else if (result.skipped) {
  print('⏸️ Synchronisation ignorée (pas de connexion)');
} else {
  print('❌ Erreurs : ${result.errors.join(', ')}');
}

// Détail par table
print('Magasins : ${result.storesSynced}');
print('Utilisateurs : ${result.usersSynced}');
print('Réglages : ${result.settingsSynced}');
print('Catégories : ${result.categoriesSynced}');
print('Articles : ${result.itemsSynced}');
```

### 2.3 Synchronisation automatique en arrière-plan

Dans un vrai projet, utilisez un timer périodique :

```dart
// Dans votre service global ou dans main()
Timer.periodic(const Duration(minutes: 5), (timer) async {
  if (SupabaseService.isInitialized) {
    await syncService.syncToRemote();
  }
});
```

Ou déclenchez la synchronisation après chaque modification :

```dart
// Après une modification
await db.itemDao.updateItem(/* ... */);

// Synchroniser en arrière-plan sans bloquer l'UI
syncService.syncToRemote().catchError((e) {
  // Log l'erreur mais ne bloque pas l'utilisateur
  debugPrint('Sync failed: $e');
});
```

### 2.4 Vérifier les enregistrements non synchronisés

```dart
final unsyncedStores = await db.storeDao.getUnsyncedStores();
final unsyncedUsers = await db.userDao.getUnsyncedUsers();
final unsyncedCategories = await db.categoryDao.getUnsyncedCategories();
final unsyncedItems = await db.itemDao.getUnsyncedItems();

print('${unsyncedItems.length} articles en attente de synchronisation');
```

---

## 3. Flux de travail typique

### 3.1 Création d'un nouveau magasin (onboarding)

```dart
// 1. Créer le magasin en local
final storeId = const Uuid().v4();
await db.storeDao.insertStore(/* ... */);

// 2. Créer les réglages par défaut
await db.storeSettingsDao.createDefaultSettings(storeId);

// 3. Créer l'utilisateur OWNER
final userId = const Uuid().v4();
await db.userDao.insertUser(/* ... role: 'OWNER' ... */);

// 4. Synchroniser immédiatement si connecté
await syncService.syncToRemote();
```

### 3.2 Ajout d'un produit en caisse (offline)

```dart
// L'utilisateur scanne un code-barres ou saisit le produit
final itemId = const Uuid().v4();

// 1. Enregistrer en local d'abord (synced: false)
await db.itemDao.insertItem(
  ItemsCompanion(
    id: Value(itemId),
    storeId: Value(currentStoreId),
    name: const Value('Riz 5kg'),
    price: const Value(15000),
    synced: const Value(false), // Marqué comme non synchronisé
    updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
  ),
);

// 2. Le produit est immédiatement disponible en caisse
final items = await db.itemDao.getAvailableItems(currentStoreId);
// Le nouveau produit est dans la liste !

// 3. Synchronisation en arrière-plan (non bloquante)
unawaited(syncService.syncToRemote()); // Ne pas attendre
```

### 3.3 Modification de prix (online ou offline)

```dart
// 1. Modifier en local
await db.itemDao.updateItem(
  ItemsCompanion(
    id: Value(itemId),
    price: const Value(18000), // Nouveau prix
    // synced: false et updatedAt sont automatiquement mis à jour
  ),
);

// 2. Le nouveau prix est IMMÉDIATEMENT utilisé en caisse
// Pas besoin d'attendre la synchro !

// 3. Synchro en arrière-plan
await syncService.syncToRemote();
```

---

## 4. Gestion des erreurs

### 4.1 Erreur de synchronisation

Le `SyncService` ne lance jamais d'exception — il log les erreurs et continue :

```dart
final result = await syncService.syncToRemote();

if (result.hasErrors) {
  for (final error in result.errors) {
    // Afficher un snackbar à l'utilisateur
    showSnackBar('Erreur de synchronisation : $error');
  }
}
```

### 4.2 Stock négatif

```dart
try {
  await db.itemDao.updateStock(
    itemId: itemId,
    quantityChange: -100, // Tentative de vendre 100 unités
  );
} catch (e) {
  showDialog(
    title: 'Stock insuffisant',
    message: 'Impossible de vendre cette quantité',
  );
}
```

### 4.3 SKU en double

```dart
final skuExists = await db.itemDao.skuExists(
  storeId,
  'COCA-001',
  excludeItemId: itemId, // null si nouveau produit
);

if (skuExists) {
  showError('Ce SKU existe déjà');
  return;
}
```

---

## 5. Bonnes pratiques

### ✅ À FAIRE

1. **Toujours écrire en local d'abord** — ne jamais écrire directement dans Supabase
2. **Utiliser les Streams** pour les UI réactives (watchXxx methods)
3. **Synchroniser en arrière-plan** sans bloquer l'utilisateur
4. **Gérer le offline gracefully** — afficher un indicateur de synchro en attente
5. **Marquer synced: false** explicitement lors des insertions

### ❌ À ÉVITER

1. **Ne jamais attendre la synchro** pour afficher les données (lecture depuis Drift)
2. **Ne jamais bloquer l'UI** avec `await syncService.syncToRemote()`
3. **Ne jamais modifier Supabase directement** — toujours passer par Drift
4. **Ne jamais ignorer les erreurs de stock** — respecter les contraintes métier

---

## 6. Prochaines étapes (TODO)

### Fonctionnalités à implémenter

- [ ] `syncFromRemote(storeId)` — téléchargement initial depuis Supabase
- [ ] `subscribeToChanges(storeId)` — subscriptions Realtime pour sync bidirectionnelle
- [ ] Résolution de conflits (last-write-wins vs merge custom)
- [ ] Batch sync avec limitation de taille (éviter timeouts sur gros volumes)
- [ ] Retry automatique en cas d'échec réseau
- [ ] Indicateur de synchronisation dans l'UI
- [ ] Background sync avec WorkManager (Android) / Background Tasks (iOS)

---

## 7. Références

- **Drift documentation** : https://drift.simonbinder.eu/
- **Supabase Dart SDK** : https://supabase.com/docs/reference/dart/introduction
- **docs/database.md** : Schéma complet de la base de données
- **docs/formulas.md** : Formules de calcul (coût moyen, taxes, etc.)

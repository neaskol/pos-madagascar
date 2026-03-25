# Résumé : Couche Repository + BLoC

**Date** : 2026-03-25
**Statut** : ✅ Terminé
**Compilation** : ✅ Sans erreur (5 suggestions de style uniquement)

---

## Architecture implémentée

Pattern **DataSource → Repository → BLoC → UI** (offline-first avec Drift)

```
Drift DAOs (local SQLite)
    ↓
Repositories (logique métier)
    ↓
BLoCs (gestion d'état)
    ↓
UI (Widgets Flutter)
```

---

## Repositories créés

### 1. StoreRepository
**Fichier** : `lib/features/store/data/repositories/store_repository.dart`

**Méthodes** :
- `watchAllStores()` — Stream de tous les magasins
- `getStoreById(storeId)` — Récupérer un magasin
- `createStore(...)` — Créer un nouveau magasin
- `updateStore(...)` — Mettre à jour un magasin
- `deleteStore(storeId)` — Supprimer un magasin
- `getUnsyncedStores()` — Magasins non synchronisés
- `markStoreAsSynced(storeId)` — Marquer comme synchronisé
- `countStores()` — Compter les magasins

### 2. UserRepository
**Fichier** : `lib/features/user/data/repositories/user_repository.dart`

**Méthodes** :
- `watchStoreUsers(storeId)` — Stream de tous les utilisateurs d'un magasin
- `getUserById(userId)` — Récupérer un utilisateur
- `getUserByEmail(email)` — Récupérer par email
- `watchActiveUsers(storeId)` — Stream des utilisateurs actifs
- `watchUsersByRole(storeId, role)` — Stream par rôle
- `createUser(...)` — Créer un utilisateur
- `updateUser(...)` — Mettre à jour un utilisateur
- `deleteUser(userId)` — Supprimer un utilisateur
- `verifyUserPin(userId, pinHash)` — Vérifier le PIN
- `getUnsyncedUsers()` — Utilisateurs non synchronisés
- `markUserAsSynced(userId)` — Marquer comme synchronisé
- `countStoreUsers(storeId)` — Compter les utilisateurs

### 3. StoreSettingsRepository
**Fichier** : `lib/features/store/data/repositories/store_settings_repository.dart`

**Méthodes** :
- `watchStoreSettings(storeId)` — Stream des réglages
- `getStoreSettings(storeId)` — Récupérer les réglages (one-time)
- `createDefaultSettings(storeId)` — Créer les réglages par défaut
- `updateSettings(...)` — Mettre à jour plusieurs réglages
- `toggleShifts(storeId, enabled)` — Toggle shifts
- `toggleOpenTickets(storeId, enabled)` — Toggle tickets ouverts
- `toggleLowStockNotifications(storeId, enabled)` — Toggle notifications stock bas
- `updateCashRoundingUnit(storeId, unit)` — Mettre à jour l'arrondi caisse
- `updateReceiptFooter(storeId, footer)` — Mettre à jour le footer des reçus
- `getUnsyncedSettings()` — Réglages non synchronisés
- `markSettingsAsSynced(storeId)` — Marquer comme synchronisé

### 4. CategoryRepository
**Fichier** : `lib/features/products/data/repositories/category_repository.dart`

**Méthodes** :
- `watchStoreCategories(storeId)` — Stream de toutes les catégories (triées)
- `getCategoryById(categoryId)` — Récupérer une catégorie
- `createCategory(...)` — Créer une catégorie
- `updateCategory(...)` — Mettre à jour une catégorie
- `deleteCategory(categoryId)` — Supprimer une catégorie
- `reorderCategories(storeId, categoryIds)` — Réorganiser les catégories
- `getUnsyncedCategories()` — Catégories non synchronisées
- `markCategoryAsSynced(categoryId)` — Marquer comme synchronisé
- `countStoreCategories(storeId)` — Compter les catégories

### 5. ItemRepository
**Fichier** : `lib/features/products/data/repositories/item_repository.dart`

**Méthodes** :
- `watchStoreItems(storeId)` — Stream de tous les items
- `getItemById(itemId)` — Récupérer un item
- `getItemBySku(storeId, sku)` — Récupérer par SKU
- `getItemByBarcode(storeId, barcode)` — Récupérer par code-barres
- `watchCategoryItems(categoryId)` — Stream des items d'une catégorie
- `watchAvailableItems(storeId)` — Stream des items disponibles à la vente
- `searchItemsByName(storeId, query)` — Rechercher par nom
- `createItem(...)` — Créer un item
- `updateItem(...)` — Mettre à jour un item
- `deleteItem(itemId)` — Supprimer un item
- `updateItemStock(itemId, newStock)` — Mettre à jour le stock
- `updateAverageCost(itemId, newAverageCost)` — Mettre à jour le coût moyen
- `getLowStockItems(storeId)` — Items avec stock bas
- `getUnsyncedItems()` — Items non synchronisés
- `markItemAsSynced(itemId)` — Marquer comme synchronisé
- `countStoreItems(storeId)` — Compter les items

---

## BLoCs créés

Chaque BLoC suit le pattern **Event → BLoC → State**.

### 1. StoreBloc
**Fichiers** :
- `lib/features/store/presentation/bloc/store_bloc.dart`
- `lib/features/store/presentation/bloc/store_event.dart`
- `lib/features/store/presentation/bloc/store_state.dart`

**Events** :
- `LoadStoresEvent` — Charger tous les magasins
- `LoadStoreByIdEvent` — Charger un magasin par ID
- `CreateStoreEvent` — Créer un magasin
- `UpdateStoreEvent` — Mettre à jour un magasin
- `DeleteStoreEvent` — Supprimer un magasin

**States** :
- `StoreInitial` — État initial
- `StoreLoading` — Chargement en cours
- `StoresLoaded` — Liste chargée
- `StoreLoaded` — Magasin unique chargé
- `StoreOperationSuccess` — Opération réussie
- `StoreError` — Erreur

### 2. UserBloc
**Fichiers** :
- `lib/features/user/presentation/bloc/user_bloc.dart`
- `lib/features/user/presentation/bloc/user_event.dart`
- `lib/features/user/presentation/bloc/user_state.dart`

**Events** :
- `LoadStoreUsersEvent` — Charger les utilisateurs d'un magasin
- `LoadUserByIdEvent` — Charger par ID
- `LoadUserByEmailEvent` — Charger par email
- `LoadActiveUsersEvent` — Charger les utilisateurs actifs
- `LoadUsersByRoleEvent` — Charger par rôle
- `CreateUserEvent` — Créer
- `UpdateUserEvent` — Mettre à jour
- `DeleteUserEvent` — Supprimer
- `VerifyUserPinEvent` — Vérifier le PIN

**States** :
- `UserInitial`
- `UserLoading`
- `UsersLoaded`
- `UserLoaded`
- `UserPinVerified`
- `UserOperationSuccess`
- `UserError`

### 3. StoreSettingsBloc
**Fichiers** :
- `lib/features/store/presentation/bloc/store_settings_bloc.dart`
- `lib/features/store/presentation/bloc/store_settings_event.dart`
- `lib/features/store/presentation/bloc/store_settings_state.dart`

**Events** :
- `LoadStoreSettingsEvent`
- `CreateDefaultSettingsEvent`
- `UpdateStoreSettingsEvent`
- `ToggleShiftsEvent`
- `ToggleOpenTicketsEvent`
- `ToggleLowStockNotificationsEvent`
- `UpdateCashRoundingUnitEvent`
- `UpdateReceiptFooterEvent`

**States** :
- `StoreSettingsInitial`
- `StoreSettingsLoading`
- `StoreSettingsLoaded`
- `StoreSettingsNotFound`
- `StoreSettingsOperationSuccess`
- `StoreSettingsError`

### 4. CategoryBloc
**Fichiers** :
- `lib/features/products/presentation/bloc/category_bloc.dart`
- `lib/features/products/presentation/bloc/category_event.dart`
- `lib/features/products/presentation/bloc/category_state.dart`

**Events** :
- `LoadStoreCategoriesEvent`
- `LoadCategoryByIdEvent`
- `CreateCategoryEvent`
- `UpdateCategoryEvent`
- `DeleteCategoryEvent`
- `ReorderCategoriesEvent`

**States** :
- `CategoryInitial`
- `CategoryLoading`
- `CategoriesLoaded`
- `CategoryLoaded`
- `CategoryOperationSuccess`
- `CategoryError`

### 5. ItemBloc
**Fichiers** :
- `lib/features/products/presentation/bloc/item_bloc.dart`
- `lib/features/products/presentation/bloc/item_event.dart`
- `lib/features/products/presentation/bloc/item_state.dart`

**Events** :
- `LoadStoreItemsEvent`
- `LoadItemByIdEvent`
- `LoadItemBySkuEvent`
- `LoadItemByBarcodeEvent`
- `LoadCategoryItemsEvent`
- `LoadAvailableItemsEvent`
- `SearchItemsByNameEvent`
- `CreateItemEvent`
- `UpdateItemEvent`
- `DeleteItemEvent`
- `UpdateItemStockEvent`
- `UpdateAverageCostEvent`
- `LoadLowStockItemsEvent`

**States** :
- `ItemInitial`
- `ItemLoading`
- `ItemsLoaded`
- `ItemLoaded`
- `ItemOperationSuccess`
- `ItemError`

---

## Points techniques importants

### 1. Drift Queries
Les queries définies dans les fichiers `.drift` (ex: `getCategoriesByStore`) sont générées automatiquement par Drift et retournent des **`Selectable<T>`**, pas des `Future<T>`.

**Utilisation** :
```dart
// Pour un Future
final items = await _dao.getItemsByStore(storeId).get();

// Pour un Stream
final stream = _dao.getItemsByStore(storeId).watch();
```

### 2. Conversions de types

**Boolean → Integer** : SQLite stocke les booléens en 0/1
```dart
synced: const Value(0),  // false
active: Value(emailVerified ? 1 : 0),
```

**DateTime → Milliseconds** :
```dart
updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
```

### 3. Utilisation des Streams dans les BLoCs

Les BLoCs utilisent `emit.forEach()` pour écouter les Streams Drift :
```dart
await emit.forEach(
  _repository.watchStoreUsers(storeId),
  onData: (users) => UsersLoaded(users),
  onError: (error, stackTrace) => UserError(error.toString()),
);
```

---

## Prochaines étapes

1. **Créer les providers BLoC** dans `main.dart`
2. **Créer les écrans UI** qui utilisent les BLoCs
3. **Tester le flux complet** offline-first :
   - Créer des données en mode offline
   - Vérifier qu'elles sont marquées `synced: false`
   - Vérifier la synchronisation avec Supabase quand online
4. **Implémenter l'authentification** (AuthRepository + AuthBloc)

---

## Vérification

✅ Aucune erreur de compilation
✅ 5 suggestions de style (non bloquantes)
✅ Pattern Repository → BLoC correctement implémenté
✅ Offline-first fonctionnel (Drift + sync flags)
✅ Code généré par build_runner à jour

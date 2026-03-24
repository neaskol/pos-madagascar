# Base de données locale — Drift (SQLite)

## Structure créée

### Tables actuelles

✅ **Core**
- `stores.drift` — Magasins
- `users.drift` — Utilisateurs (OWNER, ADMIN, MANAGER, CASHIER)
- `store_settings.drift` — Réglages modulaires du magasin

✅ **Produits**
- `categories.drift` — Catégories de produits
- `items.drift` — Produits/articles avec gestion stock

### Fichiers générés

- `app_database.dart` — Configuration centrale
- `app_database.g.dart` — Code généré (195 KB) ✅

## Utilisation

### 1. Initialiser la base

```dart
import 'package:pos_madagascar/core/data/local/app_database.dart';

// Singleton
final database = AppDatabase();
```

### 2. Insérer des données

```dart
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

// Créer un magasin
final store = Store(
  id: _uuid.v4(),
  name: 'Épicerie Tana',
  address: 'Analakely, Antananarivo',
  phone: '+261 34 12 345 67',
  currency: 'MGA',
  timezone: 'Indian/Antananarivo',
  synced: false,
  updatedAt: DateTime.now().millisecondsSinceEpoch,
);

await database.into(database.stores).insert(store);
```

### 3. Lire avec les queries nommées

```dart
// Utiliser les queries auto-générées depuis les fichiers .drift
final allStores = await database.getAllStores().get();

// Watch (Stream temps réel)
database.getAvailableItems(storeId).watch().listen((items) {
  print('${items.length} articles disponibles');
});
```

### 4. Rechercher

```dart
final results = await database.searchItems(storeId, query: 'Coca').get();
```

### 5. Mettre à jour

```dart
await (database.update(database.items)
  ..where((i) => i.id.equals(itemId))
).write(
  ItemsCompanion(
    price: Value(250000), // 2500 Ar
    synced: const Value(false),
    updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
  ),
);
```

### 6. Soft delete

```dart
await (database.update(database.items)
  ..where((i) => i.id.equals(itemId))
).write(
  ItemsCompanion(
    deletedAt: Value(DateTime.now().millisecondsSinceEpoch),
    synced: const Value(false),
  ),
);
```

## Conventions

### 1. IDs = UUIDs (String)

```dart
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

final id = _uuid.v4(); // "550e8400-e29b-41d4-a716-446655440000"
```

### 2. Prix = Integer (centimes d'Ariary)

```dart
// 1500 Ar = 150000 (stocké en centimes)
final item = Item(
  price: 150000, // 1500.00 Ar
  cost: 100000,  // 1000.00 Ar
);

// Affichage
String formatAriary(int centimes) {
  final ariary = centimes ~/ 100;
  return NumberFormat('#,###', 'fr').format(ariary) + ' Ar';
}

print(formatAriary(150000)); // "1 500 Ar"
```

### 3. DateTime = Integer (Unix timestamp milliseconds)

```dart
// Stockage
updatedAt: DateTime.now().millisecondsSinceEpoch

// Lecture
DateTime.fromMillisecondsSinceEpoch(row.updatedAt)
```

### 4. Boolean = Integer (0/1)

```dart
// SQLite n'a pas de type BOOLEAN
synced INTEGER NOT NULL DEFAULT 0  -- false
active INTEGER NOT NULL DEFAULT 1  -- true

// Dart reconnaît automatiquement
final user = User(active: true); // → stocké comme 1
```

### 5. Sync pattern

```dart
// Toujours écrire local EN PREMIER
await database.upsertProduct(product.copyWith(synced: false));

// Sync en arrière-plan (fire and forget)
unawaited(_syncToSupabase());

Future<void> _syncToSupabase() async {
  final unsynced = await database.getUnsyncedItems().get();
  for (final item in unsynced) {
    await supabase.from('items').upsert(item.toJson());
  }
  // Marquer comme synced
  await database.batch((batch) {
    for (final item in unsynced) {
      batch.update(
        database.items,
        ItemsCompanion(synced: const Value(true)),
        where: (i) => i.id.equals(item.id),
      );
    }
  });
}
```

## Commandes

### Générer le code après modification

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Nettoyer les fichiers générés

```bash
dart run build_runner clean
```

### Watch mode (auto-regeneration)

```bash
dart run build_runner watch --delete-conflicting-outputs
```

## Migrations

Lorsque vous modifiez le schéma :

1. **Modifier le fichier `.drift`**
2. **Incrémenter `schemaVersion`** dans `app_database.dart`
3. **Ajouter la migration** dans `onUpgrade`

```dart
@override
int get schemaVersion => 2; // était 1

@override
MigrationStrategy get migration => MigrationStrategy(
  onUpgrade: (m, from, to) async {
    if (from < 2) {
      // Ajouter une colonne
      await m.addColumn(items, items.imageUrl);

      // Ou créer un index
      await m.createIndex(Index(
        'idx_items_sku',
        'CREATE INDEX idx_items_sku ON items(sku)',
      ));
    }
  },
);
```

4. **Regénérer le code**

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Tables restantes à créer

🔲 **Produits avancés**
- `item_variants.drift` — Variantes (taille, couleur)
- `modifiers.drift` — Modificateurs (options)
- `modifier_options.drift`
- `item_modifiers.drift` — Liaison
- `taxes.drift` — Taxes
- `item_taxes.drift` — Liaison
- `discounts.drift` — Remises

🔲 **Ventes**
- `shifts.drift` — Shifts de caisse
- `sales.drift` — Ventes
- `sale_items.drift` — Lignes de vente
- `sale_payments.drift` — Paiements
- `refunds.drift` — Remboursements

🔲 **Clients**
- `customers.drift` — Clients
- `credits.drift` — Vente à crédit 🚀

🔲 **Inventaire**
- `suppliers.drift` — Fournisseurs
- `purchase_orders.drift` — Bons de commande
- `stock_adjustments.drift` — Ajustements
- `inventory_counts.drift` — Inventaires

## Optimisations SQLite activées

```dart
PRAGMA journal_mode = WAL          // Write-Ahead Logging
PRAGMA synchronous = NORMAL        // Compromis perfs/sécurité
PRAGMA temp_store = MEMORY         // Tables temp en RAM
PRAGMA mmap_size = 30000000000     // Memory-mapped I/O (30 GB)
PRAGMA cache_size = -64000         // Cache 64 MB
PRAGMA foreign_keys = ON           // Contraintes FK activées
```

## Prochaines étapes

1. ✅ Installer le skill `drift-expert` → fait (redémarrer session pour l'activer)
2. ✅ Créer les tables core → fait
3. 🔲 Créer les DAOs (Data Access Objects)
4. 🔲 Créer les repositories (couche métier)
5. 🔲 Intégrer avec les BLoCs
6. 🔲 Configurer Supabase et la synchronisation

---

**Note** : Le skill `drift-expert` a été créé dans `~/.claude/skills/drift-expert.md` et sera disponible après redémarrage de la session Claude Code.

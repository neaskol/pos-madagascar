import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

// Import DAOs
import 'daos/store_dao.dart';
import 'daos/user_dao.dart';
import 'daos/store_settings_dao.dart';
import 'daos/category_dao.dart';
import 'daos/item_dao.dart';
import 'daos/item_variant_dao.dart';
import 'daos/modifier_dao.dart';
import 'daos/custom_page_dao.dart';

// Export DAOs for use in repositories
export 'daos/store_dao.dart';
export 'daos/user_dao.dart';
export 'daos/store_settings_dao.dart';
export 'daos/category_dao.dart';
export 'daos/item_dao.dart';
export 'daos/item_variant_dao.dart';
export 'daos/modifier_dao.dart';
export 'daos/custom_page_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  include: {
    'tables/stores.drift',
    'tables/users.drift',
    'tables/store_settings.drift',
    'tables/categories.drift',
    'tables/items.drift',
    'tables/item_variants.drift',
    'tables/modifiers.drift',
    'tables/modifier_options.drift',
    'tables/item_modifiers.drift',
    'tables/custom_pages.drift',
  },
  daos: [
    StoreDao,
    UserDao,
    StoreSettingsDao,
    CategoryDao,
    ItemDao,
    ItemVariantDao,
    ModifierDao,
    CustomPageDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          // Migrations futures ici
        },
        beforeOpen: (details) async {
          // Activer les foreign keys
          await customStatement('PRAGMA foreign_keys = ON');

          // Optimisations SQLite pour mobile
          await customStatement('PRAGMA journal_mode = WAL');
          await customStatement('PRAGMA synchronous = NORMAL');
          await customStatement('PRAGMA temp_store = MEMORY');
          await customStatement('PRAGMA mmap_size = 30000000000');
          await customStatement('PRAGMA cache_size = -64000'); // 64MB cache

          if (details.wasCreated) {
            // Initialiser les données par défaut si besoin
          }
        },
      );

  // Debug mode - à désactiver en prod
  bool get logStatements => true;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'pos_madagascar.db'));
    return NativeDatabase(file);
  });
}

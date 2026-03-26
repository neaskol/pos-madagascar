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
import 'daos/customer_dao.dart';
import 'daos/credit_dao.dart';
import 'daos/sale_dao.dart';
import 'daos/shift_dao.dart';
import 'daos/open_ticket_dao.dart';
import 'daos/refund_dao.dart';
import 'daos/dining_option_dao.dart';
import 'daos/pos_device_dao.dart';
import 'daos/stock_adjustment_dao.dart';
import 'daos/inventory_history_dao.dart';
import 'daos/inventory_count_dao.dart';

// Export DAOs for use in repositories
export 'daos/store_dao.dart';
export 'daos/user_dao.dart';
export 'daos/store_settings_dao.dart';
export 'daos/category_dao.dart';
export 'daos/item_dao.dart';
export 'daos/item_variant_dao.dart';
export 'daos/modifier_dao.dart';
export 'daos/custom_page_dao.dart';
export 'daos/customer_dao.dart';
export 'daos/credit_dao.dart';
export 'daos/sale_dao.dart';
export 'daos/shift_dao.dart';
export 'daos/open_ticket_dao.dart';
export 'daos/refund_dao.dart';
export 'daos/dining_option_dao.dart';
export 'daos/pos_device_dao.dart';
export 'daos/stock_adjustment_dao.dart';
export 'daos/inventory_history_dao.dart';
export 'daos/inventory_count_dao.dart';

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
    'tables/customers.drift',
    'tables/credits.drift',
    'tables/sales.drift',
    'tables/sale_items.drift',
    'tables/sale_payments.drift',
    'tables/shifts.drift',
    'tables/cash_movements.drift',
    'tables/open_tickets.drift',
    'tables/refunds.drift',
    'tables/dining_options.drift',
    'tables/pos_devices.drift',
    'tables/stock_adjustments.drift',
    'tables/stock_adjustment_items.drift',
    'tables/inventory_history.drift',
    'tables/inventory_counts.drift',
    'tables/inventory_count_items.drift',
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
    CustomerDao,
    CreditDao,
    SaleDao,
    ShiftDao,
    OpenTicketDao,
    RefundDao,
    DiningOptionDao,
    PosDeviceDao,
    StockAdjustmentDao,
    InventoryHistoryDao,
    InventoryCountDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) {
            // v2: Ajout des tables ventes, shifts, tickets, remboursements, dining, pos_devices
            await m.createAll();
          }
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

  // Debug mode - désactivé en production
  // Pour activer les logs en développement, passer à true
  bool get logStatements => false;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'pos_madagascar.db'));
    return NativeDatabase(file);
  });
}

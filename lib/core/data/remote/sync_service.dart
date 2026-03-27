import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:drift/drift.dart';
import '../local/app_database.dart';
import 'dart:developer' as developer;

/// Handles bidirectional sync between Drift (local) and Supabase (remote)
///
/// Architecture: Offline-first
/// - Priority: Drift is source of truth
/// - Writes: Always go to Drift first, then sync to Supabase in background
/// - Reads: From Drift for speed, Supabase for initial seed
/// - Conflicts: Last-write-wins (can be customized per table)
///
/// Usage:
/// ```dart
/// final syncService = SyncService(localDb, SupabaseService.client);
/// await syncService.syncToRemote(); // Push unsynced local changes
/// ```
class SyncService {
  final AppDatabase _localDb;
  final SupabaseClient _supabase;
  DateTime? _lastSyncAttempt;
  static const _minSyncInterval = Duration(seconds: 10);

  SyncService(this._localDb, this._supabase);

  /// Sync all unsynced local changes to Supabase
  ///
  /// This method pushes all records marked as `synced: false` to Supabase.
  /// On success, marks them as `synced: true` locally.
  /// On error, logs but doesn't throw (offline resilience).
  ///
  /// [force] - If true, ignores the minimum sync interval throttling
  Future<SyncResult> syncToRemote({bool force = false}) async {
    final result = SyncResult();

    try {
      // Throttle : éviter les syncs trop fréquentes (sauf si forcé)
      if (!force && _lastSyncAttempt != null) {
        final timeSinceLastSync = DateTime.now().difference(_lastSyncAttempt!);
        if (timeSinceLastSync < _minSyncInterval) {
          developer.log('Sync throttled (too soon)', name: 'SyncService');
          result.skipped = true;
          return result;
        }
      }

      _lastSyncAttempt = DateTime.now();

      // Vérifier la connexion internet
      if (!await _hasInternetConnection()) {
        developer.log('No internet connection - skipping sync', name: 'SyncService');
        result.skipped = true;
        return result;
      }

      // Synchroniser chaque table dans l'ordre (respect des foreign keys)
      await _syncStores(result);
      await _syncUsers(result);
      await _syncStoreSettings(result);
      await _syncCategories(result);
      await _syncItems(result);
      await _syncCustomers(result);

      developer.log('Sync completed: ${result.summary}', name: 'SyncService');
    } catch (e, stack) {
      developer.log(
        'Sync failed',
        name: 'SyncService',
        error: e,
        stackTrace: stack,
      );
      result.errors.add(e.toString());
    }

    return result;
  }

  /// Synchronise les magasins
  Future<void> _syncStores(SyncResult result) async {
    try {
      final unsyncedStores = await _localDb.storeDao.getUnsyncedStores().get();

      for (final store in unsyncedStores) {
        try {
          final storeData = {
            'id': store.id,
            'name': store.name,
            'address': store.address,
            'phone': store.phone,
            'logo_url': store.logoUrl,
            'currency': store.currency,
            'timezone': store.timezone,
            'updated_at': DateTime.fromMillisecondsSinceEpoch(store.updatedAt).toIso8601String(),
            'deleted_at': store.deletedAt != null
                ? DateTime.fromMillisecondsSinceEpoch(store.deletedAt!).toIso8601String()
                : null,
          };

          // Upsert dans Supabase
          await _supabase.from('stores').upsert(storeData);

          // Marquer comme synchronisé
          await _localDb.storeDao.markStoreSynced(store.id);
          result.storesSynced++;
        } catch (e) {
          developer.log('Failed to sync store ${store.id}', name: 'SyncService', error: e);
          result.errors.add('Store ${store.name}: $e');
        }
      }
    } catch (e) {
      developer.log('Failed to sync stores', name: 'SyncService', error: e);
      result.errors.add('Stores: $e');
    }
  }

  /// Synchronise les utilisateurs
  Future<void> _syncUsers(SyncResult result) async {
    try {
      final unsyncedUsers = await _localDb.userDao.getUnsyncedUsers().get();

      for (final user in unsyncedUsers) {
        try {
          final userData = {
            'id': user.id,
            'store_id': user.storeId,
            'name': user.name,
            'email': user.email,
            'phone': user.phone,
            'role': user.role,
            'pin_hash': user.pinHash,
            'email_verified': user.emailVerified,
            'active': user.active,
            'updated_at': DateTime.fromMillisecondsSinceEpoch(user.updatedAt).toIso8601String(),
            'deleted_at': user.deletedAt != null
                ? DateTime.fromMillisecondsSinceEpoch(user.deletedAt!).toIso8601String()
                : null,
          };

          await _supabase.from('users').upsert(userData);
          await _localDb.userDao.markUserSynced(user.id);
          result.usersSynced++;
        } catch (e) {
          developer.log('Failed to sync user ${user.id}', name: 'SyncService', error: e);
          result.errors.add('User ${user.name}: $e');
        }
      }
    } catch (e) {
      developer.log('Failed to sync users', name: 'SyncService', error: e);
      result.errors.add('Users: $e');
    }
  }

  /// Synchronise les réglages de magasin
  Future<void> _syncStoreSettings(SyncResult result) async {
    try {
      final unsyncedSettings = await _localDb.storeSettingsDao.getUnsyncedSettings().get();

      for (final settings in unsyncedSettings) {
        try {
          final settingsData = {
            'store_id': settings.storeId,
            'shifts_enabled': settings.shiftsEnabled,
            'time_clock_enabled': settings.timeClockEnabled,
            'open_tickets_enabled': settings.openTicketsEnabled,
            'predefined_tickets_enabled': settings.predefinedTicketsEnabled,
            'kitchen_printers_enabled': settings.kitchenPrintersEnabled,
            'customer_display_enabled': settings.customerDisplayEnabled,
            'dining_options_enabled': settings.diningOptionsEnabled,
            'low_stock_notifications': settings.lowStockNotifications,
            'negative_stock_alerts': settings.negativeStockAlerts,
            'weight_barcodes_enabled': settings.weightBarcodesEnabled,
            'cash_rounding_unit': settings.cashRoundingUnit,
            'receipt_footer': settings.receiptFooter,
            'updated_at': DateTime.fromMillisecondsSinceEpoch(settings.updatedAt).toIso8601String(),
          };

          await _supabase.from('store_settings').upsert(settingsData);
          await _localDb.storeSettingsDao.markSettingsSynced(settings.storeId);
          result.settingsSynced++;
        } catch (e) {
          developer.log('Failed to sync settings ${settings.storeId}', name: 'SyncService', error: e);
          result.errors.add('Settings: $e');
        }
      }
    } catch (e) {
      developer.log('Failed to sync store settings', name: 'SyncService', error: e);
      result.errors.add('Store settings: $e');
    }
  }

  /// Synchronise les catégories
  Future<void> _syncCategories(SyncResult result) async {
    try {
      final unsyncedCategories = await _localDb.categoryDao.getUnsyncedCategories().get();

      for (final category in unsyncedCategories) {
        try {
          final categoryData = {
            'id': category.id,
            'store_id': category.storeId,
            'name': category.name,
            'color': category.color,
            'sort_order': category.sortOrder,
            'updated_at': DateTime.fromMillisecondsSinceEpoch(category.updatedAt).toIso8601String(),
            'deleted_at': category.deletedAt != null
                ? DateTime.fromMillisecondsSinceEpoch(category.deletedAt!).toIso8601String()
                : null,
          };

          await _supabase.from('categories').upsert(categoryData);
          await _localDb.categoryDao.markCategorySynced(category.id);
          result.categoriesSynced++;
        } catch (e) {
          developer.log('Failed to sync category ${category.id}', name: 'SyncService', error: e);
          result.errors.add('Category ${category.name}: $e');
        }
      }
    } catch (e) {
      developer.log('Failed to sync categories', name: 'SyncService', error: e);
      result.errors.add('Categories: $e');
    }
  }

  /// Synchronise les articles/produits
  Future<void> _syncItems(SyncResult result) async {
    try {
      final unsyncedItems = await _localDb.itemDao.getUnsyncedItems().get();

      for (final item in unsyncedItems) {
        try {
          final itemData = {
            'id': item.id,
            'store_id': item.storeId,
            'category_id': item.categoryId,
            'name': item.name,
            'description': item.description,
            'sku': item.sku,
            'barcode': item.barcode,
            'price': item.price,
            'cost': item.cost,
            'cost_is_percentage': item.costIsPercentage,
            'sold_by': item.soldBy,
            'available_for_sale': item.availableForSale,
            'track_stock': item.trackStock,
            'in_stock': item.inStock,
            'low_stock_threshold': item.lowStockThreshold,
            'is_composite': item.isComposite,
            'use_production': item.useProduction,
            'image_url': item.imageUrl,
            'average_cost': item.averageCost,
            'updated_at': DateTime.fromMillisecondsSinceEpoch(item.updatedAt).toIso8601String(),
            'deleted_at': item.deletedAt != null
                ? DateTime.fromMillisecondsSinceEpoch(item.deletedAt!).toIso8601String()
                : null,
          };

          await _supabase.from('items').upsert(itemData);
          await _localDb.itemDao.markItemSynced(item.id);
          result.itemsSynced++;
        } catch (e) {
          developer.log('Failed to sync item ${item.id}', name: 'SyncService', error: e);
          result.errors.add('Item ${item.name}: $e');
        }
      }
    } catch (e) {
      developer.log('Failed to sync items', name: 'SyncService', error: e);
      result.errors.add('Items: $e');
    }
  }

  /// Synchronise les clients
  Future<void> _syncCustomers(SyncResult result) async {
    try {
      final unsyncedCustomers = await _localDb.customerDao.getUnsyncedCustomers();

      for (final customer in unsyncedCustomers) {
        try {
          final customerData = {
            'id': customer.id,
            'store_id': customer.storeId,
            'name': customer.name,
            'phone': customer.phone,
            'email': customer.email,
            'loyalty_card_barcode': customer.loyaltyCardBarcode,
            'total_visits': customer.totalVisits,
            'total_spent': customer.totalSpent,
            'credit_balance': customer.creditBalance,
            'notes': customer.notes,
            'created_by': customer.createdBy,
            'created_at': DateTime.fromMillisecondsSinceEpoch(customer.createdAt).toIso8601String(),
            'updated_at': DateTime.fromMillisecondsSinceEpoch(customer.updatedAt).toIso8601String(),
          };

          await _supabase.from('customers').upsert(customerData);
          await _localDb.customerDao.markCustomerAsSynced(customer.id);
          result.customersSynced++;
        } catch (e) {
          developer.log('Failed to sync customer ${customer.id}', name: 'SyncService', error: e);
          result.errors.add('Customer ${customer.name}: $e');
        }
      }
    } catch (e) {
      developer.log('Failed to sync customers', name: 'SyncService', error: e);
      result.errors.add('Customers: $e');
    }
  }

  /// Vérifie si une connexion internet est disponible
  ///
  /// Note: Cette implémentation simple tente une requête HEAD vers Supabase.
  /// Pour une vraie app, utiliser connectivity_plus package.
  Future<bool> _hasInternetConnection() async {
    try {
      // Tenter une simple requête pour vérifier la connectivité
      await _supabase.from('stores').select('id').limit(1).count();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Pull changes from Supabase to Drift (initial seed)
  ///
  /// Cette méthode est appelée après l'authentification initiale pour télécharger
  /// toutes les données du magasin de l'utilisateur depuis Supabase vers Drift.
  ///
  /// [storeId] - ID du magasin dont on veut récupérer les données
  /// [forceRefresh] - Si true, efface et recharge toutes les données
  Future<SyncResult> syncFromRemote(String storeId, {bool forceRefresh = false}) async {
    final result = SyncResult();

    try {
      developer.log('Starting pull sync from Supabase for store: $storeId', name: 'SyncService');

      // Vérifier la connexion internet
      if (!await _hasInternetConnection()) {
        developer.log('No internet connection - skipping pull sync', name: 'SyncService');
        result.skipped = true;
        return result;
      }

      // Synchroniser chaque table dans l'ordre (respect des foreign keys)
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

      developer.log('Pull sync completed: ${result.summary}', name: 'SyncService');
    } catch (e, stack) {
      developer.log(
        'Pull sync failed',
        name: 'SyncService',
        error: e,
        stackTrace: stack,
      );
      result.errors.add(e.toString());
    }

    return result;
  }

  /// Récupère les catégories depuis Supabase
  Future<void> _pullCategories(String storeId, SyncResult result) async {
    try {
      final remoteCategories = await _supabase
          .from('categories')
          .select()
          .eq('store_id', storeId)
          .order('sort_order');

      for (final categoryData in remoteCategories) {
        try {
          final companion = CategoriesCompanion(
            id: Value(categoryData['id'] as String),
            storeId: Value(categoryData['store_id'] as String),
            name: Value(categoryData['name'] as String),
            color: Value(categoryData['color'] as String?),
            sortOrder: Value(categoryData['sort_order'] as int? ?? 0),
            updatedAt: Value(DateTime.parse(categoryData['updated_at'] as String).millisecondsSinceEpoch),
            deletedAt: categoryData['deleted_at'] != null
                ? Value(DateTime.parse(categoryData['deleted_at'] as String).millisecondsSinceEpoch)
                : const Value(null),
            synced: const Value(1), // Marqué comme synchronisé
          );

          await _localDb.categoryDao.upsertCategory(companion);
          result.categoriesSynced++;
        } catch (e) {
          developer.log('Failed to pull category ${categoryData['id']}', name: 'SyncService', error: e);
          result.errors.add('Category ${categoryData['name']}: $e');
        }
      }
    } catch (e) {
      developer.log('Failed to pull categories', name: 'SyncService', error: e);
      result.errors.add('Categories: $e');
    }
  }

  /// Récupère les items depuis Supabase
  Future<void> _pullItems(String storeId, SyncResult result) async {
    try {
      final remoteItems = await _supabase
          .from('items')
          .select()
          .eq('store_id', storeId)
          .order('name');

      for (final itemData in remoteItems) {
        try {
          final companion = ItemsCompanion(
            id: Value(itemData['id'] as String),
            storeId: Value(itemData['store_id'] as String),
            categoryId: Value(itemData['category_id'] as String?),
            name: Value(itemData['name'] as String),
            description: Value(itemData['description'] as String?),
            sku: Value(itemData['sku'] as String?),
            barcode: Value(itemData['barcode'] as String?),
            price: Value(itemData['price'] as int),
            cost: Value(itemData['cost'] as int? ?? 0),
            costIsPercentage: Value(itemData['cost_is_percentage'] as int? ?? 0),
            soldBy: Value(itemData['sold_by'] as String? ?? 'piece'),
            availableForSale: Value(itemData['available_for_sale'] as int? ?? 1),
            trackStock: Value(itemData['track_stock'] as int? ?? 0),
            inStock: Value(itemData['in_stock'] as int? ?? 0),
            lowStockThreshold: Value(itemData['low_stock_threshold'] as int? ?? 0),
            isComposite: Value(itemData['is_composite'] as int? ?? 0),
            useProduction: Value(itemData['use_production'] as int? ?? 0),
            imageUrl: Value(itemData['image_url'] as String?),
            averageCost: Value(itemData['average_cost'] as int? ?? 0),
            updatedAt: Value(DateTime.parse(itemData['updated_at'] as String).millisecondsSinceEpoch),
            deletedAt: itemData['deleted_at'] != null
                ? Value(DateTime.parse(itemData['deleted_at'] as String).millisecondsSinceEpoch)
                : const Value(null),
            synced: const Value(1), // Marqué comme synchronisé
          );

          await _localDb.itemDao.upsertItem(companion);
          result.itemsSynced++;
        } catch (e) {
          developer.log('Failed to pull item ${itemData['id']}', name: 'SyncService', error: e);
          result.errors.add('Item ${itemData['name']}: $e');
        }
      }
    } catch (e) {
      developer.log('Failed to pull items', name: 'SyncService', error: e);
      result.errors.add('Items: $e');
    }
  }

  /// Récupère les clients depuis Supabase
  Future<void> _pullCustomers(String storeId, SyncResult result) async {
    try {
      final remoteCustomers = await _supabase
          .from('customers')
          .select()
          .eq('store_id', storeId)
          .order('name');

      for (final customerData in remoteCustomers) {
        try {
          final companion = CustomersCompanion(
            id: Value(customerData['id'] as String),
            storeId: Value(customerData['store_id'] as String),
            name: Value(customerData['name'] as String),
            phone: Value(customerData['phone'] as String?),
            email: Value(customerData['email'] as String?),
            loyaltyCardBarcode: Value(customerData['loyalty_card_barcode'] as String?),
            totalVisits: Value(customerData['total_visits'] as int? ?? 0),
            totalSpent: Value(customerData['total_spent'] as int? ?? 0),
            creditBalance: Value(customerData['credit_balance'] as int? ?? 0),
            notes: Value(customerData['notes'] as String?),
            createdBy: Value(customerData['created_by'] as String?),
            createdAt: Value(DateTime.parse(customerData['created_at'] as String).millisecondsSinceEpoch),
            updatedAt: Value(DateTime.parse(customerData['updated_at'] as String).millisecondsSinceEpoch),
            synced: const Value(1), // Marqué comme synchronisé
          );

          await _localDb.customerDao.upsertCustomer(companion);
          result.customersSynced++;
        } catch (e) {
          developer.log('Failed to pull customer ${customerData['id']}', name: 'SyncService', error: e);
          result.errors.add('Customer ${customerData['name']}: $e');
        }
      }
    } catch (e) {
      developer.log('Failed to pull customers', name: 'SyncService', error: e);
      result.errors.add('Customers: $e');
    }
  }

  /// Récupère les options de service depuis Supabase
  Future<void> _pullDiningOptions(String storeId, SyncResult result) async {
    try {
      final remoteDiningOptions = await _supabase
          .from('dining_options')
          .select()
          .eq('store_id', storeId)
          .order('sort_order');

      for (final optionData in remoteDiningOptions) {
        try {
          final companion = DiningOptionsCompanion(
            id: Value(optionData['id'] as String),
            storeId: Value(optionData['store_id'] as String),
            name: Value(optionData['name'] as String),
            sortOrder: Value(optionData['sort_order'] as int? ?? 0),
            isDefault: Value(optionData['is_default'] as int? ?? 0),
            createdAt: Value(DateTime.parse(optionData['created_at'] as String).millisecondsSinceEpoch),
            updatedAt: Value(DateTime.parse(optionData['updated_at'] as String).millisecondsSinceEpoch),
            deletedAt: optionData['deleted_at'] != null
                ? Value(DateTime.parse(optionData['deleted_at'] as String).millisecondsSinceEpoch)
                : const Value(null),
            synced: const Value(1), // Marqué comme synchronisé
          );

          await _localDb.diningOptionDao.upsertDiningOption(companion);
        } catch (e) {
          developer.log('Failed to pull dining option ${optionData['id']}', name: 'SyncService', error: e);
          result.errors.add('DiningOption ${optionData['name']}: $e');
        }
      }
    } catch (e) {
      developer.log('Failed to pull dining options', name: 'SyncService', error: e);
      result.errors.add('DiningOptions: $e');
    }
  }

  /// Récupère les appareils POS depuis Supabase
  Future<void> _pullPosDevices(String storeId, SyncResult result) async {
    try {
      final remotePosDevices = await _supabase
          .from('pos_devices')
          .select()
          .eq('store_id', storeId)
          .order('name');

      for (final deviceData in remotePosDevices) {
        try {
          final companion = PosDevicesCompanion(
            id: Value(deviceData['id'] as String),
            storeId: Value(deviceData['store_id'] as String),
            name: Value(deviceData['name'] as String),
            active: Value(deviceData['active'] as int? ?? 1),
            lastSeenAt: deviceData['last_seen_at'] != null
                ? Value(DateTime.parse(deviceData['last_seen_at'] as String).millisecondsSinceEpoch)
                : const Value(null),
            createdAt: Value(DateTime.parse(deviceData['created_at'] as String).millisecondsSinceEpoch),
            updatedAt: Value(DateTime.parse(deviceData['updated_at'] as String).millisecondsSinceEpoch),
            createdBy: Value(deviceData['created_by'] as String?),
            synced: const Value(1), // Marqué comme synchronisé
          );

          await _localDb.posDeviceDao.upsertPosDevice(companion);
        } catch (e) {
          developer.log('Failed to pull POS device ${deviceData['id']}', name: 'SyncService', error: e);
          result.errors.add('PosDevice ${deviceData['name']}: $e');
        }
      }
    } catch (e) {
      developer.log('Failed to pull POS devices', name: 'SyncService', error: e);
      result.errors.add('PosDevices: $e');
    }
  }

  /// Récupère les variants d'items depuis Supabase
  Future<void> _pullItemVariants(String storeId, SyncResult result) async {
    try {
      final remoteVariants = await _supabase
          .from('item_variants')
          .select()
          .eq('store_id', storeId)
          .order('item_id');

      for (final variantData in remoteVariants) {
        try {
          final companion = ItemVariantsCompanion(
            id: Value(variantData['id'] as String),
            itemId: Value(variantData['item_id'] as String),
            storeId: Value(variantData['store_id'] as String),
            option1Name: Value(variantData['option1_name'] as String?),
            option1Value: Value(variantData['option1_value'] as String?),
            option2Name: Value(variantData['option2_name'] as String?),
            option2Value: Value(variantData['option2_value'] as String?),
            option3Name: Value(variantData['option3_name'] as String?),
            option3Value: Value(variantData['option3_value'] as String?),
            sku: Value(variantData['sku'] as String?),
            barcode: Value(variantData['barcode'] as String?),
            price: Value(variantData['price'] as int?),
            cost: Value(variantData['cost'] as int?),
            inStock: Value(variantData['in_stock'] as int? ?? 0),
            lowStockThreshold: Value(variantData['low_stock_threshold'] as int? ?? 0),
            imageUrl: Value(variantData['image_url'] as String?),
            createdAt: Value(DateTime.parse(variantData['created_at'] as String).millisecondsSinceEpoch),
            updatedAt: Value(DateTime.parse(variantData['updated_at'] as String).millisecondsSinceEpoch),
            createdBy: Value(variantData['created_by'] as String?),
            synced: const Value(1), // Marqué comme synchronisé
          );

          await _localDb.itemVariantDao.upsertVariant(companion);
        } catch (e) {
          developer.log('Failed to pull item variant ${variantData['id']}', name: 'SyncService', error: e);
          result.errors.add('ItemVariant ${variantData['id']}: $e');
        }
      }
    } catch (e) {
      developer.log('Failed to pull item variants', name: 'SyncService', error: e);
      result.errors.add('ItemVariants: $e');
    }
  }

  /// Récupère les modifiers et leurs options depuis Supabase
  Future<void> _pullModifiers(String storeId, SyncResult result) async {
    try {
      // 1. Pull modifiers
      final remoteModifiers = await _supabase
          .from('modifiers')
          .select()
          .eq('store_id', storeId)
          .order('name');

      for (final modifierData in remoteModifiers) {
        try {
          final companion = ModifiersCompanion(
            id: Value(modifierData['id'] as String),
            storeId: Value(modifierData['store_id'] as String),
            name: Value(modifierData['name'] as String),
            isRequired: Value(modifierData['is_required'] as int? ?? 0),
            createdAt: Value(DateTime.parse(modifierData['created_at'] as String).millisecondsSinceEpoch),
            updatedAt: Value(DateTime.parse(modifierData['updated_at'] as String).millisecondsSinceEpoch),
            createdBy: Value(modifierData['created_by'] as String?),
            synced: const Value(1), // Marqué comme synchronisé
          );

          await _localDb.modifierDao.upsertModifier(companion);
        } catch (e) {
          developer.log('Failed to pull modifier ${modifierData['id']}', name: 'SyncService', error: e);
          result.errors.add('Modifier ${modifierData['name']}: $e');
        }
      }

      // 2. Pull modifier options
      final remoteOptions = await _supabase
          .from('modifier_options')
          .select('*, modifiers!inner(store_id)')
          .eq('modifiers.store_id', storeId)
          .order('modifier_id')
          .order('sort_order');

      for (final optionData in remoteOptions) {
        try {
          final companion = ModifierOptionsCompanion(
            id: Value(optionData['id'] as String),
            modifierId: Value(optionData['modifier_id'] as String),
            name: Value(optionData['name'] as String),
            priceAddition: Value(optionData['price_addition'] as int? ?? 0),
            sortOrder: Value(optionData['sort_order'] as int? ?? 0),
            createdAt: Value(DateTime.parse(optionData['created_at'] as String).millisecondsSinceEpoch),
            updatedAt: Value(DateTime.parse(optionData['updated_at'] as String).millisecondsSinceEpoch),
            synced: const Value(1), // Marqué comme synchronisé
          );

          await _localDb.modifierDao.upsertModifierOption(companion);
        } catch (e) {
          developer.log('Failed to pull modifier option ${optionData['id']}', name: 'SyncService', error: e);
          result.errors.add('ModifierOption ${optionData['name']}: $e');
        }
      }
    } catch (e) {
      developer.log('Failed to pull modifiers', name: 'SyncService', error: e);
      result.errors.add('Modifiers: $e');
    }
  }

  /// Récupère les ventes depuis Supabase (sales + sale_items + sale_payments)
  Future<void> _pullSales(String storeId, SyncResult result) async {
    try {
      // 1. Pull sales
      final remoteSales = await _supabase
          .from('sales')
          .select()
          .eq('store_id', storeId)
          .order('created_at', ascending: false);

      for (final saleData in remoteSales) {
        try {
          final companion = SalesCompanion(
            id: Value(saleData['id'] as String),
            storeId: Value(saleData['store_id'] as String),
            posDeviceId: Value(saleData['pos_device_id'] as String?),
            receiptNumber: Value(saleData['receipt_number'] as String),
            employeeId: Value(saleData['employee_id'] as String?),
            customerId: Value(saleData['customer_id'] as String?),
            diningOptionId: Value(saleData['dining_option_id'] as String?),
            subtotal: Value(saleData['subtotal'] as int),
            taxAmount: Value(saleData['tax_amount'] as int? ?? 0),
            discountAmount: Value(saleData['discount_amount'] as int? ?? 0),
            total: Value(saleData['total'] as int),
            changeDue: Value(saleData['change_due'] as int? ?? 0),
            note: Value(saleData['note'] as String?),
            createdAt: Value(DateTime.parse(saleData['created_at'] as String).millisecondsSinceEpoch),
            updatedAt: Value(DateTime.parse(saleData['updated_at'] as String).millisecondsSinceEpoch),
            deletedAt: saleData['deleted_at'] != null
                ? Value(DateTime.parse(saleData['deleted_at'] as String).millisecondsSinceEpoch)
                : const Value(null),
            synced: const Value(1), // Marqué comme synchronisé
          );

          await _localDb.saleDao.upsertSale(companion);
        } catch (e) {
          developer.log('Failed to pull sale ${saleData['id']}', name: 'SyncService', error: e);
          result.errors.add('Sale ${saleData['receipt_number']}: $e');
        }
      }

      // 2. Pull sale_items
      final remoteSaleItems = await _supabase
          .from('sale_items')
          .select('*, sales!inner(store_id)')
          .eq('sales.store_id', storeId)
          .order('sale_id');

      for (final itemData in remoteSaleItems) {
        try {
          final companion = SaleItemsCompanion(
            id: Value(itemData['id'] as String),
            saleId: Value(itemData['sale_id'] as String),
            itemId: Value(itemData['item_id'] as String?),
            itemVariantId: Value(itemData['item_variant_id'] as String?),
            itemName: Value(itemData['item_name'] as String),
            quantity: Value(itemData['quantity'] as double? ?? 1.0),
            unitPrice: Value(itemData['unit_price'] as int),
            cost: Value(itemData['cost'] as int? ?? 0),
            discountAmount: Value(itemData['discount_amount'] as int? ?? 0),
            taxAmount: Value(itemData['tax_amount'] as int? ?? 0),
            total: Value(itemData['total'] as int),
            modifiers: Value(itemData['modifiers'] as String?),
            updatedAt: Value(DateTime.parse(itemData['updated_at'] as String).millisecondsSinceEpoch),
            synced: const Value(1), // Marqué comme synchronisé
          );

          await _localDb.saleDao.upsertSaleItem(companion);
        } catch (e) {
          developer.log('Failed to pull sale item ${itemData['id']}', name: 'SyncService', error: e);
          result.errors.add('SaleItem ${itemData['item_name']}: $e');
        }
      }

      // 3. Pull sale_payments
      final remoteSalePayments = await _supabase
          .from('sale_payments')
          .select('*, sales!inner(store_id)')
          .eq('sales.store_id', storeId)
          .order('sale_id');

      for (final paymentData in remoteSalePayments) {
        try {
          final companion = SalePaymentsCompanion(
            id: Value(paymentData['id'] as String),
            saleId: Value(paymentData['sale_id'] as String),
            paymentType: Value(paymentData['payment_type'] as String),
            paymentTypeName: Value(paymentData['payment_type_name'] as String?),
            amount: Value(paymentData['amount'] as int),
            paymentReference: Value(paymentData['payment_reference'] as String?),
            paymentStatus: Value(paymentData['payment_status'] as String? ?? 'confirmed'),
            updatedAt: Value(DateTime.parse(paymentData['updated_at'] as String).millisecondsSinceEpoch),
            synced: const Value(1), // Marqué comme synchronisé
          );

          await _localDb.saleDao.upsertSalePayment(companion);
        } catch (e) {
          developer.log('Failed to pull sale payment ${paymentData['id']}', name: 'SyncService', error: e);
          result.errors.add('SalePayment ${paymentData['id']}: $e');
        }
      }
    } catch (e) {
      developer.log('Failed to pull sales', name: 'SyncService', error: e);
      result.errors.add('Sales: $e');
    }
  }

  /// Récupère les remboursements depuis Supabase (refunds + refund_items)
  Future<void> _pullRefunds(String storeId, SyncResult result) async {
    try {
      // 1. Pull refunds
      final remoteRefunds = await _supabase
          .from('refunds')
          .select()
          .eq('store_id', storeId)
          .order('created_at', ascending: false);

      for (final refundData in remoteRefunds) {
        try {
          final companion = RefundsCompanion(
            id: Value(refundData['id'] as String),
            saleId: Value(refundData['sale_id'] as String),
            storeId: Value(refundData['store_id'] as String),
            employeeId: Value(refundData['employee_id'] as String?),
            total: Value(refundData['total'] as int),
            reason: Value(refundData['reason'] as String?),
            createdAt: Value(DateTime.parse(refundData['created_at'] as String).millisecondsSinceEpoch),
            updatedAt: Value(DateTime.parse(refundData['updated_at'] as String).millisecondsSinceEpoch),
            synced: const Value(1), // Marqué comme synchronisé
          );

          await _localDb.refundDao.upsertRefund(companion);
        } catch (e) {
          developer.log('Failed to pull refund ${refundData['id']}', name: 'SyncService', error: e);
          result.errors.add('Refund ${refundData['id']}: $e');
        }
      }

      // 2. Pull refund_items
      final remoteRefundItems = await _supabase
          .from('refund_items')
          .select('*, refunds!inner(store_id)')
          .eq('refunds.store_id', storeId)
          .order('refund_id');

      for (final itemData in remoteRefundItems) {
        try {
          final companion = RefundItemsCompanion(
            id: Value(itemData['id'] as String),
            refundId: Value(itemData['refund_id'] as String),
            saleItemId: Value(itemData['sale_item_id'] as String),
            quantity: Value(itemData['quantity'] as double? ?? 1.0),
            amount: Value(itemData['amount'] as int),
            updatedAt: Value(DateTime.parse(itemData['updated_at'] as String).millisecondsSinceEpoch),
            synced: const Value(1), // Marqué comme synchronisé
          );

          await _localDb.refundDao.upsertRefundItem(companion);
        } catch (e) {
          developer.log('Failed to pull refund item ${itemData['id']}', name: 'SyncService', error: e);
          result.errors.add('RefundItem ${itemData['id']}: $e');
        }
      }
    } catch (e) {
      developer.log('Failed to pull refunds', name: 'SyncService', error: e);
      result.errors.add('Refunds: $e');
    }
  }

  /// Récupère les crédits depuis Supabase (credits + credit_payments)
  Future<void> _pullCredits(String storeId, SyncResult result) async {
    try {
      // 1. Pull credits
      final remoteCredits = await _supabase
          .from('credits')
          .select()
          .eq('store_id', storeId)
          .order('created_at', ascending: false);

      for (final creditData in remoteCredits) {
        try {
          final companion = CreditsCompanion(
            id: Value(creditData['id'] as String),
            storeId: Value(creditData['store_id'] as String),
            customerId: Value(creditData['customer_id'] as String),
            saleId: Value(creditData['sale_id'] as String?),
            amountTotal: Value(creditData['amount_total'] as int),
            amountPaid: Value(creditData['amount_paid'] as int? ?? 0),
            amountRemaining: Value(creditData['amount_remaining'] as int),
            dueDate: creditData['due_date'] != null
                ? Value(DateTime.parse(creditData['due_date'] as String).millisecondsSinceEpoch)
                : const Value(null),
            status: Value(creditData['status'] as String? ?? 'pending'),
            notes: Value(creditData['notes'] as String?),
            createdBy: Value(creditData['created_by'] as String?),
            createdAt: Value(DateTime.parse(creditData['created_at'] as String).millisecondsSinceEpoch),
            updatedAt: Value(DateTime.parse(creditData['updated_at'] as String).millisecondsSinceEpoch),
            synced: const Value(1), // Marqué comme synchronisé
          );

          await _localDb.creditDao.upsertCredit(companion);
        } catch (e) {
          developer.log('Failed to pull credit ${creditData['id']}', name: 'SyncService', error: e);
          result.errors.add('Credit ${creditData['id']}: $e');
        }
      }

      // 2. Pull credit_payments
      final remoteCreditPayments = await _supabase
          .from('credit_payments')
          .select('*, credits!inner(store_id)')
          .eq('credits.store_id', storeId)
          .order('created_at', ascending: false);

      for (final paymentData in remoteCreditPayments) {
        try {
          final companion = CreditPaymentsCompanion(
            id: Value(paymentData['id'] as String),
            creditId: Value(paymentData['credit_id'] as String),
            amount: Value(paymentData['amount'] as int),
            paymentType: Value(paymentData['payment_type'] as String? ?? 'cash'),
            notes: Value(paymentData['notes'] as String?),
            createdBy: Value(paymentData['created_by'] as String?),
            createdAt: Value(DateTime.parse(paymentData['created_at'] as String).millisecondsSinceEpoch),
            updatedAt: Value(DateTime.parse(paymentData['updated_at'] as String).millisecondsSinceEpoch),
            synced: const Value(1), // Marqué comme synchronisé
          );

          await _localDb.creditDao.upsertCreditPayment(companion);
        } catch (e) {
          developer.log('Failed to pull credit payment ${paymentData['id']}', name: 'SyncService', error: e);
          result.errors.add('CreditPayment ${paymentData['id']}: $e');
        }
      }
    } catch (e) {
      developer.log('Failed to pull credits', name: 'SyncService', error: e);
      result.errors.add('Credits: $e');
    }
  }

  /// Récupère les ajustements de stock depuis Supabase (stock_adjustments + stock_adjustment_items)
  Future<void> _pullStockAdjustments(String storeId, SyncResult result) async {
    try {
      // 1. Pull stock_adjustments
      final remoteAdjustments = await _supabase
          .from('stock_adjustments')
          .select()
          .eq('store_id', storeId)
          .order('created_at', ascending: false);

      for (final adjustmentData in remoteAdjustments) {
        try {
          final companion = StockAdjustmentsCompanion(
            id: Value(adjustmentData['id'] as String),
            storeId: Value(adjustmentData['store_id'] as String),
            reason: Value(adjustmentData['reason'] as int),
            notes: Value(adjustmentData['notes'] as String?),
            createdBy: Value(adjustmentData['created_by'] as String),
            createdAt: Value(DateTime.parse(adjustmentData['created_at'] as String).millisecondsSinceEpoch),
            updatedAt: Value(DateTime.parse(adjustmentData['updated_at'] as String).millisecondsSinceEpoch),
            synced: const Value(1), // Marqué comme synchronisé
          );

          await _localDb.stockAdjustmentDao.upsertStockAdjustment(companion);
        } catch (e) {
          developer.log('Failed to pull stock adjustment ${adjustmentData['id']}', name: 'SyncService', error: e);
          result.errors.add('StockAdjustment ${adjustmentData['id']}: $e');
        }
      }

      // 2. Pull stock_adjustment_items
      final remoteAdjustmentItems = await _supabase
          .from('stock_adjustment_items')
          .select('*, stock_adjustments!inner(store_id)')
          .eq('stock_adjustments.store_id', storeId)
          .order('adjustment_id');

      for (final itemData in remoteAdjustmentItems) {
        try {
          final companion = StockAdjustmentItemsCompanion(
            id: Value(itemData['id'] as String),
            adjustmentId: Value(itemData['adjustment_id'] as String),
            itemId: Value(itemData['item_id'] as String),
            itemVariantId: Value(itemData['item_variant_id'] as String?),
            quantityBefore: Value(itemData['quantity_before'] as double? ?? 0.0),
            quantityChange: Value(itemData['quantity_change'] as double? ?? 0.0),
            quantityAfter: Value(itemData['quantity_after'] as double? ?? 0.0),
            cost: Value(itemData['cost'] as int? ?? 0),
            createdAt: Value(DateTime.parse(itemData['created_at'] as String).millisecondsSinceEpoch),
            updatedAt: Value(DateTime.parse(itemData['updated_at'] as String).millisecondsSinceEpoch),
            synced: const Value(1), // Marqué comme synchronisé
          );

          await _localDb.stockAdjustmentDao.upsertStockAdjustmentItem(companion);
        } catch (e) {
          developer.log('Failed to pull stock adjustment item ${itemData['id']}', name: 'SyncService', error: e);
          result.errors.add('StockAdjustmentItem ${itemData['id']}: $e');
        }
      }
    } catch (e) {
      developer.log('Failed to pull stock adjustments', name: 'SyncService', error: e);
      result.errors.add('StockAdjustments: $e');
    }
  }

  /// Récupère les comptages d'inventaire depuis Supabase (inventory_counts + inventory_count_items)
  Future<void> _pullInventoryCounts(String storeId, SyncResult result) async {
    try {
      // 1. Pull inventory_counts
      final remoteCounts = await _supabase
          .from('inventory_counts')
          .select()
          .eq('store_id', storeId)
          .order('created_at', ascending: false);

      for (final countData in remoteCounts) {
        try {
          final companion = InventoryCountsCompanion(
            id: Value(countData['id'] as String),
            storeId: Value(countData['store_id'] as String),
            type: Value(countData['type'] as String? ?? 'full'),
            status: Value(countData['status'] as String? ?? 'pending'),
            notes: Value(countData['notes'] as String?),
            createdBy: Value(countData['created_by'] as String),
            createdAt: Value(DateTime.parse(countData['created_at'] as String).millisecondsSinceEpoch),
            completedAt: countData['completed_at'] != null
                ? Value(DateTime.parse(countData['completed_at'] as String).millisecondsSinceEpoch)
                : const Value(null),
            updatedAt: Value(DateTime.parse(countData['updated_at'] as String).millisecondsSinceEpoch),
            deletedAt: countData['deleted_at'] != null
                ? Value(DateTime.parse(countData['deleted_at'] as String).millisecondsSinceEpoch)
                : const Value(null),
            synced: const Value(1), // Marqué comme synchronisé
          );

          await _localDb.inventoryCountDao.upsertInventoryCount(companion);
        } catch (e) {
          developer.log('Failed to pull inventory count ${countData['id']}', name: 'SyncService', error: e);
          result.errors.add('InventoryCount ${countData['id']}: $e');
        }
      }

      // 2. Pull inventory_count_items
      final remoteCountItems = await _supabase
          .from('inventory_count_items')
          .select('*, inventory_counts!inner(store_id)')
          .eq('inventory_counts.store_id', storeId)
          .order('count_id');

      for (final itemData in remoteCountItems) {
        try {
          final companion = InventoryCountItemsCompanion(
            id: Value(itemData['id'] as String),
            countId: Value(itemData['count_id'] as String),
            itemId: Value(itemData['item_id'] as String),
            itemVariantId: Value(itemData['item_variant_id'] as String?),
            itemName: Value(itemData['item_name'] as String),
            expectedStock: Value(itemData['expected_stock'] as double? ?? 0.0),
            countedStock: Value(itemData['counted_stock'] as double?),
            difference: Value(itemData['difference'] as double? ?? 0.0),
            updatedAt: Value(DateTime.parse(itemData['updated_at'] as String).millisecondsSinceEpoch),
            synced: const Value(1), // Marqué comme synchronisé
          );

          await _localDb.inventoryCountDao.upsertInventoryCountItem(companion);
        } catch (e) {
          developer.log('Failed to pull inventory count item ${itemData['id']}', name: 'SyncService', error: e);
          result.errors.add('InventoryCountItem ${itemData['id']}: $e');
        }
      }
    } catch (e) {
      developer.log('Failed to pull inventory counts', name: 'SyncService', error: e);
      result.errors.add('InventoryCounts: $e');
    }
  }

  /// Récupère l'historique d'inventaire depuis Supabase
  Future<void> _pullInventoryHistory(String storeId, SyncResult result) async {
    try {
      final remoteHistory = await _supabase
          .from('inventory_history')
          .select()
          .eq('store_id', storeId)
          .order('created_at', ascending: false);

      for (final historyData in remoteHistory) {
        try {
          final companion = InventoryHistoryCompanion(
            id: Value(historyData['id'] as String),
            storeId: Value(historyData['store_id'] as String),
            itemId: Value(historyData['item_id'] as String),
            itemVariantId: Value(historyData['item_variant_id'] as String?),
            reason: Value(historyData['reason'] as int),
            referenceId: Value(historyData['reference_id'] as String?),
            quantityChange: Value(historyData['quantity_change'] as double? ?? 0.0),
            quantityAfter: Value(historyData['quantity_after'] as double? ?? 0.0),
            cost: Value(historyData['cost'] as int? ?? 0),
            employeeId: Value(historyData['employee_id'] as String?),
            createdAt: Value(DateTime.parse(historyData['created_at'] as String).millisecondsSinceEpoch),
            synced: const Value(1), // Marqué comme synchronisé
          );

          await _localDb.inventoryHistoryDao.upsertInventoryHistory(companion);
        } catch (e) {
          developer.log('Failed to pull inventory history ${historyData['id']}', name: 'SyncService', error: e);
          result.errors.add('InventoryHistory ${historyData['id']}: $e');
        }
      }
    } catch (e) {
      developer.log('Failed to pull inventory history', name: 'SyncService', error: e);
      result.errors.add('InventoryHistory: $e');
    }
  }

  /// Récupère les shifts depuis Supabase (shifts + cash_movements optionnel)
  Future<void> _pullShifts(String storeId, SyncResult result) async {
    try {
      // 1. Pull shifts
      final remoteShifts = await _supabase
          .from('shifts')
          .select()
          .eq('store_id', storeId)
          .order('opened_at', ascending: false);

      for (final shiftData in remoteShifts) {
        try {
          final companion = ShiftsCompanion(
            id: Value(shiftData['id'] as String),
            storeId: Value(shiftData['store_id'] as String),
            posDeviceId: Value(shiftData['pos_device_id'] as String?),
            employeeId: Value(shiftData['employee_id'] as String?),
            openedAt: Value(DateTime.parse(shiftData['opened_at'] as String).millisecondsSinceEpoch),
            closedAt: shiftData['closed_at'] != null
                ? Value(DateTime.parse(shiftData['closed_at'] as String).millisecondsSinceEpoch)
                : const Value(null),
            openingCash: Value(shiftData['opening_cash'] as int? ?? 0),
            expectedCash: Value(shiftData['expected_cash'] as int? ?? 0),
            actualCash: Value(shiftData['actual_cash'] as int? ?? 0),
            cashDifference: Value(shiftData['cash_difference'] as int? ?? 0),
            status: Value(shiftData['status'] as String? ?? 'open'),
            updatedAt: Value(DateTime.parse(shiftData['updated_at'] as String).millisecondsSinceEpoch),
            synced: const Value(1), // Marqué comme synchronisé
          );

          await _localDb.shiftDao.upsertShift(companion);
        } catch (e) {
          developer.log('Failed to pull shift ${shiftData['id']}', name: 'SyncService', error: e);
          result.errors.add('Shift ${shiftData['id']}: $e');
        }
      }

      // 2. Pull cash_movements
      final remoteCashMovements = await _supabase
          .from('cash_movements')
          .select('*, shifts!inner(store_id)')
          .eq('shifts.store_id', storeId)
          .order('created_at', ascending: false);

      for (final movementData in remoteCashMovements) {
        try {
          final companion = CashMovementsCompanion(
            id: Value(movementData['id'] as String),
            shiftId: Value(movementData['shift_id'] as String),
            storeId: Value(movementData['store_id'] as String),
            type: Value(movementData['type'] as String),
            amount: Value(movementData['amount'] as int),
            note: Value(movementData['note'] as String?),
            employeeId: Value(movementData['employee_id'] as String?),
            createdAt: Value(DateTime.parse(movementData['created_at'] as String).millisecondsSinceEpoch),
            updatedAt: Value(DateTime.parse(movementData['updated_at'] as String).millisecondsSinceEpoch),
            synced: const Value(1), // Marqué comme synchronisé
          );

          await _localDb.shiftDao.upsertCashMovement(companion);
        } catch (e) {
          developer.log('Failed to pull cash movement ${movementData['id']}', name: 'SyncService', error: e);
          result.errors.add('CashMovement ${movementData['id']}: $e');
        }
      }
    } catch (e) {
      developer.log('Failed to pull shifts', name: 'SyncService', error: e);
      result.errors.add('Shifts: $e');
    }
  }

  /// Récupère les tickets ouverts depuis Supabase
  Future<void> _pullOpenTickets(String storeId, SyncResult result) async {
    try {
      final remoteTickets = await _supabase
          .from('open_tickets')
          .select()
          .eq('store_id', storeId)
          .order('created_at', ascending: false);

      for (final ticketData in remoteTickets) {
        try {
          final companion = OpenTicketsCompanion(
            id: Value(ticketData['id'] as String),
            storeId: Value(ticketData['store_id'] as String),
            posDeviceId: Value(ticketData['pos_device_id'] as String?),
            name: Value(ticketData['name'] as String? ?? 'Ticket'),
            comment: Value(ticketData['comment'] as String?),
            employeeId: Value(ticketData['employee_id'] as String?),
            isPredefined: Value(ticketData['is_predefined'] as int? ?? 0),
            diningOptionId: Value(ticketData['dining_option_id'] as String?),
            items: Value(ticketData['items'] as String? ?? '[]'),
            createdAt: Value(DateTime.parse(ticketData['created_at'] as String).millisecondsSinceEpoch),
            updatedAt: Value(DateTime.parse(ticketData['updated_at'] as String).millisecondsSinceEpoch),
            synced: const Value(1), // Marqué comme synchronisé
          );

          await _localDb.openTicketDao.upsertOpenTicket(companion);
        } catch (e) {
          developer.log('Failed to pull open ticket ${ticketData['id']}', name: 'SyncService', error: e);
          result.errors.add('OpenTicket ${ticketData['name']}: $e');
        }
      }
    } catch (e) {
      developer.log('Failed to pull open tickets', name: 'SyncService', error: e);
      result.errors.add('OpenTickets: $e');
    }
  }

  /// Récupère les pages personnalisées depuis Supabase (custom_pages + custom_page_items + custom_page_category_grids)
  Future<void> _pullCustomPages(String storeId, SyncResult result) async {
    try {
      // 1. Pull custom_product_pages
      final remotePages = await _supabase
          .from('custom_product_pages')
          .select()
          .eq('store_id', storeId)
          .order('sort_order');

      for (final pageData in remotePages) {
        try {
          final companion = CustomProductPagesCompanion(
            id: Value(pageData['id'] as String),
            storeId: Value(pageData['store_id'] as String),
            name: Value(pageData['name'] as String),
            sortOrder: Value(pageData['sort_order'] as int? ?? 0),
            isDefault: Value(pageData['is_default'] as int? ?? 0),
            createdBy: Value(pageData['created_by'] as String?),
            createdAt: Value(DateTime.parse(pageData['created_at'] as String).millisecondsSinceEpoch),
            updatedAt: Value(DateTime.parse(pageData['updated_at'] as String).millisecondsSinceEpoch),
            synced: const Value(1), // Marqué comme synchronisé
          );

          await _localDb.customPageDao.upsertCustomPage(companion);
        } catch (e) {
          developer.log('Failed to pull custom page ${pageData['id']}', name: 'SyncService', error: e);
          result.errors.add('CustomPage ${pageData['name']}: $e');
        }
      }

      // 2. Pull custom_page_items
      final remotePageItems = await _supabase
          .from('custom_page_items')
          .select('*, custom_product_pages!inner(store_id)')
          .eq('custom_product_pages.store_id', storeId)
          .order('page_id')
          .order('position');

      for (final itemData in remotePageItems) {
        try {
          final companion = CustomPageItemsCompanion(
            id: Value(itemData['id'] as String),
            pageId: Value(itemData['page_id'] as String),
            itemId: Value(itemData['item_id'] as String),
            position: Value(itemData['position'] as int? ?? 0),
            createdAt: Value(DateTime.parse(itemData['created_at'] as String).millisecondsSinceEpoch),
            updatedAt: Value(DateTime.parse(itemData['updated_at'] as String).millisecondsSinceEpoch),
            synced: const Value(1), // Marqué comme synchronisé
          );

          await _localDb.customPageDao.upsertCustomPageItem(companion);
        } catch (e) {
          developer.log('Failed to pull custom page item ${itemData['id']}', name: 'SyncService', error: e);
          result.errors.add('CustomPageItem ${itemData['id']}: $e');
        }
      }

      // 3. Pull custom_page_category_grids
      final remotePageGrids = await _supabase
          .from('custom_page_category_grids')
          .select('*, custom_product_pages!inner(store_id)')
          .eq('custom_product_pages.store_id', storeId)
          .order('page_id')
          .order('position');

      for (final gridData in remotePageGrids) {
        try {
          final companion = CustomPageCategoryGridsCompanion(
            id: Value(gridData['id'] as String),
            pageId: Value(gridData['page_id'] as String),
            categoryId: Value(gridData['category_id'] as String),
            position: Value(gridData['position'] as int? ?? 0),
            createdAt: Value(DateTime.parse(gridData['created_at'] as String).millisecondsSinceEpoch),
            updatedAt: Value(DateTime.parse(gridData['updated_at'] as String).millisecondsSinceEpoch),
            synced: const Value(1), // Marqué comme synchronisé
          );

          await _localDb.customPageDao.upsertCustomPageCategoryGrid(companion);
        } catch (e) {
          developer.log('Failed to pull custom page category grid ${gridData['id']}', name: 'SyncService', error: e);
          result.errors.add('CustomPageCategoryGrid ${gridData['id']}: $e');
        }
      }
    } catch (e) {
      developer.log('Failed to pull custom pages', name: 'SyncService', error: e);
      result.errors.add('CustomPages: $e');
    }
  }
  /// Subscribe to real-time changes from Supabase
  ///
  /// TODO: Implémenter les subscriptions Realtime pour sync bidirectionnelle
  Future<void> subscribeToChanges(String storeId) async {
    throw UnimplementedError('Realtime subscriptions not yet implemented');
  }

  /// Force immediate synchronization (bypasses throttling)
  ///
  /// Use this after critical operations (product creation, customer creation, etc.)
  /// to ensure data is backed up to Supabase immediately.
  Future<SyncResult> forceSyncNow() async {
    developer.log('Force sync requested', name: 'SyncService');
    return syncToRemote(force: true);
  }
}

/// Résultat d'une synchronisation
class SyncResult {
  int storesSynced = 0;
  int usersSynced = 0;
  int settingsSynced = 0;
  int categoriesSynced = 0;
  int itemsSynced = 0;
  int customersSynced = 0;
  List<String> errors = [];
  bool skipped = false;

  int get totalSynced =>
      storesSynced + usersSynced + settingsSynced + categoriesSynced + itemsSynced + customersSynced;

  bool get hasErrors => errors.isNotEmpty;

  bool get isSuccess => totalSynced > 0 && !hasErrors;

  String get summary => skipped
      ? 'Sync skipped (no connection)'
      : 'Synced $totalSynced records (stores: $storesSynced, users: $usersSynced, '
        'settings: $settingsSynced, categories: $categoriesSynced, items: $itemsSynced, '
        'customers: $customersSynced) '
        '${hasErrors ? "with ${errors.length} errors" : "successfully"}';
}

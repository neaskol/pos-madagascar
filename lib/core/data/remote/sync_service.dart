import 'package:supabase_flutter/supabase_flutter.dart';
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

  SyncService(this._localDb, this._supabase);

  /// Sync all unsynced local changes to Supabase
  ///
  /// This method pushes all records marked as `synced: false` to Supabase.
  /// On success, marks them as `synced: true` locally.
  /// On error, logs but doesn't throw (offline resilience).
  Future<SyncResult> syncToRemote() async {
    final result = SyncResult();

    try {
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
  /// TODO: Implémenter quand on aura besoin du téléchargement initial
  Future<void> syncFromRemote(String storeId) async {
    throw UnimplementedError('Pull sync not yet implemented - will be needed for initial data load');
  }

  /// Subscribe to real-time changes from Supabase
  ///
  /// TODO: Implémenter les subscriptions Realtime pour sync bidirectionnelle
  Future<void> subscribeToChanges(String storeId) async {
    throw UnimplementedError('Realtime subscriptions not yet implemented');
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

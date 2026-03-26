import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart';
import '../../../../core/data/local/app_database.dart';
import '../../domain/entities/inventory_count.dart' as entity;
import '../../domain/entities/inventory_count_item.dart' as entity;

/// Repository for inventory counts with offline-first pattern
class InventoryCountRepository {
  final AppDatabase database;
  final _uuid = const Uuid();

  InventoryCountRepository(this.database);

  // ===== INVENTORY COUNTS =====

  /// Watch all inventory counts for a store
  Stream<List<entity.InventoryCount>> watchInventoryCounts(String storeId) {
    return database.inventoryCountDao
        .watchInventoryCounts(storeId)
        .map((list) => list.map(_mapToEntity).toList());
  }

  /// Watch inventory counts by status
  Stream<List<entity.InventoryCount>> watchInventoryCountsByStatus(
    String storeId,
    String status,
  ) {
    return database.inventoryCountDao
        .watchInventoryCountsByStatus(storeId, status)
        .map((list) => list.map(_mapToEntity).toList());
  }

  /// Watch single inventory count
  Stream<entity.InventoryCount?> watchInventoryCount(String countId) {
    return database.inventoryCountDao
        .watchInventoryCount(countId)
        .map((count) => count != null ? _mapToEntity(count) : null);
  }

  /// Get inventory count (future)
  Future<entity.InventoryCount?> getInventoryCount(String countId) async {
    final count = await database.inventoryCountDao.getInventoryCount(countId);
    return count != null ? _mapToEntity(count) : null;
  }

  /// Create new inventory count
  Future<entity.InventoryCount> createInventoryCount({
    required String storeId,
    required String type, // 'full' or 'partial'
    required String createdBy,
    String? notes,
  }) async {
    final count = await database.inventoryCountDao.createInventoryCount(
      storeId: storeId,
      type: type,
      createdBy: createdBy,
      notes: notes,
    );

    return _mapToEntity(count);
  }

  /// Update status
  Future<void> updateStatus(String countId, String status) async {
    await database.inventoryCountDao.updateInventoryCountStatus(countId, status);
  }

  /// Update notes
  Future<void> updateNotes(String countId, String? notes) async {
    await database.inventoryCountDao.updateInventoryCountNotes(countId, notes);
  }

  /// Delete inventory count
  Future<void> deleteInventoryCount(String countId) async {
    await database.inventoryCountDao.deleteInventoryCount(countId);
  }

  /// Complete inventory count
  Future<void> completeInventoryCount(String countId) async {
    await database.inventoryCountDao.completeInventoryCount(countId);
  }

  // ===== INVENTORY COUNT ITEMS =====

  /// Watch items for a count
  Stream<List<entity.InventoryCountItem>> watchInventoryCountItems(
    String countId,
  ) {
    return database.inventoryCountDao
        .watchInventoryCountItems(countId)
        .map((list) => list.map(_mapItemToEntity).toList());
  }

  /// Get count items (future)
  Future<List<entity.InventoryCountItem>> getInventoryCountItems(
    String countId,
  ) async {
    final items =
        await database.inventoryCountDao.getInventoryCountItems(countId);
    return items.map(_mapItemToEntity).toList();
  }

  /// Add item to count
  Future<entity.InventoryCountItem> addInventoryCountItem({
    required String countId,
    required String itemId,
    String? itemVariantId,
    required String itemName,
    required double expectedStock,
    double? countedStock,
  }) async {
    final item = await database.inventoryCountDao.addInventoryCountItem(
      countId: countId,
      itemId: itemId,
      itemVariantId: itemVariantId,
      itemName: itemName,
      expectedStock: expectedStock,
      countedStock: countedStock,
    );

    return _mapItemToEntity(item);
  }

  /// Update counted stock
  Future<void> updateCountedStock({
    required String itemId,
    required double countedStock,
  }) async {
    await database.inventoryCountDao.updateCountedStock(
      itemId: itemId,
      countedStock: countedStock,
    );
  }

  /// Remove item from count
  Future<void> removeInventoryCountItem(String itemId) async {
    await database.inventoryCountDao.removeInventoryCountItem(itemId);
  }

  /// Get summary
  Future<InventoryCountSummary> getSummary(String countId) async {
    return database.inventoryCountDao.getInventoryCountSummary(countId);
  }

  // ===== MAPPING =====

  entity.InventoryCount _mapToEntity(InventoryCount count) {
    return entity.InventoryCount(
      id: count.id,
      storeId: count.storeId,
      type: count.type,
      status: count.status,
      notes: count.notes,
      createdBy: count.createdBy,
      createdAt: DateTime.fromMillisecondsSinceEpoch(count.createdAt),
      completedAt: count.completedAt != null
          ? DateTime.fromMillisecondsSinceEpoch(count.completedAt!)
          : null,
      synced: count.synced == 1,
    );
  }

  entity.InventoryCountItem _mapItemToEntity(InventoryCountItem item) {
    return entity.InventoryCountItem(
      id: item.id,
      countId: item.countId,
      itemId: item.itemId,
      itemVariantId: item.itemVariantId,
      itemName: item.itemName,
      expectedStock: item.expectedStock,
      countedStock: item.countedStock,
      difference: item.difference,
    );
  }
}

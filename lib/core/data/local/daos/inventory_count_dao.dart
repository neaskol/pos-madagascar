import 'package:drift/drift.dart';
import '../app_database.dart';

part 'inventory_count_dao.g.dart';

@DriftAccessor(include: {
  '../tables/inventory_counts.drift',
  '../tables/inventory_count_items.drift',
})
class InventoryCountDao extends DatabaseAccessor<AppDatabase>
    with _$InventoryCountDaoMixin {
  InventoryCountDao(super.db);

  // ===== INVENTORY COUNTS =====

  /// Get all inventory counts for a store
  Stream<List<InventoryCount>> watchInventoryCounts(String storeId) {
    return (select(inventoryCounts)
          ..where((t) => t.storeId.equals(storeId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  /// Get inventory counts by status
  Stream<List<InventoryCount>> watchInventoryCountsByStatus(
    String storeId,
    String status,
  ) {
    return (select(inventoryCounts)
          ..where((t) => t.storeId.equals(storeId) & t.status.equals(status))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  /// Get a single inventory count by ID
  Stream<InventoryCount?> watchInventoryCount(String countId) {
    return (select(inventoryCounts)..where((t) => t.id.equals(countId)))
        .watchSingleOrNull();
  }

  /// Get a single inventory count by ID (future)
  Future<InventoryCount?> getInventoryCount(String countId) {
    return (select(inventoryCounts)..where((t) => t.id.equals(countId)))
        .getSingleOrNull();
  }

  /// Create a new inventory count
  Future<InventoryCount> createInventoryCount({
    required String storeId,
    required String type, // 'full' or 'partial'
    required String createdBy,
    String? notes,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    final companion = InventoryCountsCompanion.insert(
      storeId: storeId,
      type: Value(type),
      status: const Value('pending'),
      notes: Value(notes),
      createdBy: createdBy,
      createdAt: Value(now),
      updatedAt: Value(now),
    );

    await into(inventoryCounts).insert(companion);

    // Get the last inserted count (newest by created_at)
    final result = await (select(inventoryCounts)
      ..where((t) => t.storeId.equals(storeId))
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
      ..limit(1)
    ).getSingle();

    return result;
  }

  /// Update inventory count status
  Future<void> updateInventoryCountStatus(
    String countId,
    String status, // 'pending', 'in_progress', 'completed'
  ) async {
    await (update(inventoryCounts)..where((t) => t.id.equals(countId))).write(
      InventoryCountsCompanion(
        status: Value(status),
        completedAt: status == 'completed'
            ? Value(DateTime.now().millisecondsSinceEpoch)
            : const Value(null),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
        synced: const Value(0),
      ),
    );
  }

  /// Update inventory count notes
  Future<void> updateInventoryCountNotes(String countId, String? notes) async {
    await (update(inventoryCounts)..where((t) => t.id.equals(countId))).write(
      InventoryCountsCompanion(
        notes: Value(notes),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
        synced: const Value(0),
      ),
    );
  }

  /// Delete inventory count (soft delete)
  Future<void> deleteInventoryCount(String countId) async {
    await (update(inventoryCounts)..where((t) => t.id.equals(countId))).write(
      InventoryCountsCompanion(
        deletedAt: Value(DateTime.now().millisecondsSinceEpoch),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
        synced: const Value(0),
      ),
    );
  }

  // ===== INVENTORY COUNT ITEMS =====

  /// Watch all items for a specific count
  Stream<List<InventoryCountItem>> watchInventoryCountItems(String countId) {
    return (select(inventoryCountItems)
          ..where((t) => t.countId.equals(countId))
          ..orderBy([
            (t) => OrderingTerm(
                  expression: t.itemName,
                  mode: OrderingMode.asc,
                )
          ]))
        .watch();
  }

  /// Get inventory count items (future)
  Future<List<InventoryCountItem>> getInventoryCountItems(String countId) {
    return (select(inventoryCountItems)
          ..where((t) => t.countId.equals(countId)))
        .get();
  }

  /// Get single inventory count item
  Future<InventoryCountItem?> getInventoryCountItem(String itemId) {
    return (select(inventoryCountItems)..where((t) => t.id.equals(itemId)))
        .getSingleOrNull();
  }

  /// Add item to inventory count
  Future<InventoryCountItem> addInventoryCountItem({
    required String countId,
    required String itemId,
    String? itemVariantId,
    required String itemName,
    required double expectedStock,
    double? countedStock,
  }) async {
    final difference = (countedStock ?? 0) - expectedStock;
    final now = DateTime.now().millisecondsSinceEpoch;

    final companion = InventoryCountItemsCompanion.insert(
      countId: countId,
      itemId: itemId,
      itemVariantId: Value(itemVariantId),
      itemName: itemName,
      expectedStock: expectedStock,
      countedStock: Value(countedStock),
      difference: Value(difference),
      updatedAt: Value(now),
    );

    await into(inventoryCountItems).insert(companion);

    // Get the last inserted item (newest by updated_at)
    final result = await (select(inventoryCountItems)
      ..where((t) => t.countId.equals(countId))
      ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)])
      ..limit(1)
    ).getSingle();

    return result;
  }

  /// Update counted stock for an item
  Future<void> updateCountedStock({
    required String itemId,
    required double countedStock,
  }) async {
    // Get current item to recalculate difference
    final item = await getInventoryCountItem(itemId);
    if (item == null) return;

    final difference = countedStock - item.expectedStock;

    await (update(inventoryCountItems)..where((t) => t.id.equals(itemId)))
        .write(
      InventoryCountItemsCompanion(
        countedStock: Value(countedStock),
        difference: Value(difference),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
        synced: const Value(0),
      ),
    );
  }

  /// Remove item from inventory count
  Future<void> removeInventoryCountItem(String itemId) async {
    await (delete(inventoryCountItems)..where((t) => t.id.equals(itemId))).go();
  }

  /// Get inventory count summary (total items, counted items, discrepancies)
  Future<InventoryCountSummary> getInventoryCountSummary(String countId) async {
    final items = await getInventoryCountItems(countId);

    final totalItems = items.length;
    final countedItems =
        items.where((item) => item.countedStock != null).length;
    final discrepancies = items.where((item) {
      if (item.countedStock == null) return false;
      return item.difference.abs() > 0.0001; // floating point tolerance
    }).length;

    final totalDifference = items.fold<double>(
      0,
      (sum, item) => sum + item.difference,
    );

    return InventoryCountSummary(
      totalItems: totalItems,
      countedItems: countedItems,
      discrepancies: discrepancies,
      totalDifference: totalDifference,
    );
  }

  /// Complete inventory count (mark as completed)
  Future<void> completeInventoryCount(String countId) async {
    await updateInventoryCountStatus(countId, 'completed');
  }

  /// Mark inventory count as synced
  Future<void> markInventoryCountSynced(String countId) async {
    await (update(inventoryCounts)..where((t) => t.id.equals(countId))).write(
      const InventoryCountsCompanion(synced: Value(1)),
    );

    // Mark all items as synced too
    await (update(inventoryCountItems)..where((t) => t.countId.equals(countId)))
        .write(
      const InventoryCountItemsCompanion(synced: Value(1)),
    );
  }
}

/// Summary data for inventory count
class InventoryCountSummary {
  final int totalItems;
  final int countedItems;
  final int discrepancies;
  final double totalDifference;

  InventoryCountSummary({
    required this.totalItems,
    required this.countedItems,
    required this.discrepancies,
    required this.totalDifference,
  });

  int get remainingItems => totalItems - countedItems;
  double get completionPercentage =>
      totalItems > 0 ? (countedItems / totalItems) * 100 : 0;
}

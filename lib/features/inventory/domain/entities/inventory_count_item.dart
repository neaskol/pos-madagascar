class InventoryCountItem {
  final String id;
  final String countId;
  final String itemId;
  final String? itemVariantId;
  final String itemName;
  final double expectedStock;
  final double? countedStock;
  final double difference;

  InventoryCountItem({
    required this.id,
    required this.countId,
    required this.itemId,
    this.itemVariantId,
    required this.itemName,
    required this.expectedStock,
    this.countedStock,
    required this.difference,
  });

  bool get isCounted => countedStock != null;
  bool get hasDiscrepancy => difference.abs() > 0.0001;

  InventoryCountItem copyWith({
    String? id,
    String? countId,
    String? itemId,
    String? itemVariantId,
    String? itemName,
    double? expectedStock,
    double? countedStock,
    double? difference,
  }) {
    return InventoryCountItem(
      id: id ?? this.id,
      countId: countId ?? this.countId,
      itemId: itemId ?? this.itemId,
      itemVariantId: itemVariantId ?? this.itemVariantId,
      itemName: itemName ?? this.itemName,
      expectedStock: expectedStock ?? this.expectedStock,
      countedStock: countedStock ?? this.countedStock,
      difference: difference ?? this.difference,
    );
  }
}

class InventoryCount {
  final String id;
  final String storeId;
  final String type; // 'full' or 'partial'
  final String status; // 'pending', 'in_progress', 'completed'
  final String? notes;
  final String createdBy;
  final DateTime createdAt;
  final DateTime? completedAt;
  final bool synced;

  InventoryCount({
    required this.id,
    required this.storeId,
    required this.type,
    required this.status,
    this.notes,
    required this.createdBy,
    required this.createdAt,
    this.completedAt,
    required this.synced,
  });

  InventoryCount copyWith({
    String? id,
    String? storeId,
    String? type,
    String? status,
    String? notes,
    String? createdBy,
    DateTime? createdAt,
    DateTime? completedAt,
    bool? synced,
  }) {
    return InventoryCount(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      type: type ?? this.type,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      synced: synced ?? this.synced,
    );
  }
}

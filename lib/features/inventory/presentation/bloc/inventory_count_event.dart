import 'package:equatable/equatable.dart';

abstract class InventoryCountEvent extends Equatable {
  const InventoryCountEvent();

  @override
  List<Object?> get props => [];
}

/// Load all inventory counts for a store
class LoadInventoryCounts extends InventoryCountEvent {
  final String storeId;

  const LoadInventoryCounts(this.storeId);

  @override
  List<Object> get props => [storeId];
}

/// Load counts by status
class LoadInventoryCountsByStatus extends InventoryCountEvent {
  final String storeId;
  final String status;

  const LoadInventoryCountsByStatus(this.storeId, this.status);

  @override
  List<Object> get props => [storeId, status];
}

/// Load single count details
class LoadInventoryCountDetails extends InventoryCountEvent {
  final String countId;

  const LoadInventoryCountDetails(this.countId);

  @override
  List<Object> get props => [countId];
}

/// Create new inventory count
class CreateInventoryCount extends InventoryCountEvent {
  final String storeId;
  final String type; // 'full' or 'partial'
  final String createdBy;
  final String? notes;

  const CreateInventoryCount({
    required this.storeId,
    required this.type,
    required this.createdBy,
    this.notes,
  });

  @override
  List<Object?> get props => [storeId, type, createdBy, notes];
}

/// Update count status
class UpdateInventoryCountStatus extends InventoryCountEvent {
  final String countId;
  final String status;

  const UpdateInventoryCountStatus(this.countId, this.status);

  @override
  List<Object> get props => [countId, status];
}

/// Update count notes
class UpdateInventoryCountNotes extends InventoryCountEvent {
  final String countId;
  final String? notes;

  const UpdateInventoryCountNotes(this.countId, this.notes);

  @override
  List<Object?> get props => [countId, notes];
}

/// Add item to count
class AddInventoryCountItem extends InventoryCountEvent {
  final String countId;
  final String itemId;
  final String? itemVariantId;
  final String itemName;
  final double expectedStock;

  const AddInventoryCountItem({
    required this.countId,
    required this.itemId,
    this.itemVariantId,
    required this.itemName,
    required this.expectedStock,
  });

  @override
  List<Object?> get props => [countId, itemId, itemVariantId, itemName, expectedStock];
}

/// Update counted stock
class UpdateCountedStock extends InventoryCountEvent {
  final String itemId;
  final double countedStock;

  const UpdateCountedStock(this.itemId, this.countedStock);

  @override
  List<Object> get props => [itemId, countedStock];
}

/// Remove item from count
class RemoveInventoryCountItem extends InventoryCountEvent {
  final String itemId;

  const RemoveInventoryCountItem(this.itemId);

  @override
  List<Object> get props => [itemId];
}

/// Complete inventory count
class CompleteInventoryCount extends InventoryCountEvent {
  final String countId;

  const CompleteInventoryCount(this.countId);

  @override
  List<Object> get props => [countId];
}

/// Delete inventory count
class DeleteInventoryCount extends InventoryCountEvent {
  final String countId;

  const DeleteInventoryCount(this.countId);

  @override
  List<Object> get props => [countId];
}

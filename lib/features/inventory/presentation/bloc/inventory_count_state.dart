import 'package:equatable/equatable.dart';
import '../../../../core/data/local/app_database.dart';
import '../../domain/entities/inventory_count.dart';
import '../../domain/entities/inventory_count_item.dart';

abstract class InventoryCountState extends Equatable {
  const InventoryCountState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class InventoryCountInitial extends InventoryCountState {}

/// Loading state
class InventoryCountLoading extends InventoryCountState {}

/// Counts loaded successfully
class InventoryCountsLoaded extends InventoryCountState {
  final List<InventoryCount> counts;

  const InventoryCountsLoaded(this.counts);

  @override
  List<Object> get props => [counts];
}

/// Count details loaded
class InventoryCountDetailsLoaded extends InventoryCountState {
  final InventoryCount count;
  final List<InventoryCountItem> items;
  final InventoryCountSummary summary;

  const InventoryCountDetailsLoaded({
    required this.count,
    required this.items,
    required this.summary,
  });

  @override
  List<Object> get props => [count, items, summary];

  InventoryCountDetailsLoaded copyWith({
    InventoryCount? count,
    List<InventoryCountItem>? items,
    InventoryCountSummary? summary,
  }) {
    return InventoryCountDetailsLoaded(
      count: count ?? this.count,
      items: items ?? this.items,
      summary: summary ?? this.summary,
    );
  }
}

/// Count created successfully
class InventoryCountCreated extends InventoryCountState {
  final InventoryCount count;

  const InventoryCountCreated(this.count);

  @override
  List<Object> get props => [count];
}

/// Item added to count
class InventoryCountItemAdded extends InventoryCountState {
  final InventoryCountItem item;

  const InventoryCountItemAdded(this.item);

  @override
  List<Object> get props => [item];
}

/// Stock updated
class CountedStockUpdated extends InventoryCountState {
  final String itemId;
  final double countedStock;

  const CountedStockUpdated(this.itemId, this.countedStock);

  @override
  List<Object> get props => [itemId, countedStock];
}

/// Count completed
class InventoryCountCompleted extends InventoryCountState {
  final String countId;

  const InventoryCountCompleted(this.countId);

  @override
  List<Object> get props => [countId];
}

/// Error state
class InventoryCountError extends InventoryCountState {
  final String message;

  const InventoryCountError(this.message);

  @override
  List<Object> get props => [message];
}

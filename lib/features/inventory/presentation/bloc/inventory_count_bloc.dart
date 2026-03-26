import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/data/local/app_database.dart';
import '../../data/repositories/inventory_count_repository.dart';
import '../../domain/entities/inventory_count.dart';
import '../../domain/entities/inventory_count_item.dart';
import 'inventory_count_event.dart';
import 'inventory_count_state.dart';

class InventoryCountBloc
    extends Bloc<InventoryCountEvent, InventoryCountState> {
  final InventoryCountRepository repository;
  StreamSubscription? _countsSubscription;
  StreamSubscription? _detailsSubscription;

  InventoryCountBloc(this.repository) : super(InventoryCountInitial()) {
    on<LoadInventoryCounts>(_onLoadInventoryCounts);
    on<LoadInventoryCountsByStatus>(_onLoadInventoryCountsByStatus);
    on<LoadInventoryCountDetails>(_onLoadInventoryCountDetails);
    on<CreateInventoryCount>(_onCreateInventoryCount);
    on<UpdateInventoryCountStatus>(_onUpdateInventoryCountStatus);
    on<UpdateInventoryCountNotes>(_onUpdateInventoryCountNotes);
    on<AddInventoryCountItem>(_onAddInventoryCountItem);
    on<UpdateCountedStock>(_onUpdateCountedStock);
    on<RemoveInventoryCountItem>(_onRemoveInventoryCountItem);
    on<CompleteInventoryCount>(_onCompleteInventoryCount);
    on<DeleteInventoryCount>(_onDeleteInventoryCount);
    on<_InventoryCountsUpdated>(_onInternalCountsUpdated);
    on<_InventoryCountDetailsUpdated>(_onInternalDetailsUpdated);
  }

  Future<void> _onLoadInventoryCounts(
    LoadInventoryCounts event,
    Emitter<InventoryCountState> emit,
  ) async {
    emit(InventoryCountLoading());
    await _countsSubscription?.cancel();

    _countsSubscription = repository
        .watchInventoryCounts(event.storeId)
        .listen((counts) {
      add(_InventoryCountsUpdated(counts));
    });
  }

  Future<void> _onLoadInventoryCountsByStatus(
    LoadInventoryCountsByStatus event,
    Emitter<InventoryCountState> emit,
  ) async {
    emit(InventoryCountLoading());
    await _countsSubscription?.cancel();

    _countsSubscription = repository
        .watchInventoryCountsByStatus(event.storeId, event.status)
        .listen((counts) {
      add(_InventoryCountsUpdated(counts));
    });
  }

  Future<void> _onLoadInventoryCountDetails(
    LoadInventoryCountDetails event,
    Emitter<InventoryCountState> emit,
  ) async {
    emit(InventoryCountLoading());
    await _detailsSubscription?.cancel();

    try {
      // Watch both count and items
      _detailsSubscription = repository
          .watchInventoryCount(event.countId)
          .asyncMap((count) async {
        if (count == null) return null;

        final items = await repository.getInventoryCountItems(event.countId);
        final summary = await repository.getSummary(event.countId);

        return _InventoryCountDetailsData(
          count: count,
          items: items,
          summary: summary,
        );
      }).listen((data) {
        if (data != null) {
          add(_InventoryCountDetailsUpdated(data));
        }
      });
    } catch (e) {
      emit(InventoryCountError('Failed to load count details: $e'));
    }
  }

  Future<void> _onCreateInventoryCount(
    CreateInventoryCount event,
    Emitter<InventoryCountState> emit,
  ) async {
    try {
      final count = await repository.createInventoryCount(
        storeId: event.storeId,
        type: event.type,
        createdBy: event.createdBy,
        notes: event.notes,
      );

      emit(InventoryCountCreated(count));
    } catch (e) {
      emit(InventoryCountError('Failed to create inventory count: $e'));
    }
  }

  Future<void> _onUpdateInventoryCountStatus(
    UpdateInventoryCountStatus event,
    Emitter<InventoryCountState> emit,
  ) async {
    try {
      await repository.updateStatus(event.countId, event.status);
      // Details will update automatically via stream
    } catch (e) {
      emit(InventoryCountError('Failed to update status: $e'));
    }
  }

  Future<void> _onUpdateInventoryCountNotes(
    UpdateInventoryCountNotes event,
    Emitter<InventoryCountState> emit,
  ) async {
    try {
      await repository.updateNotes(event.countId, event.notes);
    } catch (e) {
      emit(InventoryCountError('Failed to update notes: $e'));
    }
  }

  Future<void> _onAddInventoryCountItem(
    AddInventoryCountItem event,
    Emitter<InventoryCountState> emit,
  ) async {
    try {
      final item = await repository.addInventoryCountItem(
        countId: event.countId,
        itemId: event.itemId,
        itemVariantId: event.itemVariantId,
        itemName: event.itemName,
        expectedStock: event.expectedStock,
      );

      emit(InventoryCountItemAdded(item));

      // Reload details to get updated summary
      add(LoadInventoryCountDetails(event.countId));
    } catch (e) {
      emit(InventoryCountError('Failed to add item: $e'));
    }
  }

  Future<void> _onUpdateCountedStock(
    UpdateCountedStock event,
    Emitter<InventoryCountState> emit,
  ) async {
    try {
      await repository.updateCountedStock(
        itemId: event.itemId,
        countedStock: event.countedStock,
      );

      emit(CountedStockUpdated(event.itemId, event.countedStock));

      // Summary will update automatically via stream
    } catch (e) {
      emit(InventoryCountError('Failed to update counted stock: $e'));
    }
  }

  Future<void> _onRemoveInventoryCountItem(
    RemoveInventoryCountItem event,
    Emitter<InventoryCountState> emit,
  ) async {
    try {
      await repository.removeInventoryCountItem(event.itemId);
    } catch (e) {
      emit(InventoryCountError('Failed to remove item: $e'));
    }
  }

  Future<void> _onCompleteInventoryCount(
    CompleteInventoryCount event,
    Emitter<InventoryCountState> emit,
  ) async {
    try {
      await repository.completeInventoryCount(event.countId);
      emit(InventoryCountCompleted(event.countId));
    } catch (e) {
      emit(InventoryCountError('Failed to complete inventory count: $e'));
    }
  }

  Future<void> _onDeleteInventoryCount(
    DeleteInventoryCount event,
    Emitter<InventoryCountState> emit,
  ) async {
    try {
      await repository.deleteInventoryCount(event.countId);
    } catch (e) {
      emit(InventoryCountError('Failed to delete inventory count: $e'));
    }
  }

  Future<void> _onInternalCountsUpdated(
    _InventoryCountsUpdated event,
    Emitter<InventoryCountState> emit,
  ) async {
    emit(InventoryCountsLoaded(event.counts));
  }

  Future<void> _onInternalDetailsUpdated(
    _InventoryCountDetailsUpdated event,
    Emitter<InventoryCountState> emit,
  ) async {
    final data = event.data;
    emit(InventoryCountDetailsLoaded(
      count: data.count,
      items: data.items,
      summary: data.summary,
    ));
  }

  @override
  Future<void> close() {
    _countsSubscription?.cancel();
    _detailsSubscription?.cancel();
    return super.close();
  }
}

// Internal events for stream updates
class _InventoryCountsUpdated extends InventoryCountEvent {
  final List<InventoryCount> counts;

  const _InventoryCountsUpdated(this.counts);

  @override
  List<Object> get props => [counts];
}

class _InventoryCountDetailsUpdated extends InventoryCountEvent {
  final _InventoryCountDetailsData data;

  const _InventoryCountDetailsUpdated(this.data);

  @override
  List<Object> get props => [data];
}

class _InventoryCountDetailsData {
  final InventoryCount count;
  final List<InventoryCountItem> items;
  final InventoryCountSummary summary;

  _InventoryCountDetailsData({
    required this.count,
    required this.items,
    required this.summary,
  });
}

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/data/local/app_database.dart';
import '../../data/repositories/stock_adjustment_repository.dart';
import 'stock_adjustment_event.dart';
import 'stock_adjustment_state.dart';

class StockAdjustmentBloc
    extends Bloc<StockAdjustmentEvent, StockAdjustmentState> {
  final StockAdjustmentRepository repository;
  StreamSubscription? _adjustmentsSubscription;
  StreamSubscription? _itemsSubscription;
  StreamSubscription? _historySubscription;

  StockAdjustmentBloc({required this.repository})
      : super(StockAdjustmentInitial()) {
    on<LoadStockAdjustments>(_onLoadStockAdjustments);
    on<CreateStockAdjustment>(_onCreateStockAdjustment);
    on<LoadAdjustmentItems>(_onLoadAdjustmentItems);
    on<LoadInventoryHistory>(_onLoadInventoryHistory);
    on<LoadItemHistory>(_onLoadItemHistory);
    on<_AdjustmentsUpdated>(_handleAdjustmentsUpdated);
    on<_AdjustmentItemsUpdated>(_handleAdjustmentItemsUpdated);
    on<_HistoryUpdated>(_handleHistoryUpdated);
  }

  Future<void> _onLoadStockAdjustments(
    LoadStockAdjustments event,
    Emitter<StockAdjustmentState> emit,
  ) async {
    emit(StockAdjustmentLoading());
    try {
      await _adjustmentsSubscription?.cancel();
      _adjustmentsSubscription = repository
          .watchAdjustmentsByStore(event.storeId)
          .listen((adjustments) {
        add(_AdjustmentsUpdated(adjustments));
      });
    } catch (e) {
      emit(StockAdjustmentError(e.toString()));
    }
  }

  Future<void> _onCreateStockAdjustment(
    CreateStockAdjustment event,
    Emitter<StockAdjustmentState> emit,
  ) async {
    emit(StockAdjustmentLoading());
    try {
      final adjustmentId = await repository.createAdjustment(
        storeId: event.storeId,
        reason: event.reason,
        createdBy: event.createdBy,
        items: event.items,
        notes: event.notes,
      );
      emit(StockAdjustmentCreated(adjustmentId));
    } catch (e) {
      emit(StockAdjustmentError(e.toString()));
    }
  }

  Future<void> _onLoadAdjustmentItems(
    LoadAdjustmentItems event,
    Emitter<StockAdjustmentState> emit,
  ) async {
    emit(StockAdjustmentLoading());
    try {
      final adjustment =
          await repository.getAdjustmentById(event.adjustmentId);
      if (adjustment == null) {
        emit(const StockAdjustmentError('Ajustement non trouvé'));
        return;
      }

      await _itemsSubscription?.cancel();
      _itemsSubscription =
          repository.watchAdjustmentItems(event.adjustmentId).listen((items) {
        add(_AdjustmentItemsUpdated(adjustment, items));
      });
    } catch (e) {
      emit(StockAdjustmentError(e.toString()));
    }
  }

  Future<void> _onLoadInventoryHistory(
    LoadInventoryHistory event,
    Emitter<StockAdjustmentState> emit,
  ) async {
    emit(StockAdjustmentLoading());
    try {
      await _historySubscription?.cancel();
      _historySubscription = repository
          .watchMovementsByStore(
        event.storeId,
        dateFrom: event.dateFrom,
        dateTo: event.dateTo,
      )
          .listen((movements) {
        add(_HistoryUpdated(movements));
      });
    } catch (e) {
      emit(StockAdjustmentError(e.toString()));
    }
  }

  Future<void> _onLoadItemHistory(
    LoadItemHistory event,
    Emitter<StockAdjustmentState> emit,
  ) async {
    emit(StockAdjustmentLoading());
    try {
      await _historySubscription?.cancel();
      _historySubscription =
          repository.watchMovementsByItem(event.itemId).listen((movements) {
        add(_HistoryUpdated(movements));
      });
    } catch (e) {
      emit(StockAdjustmentError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _adjustmentsSubscription?.cancel();
    _itemsSubscription?.cancel();
    _historySubscription?.cancel();
    return super.close();
  }
}

// ─── ÉVÉNEMENTS INTERNES ─────────────────────────────────

class _AdjustmentsUpdated extends StockAdjustmentEvent {
  final List<StockAdjustment> adjustments;

  const _AdjustmentsUpdated(this.adjustments);

  @override
  List<Object?> get props => [adjustments];
}

class _AdjustmentItemsUpdated extends StockAdjustmentEvent {
  final StockAdjustment adjustment;
  final List<StockAdjustmentItem> items;

  const _AdjustmentItemsUpdated(this.adjustment, this.items);

  @override
  List<Object?> get props => [adjustment, items];
}

class _HistoryUpdated extends StockAdjustmentEvent {
  final List<InventoryHistory> movements;

  const _HistoryUpdated(this.movements);

  @override
  List<Object?> get props => [movements];
}

// ─── HANDLERS POUR ÉVÉNEMENTS INTERNES ─────────────────────

extension _InternalHandlers on StockAdjustmentBloc {
  void _handleAdjustmentsUpdated(
    _AdjustmentsUpdated event,
    Emitter<StockAdjustmentState> emit,
  ) {
    emit(StockAdjustmentsLoaded(event.adjustments));
  }

  void _handleAdjustmentItemsUpdated(
    _AdjustmentItemsUpdated event,
    Emitter<StockAdjustmentState> emit,
  ) {
    emit(AdjustmentItemsLoaded(
      adjustment: event.adjustment,
      items: event.items,
    ));
  }

  void _handleHistoryUpdated(
    _HistoryUpdated event,
    Emitter<StockAdjustmentState> emit,
  ) {
    emit(InventoryHistoryLoaded(event.movements));
  }
}

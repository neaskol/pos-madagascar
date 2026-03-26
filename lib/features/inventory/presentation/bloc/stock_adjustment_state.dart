import 'package:equatable/equatable.dart';
import '../../../../core/data/local/app_database.dart';

abstract class StockAdjustmentState extends Equatable {
  const StockAdjustmentState();

  @override
  List<Object?> get props => [];
}

/// État initial
class StockAdjustmentInitial extends StockAdjustmentState {}

/// Chargement en cours
class StockAdjustmentLoading extends StockAdjustmentState {}

/// Ajustements chargés
class StockAdjustmentsLoaded extends StockAdjustmentState {
  final List<StockAdjustment> adjustments;

  const StockAdjustmentsLoaded(this.adjustments);

  @override
  List<Object?> get props => [adjustments];
}

/// Items d'un ajustement chargés
class AdjustmentItemsLoaded extends StockAdjustmentState {
  final StockAdjustment adjustment;
  final List<StockAdjustmentItem> items;

  const AdjustmentItemsLoaded({
    required this.adjustment,
    required this.items,
  });

  @override
  List<Object?> get props => [adjustment, items];
}

/// Historique des mouvements chargé
class InventoryHistoryLoaded extends StockAdjustmentState {
  final List<InventoryHistoryEntry> movements;

  const InventoryHistoryLoaded(this.movements);

  @override
  List<Object?> get props => [movements];
}

/// Ajustement créé avec succès
class StockAdjustmentCreated extends StockAdjustmentState {
  final String adjustmentId;

  const StockAdjustmentCreated(this.adjustmentId);

  @override
  List<Object?> get props => [adjustmentId];
}

/// Erreur
class StockAdjustmentError extends StockAdjustmentState {
  final String message;

  const StockAdjustmentError(this.message);

  @override
  List<Object?> get props => [message];
}

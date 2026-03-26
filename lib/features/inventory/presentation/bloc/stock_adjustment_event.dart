import 'package:equatable/equatable.dart';
import '../../../../core/data/local/app_database.dart';
import '../../data/repositories/stock_adjustment_repository.dart';

abstract class StockAdjustmentEvent extends Equatable {
  const StockAdjustmentEvent();

  @override
  List<Object?> get props => [];
}

/// Charger les ajustements d'un magasin
class LoadStockAdjustments extends StockAdjustmentEvent {
  final String storeId;

  const LoadStockAdjustments(this.storeId);

  @override
  List<Object?> get props => [storeId];
}

/// Créer un nouvel ajustement
class CreateStockAdjustment extends StockAdjustmentEvent {
  final String storeId;
  final AdjustmentReason reason;
  final String createdBy;
  final List<AdjustmentItemData> items;
  final String? notes;

  const CreateStockAdjustment({
    required this.storeId,
    required this.reason,
    required this.createdBy,
    required this.items,
    this.notes,
  });

  @override
  List<Object?> get props => [storeId, reason, createdBy, items, notes];
}

/// Charger les items d'un ajustement spécifique
class LoadAdjustmentItems extends StockAdjustmentEvent {
  final String adjustmentId;

  const LoadAdjustmentItems(this.adjustmentId);

  @override
  List<Object?> get props => [adjustmentId];
}

/// Charger l'historique des mouvements d'un magasin
class LoadInventoryHistory extends StockAdjustmentEvent {
  final String storeId;
  final DateTime? dateFrom;
  final DateTime? dateTo;

  const LoadInventoryHistory({
    required this.storeId,
    this.dateFrom,
    this.dateTo,
  });

  @override
  List<Object?> get props => [storeId, dateFrom, dateTo];
}

/// Charger l'historique d'un item spécifique
class LoadItemHistory extends StockAdjustmentEvent {
  final String itemId;

  const LoadItemHistory(this.itemId);

  @override
  List<Object?> get props => [itemId];
}

import 'package:equatable/equatable.dart';

/// Events pour l'export d'inventaire
abstract class InventoryExportEvent extends Equatable {
  const InventoryExportEvent();

  @override
  List<Object?> get props => [];
}

/// Export vers Excel
class ExportInventoryToExcelEvent extends InventoryExportEvent {
  final String storeId;
  final String storeName;
  final String? filterType; // 'all', 'low', 'out'

  const ExportInventoryToExcelEvent({
    required this.storeId,
    required this.storeName,
    this.filterType,
  });

  @override
  List<Object?> get props => [storeId, storeName, filterType];
}

/// Export vers PDF
class ExportInventoryToPdfEvent extends InventoryExportEvent {
  final String storeId;
  final String storeName;
  final String? filterType; // 'all', 'low', 'out'

  const ExportInventoryToPdfEvent({
    required this.storeId,
    required this.storeName,
    this.filterType,
  });

  @override
  List<Object?> get props => [storeId, storeName, filterType];
}

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/inventory_export_repository.dart';
import 'inventory_export_event.dart';
import 'inventory_export_state.dart';

/// BLoC pour gérer l'export d'inventaire en PDF et Excel
class InventoryExportBloc
    extends Bloc<InventoryExportEvent, InventoryExportState> {
  final InventoryExportRepository _repository;

  InventoryExportBloc(this._repository)
      : super(const InventoryExportInitial()) {
    on<ExportInventoryToExcelEvent>(_onExportToExcel);
    on<ExportInventoryToPdfEvent>(_onExportToPdf);
  }

  Future<void> _onExportToExcel(
    ExportInventoryToExcelEvent event,
    Emitter<InventoryExportState> emit,
  ) async {
    emit(const InventoryExportLoading('excel'));

    try {
      final file = await _repository.exportToExcel(
        storeId: event.storeId,
        storeName: event.storeName,
        filterType: event.filterType,
      );

      emit(InventoryExportSuccess(file, 'excel'));
    } catch (e) {
      emit(InventoryExportError(
        'Erreur lors de l\'export Excel: ${e.toString()}',
      ));
    }
  }

  Future<void> _onExportToPdf(
    ExportInventoryToPdfEvent event,
    Emitter<InventoryExportState> emit,
  ) async {
    emit(const InventoryExportLoading('pdf'));

    try {
      final file = await _repository.exportToPdf(
        storeId: event.storeId,
        storeName: event.storeName,
        filterType: event.filterType,
      );

      emit(InventoryExportSuccess(file, 'pdf'));
    } catch (e) {
      emit(InventoryExportError(
        'Erreur lors de l\'export PDF: ${e.toString()}',
      ));
    }
  }
}

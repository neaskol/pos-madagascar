import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/item_import_repository.dart';
import 'item_import_event.dart';
import 'item_import_state.dart';

/// BLoC pour gérer l'import d'items CSV/Excel
class ItemImportBloc extends Bloc<ItemImportEvent, ItemImportState> {
  final ItemImportRepository _repository;

  ItemImportBloc(this._repository) : super(const ItemImportInitial()) {
    on<PickAndParseFileEvent>(_onPickAndParseFile);
    on<PreviewImportDataEvent>(_onPreviewImportData);
    on<ExecuteImportEvent>(_onExecuteImport);
    on<ResetImportEvent>(_onResetImport);
    on<DownloadTemplateEvent>(_onDownloadTemplate);
  }

  /// Sélectionner et parser un fichier
  Future<void> _onPickAndParseFile(
    PickAndParseFileEvent event,
    Emitter<ItemImportState> emit,
  ) async {
    try {
      emit(const ItemImportFilePicking());

      final rows = await _repository.pickAndParseFile();

      if (rows == null) {
        // Utilisateur a annulé la sélection
        emit(const ItemImportInitial());
        return;
      }

      emit(const ItemImportParsing());

      // Compter les lignes valides et invalides
      final validCount = rows.where((row) => row.isValid).length;
      final errorCount = rows.where((row) => !row.isValid).length;

      emit(ItemImportPreview(
        rows: rows,
        validCount: validCount,
        errorCount: errorCount,
      ));
    } catch (e) {
      emit(ItemImportError('Erreur lors de la lecture du fichier: ${e.toString()}'));
    }
  }

  /// Prévisualiser les données
  Future<void> _onPreviewImportData(
    PreviewImportDataEvent event,
    Emitter<ItemImportState> emit,
  ) async {
    final validCount = event.rows.where((row) => row.isValid).length;
    final errorCount = event.rows.where((row) => !row.isValid).length;

    emit(ItemImportPreview(
      rows: event.rows,
      validCount: validCount,
      errorCount: errorCount,
    ));
  }

  /// Exécuter l'import
  Future<void> _onExecuteImport(
    ExecuteImportEvent event,
    Emitter<ItemImportState> emit,
  ) async {
    try {
      // Filtrer uniquement les lignes valides
      final validRows = event.rows.where((row) => row.isValid).toList();

      if (validRows.isEmpty) {
        emit(const ItemImportError('Aucune ligne valide à importer'));
        return;
      }

      emit(ItemImportInProgress(
        progress: 0,
        total: validRows.length,
      ));

      // Récupérer le mapping des catégories
      final categoryMapping = await _repository.getCategoryMapping(event.storeId);

      // Importer les items
      final result = await _repository.importItems(
        storeId: event.storeId,
        rows: validRows,
        categoryMapping: categoryMapping,
      );

      emit(ItemImportSuccess(result));
    } catch (e) {
      emit(ItemImportError('Erreur lors de l\'import: ${e.toString()}'));
    }
  }

  /// Réinitialiser l'état
  Future<void> _onResetImport(
    ResetImportEvent event,
    Emitter<ItemImportState> emit,
  ) async {
    emit(const ItemImportInitial());
  }

  /// Télécharger le template CSV
  Future<void> _onDownloadTemplate(
    DownloadTemplateEvent event,
    Emitter<ItemImportState> emit,
  ) async {
    try {
      final template = _repository.generateCSVTemplate();
      emit(ItemImportTemplateDownloaded(template));
    } catch (e) {
      emit(ItemImportError('Erreur lors de la génération du template: ${e.toString()}'));
    }
  }
}

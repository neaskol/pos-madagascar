import 'package:equatable/equatable.dart';
import '../../data/repositories/item_import_repository.dart';

/// Événements pour l'import d'items
abstract class ItemImportEvent extends Equatable {
  const ItemImportEvent();

  @override
  List<Object?> get props => [];
}

/// Sélectionner et parser un fichier CSV/Excel
class PickAndParseFileEvent extends ItemImportEvent {
  const PickAndParseFileEvent();
}

/// Prévisualiser les données avant import
class PreviewImportDataEvent extends ItemImportEvent {
  final List<ImportItemRow> rows;

  const PreviewImportDataEvent(this.rows);

  @override
  List<Object?> get props => [rows];
}

/// Confirmer et exécuter l'import
class ExecuteImportEvent extends ItemImportEvent {
  final String storeId;
  final List<ImportItemRow> rows;

  const ExecuteImportEvent({
    required this.storeId,
    required this.rows,
  });

  @override
  List<Object?> get props => [storeId, rows];
}

/// Réinitialiser l'état d'import
class ResetImportEvent extends ItemImportEvent {
  const ResetImportEvent();
}

/// Télécharger le template CSV
class DownloadTemplateEvent extends ItemImportEvent {
  const DownloadTemplateEvent();
}

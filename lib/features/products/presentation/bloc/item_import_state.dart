import 'package:equatable/equatable.dart';
import '../../data/repositories/item_import_repository.dart';

/// États pour l'import d'items
abstract class ItemImportState extends Equatable {
  const ItemImportState();

  @override
  List<Object?> get props => [];
}

/// État initial
class ItemImportInitial extends ItemImportState {
  const ItemImportInitial();
}

/// Sélection de fichier en cours
class ItemImportFilePicking extends ItemImportState {
  const ItemImportFilePicking();
}

/// Parsing du fichier en cours
class ItemImportParsing extends ItemImportState {
  const ItemImportParsing();
}

/// Prévisualisation des données
class ItemImportPreview extends ItemImportState {
  final List<ImportItemRow> rows;
  final int validCount;
  final int errorCount;

  const ItemImportPreview({
    required this.rows,
    required this.validCount,
    required this.errorCount,
  });

  @override
  List<Object?> get props => [rows, validCount, errorCount];
}

/// Import en cours
class ItemImportInProgress extends ItemImportState {
  final int progress;
  final int total;

  const ItemImportInProgress({
    required this.progress,
    required this.total,
  });

  @override
  List<Object?> get props => [progress, total];

  double get percentage => total > 0 ? (progress / total) * 100 : 0;
}

/// Import réussi
class ItemImportSuccess extends ItemImportState {
  final ImportResult result;

  const ItemImportSuccess(this.result);

  @override
  List<Object?> get props => [result];
}

/// Erreur lors de l'import
class ItemImportError extends ItemImportState {
  final String message;

  const ItemImportError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Template téléchargé
class ItemImportTemplateDownloaded extends ItemImportState {
  final String csvContent;

  const ItemImportTemplateDownloaded(this.csvContent);

  @override
  List<Object?> get props => [csvContent];
}

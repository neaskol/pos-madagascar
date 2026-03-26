import 'dart:io';
import 'package:equatable/equatable.dart';

/// States pour l'export d'inventaire
abstract class InventoryExportState extends Equatable {
  const InventoryExportState();

  @override
  List<Object?> get props => [];
}

/// État initial
class InventoryExportInitial extends InventoryExportState {
  const InventoryExportInitial();
}

/// Export en cours
class InventoryExportLoading extends InventoryExportState {
  final String exportType; // 'pdf' ou 'excel'

  const InventoryExportLoading(this.exportType);

  @override
  List<Object?> get props => [exportType];
}

/// Export réussi
class InventoryExportSuccess extends InventoryExportState {
  final File file;
  final String exportType; // 'pdf' ou 'excel'

  const InventoryExportSuccess(this.file, this.exportType);

  @override
  List<Object?> get props => [file, exportType];
}

/// Erreur d'export
class InventoryExportError extends InventoryExportState {
  final String message;

  const InventoryExportError(this.message);

  @override
  List<Object?> get props => [message];
}

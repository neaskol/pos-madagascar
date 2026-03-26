import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/theme_ext.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../data/repositories/item_import_repository.dart';
import '../bloc/item_import_bloc.dart';
import '../bloc/item_import_event.dart';
import '../bloc/item_import_state.dart';

/// Écran d'import CSV/Excel des produits
class ImportItemsScreen extends StatelessWidget {
  const ImportItemsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.textPri),
          onPressed: () => context.pop(),
        ),
        title: Text(
          l10n.importItems,
          style: AppTypography.screenTitle.copyWith(color: context.textPri),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline, color: context.textSec),
            tooltip: l10n.help,
            onPressed: () => _showHelpDialog(context),
          ),
        ],
      ),
      body: BlocConsumer<ItemImportBloc, ItemImportState>(
        listener: (context, state) {
          if (state is ItemImportError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: context.danger,
              ),
            );
          } else if (state is ItemImportSuccess) {
            _showSuccessDialog(context, state.result);
          } else if (state is ItemImportTemplateDownloaded) {
            _downloadTemplate(context, state.csvContent);
          }
        },
        builder: (context, state) {
          if (state is ItemImportFilePicking || state is ItemImportParsing) {
            return _buildLoading(context);
          } else if (state is ItemImportPreview) {
            return _buildPreview(context, state);
          } else if (state is ItemImportInProgress) {
            return _buildImportProgress(context, state);
          } else {
            return _buildInitial(context);
          }
        },
      ),
    );
  }

  /// État initial avec boutons pour choisir fichier ou télécharger template
  Widget _buildInitial(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.file_upload_outlined,
              size: 96,
              color: context.accent.withOpacity(0.3),
            ),
            const SizedBox(height: AppDimensions.spacingLarge),
            Text(
              l10n.importItemsDescription,
              style: AppTypography.body.copyWith(color: context.textSec),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacingExtraLarge),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.read<ItemImportBloc>().add(const PickAndParseFileEvent());
                },
                icon: const Icon(Icons.file_open),
                label: Text(l10n.selectFile),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppDimensions.paddingMedium,
                    horizontal: AppDimensions.paddingLarge,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingMedium),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  context.read<ItemImportBloc>().add(const DownloadTemplateEvent());
                },
                icon: const Icon(Icons.download),
                label: Text(l10n.downloadTemplate),
                style: OutlinedButton.styleFrom(
                  foregroundColor: context.accent,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppDimensions.paddingMedium,
                    horizontal: AppDimensions.paddingLarge,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingExtraLarge),
            _buildFormatInfo(context),
          ],
        ),
      ),
    );
  }

  /// Informations sur le format du fichier
  Widget _buildFormatInfo(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: context.accent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: context.accent, size: 20),
              const SizedBox(width: AppDimensions.spacingSmall),
              Text(
                l10n.fileFormat,
                style: AppTypography.sectionTitle.copyWith(color: context.accent),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingSmall),
          Text(
            l10n.fileFormatDescription,
            style: AppTypography.bodySmall.copyWith(color: context.textSec),
          ),
        ],
      ),
    );
  }

  /// Loading state
  Widget _buildLoading(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: context.accent),
          const SizedBox(height: AppDimensions.spacingMedium),
          Text(l10n.parsingFile),
        ],
      ),
    );
  }

  /// Prévisualisation des données avant import
  Widget _buildPreview(BuildContext context, ItemImportPreview state) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        // Statistiques
        Container(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          color: context.surface,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStat(
                context,
                l10n.total,
                state.rows.length.toString(),
                context.textPri,
              ),
              _buildStat(
                context,
                l10n.valid,
                state.validCount.toString(),
                context.success,
              ),
              _buildStat(
                context,
                l10n.errors,
                state.errorCount.toString(),
                context.danger,
              ),
            ],
          ),
        ),
        // Liste des lignes
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            itemCount: state.rows.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final row = state.rows[index];
              return _buildRowPreview(context, row);
            },
          ),
        ),
        // Boutons d'action
        Container(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          decoration: BoxDecoration(
            color: context.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    context.read<ItemImportBloc>().add(const ResetImportEvent());
                  },
                  child: Text(l10n.cancel),
                ),
              ),
              const SizedBox(width: AppDimensions.spacingMedium),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: state.validCount > 0
                      ? () {
                          final authState = context.read<AuthBloc>().state;
                          if (authState is AuthStoreEmployeesLoaded) {
                            context.read<ItemImportBloc>().add(
                                  ExecuteImportEvent(
                                    storeId: authState.storeId,
                                    rows: state.rows,
                                  ),
                                );
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.accent,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(l10n.importValidRows(state.validCount)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Widget statistique
  Widget _buildStat(BuildContext context, String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.amountLarge.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(color: color),
        ),
      ],
    );
  }

  /// Prévisualisation d'une ligne
  Widget _buildRowPreview(BuildContext context, ImportItemRow row) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppDimensions.paddingSmall,
        horizontal: AppDimensions.paddingSmall,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Numéro de ligne
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: row.isValid ? context.successBg : context.dangerBg,
              borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
            ),
            child: Center(
              child: Text(
                '${row.lineNumber}',
                style: AppTypography.caption.copyWith(
                  color: row.isValid ? context.success : context.danger,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.spacingSmall),
          // Détails
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (row.name != null && row.name!.isNotEmpty)
                  Text(
                    row.name!,
                    style: AppTypography.body.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.textPri,
                    ),
                  ),
                if (row.price != null && row.price!.isNotEmpty)
                  Text(
                    '${row.price} Ar',
                    style: AppTypography.bodySmall.copyWith(color: context.textSec),
                  ),
                if (row.errors.isNotEmpty)
                  ...row.errors.map((error) => Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, size: 14, color: context.danger),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                error,
                                style: AppTypography.bodySmall.copyWith(color: context.danger),
                              ),
                            ),
                          ],
                        ),
                      )),
              ],
            ),
          ),
          // Icône statut
          Icon(
            row.isValid ? Icons.check_circle : Icons.cancel,
            color: row.isValid ? context.success : context.danger,
            size: 20,
          ),
        ],
      ),
    );
  }

  /// Progression de l'import
  Widget _buildImportProgress(BuildContext context, ItemImportInProgress state) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              value: state.percentage / 100,
              color: context.accent,
            ),
            const SizedBox(height: AppDimensions.spacingLarge),
            Text(
              l10n.importing,
              style: AppTypography.sectionTitle.copyWith(color: context.textPri),
            ),
            const SizedBox(height: AppDimensions.spacingSmall),
            Text(
              '${state.progress} / ${state.total}',
              style: AppTypography.body.copyWith(color: context.textSec),
            ),
            const SizedBox(height: AppDimensions.spacingSmall),
            Text(
              '${state.percentage.toStringAsFixed(0)}%',
              style: AppTypography.amountLarge.copyWith(
                color: context.accent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Dialog d'aide
  void _showHelpDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.surface,
        title: Text(l10n.help),
        content: SingleChildScrollView(
          child: Text(l10n.importHelpText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }

  /// Dialog de succès
  void _showSuccessDialog(BuildContext context, ImportResult result) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: context.surface,
        title: Row(
          children: [
            Icon(Icons.check_circle, color: context.success),
            const SizedBox(width: 8),
            Text(l10n.importComplete),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.importSuccessMessage(result.successCount)),
            if (result.errorCount > 0) ...[
              const SizedBox(height: 8),
              Text(
                l10n.importErrorsMessage(result.errorCount),
                style: TextStyle(color: context.danger),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<ItemImportBloc>().add(const ResetImportEvent());
              context.pop(); // Retour à la liste des produits
            },
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }

  /// Télécharger le template CSV
  Future<void> _downloadTemplate(BuildContext context, String csvContent) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/template_import_produits.csv');
      await file.writeAsString(csvContent);

      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Template Import Produits',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }
}

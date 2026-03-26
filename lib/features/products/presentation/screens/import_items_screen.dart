import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/theme/app_colors.dart';
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
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final typography = context.typography;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          l10n.importItems,
          style: typography.titleLarge.copyWith(color: colors.onSurface),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline, color: colors.onSurfaceVariant),
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
                backgroundColor: colors.error,
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
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final typography = context.typography;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.file_upload_outlined,
              size: 96,
              color: colors.primary.withOpacity(0.3),
            ),
            const SizedBox(height: AppDimensions.spacingLarge),
            Text(
              l10n.importItemsDescription,
              style: typography.bodyLarge.copyWith(color: colors.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacingXLarge),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.read<ItemImportBloc>().add(const PickAndParseFileEvent());
                },
                icon: const Icon(Icons.file_open),
                label: Text(l10n.selectFile),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: colors.onPrimary,
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
                  foregroundColor: colors.primary,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppDimensions.paddingMedium,
                    horizontal: AppDimensions.paddingLarge,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingXLarge),
            _buildFormatInfo(context),
          ],
        ),
      ),
    );
  }

  /// Informations sur le format du fichier
  Widget _buildFormatInfo(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final typography = context.typography;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: colors.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: colors.primary, size: 20),
              const SizedBox(width: AppDimensions.spacingSmall),
              Text(
                l10n.fileFormat,
                style: typography.titleSmall.copyWith(color: colors.primary),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingSmall),
          Text(
            l10n.fileFormatDescription,
            style: typography.bodySmall.copyWith(color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  /// Loading state
  Widget _buildLoading(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: colors.primary),
          const SizedBox(height: AppDimensions.spacingMedium),
          Text(l10n.parsingFile),
        ],
      ),
    );
  }

  /// Prévisualisation des données avant import
  Widget _buildPreview(BuildContext context, ItemImportPreview state) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final typography = context.typography;

    return Column(
      children: [
        // Statistiques
        Container(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          color: colors.surfaceContainerHighest,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStat(
                context,
                l10n.total,
                state.rows.length.toString(),
                colors.onSurface,
              ),
              _buildStat(
                context,
                l10n.valid,
                state.validCount.toString(),
                colors.success,
              ),
              _buildStat(
                context,
                l10n.errors,
                state.errorCount.toString(),
                colors.error,
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
            color: colors.surface,
            boxShadow: [
              BoxShadow(
                color: colors.shadow.withOpacity(0.1),
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
                                    storeId: authState.store.id,
                                    rows: state.rows,
                                  ),
                                );
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
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
    final typography = context.typography;

    return Column(
      children: [
        Text(
          value,
          style: typography.headlineMedium.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: typography.bodySmall.copyWith(color: color),
        ),
      ],
    );
  }

  /// Prévisualisation d'une ligne
  Widget _buildRowPreview(BuildContext context, ImportItemRow row) {
    final colors = context.colors;
    final typography = context.typography;

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
              color: row.isValid ? colors.successContainer : colors.errorContainer,
              borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
            ),
            child: Center(
              child: Text(
                '${row.lineNumber}',
                style: typography.labelSmall.copyWith(
                  color: row.isValid ? colors.onSuccessContainer : colors.onErrorContainer,
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
                    style: typography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.onSurface,
                    ),
                  ),
                if (row.price != null && row.price!.isNotEmpty)
                  Text(
                    '${row.price} Ar',
                    style: typography.bodySmall.copyWith(color: colors.onSurfaceVariant),
                  ),
                if (row.errors.isNotEmpty)
                  ...row.errors.map((error) => Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, size: 14, color: colors.error),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                error,
                                style: typography.bodySmall.copyWith(color: colors.error),
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
            color: row.isValid ? colors.success : colors.error,
            size: 20,
          ),
        ],
      ),
    );
  }

  /// Progression de l'import
  Widget _buildImportProgress(BuildContext context, ItemImportInProgress state) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final typography = context.typography;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              value: state.percentage / 100,
              color: colors.primary,
            ),
            const SizedBox(height: AppDimensions.spacingLarge),
            Text(
              l10n.importing,
              style: typography.titleMedium.copyWith(color: colors.onSurface),
            ),
            const SizedBox(height: AppDimensions.spacingSmall),
            Text(
              '${state.progress} / ${state.total}',
              style: typography.bodyLarge.copyWith(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: AppDimensions.spacingSmall),
            Text(
              '${state.percentage.toStringAsFixed(0)}%',
              style: typography.headlineSmall.copyWith(
                color: colors.primary,
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
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.surface,
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
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: colors.surface,
        title: Row(
          children: [
            Icon(Icons.check_circle, color: colors.success),
            const SizedBox(width: 8),
            Text(l10n.importComplete),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.importSuccessMessage(result.successCount, result.totalRows)),
            if (result.errorCount > 0) ...[
              const SizedBox(height: 8),
              Text(
                l10n.importErrorsMessage(result.errorCount),
                style: TextStyle(color: colors.error),
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

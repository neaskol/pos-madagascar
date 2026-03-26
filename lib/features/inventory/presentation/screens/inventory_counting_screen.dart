import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/theme_ext.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/inventory_count_bloc.dart';
import '../bloc/inventory_count_event.dart';
import '../bloc/inventory_count_state.dart';
import '../../domain/entities/inventory_count_item.dart';

/// Écran — Comptage d'inventaire
/// Permet de compter les items et voir les écarts
class InventoryCountingScreen extends StatefulWidget {
  final String countId;

  const InventoryCountingScreen({
    super.key,
    required this.countId,
  });

  @override
  State<InventoryCountingScreen> createState() => _InventoryCountingScreenState();
}

class _InventoryCountingScreenState extends State<InventoryCountingScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Map<String, TextEditingController> _countControllers = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InventoryCountBloc>().add(LoadInventoryCountDetails(widget.countId));
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    for (final controller in _countControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  TextEditingController _getController(String itemId, double? currentValue) {
    if (!_countControllers.containsKey(itemId)) {
      _countControllers[itemId] = TextEditingController(
        text: currentValue?.toInt().toString() ?? '',
      );
    }
    return _countControllers[itemId]!;
  }

  void _updateCountedStock(String itemId, double value) {
    context.read<InventoryCountBloc>().add(UpdateCountedStock(itemId, value));
  }

  void _completeCount(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (dialogContext) => BlocBuilder<InventoryCountBloc, InventoryCountState>(
        builder: (context, state) {
          if (state is! InventoryCountDetailsLoaded) {
            return const SizedBox.shrink();
          }

          final summary = state.summary;
          final allCounted = summary.countedItems == summary.totalItems;

          return AlertDialog(
            icon: Icon(
              allCounted ? LucideIcons.checkCircle : LucideIcons.alertCircle,
              color: allCounted ? context.success : context.warning,
              size: 48,
            ),
            title: Text(l10n.inventoryCompleteTitle),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSummaryRow(
                  l10n.inventoryTotalItems,
                  summary.totalItems.toString(),
                  context.textPri,
                ),
                const SizedBox(height: AppSpacing.sm),
                _buildSummaryRow(
                  l10n.inventoryCounted,
                  summary.countedItems.toString(),
                  context.success,
                ),
                const SizedBox(height: AppSpacing.sm),
                _buildSummaryRow(
                  l10n.inventoryDiscrepancies,
                  summary.discrepancies.toString(),
                  summary.discrepancies > 0 ? context.danger : context.success,
                ),
                if (!allCounted) ...[
                  const SizedBox(height: AppSpacing.lg),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: context.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      border: Border.all(color: context.warning),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          LucideIcons.alertTriangle,
                          color: context.warning,
                          size: 20,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            l10n.inventoryNotAllCounted,
                            style: AppTypography.bodySmall.copyWith(
                              color: context.textPri,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  context.read<InventoryCountBloc>().add(CompleteInventoryCount(widget.countId));
                },
                style: FilledButton.styleFrom(
                  backgroundColor: context.success,
                ),
                child: Text(l10n.inventoryComplete),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.body.copyWith(color: context.textSec),
        ),
        Text(
          value,
          style: AppTypography.body.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final numberFormat = NumberFormat('#,###', 'fr');

    return BlocListener<InventoryCountBloc, InventoryCountState>(
      listener: (context, state) {
        if (state is InventoryCountCompleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.inventoryCompletedSuccess),
              backgroundColor: context.success,
            ),
          );
          context.go('/inventory/counts');
        } else if (state is InventoryCountError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: context.danger,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: BlocBuilder<InventoryCountBloc, InventoryCountState>(
            builder: (context, state) {
              if (state is InventoryCountDetailsLoaded) {
                final summary = state.summary;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.inventoryCountingTitle),
                    Text(
                      '${summary.countedItems} / ${summary.totalItems} ${l10n.inventoryItemsCounted}',
                      style: AppTypography.bodySmall.copyWith(
                        color: context.textSec,
                      ),
                    ),
                  ],
                );
              }
              return Text(l10n.inventoryCountingTitle);
            },
          ),
        ),
        body: BlocBuilder<InventoryCountBloc, InventoryCountState>(
          builder: (context, state) {
            if (state is InventoryCountLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is InventoryCountError) {
              return Center(
                child: Text(
                  state.message,
                  style: AppTypography.body.copyWith(color: context.danger),
                ),
              );
            }

            if (state is! InventoryCountDetailsLoaded) {
              return const SizedBox.shrink();
            }

            final summary = state.summary;
            final items = state.items;
            final count = state.count;

            // Filter items by search
            final query = _searchController.text.toLowerCase();
            final filteredItems = query.isEmpty
                ? items
                : items.where((item) {
                    return item.itemName.toLowerCase().contains(query);
                  }).toList();

            return Column(
              children: [
                // Summary cards
                Container(
                  padding: const EdgeInsets.all(AppSpacing.page),
                  decoration: BoxDecoration(
                    color: context.isDark ? AppColors.darkSurface : AppColors.lightBackground,
                    border: Border(
                      bottom: BorderSide(color: context.border, width: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          l10n.inventoryTotalItems,
                          summary.totalItems.toString(),
                          LucideIcons.package,
                          context.textPri,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _buildSummaryCard(
                          l10n.inventoryCounted,
                          summary.countedItems.toString(),
                          LucideIcons.checkCircle,
                          context.success,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _buildSummaryCard(
                          l10n.inventoryDiscrepancies,
                          summary.discrepancies.toString(),
                          LucideIcons.alertTriangle,
                          summary.discrepancies > 0 ? context.danger : context.success,
                        ),
                      ),
                    ],
                  ),
                ),

                // Search bar
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.page),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: l10n.search,
                            prefixIcon: const Icon(LucideIcons.search),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(LucideIcons.x),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {});
                                    },
                                  )
                                : null,
                          ),
                          onChanged: (value) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      IconButton(
                        icon: const Icon(LucideIcons.scan),
                        onPressed: () {
                          // TODO: Implement barcode scanning
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.comingSoon),
                              backgroundColor: context.warning,
                            ),
                          );
                        },
                        style: IconButton.styleFrom(
                          backgroundColor: context.isDark
                              ? AppColors.darkSurface
                              : AppColors.lightSurfaceHigh,
                          padding: const EdgeInsets.all(AppSpacing.md),
                        ),
                      ),
                    ],
                  ),
                ),

                // Items list
                Expanded(
                  child: filteredItems.isEmpty
                      ? _buildEmptyState(l10n)
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                          itemCount: filteredItems.length,
                          separatorBuilder: (context, index) => Divider(
                            height: 0.5,
                            color: context.border,
                          ),
                          itemBuilder: (context, index) {
                            final item = filteredItems[index];
                            return _buildCountItem(item, l10n, numberFormat);
                          },
                        ),
                ),

                // Complete button
                Container(
                  padding: const EdgeInsets.all(AppSpacing.page),
                  decoration: BoxDecoration(
                    color: context.isDark ? AppColors.darkSurface : AppColors.lightSurface,
                    border: Border(
                      top: BorderSide(color: context.border, width: 0.5),
                    ),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.success,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        textStyle: AppTypography.button,
                      ),
                      onPressed: count.status == 'completed' ? null : () => _completeCount(context),
                      child: Text(
                        count.status == 'completed'
                            ? l10n.inventoryCompleted
                            : l10n.inventoryComplete,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.isDark ? AppColors.darkSurfaceHigh : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 20,
            color: color,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTypography.body.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: context.textSec,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildCountItem(InventoryCountItem item, AppLocalizations l10n, NumberFormat numberFormat) {
    final controller = _getController(item.id, item.countedStock);
    final isCounted = item.isCounted;
    final hasDiscrepancy = item.hasDiscrepancy;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      color: isCounted
          ? (hasDiscrepancy
              ? context.danger.withValues(alpha: 0.05)
              : context.success.withValues(alpha: 0.05))
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Item header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.itemName,
                      style: AppTypography.body.copyWith(
                        color: context.textPri,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${l10n.inventoryExpected}: ${item.expectedStock.toInt()}',
                      style: AppTypography.bodySmall.copyWith(color: context.textSec),
                    ),
                  ],
                ),
              ),
              // Status indicator
              if (isCounted)
                Icon(
                  hasDiscrepancy ? LucideIcons.alertCircle : LucideIcons.checkCircle,
                  color: hasDiscrepancy ? context.danger : context.success,
                  size: 24,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Count input
          Row(
            children: [
              // Expected stock (read-only)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.inventoryExpectedStock,
                      style: AppTypography.bodySmall.copyWith(
                        color: context.textSec,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.expectedStock.toInt().toString(),
                      style: AppTypography.body.copyWith(
                        color: context.textHint,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              // Count input
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.inventoryCountedStock,
                      style: AppTypography.bodySmall.copyWith(
                        color: context.textSec,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: controller,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: AppTypography.body.copyWith(
                        color: context.textPri,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        hintText: l10n.inventoryEnterCount,
                      ),
                      onChanged: (value) {
                        final count = double.tryParse(value);
                        if (count != null) {
                          _updateCountedStock(item.id, count);
                        }
                      },
                    ),
                  ],
                ),
              ),

              // Difference
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      l10n.inventoryDifference,
                      style: AppTypography.bodySmall.copyWith(
                        color: context.textSec,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (isCounted)
                      Text(
                        item.difference >= 0
                            ? '+${item.difference.toInt()}'
                            : item.difference.toInt().toString(),
                        style: AppTypography.body.copyWith(
                          color: item.difference > 0
                              ? context.success
                              : item.difference < 0
                                  ? context.danger
                                  : context.textPri,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      )
                    else
                      Text(
                        '-',
                        style: AppTypography.body.copyWith(
                          color: context.textHint,
                          fontSize: 16,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.search,
              size: 48,
              color: context.textHint,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              l10n.noResults,
              style: AppTypography.sectionTitle.copyWith(color: context.textPri),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.tryDifferentSearch,
              style: AppTypography.bodySmall.copyWith(color: context.textSec),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

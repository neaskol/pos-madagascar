import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/data/local/app_database.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/theme_ext.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/item_bloc.dart';
import '../bloc/item_event.dart';
import '../bloc/item_state.dart';

/// Écran 24 — Vue d'ensemble stock avec alertes
/// Spec: docs/screens.md lignes 272-279
class InventoryOverviewScreen extends StatefulWidget {
  const InventoryOverviewScreen({super.key});

  @override
  State<InventoryOverviewScreen> createState() =>
      _InventoryOverviewScreenState();
}

class _InventoryOverviewScreenState extends State<InventoryOverviewScreen> {
  String _stockFilter = 'all'; // 'all', 'low', 'out'
  String? _currentStoreId;

  List<Item> _filterAndSortItems(List<Item> items) {
    // Filter items that track stock
    var filtered = items.where((item) => item.trackStock == 1).toList();

    // Apply stock filter
    switch (_stockFilter) {
      case 'low':
        filtered = filtered
            .where((item) =>
                item.inStock > 0 && item.inStock <= item.lowStockThreshold)
            .toList();
        break;
      case 'out':
        filtered = filtered.where((item) => item.inStock == 0).toList();
        break;
      default:
        break;
    }

    // Sort by urgency: out of stock > low stock > ok
    filtered.sort((a, b) {
      // Out of stock items first
      if (a.inStock == 0 && b.inStock != 0) return -1;
      if (a.inStock != 0 && b.inStock == 0) return 1;

      // Then low stock items
      final aIsLow = a.inStock <= a.lowStockThreshold;
      final bIsLow = b.inStock <= b.lowStockThreshold;
      if (aIsLow && !bIsLow) return -1;
      if (!aIsLow && bIsLow) return 1;

      // Then by stock level ascending
      return a.inStock.compareTo(b.inStock);
    });

    return filtered;
  }

  int _countOutOfStock(List<Item> items) {
    return items
        .where((item) => item.trackStock == 1 && item.inStock == 0)
        .length;
  }

  int _countLowStock(List<Item> items) {
    return items
        .where((item) =>
            item.trackStock == 1 &&
            item.inStock > 0 &&
            item.inStock <= item.lowStockThreshold)
        .length;
  }

  int _calculateTotalValue(List<Item> items) {
    return items
        .where((item) => item.trackStock == 1)
        .fold(0, (sum, item) => sum + (item.cost * item.inStock));
  }

  Color _getStockColor(Item item, BuildContext context) {
    if (item.inStock == 0) return context.danger;
    if (item.inStock <= item.lowStockThreshold) return context.warning;
    return context.success;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final numberFormat = NumberFormat('#,###', 'fr');

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.inventoryTitle),
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          String? storeId;
          if (authState is AuthAuthenticatedWithStore) {
            storeId = authState.storeId;
          } else if (authState is AuthPinSessionActive) {
            storeId = null;
          }

          if (storeId == null) {
            return Center(
              child: Text(
                'Store ID not available',
                style: AppTypography.body.copyWith(color: context.textSec),
              ),
            );
          }

          if (_currentStoreId != storeId) {
            _currentStoreId = storeId;
            final currentStore = storeId;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.read<ItemBloc>().add(LoadStoreItemsEvent(currentStore));
            });
          }

          return BlocBuilder<ItemBloc, ItemState>(
            builder: (context, itemState) {
              if (itemState is ItemLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (itemState is ItemError) {
                return Center(
                  child: Text(
                    itemState.message,
                    style: AppTypography.body.copyWith(color: context.danger),
                  ),
                );
              }

              if (itemState is! ItemsLoaded) {
                return const SizedBox.shrink();
              }

              final allItems = itemState.items;
              final trackedItems =
                  allItems.where((item) => item.trackStock == 1).toList();
              final outOfStockCount = _countOutOfStock(allItems);
              final lowStockCount = _countLowStock(allItems);
              final totalValue = _calculateTotalValue(allItems);
              final filteredItems = _filterAndSortItems(allItems);

              return Column(
                children: [
                  // Metrics section
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.page),
                    decoration: BoxDecoration(
                      color: context.isDark
                          ? AppColors.darkSurface
                          : AppColors.lightBackground,
                      border: Border(
                        bottom: BorderSide(
                          color: context.border,
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.inventoryMetrics,
                          style: AppTypography.bodySmall.copyWith(
                            color: context.textSec,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            _buildMetricCard(
                              context,
                              l10n.inventoryOutOfStock,
                              outOfStockCount.toString(),
                              context.danger,
                              Icons.error_outline,
                            ),
                            const SizedBox(width: AppSpacing.md),
                            _buildMetricCard(
                              context,
                              l10n.inventoryLowStock,
                              lowStockCount.toString(),
                              context.warning,
                              Icons.warning_amber_outlined,
                            ),
                            const SizedBox(width: AppSpacing.md),
                            _buildMetricCard(
                              context,
                              l10n.inventoryTotalValue,
                              totalValue > 0
                                  ? '${numberFormat.format(totalValue)} Ar'
                                  : '-',
                              context.textPri,
                              Icons.inventory_2_outlined,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Filter chips
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.page,
                      vertical: AppSpacing.md,
                    ),
                    child: Row(
                      children: [
                        _buildFilterChip(
                          context,
                          l10n.inventoryFilterAll,
                          'all',
                          trackedItems.length,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _buildFilterChip(
                          context,
                          l10n.inventoryFilterLow,
                          'low',
                          lowStockCount,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _buildFilterChip(
                          context,
                          l10n.inventoryFilterOut,
                          'out',
                          outOfStockCount,
                        ),
                      ],
                    ),
                  ),

                  // Items list
                  Expanded(
                    child: filteredItems.isEmpty
                        ? _buildEmptyState(l10n)
                        : RefreshIndicator(
                            onRefresh: () async {
                              if (storeId != null) {
                                context
                                    .read<ItemBloc>()
                                    .add(LoadStoreItemsEvent(storeId));
                              }
                            },
                            child: ListView.separated(
                              padding: const EdgeInsets.symmetric(
                                  vertical: AppSpacing.sm),
                              itemCount: filteredItems.length,
                              separatorBuilder: (context, index) => Divider(
                                height: 0.5,
                                color: context.border,
                                indent: 76,
                              ),
                              itemBuilder: (context, index) {
                                final item = filteredItems[index];
                                return _buildStockItem(
                                    item, l10n, numberFormat);
                              },
                            ),
                          ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: context.isDark
              ? AppColors.darkBackground
              : AppColors.lightSurfaceHigh,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: context.border.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    label,
                    style: AppTypography.bodySmall.copyWith(
                      color: context.textSec,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: AppTypography.amount.copyWith(
                color: color,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    String label,
    String value,
    int count,
  ) {
    final isSelected = _stockFilter == value;
    return FilterChip(
      label: Text('$label ($count)'),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _stockFilter = value;
        });
      },
      backgroundColor: context.isDark
          ? AppColors.darkBackground
          : AppColors.lightSurfaceHigh,
      selectedColor: context.isDark
          ? AppColors.darkTextPrimary.withValues(alpha: 0.15)
          : AppColors.lightTextPrimary.withValues(alpha: 0.1),
      labelStyle: AppTypography.bodySmall.copyWith(
        color: isSelected ? context.textPri : context.textSec,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected
            ? context.textPri.withValues(alpha: 0.3)
            : context.border,
      ),
    );
  }

  Widget _buildStockItem(
      Item item, AppLocalizations l10n, NumberFormat numberFormat) {
    final stockColor = _getStockColor(item, context);
    final stockPercent = item.lowStockThreshold > 0
        ? (item.inStock / item.lowStockThreshold).clamp(0.0, 1.0)
        : 1.0;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      leading: _buildProductImage(item),
      title: Text(
        item.name,
        style: AppTypography.body.copyWith(color: context.textPri),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item.sku != null && item.sku!.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              item.sku!,
              style: AppTypography.bodySmall.copyWith(
                color: context.textSec,
                fontSize: 12,
              ),
            ),
          ],
          const SizedBox(height: 6),
          // Stock indicator bar
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${item.inStock}',
                          style: AppTypography.body.copyWith(
                            color: stockColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          l10n.inventoryUnitsRemaining(item.inStock),
                          style: AppTypography.bodySmall.copyWith(
                            color: stockColor,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      child: LinearProgressIndicator(
                        value: stockPercent,
                        backgroundColor: context.border.withValues(alpha: 0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(stockColor),
                        minHeight: 3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                item.cost > 0
                    ? '${numberFormat.format(item.cost * item.inStock)} Ar'
                    : '',
                style: AppTypography.bodySmall.copyWith(
                  color: context.textSec,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
      onTap: () {
        _showQuickEditDialog(item);
      },
    );
  }

  Widget _buildProductImage(Item item) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Container(
        width: 44,
        height: 44,
        color: item.imageUrl != null
            ? null
            : context.isDark
                ? AppColors.darkSurface
                : AppColors.lightSurfaceHigh,
        child: item.imageUrl != null
            ? Image.network(
                item.imageUrl!,
                width: 44,
                height: 44,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildPlaceholder();
                },
              )
            : _buildPlaceholder(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Icon(
      Icons.inventory_2_outlined,
      color: context.textHint,
      size: 20,
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
              Icons.inventory_2_outlined,
              size: 48,
              color: context.textHint,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              l10n.inventoryEmpty,
              style: AppTypography.sectionTitle.copyWith(color: context.textPri),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.inventoryEmptyDescription,
              style: AppTypography.bodySmall.copyWith(color: context.textSec),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showQuickEditDialog(Item item) {
    final l10n = AppLocalizations.of(context)!;
    final TextEditingController stockController =
        TextEditingController(text: item.inStock.toString());

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.inventoryQuickEdit),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: AppTypography.body.copyWith(
                  color: context.textPri,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                '${l10n.inventoryCurrentStock}: ${item.inStock}',
                style: AppTypography.bodySmall.copyWith(
                  color: context.textSec,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: stockController,
                keyboardType: TextInputType.number,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: l10n.inventoryNewStock,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                final newStock = int.tryParse(stockController.text);
                if (newStock != null && _currentStoreId != null) {
                  // Update stock via ItemBloc
                  context.read<ItemBloc>().add(
                        UpdateItemStockEvent(
                          item.id,
                          newStock,
                        ),
                      );
                  Navigator.of(dialogContext).pop();

                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.inventoryStockUpdated(item.name)),
                      backgroundColor: context.success,
                    ),
                  );
                }
              },
              child: Text(l10n.save),
            ),
          ],
        );
      },
    );
  }
}

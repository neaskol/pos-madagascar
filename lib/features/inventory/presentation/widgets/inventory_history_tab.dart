import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/data/local/app_database.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/theme_ext.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/stock_adjustment_bloc.dart';
import '../bloc/stock_adjustment_event.dart';
import '../bloc/stock_adjustment_state.dart';

/// Widget onglet Historique pour l'écran inventory_overview_screen
/// Spec: docs/screens.md Phase 3.14 - InventoryHistoryTab
class InventoryHistoryTab extends StatefulWidget {
  final String storeId;

  const InventoryHistoryTab({
    super.key,
    required this.storeId,
  });

  @override
  State<InventoryHistoryTab> createState() => _InventoryHistoryTabState();
}

class _InventoryHistoryTabState extends State<InventoryHistoryTab> {
  InventoryMovementReason? _reasonFilter;
  String _periodFilter = 'all'; // 'all', '7days', '30days', 'month', 'custom'
  DateTime? _customDateFrom;
  DateTime? _customDateTo;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    DateTime? dateFrom;
    DateTime? dateTo;

    final now = DateTime.now();

    switch (_periodFilter) {
      case '7days':
        dateFrom = now.subtract(const Duration(days: 7));
        break;
      case '30days':
        dateFrom = now.subtract(const Duration(days: 30));
        break;
      case 'month':
        dateFrom = DateTime(now.year, now.month, 1);
        break;
      case 'custom':
        dateFrom = _customDateFrom;
        dateTo = _customDateTo;
        break;
      default:
        break;
    }

    context.read<StockAdjustmentBloc>().add(
          LoadInventoryHistory(
            storeId: widget.storeId,
            dateFrom: dateFrom,
            dateTo: dateTo,
          ),
        );
  }

  String _getReasonLabel(InventoryMovementReason reason, AppLocalizations l10n) {
    switch (reason) {
      case InventoryMovementReason.sale:
        return 'Vente';
      case InventoryMovementReason.refund:
        return 'Remboursement';
      case InventoryMovementReason.adjustment:
        return 'Ajustement';
      case InventoryMovementReason.receive:
        return l10n.inventoryReasonReceive;
      case InventoryMovementReason.loss:
        return l10n.inventoryReasonLoss;
      case InventoryMovementReason.damage:
        return l10n.inventoryReasonDamage;
      case InventoryMovementReason.transfer:
        return 'Transfert';
      case InventoryMovementReason.inventoryCount:
        return l10n.inventoryReasonCount;
    }
  }

  IconData _getReasonIcon(InventoryMovementReason reason) {
    switch (reason) {
      case InventoryMovementReason.sale:
        return Icons.shopping_cart_outlined;
      case InventoryMovementReason.refund:
        return Icons.keyboard_return_outlined;
      case InventoryMovementReason.adjustment:
        return Icons.tune_outlined;
      case InventoryMovementReason.receive:
        return Icons.add_circle_outline;
      case InventoryMovementReason.loss:
        return Icons.remove_circle_outline;
      case InventoryMovementReason.damage:
        return Icons.broken_image_outlined;
      case InventoryMovementReason.transfer:
        return Icons.swap_horiz_outlined;
      case InventoryMovementReason.inventoryCount:
        return Icons.inventory_outlined;
    }
  }

  Color _getReasonColor(InventoryMovementReason reason) {
    switch (reason) {
      case InventoryMovementReason.sale:
      case InventoryMovementReason.loss:
      case InventoryMovementReason.damage:
        return context.danger;
      case InventoryMovementReason.refund:
      case InventoryMovementReason.receive:
        return context.success;
      case InventoryMovementReason.adjustment:
      case InventoryMovementReason.transfer:
      case InventoryMovementReason.inventoryCount:
        return context.accent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm', 'fr');
    final numberFormat = NumberFormat('#,###', 'fr');

    return Column(
      children: [
        // Filters section
        Container(
          padding: const EdgeInsets.all(AppSpacing.page),
          decoration: BoxDecoration(
            color: context.isDark
                ? AppColors.darkSurface
                : AppColors.lightBackground,
            border: Border(
              bottom: BorderSide(color: context.border, width: 0.5),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Period filter
              Text(
                l10n.historyFilterPeriod,
                style: AppTypography.bodySmall.copyWith(
                  color: context.textSec,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildPeriodChip(l10n.adjustmentFilterAll, 'all'),
                    const SizedBox(width: AppSpacing.sm),
                    _buildPeriodChip(l10n.historyFilterLast7Days, '7days'),
                    const SizedBox(width: AppSpacing.sm),
                    _buildPeriodChip(l10n.historyFilterLast30Days, '30days'),
                    const SizedBox(width: AppSpacing.sm),
                    _buildPeriodChip(l10n.historyFilterThisMonth, 'month'),
                    const SizedBox(width: AppSpacing.sm),
                    _buildPeriodChip(l10n.historyFilterCustom, 'custom'),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Reason filter
              Text(
                l10n.inventoryAdjustmentReason,
                style: AppTypography.bodySmall.copyWith(
                  color: context.textSec,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildReasonChip(l10n.adjustmentFilterAll, null),
                    const SizedBox(width: AppSpacing.sm),
                    ...InventoryMovementReason.values.map((reason) {
                      return Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.sm),
                        child: _buildReasonChip(
                          _getReasonLabel(reason, l10n),
                          reason,
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),

        // History list
        Expanded(
          child: BlocBuilder<StockAdjustmentBloc, StockAdjustmentState>(
            builder: (context, state) {
              if (state is StockAdjustmentLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is StockAdjustmentError) {
                return Center(
                  child: Text(
                    state.message,
                    style: AppTypography.body.copyWith(color: context.danger),
                  ),
                );
              }

              if (state is! InventoryHistoryLoaded) {
                return const SizedBox.shrink();
              }

              var movements = state.movements;

              // Apply reason filter
              if (_reasonFilter != null) {
                movements = movements
                    .where((movement) => movement.reason == _reasonFilter)
                    .toList();
              }

              if (movements.isEmpty) {
                return _buildEmptyState(l10n);
              }

              return RefreshIndicator(
                onRefresh: () async {
                  _loadHistory();
                },
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  itemCount: movements.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 0.5,
                    color: context.border,
                  ),
                  itemBuilder: (context, index) {
                    final movement = movements[index];
                    return _buildMovementTile(
                      movement,
                      l10n,
                      dateFormat,
                      numberFormat,
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodChip(String label, String value) {
    final isSelected = _periodFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _periodFilter = value;
        });

        if (value == 'custom') {
          _showDateRangePicker();
        } else {
          _loadHistory();
        }
      },
      backgroundColor: context.isDark
          ? AppColors.darkBackground
          : AppColors.lightSurfaceHigh,
      selectedColor: context.accent.withValues(alpha: 0.15),
      labelStyle: AppTypography.bodySmall.copyWith(
        color: isSelected ? context.accent : context.textSec,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? context.accent : context.border,
      ),
    );
  }

  Widget _buildReasonChip(String label, InventoryMovementReason? reason) {
    final isSelected = _reasonFilter == reason;
    final color = reason != null ? _getReasonColor(reason) : context.textSec;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _reasonFilter = selected ? reason : null;
        });
      },
      backgroundColor: context.isDark
          ? AppColors.darkBackground
          : AppColors.lightSurfaceHigh,
      selectedColor: color.withValues(alpha: 0.15),
      labelStyle: AppTypography.bodySmall.copyWith(
        color: isSelected ? color : context.textSec,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? color : context.border,
      ),
    );
  }

  Widget _buildMovementTile(
    InventoryHistoryEntry movement,
    AppLocalizations l10n,
    DateFormat dateFormat,
    NumberFormat numberFormat,
  ) {
    final reason = movement.reason;
    final reasonColor = _getReasonColor(reason);
    final reasonIcon = _getReasonIcon(reason);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: reasonColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Icon(
          reasonIcon,
          color: reasonColor,
          size: 20,
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              'Item ${movement.itemId}', // TODO: Get item name from join
              style: AppTypography.body.copyWith(
                color: context.textPri,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            movement.quantityChange >= 0
                ? '+${movement.quantityChange.toInt()}'
                : '${movement.quantityChange.toInt()}',
            style: AppTypography.body.copyWith(
              color: movement.quantityChange >= 0
                  ? context.success
                  : context.danger,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: reasonColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                ),
                child: Text(
                  _getReasonLabel(reason, l10n),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: reasonColor,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  dateFormat.format(movement.createdAt),
                  style: AppTypography.bodySmall.copyWith(
                    color: context.textSec,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                '${l10n.adjustmentStockAfter}: ',
                style: AppTypography.bodySmall.copyWith(
                  color: context.textSec,
                  fontSize: 11,
                ),
              ),
              Text(
                '${movement.quantityAfter.toInt()}',
                style: AppTypography.bodySmall.copyWith(
                  color: context.textPri,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
              if (movement.employeeId != null) ...[
                const SizedBox(width: AppSpacing.md),
                Icon(
                  Icons.person_outline,
                  size: 12,
                  color: context.textSec,
                ),
                const SizedBox(width: 2),
                Text(
                  l10n.adjustmentBy('Employé'), // TODO: Get employee name
                  style: AppTypography.bodySmall.copyWith(
                    color: context.textSec,
                    fontSize: 11,
                  ),
                ),
              ],
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
              Icons.history_outlined,
              size: 48,
              color: context.textHint,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              l10n.historyEmpty,
              style: AppTypography.sectionTitle.copyWith(color: context.textPri),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.historyEmptyDescription,
              style: AppTypography.bodySmall.copyWith(color: context.textSec),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDateRangePicker() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: now,
      initialDateRange: _customDateFrom != null && _customDateTo != null
          ? DateTimeRange(start: _customDateFrom!, end: _customDateTo!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: context.isDark
                  ? AppColors.darkAccent
                  : AppColors.lightAccent,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _customDateFrom = picked.start;
        _customDateTo = picked.end;
      });
      _loadHistory();
    } else {
      // User cancelled, revert to "all"
      setState(() {
        _periodFilter = 'all';
      });
      _loadHistory();
    }
  }
}

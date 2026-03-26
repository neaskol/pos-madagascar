import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/enums/adjustment_reason.dart';
import 'package:intl/intl.dart';
import '../../../../core/data/local/app_database.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/theme_ext.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/stock_adjustment_bloc.dart';
import '../bloc/stock_adjustment_event.dart';
import '../bloc/stock_adjustment_state.dart';

/// Écran 26 — Liste des ajustements
/// Route: /inventory/adjustments
/// Spec: docs/screens.md lignes 290-295
class AdjustmentListScreen extends StatefulWidget {
  const AdjustmentListScreen({super.key});

  @override
  State<AdjustmentListScreen> createState() => _AdjustmentListScreenState();
}

class _AdjustmentListScreenState extends State<AdjustmentListScreen> {
  AdjustmentReason? _reasonFilter;
  String? _currentStoreId;

  String _getReasonLabel(AdjustmentReason reason, AppLocalizations l10n) {
    switch (reason) {
      case AdjustmentReason.receive:
        return l10n.inventoryReasonReceive;
      case AdjustmentReason.loss:
        return l10n.inventoryReasonLoss;
      case AdjustmentReason.damage:
        return l10n.inventoryReasonDamage;
      case AdjustmentReason.count:
        return l10n.inventoryReasonCount;
      case AdjustmentReason.other:
        return l10n.inventoryReasonOther;
    }
  }

  Color _getReasonColor(AdjustmentReason reason) {
    switch (reason) {
      case AdjustmentReason.receive:
        return context.success;
      case AdjustmentReason.loss:
      case AdjustmentReason.damage:
        return context.danger;
      case AdjustmentReason.count:
        return context.accent;
      case AdjustmentReason.other:
        return context.textSec;
    }
  }

  Color _getReasonBgColor(AdjustmentReason reason) {
    switch (reason) {
      case AdjustmentReason.receive:
        return context.isDark
            ? AppColors.successBgDark
            : AppColors.successBgLight;
      case AdjustmentReason.loss:
      case AdjustmentReason.damage:
        return context.isDark
            ? AppColors.dangerBgDark
            : AppColors.dangerBgLight;
      case AdjustmentReason.count:
        return context.isDark
            ? AppColors.darkSurface
            : AppColors.lightSurfaceHigh;
      case AdjustmentReason.other:
        return context.isDark
            ? AppColors.darkSurface
            : AppColors.lightSurfaceHigh;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm', 'fr');
    final numberFormat = NumberFormat('#,###', 'fr');

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.adjustmentListTitle),
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          String? storeId;
          if (authState is AuthAuthenticatedWithStore) {
            storeId = authState.storeId;
          } else if (authState is AuthPinSessionActive) {
            storeId = authState.user.storeId;
          }

          if (storeId == null) {
            return Center(
              child: Text(
                l10n.noStoreSelected,
                style: AppTypography.body.copyWith(color: context.textSec),
              ),
            );
          }

          if (_currentStoreId != storeId) {
            _currentStoreId = storeId;
            final currentStore = storeId;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context
                  .read<StockAdjustmentBloc>()
                  .add(LoadStockAdjustments(currentStore));
            });
          }

          return Column(
            children: [
              // Filter chips
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.page,
                  vertical: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: context.isDark
                      ? AppColors.darkSurface
                      : AppColors.lightBackground,
                  border: Border(
                    bottom: BorderSide(color: context.border, width: 0.5),
                  ),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(
                        l10n.adjustmentFilterAll,
                        null,
                        context.textSec,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      ...AdjustmentReason.values.map((reason) {
                        return Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.sm),
                          child: _buildFilterChip(
                            _getReasonLabel(reason, l10n),
                            reason,
                            _getReasonColor(reason),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),

              // Adjustments list
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
                          style:
                              AppTypography.body.copyWith(color: context.danger),
                        ),
                      );
                    }

                    if (state is! StockAdjustmentsLoaded) {
                      return const SizedBox.shrink();
                    }

                    var adjustments = state.adjustments;

                    // Apply filter
                    if (_reasonFilter != null) {
                      adjustments = adjustments
                          .where((adj) => adj.reason == _reasonFilter)
                          .toList();
                    }

                    if (adjustments.isEmpty) {
                      return _buildEmptyState(l10n);
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        if (storeId != null) {
                          context
                              .read<StockAdjustmentBloc>()
                              .add(LoadStockAdjustments(storeId));
                        }
                      },
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.sm),
                        itemCount: adjustments.length,
                        separatorBuilder: (context, index) => Divider(
                          height: 0.5,
                          color: context.border,
                        ),
                        itemBuilder: (context, index) {
                          final adjustment = adjustments[index];
                          return _buildAdjustmentTile(
                            adjustment,
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
        },
      ),
    );
  }

  Widget _buildFilterChip(String label, AdjustmentReason? reason, Color color) {
    final isSelected = _reasonFilter == reason;
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

  Widget _buildAdjustmentTile(
    StockAdjustment adjustment,
    AppLocalizations l10n,
    DateFormat dateFormat,
    NumberFormat numberFormat,
  ) {
    final reason = AdjustmentReason.values[adjustment.reason];
    final reasonColor = _getReasonColor(reason);
    final reasonBgColor = _getReasonBgColor(reason);

    // Calculate total variation (will be populated from adjustment items in real implementation)
    // For now, we show a placeholder
    final totalVariation = 0; // TODO: Calculate from items

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      title: Row(
        children: [
          // Reason badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 3,
            ),
            decoration: BoxDecoration(
              color: reasonBgColor,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Text(
              _getReasonLabel(reason, l10n),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: reasonColor,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              dateFormat.format(DateTime.fromMillisecondsSinceEpoch(adjustment.createdAt)),
              style: AppTypography.body.copyWith(
                color: context.textPri,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 14,
                color: context.textSec,
              ),
              const SizedBox(width: 4),
              Text(
                l10n.adjustmentItemsCount(0), // TODO: Get real count
                style: AppTypography.bodySmall.copyWith(
                  color: context.textSec,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              if (adjustment.createdBy.isNotEmpty) ...[
                Icon(
                  Icons.person_outline,
                  size: 14,
                  color: context.textSec,
                ),
                const SizedBox(width: 4),
                Text(
                  l10n.adjustmentBy('Employé'), // TODO: Get employee name
                  style: AppTypography.bodySmall.copyWith(
                    color: context.textSec,
                  ),
                ),
              ],
            ],
          ),
          if (adjustment.notes != null && adjustment.notes!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              adjustment.notes!,
              style: AppTypography.bodySmall.copyWith(
                color: context.textSec,
                fontSize: 12,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            totalVariation >= 0 ? '+$totalVariation' : '$totalVariation',
            style: AppTypography.body.copyWith(
              color: totalVariation >= 0 ? context.success : context.danger,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          Text(
            l10n.adjustmentTotalVariation,
            style: AppTypography.bodySmall.copyWith(
              color: context.textSec,
              fontSize: 11,
            ),
          ),
        ],
      ),
      onTap: () {
        // TODO: Navigate to adjustment detail or show modal
        _showAdjustmentDetail(adjustment, l10n);
      },
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
              Icons.receipt_long_outlined,
              size: 48,
              color: context.textHint,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              l10n.adjustmentEmptyList,
              style: AppTypography.sectionTitle.copyWith(color: context.textPri),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.adjustmentEmptyDescription,
              style: AppTypography.bodySmall.copyWith(color: context.textSec),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showAdjustmentDetail(StockAdjustment adjustment, AppLocalizations l10n) {
    // Load adjustment items
    context
        .read<StockAdjustmentBloc>()
        .add(LoadAdjustmentItems(adjustment.id));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => BlocProvider.value(
        value: context.read<StockAdjustmentBloc>(),
        child: DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: this.context.isDark
                    ? AppColors.darkSurface
                    : AppColors.lightSurface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadius.sheet),
                ),
              ),
              child: Column(
                children: [
                  // Handle
                  Container(
                    margin: const EdgeInsets.only(top: AppSpacing.md),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: this.context.border,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                  ),

                  // Header
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: _getReasonBgColor(AdjustmentReason.values[adjustment.reason]),
                                borderRadius:
                                    BorderRadius.circular(AppRadius.full),
                              ),
                              child: Text(
                                _getReasonLabel(AdjustmentReason.values[adjustment.reason], l10n),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: _getReasonColor(AdjustmentReason.values[adjustment.reason]),
                                ),
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.pop(modalContext),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          DateFormat('dd/MM/yyyy HH:mm', 'fr')
                              .format(DateTime.fromMillisecondsSinceEpoch(adjustment.createdAt)),
                          style: AppTypography.body.copyWith(
                            color: this.context.textPri,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (adjustment.notes != null &&
                            adjustment.notes!.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            adjustment.notes!,
                            style: AppTypography.bodySmall
                                .copyWith(color: this.context.textSec),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const Divider(height: 0.5),

                  // Items list
                  Expanded(
                    child: BlocBuilder<StockAdjustmentBloc,
                        StockAdjustmentState>(
                      builder: (context, state) {
                        if (state is StockAdjustmentLoading) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (state is! AdjustmentItemsLoaded) {
                          return Center(
                            child: Text(
                              l10n.noItems,
                              style: AppTypography.body
                                  .copyWith(color: this.context.textSec),
                            ),
                          );
                        }

                        final items = state.items;

                        return ListView.separated(
                          controller: scrollController,
                          padding: const EdgeInsets.all(AppSpacing.page),
                          itemCount: items.length,
                          separatorBuilder: (context, index) => const Divider(
                            height: AppSpacing.lg,
                          ),
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Item ${item.itemId}', // TODO: Get item name
                                        style: AppTypography.body.copyWith(
                                          color: this.context.textPri,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${item.quantityBefore.toInt()} → ${item.quantityAfter.toInt()}',
                                        style: AppTypography.bodySmall.copyWith(
                                          color: this.context.textSec,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  item.quantityChange >= 0
                                      ? '+${item.quantityChange.toInt()}'
                                      : '${item.quantityChange.toInt()}',
                                  style: AppTypography.body.copyWith(
                                    color: item.quantityChange >= 0
                                        ? this.context.success
                                        : this.context.danger,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

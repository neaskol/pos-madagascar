import 'package:flutter/material.dart';
import '../../domain/enums/adjustment_reason.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/data/local/app_database.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/theme_ext.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../products/presentation/bloc/item_bloc.dart';
import '../../../products/presentation/bloc/item_event.dart';
import '../../../products/presentation/bloc/item_state.dart';
import '../../data/repositories/stock_adjustment_repository.dart';
import '../bloc/stock_adjustment_bloc.dart';
import '../bloc/stock_adjustment_event.dart';
import '../bloc/stock_adjustment_state.dart';

/// Écran 25 — Ajustement de stock
/// Route: /inventory/adjustments/new
/// Spec: docs/screens.md lignes 281-289
class StockAdjustmentScreen extends StatefulWidget {
  const StockAdjustmentScreen({super.key});

  @override
  State<StockAdjustmentScreen> createState() => _StockAdjustmentScreenState();
}

class _StockAdjustmentScreenState extends State<StockAdjustmentScreen> {
  AdjustmentReason _selectedReason = AdjustmentReason.receive;
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final Map<String, _AdjustmentItemData> _adjustmentItems = {};
  String? _currentStoreId;

  @override
  void dispose() {
    _notesController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _addItem(Item item) {
    if (!_adjustmentItems.containsKey(item.id)) {
      setState(() {
        _adjustmentItems[item.id] = _AdjustmentItemData(
          item: item,
          variation: 0,
        );
      });
    }
  }

  void _removeItem(String itemId) {
    setState(() {
      _adjustmentItems.remove(itemId);
    });
  }

  void _updateVariation(String itemId, int variation) {
    setState(() {
      _adjustmentItems[itemId]?.variation = variation;
    });
  }

  void _validateAdjustment() {
    final authState = context.read<AuthBloc>().state;
    String? storeId;
    String? employeeId;

    if (authState is AuthAuthenticatedWithStore) {
      storeId = authState.storeId;
      employeeId = authState.user.id;
    } else if (authState is AuthPinSessionActive) {
      storeId = authState.user.storeId;
      employeeId = authState.user.id;
    }

    if (storeId == null || employeeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.errorFieldRequired),
          backgroundColor: context.danger,
        ),
      );
      return;
    }

    if (_adjustmentItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.adjustmentNoItems),
          backgroundColor: context.danger,
        ),
      );
      return;
    }

    final items = _adjustmentItems.values
        .where((data) => data.variation != 0)
        .map((data) => AdjustmentItemData(
              itemId: data.item.id,
              quantityBefore: data.item.inStock.toDouble(),
              quantityChange: data.variation.toDouble(),
              quantityAfter: (data.item.inStock + data.variation).toDouble(),
              cost: data.item.cost,
            ))
        .toList();

    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Aucune variation à enregistrer'),
          backgroundColor: context.danger,
        ),
      );
      return;
    }

    context.read<StockAdjustmentBloc>().add(
          CreateStockAdjustment(
            storeId: storeId,
            reason: _selectedReason,
            createdBy: employeeId,
            items: items,
            notes: _notesController.text.isNotEmpty
                ? _notesController.text
                : null,
          ),
        );
  }

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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final numberFormat = NumberFormat('#,###', 'fr');

    return BlocListener<StockAdjustmentBloc, StockAdjustmentState>(
      listener: (context, state) {
        if (state is StockAdjustmentCreated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.adjustmentCreated),
              backgroundColor: context.success,
            ),
          );
          context.pop();
        } else if (state is StockAdjustmentError) {
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
          title: Text(l10n.adjustmentNewTitle),
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
                context.read<ItemBloc>().add(LoadStoreItemsEvent(currentStore));
              });
            }

            return Column(
              children: [
                // Reason selector
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
                      Text(
                        l10n.adjustmentSelectReason,
                        style: AppTypography.bodySmall.copyWith(
                          color: context.textSec,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: AdjustmentReason.values.map((reason) {
                          final isSelected = _selectedReason == reason;
                          return ChoiceChip(
                            label: Text(_getReasonLabel(reason, l10n)),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _selectedReason = reason;
                              });
                            },
                            backgroundColor: context.isDark
                                ? AppColors.darkBackground
                                : AppColors.lightSurfaceHigh,
                            selectedColor:
                                _getReasonColor(reason).withValues(alpha: 0.15),
                            labelStyle: AppTypography.bodySmall.copyWith(
                              color: isSelected
                                  ? _getReasonColor(reason)
                                  : context.textSec,
                              fontWeight:
                                  isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                            side: BorderSide(
                              color: isSelected
                                  ? _getReasonColor(reason)
                                  : context.border,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      TextField(
                        controller: _notesController,
                        decoration: InputDecoration(
                          labelText: l10n.inventoryAdjustmentNote,
                          hintText: l10n.noteOptional,
                        ),
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),

                // Search bar
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.page),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: l10n.adjustmentSearchItems,
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
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

                // Items list or search results
                Expanded(
                  child: _adjustmentItems.isEmpty && _searchController.text.isEmpty
                      ? _buildEmptyState(l10n)
                      : _searchController.text.isNotEmpty
                          ? _buildSearchResults(storeId, l10n, numberFormat)
                          : _buildAdjustmentItems(l10n, numberFormat),
                ),

                // Bottom action button
                Container(
                  padding: const EdgeInsets.all(AppSpacing.page),
                  decoration: BoxDecoration(
                    color: context.isDark
                        ? AppColors.darkSurface
                        : AppColors.lightSurface,
                    border: Border(
                      top: BorderSide(color: context.border, width: 0.5),
                    ),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                        foregroundColor: context.isDark
                            ? AppColors.darkBackground
                            : AppColors.lightBackground,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        textStyle: AppTypography.button,
                      ),
                      onPressed:
                          _adjustmentItems.isEmpty ? null : _validateAdjustment,
                      child: Text(l10n.adjustmentValidate),
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
              l10n.adjustmentNoItems,
              style: AppTypography.sectionTitle.copyWith(color: context.textPri),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.adjustmentNoItemsHint,
              style: AppTypography.bodySmall.copyWith(color: context.textSec),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(
      String storeId, AppLocalizations l10n, NumberFormat numberFormat) {
    return BlocBuilder<ItemBloc, ItemState>(
      builder: (context, state) {
        if (state is ItemLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is! ItemsLoaded) {
          return const SizedBox.shrink();
        }

        final query = _searchController.text.toLowerCase();
        final filteredItems = state.items.where((item) {
          final alreadyAdded = _adjustmentItems.containsKey(item.id);
          if (alreadyAdded) return false;

          return item.name.toLowerCase().contains(query) ||
              (item.sku?.toLowerCase().contains(query) ?? false) ||
              (item.barcode?.toLowerCase().contains(query) ?? false);
        }).toList();

        if (filteredItems.isEmpty) {
          return Center(
            child: Text(
              l10n.noProducts,
              style: AppTypography.body.copyWith(color: context.textSec),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          itemCount: filteredItems.length,
          separatorBuilder: (context, index) => Divider(
            height: 0.5,
            color: context.border,
            indent: 76,
          ),
          itemBuilder: (context, index) {
            final item = filteredItems[index];
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              leading: _buildProductImage(item),
              title: Text(
                item.name,
                style: AppTypography.body.copyWith(color: context.textPri),
              ),
              subtitle: item.sku != null && item.sku!.isNotEmpty
                  ? Text(
                      item.sku!,
                      style: AppTypography.bodySmall
                          .copyWith(color: context.textSec),
                    )
                  : null,
              trailing: Text(
                '${item.inStock}',
                style: AppTypography.body.copyWith(
                  color: context.textSec,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                _addItem(item);
                _searchController.clear();
                setState(() {});
              },
            );
          },
        );
      },
    );
  }

  Widget _buildAdjustmentItems(AppLocalizations l10n, NumberFormat numberFormat) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      itemCount: _adjustmentItems.length,
      separatorBuilder: (context, index) => Divider(
        height: 0.5,
        color: context.border,
      ),
      itemBuilder: (context, index) {
        final itemData = _adjustmentItems.values.elementAt(index);
        final item = itemData.item;
        final variation = itemData.variation;
        final stockAfter = item.inStock + variation;

        return Dismissible(
          key: Key(item.id),
          direction: DismissDirection.endToStart,
          background: Container(
            color: context.danger,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: AppSpacing.lg),
            child: const Icon(Icons.delete_outline, color: Colors.white),
          ),
          onDismissed: (direction) {
            _removeItem(item.id);
          },
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Item header
                Row(
                  children: [
                    _buildProductImage(item),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: AppTypography.body
                                .copyWith(color: context.textPri),
                          ),
                          if (item.sku != null && item.sku!.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              item.sku!,
                              style: AppTypography.bodySmall
                                  .copyWith(color: context.textSec),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),

                // Stock adjustment row
                Row(
                  children: [
                    // Current stock
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.adjustmentCurrentStock,
                            style: AppTypography.bodySmall.copyWith(
                              color: context.textSec,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${item.inStock}',
                            style: AppTypography.body.copyWith(
                              color: context.textHint,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Variation input
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.adjustmentVariation,
                            style: AppTypography.bodySmall.copyWith(
                              color: context.textSec,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: () {
                                  _updateVariation(item.id, variation - 1);
                                },
                                color: context.danger,
                                iconSize: 28,
                              ),
                              Expanded(
                                child: TextField(
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 8,
                                    ),
                                  ),
                                  controller: TextEditingController(
                                    text: variation.toString(),
                                  ),
                                  onChanged: (value) {
                                    final newValue = int.tryParse(value) ?? 0;
                                    _updateVariation(item.id, newValue);
                                  },
                                  style: AppTypography.body.copyWith(
                                    color: variation > 0
                                        ? context.success
                                        : variation < 0
                                            ? context.danger
                                            : context.textPri,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline),
                                onPressed: () {
                                  _updateVariation(item.id, variation + 1);
                                },
                                color: context.success,
                                iconSize: 28,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Stock after
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            l10n.adjustmentStockAfter,
                            style: AppTypography.bodySmall.copyWith(
                              color: context.textSec,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$stockAfter',
                            style: AppTypography.body.copyWith(
                              color: variation > 0
                                  ? context.success
                                  : variation < 0
                                      ? context.danger
                                      : context.textPri,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
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
}

class _AdjustmentItemData {
  final Item item;
  int variation;

  _AdjustmentItemData({
    required this.item,
    required this.variation,
  });
}

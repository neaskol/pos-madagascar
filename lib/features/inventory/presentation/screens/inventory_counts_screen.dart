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
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/inventory_count_bloc.dart';
import '../bloc/inventory_count_event.dart';
import '../bloc/inventory_count_state.dart';
import '../../domain/entities/inventory_count.dart';

/// Écran — Liste des inventaires
/// Affiche tous les comptages d'inventaire avec filtres par statut
class InventoryCountsScreen extends StatefulWidget {
  const InventoryCountsScreen({super.key});

  @override
  State<InventoryCountsScreen> createState() => _InventoryCountsScreenState();
}

class _InventoryCountsScreenState extends State<InventoryCountsScreen> {
  String? _statusFilter;
  String? _currentStoreId;

  String _getStatusLabel(String status, AppLocalizations l10n) {
    switch (status) {
      case 'pending':
        return l10n.inventoryStatusPending;
      case 'in_progress':
        return l10n.inventoryStatusInProgress;
      case 'completed':
        return l10n.inventoryStatusCompleted;
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return context.textSec;
      case 'in_progress':
        return context.warning;
      case 'completed':
        return context.success;
      default:
        return context.textSec;
    }
  }

  Color _getStatusBgColor(String status) {
    switch (status) {
      case 'pending':
        return context.isDark ? AppColors.darkSurface : AppColors.lightSurfaceHigh;
      case 'in_progress':
        return context.isDark ? AppColors.warningBgDark : AppColors.warningBgLight;
      case 'completed':
        return context.isDark ? AppColors.successBgDark : AppColors.successBgLight;
      default:
        return context.isDark ? AppColors.darkSurface : AppColors.lightSurfaceHigh;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm', 'fr');

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.inventoryCountsTitle),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/inventory/counts/new');
        },
        backgroundColor: context.isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
        foregroundColor: context.isDark ? AppColors.darkBackground : AppColors.lightBackground,
        child: const Icon(LucideIcons.plus),
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          String? storeId;
          if (authState is AuthAuthenticatedWithStore) {
            storeId = authState.storeId;
          } else if (authState is AuthPinSessionActive) {
            storeId = authState.storeId;
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
              context.read<InventoryCountBloc>().add(LoadInventoryCounts(currentStore));
            });
          }

          return Column(
            children: [
              // Filter tabs
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.page,
                  vertical: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: context.isDark ? AppColors.darkSurface : AppColors.lightBackground,
                  border: Border(
                    bottom: BorderSide(color: context.border, width: 0.5),
                  ),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(l10n.inventoryFilterAll, null, context.textSec),
                      const SizedBox(width: AppSpacing.sm),
                      _buildFilterChip(l10n.inventoryStatusPending, 'pending', context.textSec),
                      const SizedBox(width: AppSpacing.sm),
                      _buildFilterChip(l10n.inventoryStatusInProgress, 'in_progress', context.warning),
                      const SizedBox(width: AppSpacing.sm),
                      _buildFilterChip(l10n.inventoryStatusCompleted, 'completed', context.success),
                    ],
                  ),
                ),
              ),

              // Counts list
              Expanded(
                child: BlocBuilder<InventoryCountBloc, InventoryCountState>(
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

                    if (state is! InventoryCountsLoaded) {
                      return const SizedBox.shrink();
                    }

                    var counts = state.counts;

                    // Apply filter
                    if (_statusFilter != null) {
                      counts = counts.where((count) => count.status == _statusFilter).toList();
                    }

                    if (counts.isEmpty) {
                      return _buildEmptyState(l10n);
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        if (storeId != null) {
                          context.read<InventoryCountBloc>().add(LoadInventoryCounts(storeId));
                        }
                      },
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                        itemCount: counts.length,
                        separatorBuilder: (context, index) => Divider(
                          height: 0.5,
                          color: context.border,
                        ),
                        itemBuilder: (context, index) {
                          final count = counts[index];
                          return _buildCountCard(count, l10n, dateFormat);
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

  Widget _buildFilterChip(String label, String? status, Color color) {
    final isSelected = _statusFilter == status;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _statusFilter = selected ? status : null;
        });
      },
      backgroundColor: context.isDark ? AppColors.darkBackground : AppColors.lightSurfaceHigh,
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

  Widget _buildCountCard(InventoryCount count, AppLocalizations l10n, DateFormat dateFormat) {
    final statusColor = _getStatusColor(count.status);
    final statusBgColor = _getStatusBgColor(count.status);

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.page,
        vertical: AppSpacing.sm,
      ),
      child: InkWell(
        onTap: () {
          // Navigate to counting screen
          context.push('/inventory/counts/${count.id}');
        },
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row: status badge + date
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusBgColor,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      _getStatusLabel(count.status, l10n),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    dateFormat.format(count.createdAt),
                    style: AppTypography.bodySmall.copyWith(color: context.textSec),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Type and items count
              Row(
                children: [
                  Icon(
                    count.type == 'full' ? LucideIcons.package : LucideIcons.packageCheck,
                    size: 16,
                    color: context.textSec,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    count.type == 'full' ? l10n.inventoryTypeFull : l10n.inventoryTypePartial,
                    style: AppTypography.body.copyWith(
                      color: context.textPri,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    LucideIcons.clipboardList,
                    size: 14,
                    color: context.textSec,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    l10n.inventoryItemsCount(0), // TODO: Get actual count from summary
                    style: AppTypography.bodySmall.copyWith(color: context.textSec),
                  ),
                ],
              ),

              // Notes
              if (count.notes != null && count.notes!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  count.notes!,
                  style: AppTypography.bodySmall.copyWith(
                    color: context.textSec,
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              // Created by
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Icon(
                    LucideIcons.user,
                    size: 14,
                    color: context.textSec,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    l10n.inventoryCreatedBy(count.createdBy),
                    style: AppTypography.bodySmall.copyWith(
                      color: context.textSec,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
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
              LucideIcons.clipboardList,
              size: 48,
              color: context.textHint,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              l10n.inventoryCountsEmpty,
              style: AppTypography.sectionTitle.copyWith(color: context.textPri),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.inventoryCountsEmptyHint,
              style: AppTypography.bodySmall.copyWith(color: context.textSec),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

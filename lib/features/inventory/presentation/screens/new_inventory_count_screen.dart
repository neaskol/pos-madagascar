import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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
import '../bloc/inventory_count_bloc.dart';
import '../bloc/inventory_count_event.dart';
import '../bloc/inventory_count_state.dart';

/// Écran — Nouvel inventaire
/// Permet de créer un comptage d'inventaire (complet ou partiel)
class NewInventoryCountScreen extends StatefulWidget {
  const NewInventoryCountScreen({super.key});

  @override
  State<NewInventoryCountScreen> createState() => _NewInventoryCountScreenState();
}

class _NewInventoryCountScreenState extends State<NewInventoryCountScreen> {
  String _selectedType = 'full'; // 'full' or 'partial'
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedItems = {};
  String? _currentStoreId;

  @override
  void dispose() {
    _notesController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _toggleItem(String itemId) {
    setState(() {
      if (_selectedItems.contains(itemId)) {
        _selectedItems.remove(itemId);
      } else {
        _selectedItems.add(itemId);
      }
    });
  }

  void _startCounting(BuildContext context, String storeId, String employeeId) {
    final l10n = AppLocalizations.of(context)!;

    if (_selectedType == 'partial' && _selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.inventorySelectItems),
          backgroundColor: context.danger,
        ),
      );
      return;
    }

    context.read<InventoryCountBloc>().add(
          CreateInventoryCount(
            storeId: storeId,
            type: _selectedType,
            createdBy: employeeId,
            notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<InventoryCountBloc, InventoryCountState>(
      listener: (context, state) {
        if (state is InventoryCountCreated) {
          // Navigate to counting screen
          context.go('/inventory/counts/${state.count.id}');
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
          title: Text(l10n.inventoryNewCountTitle),
        ),
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
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
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.page),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Type selector
                        Text(
                          l10n.inventoryCountType,
                          style: AppTypography.sectionTitle.copyWith(color: context.textPri),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _buildTypeSelector(l10n),
                        const SizedBox(height: AppSpacing.xl),

                        // Notes field
                        Text(
                          l10n.noteOptional,
                          style: AppTypography.sectionTitle.copyWith(color: context.textPri),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        TextField(
                          controller: _notesController,
                          maxLines: 3,
                          maxLength: 200,
                          decoration: InputDecoration(
                            hintText: l10n.inventoryNotesHint,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppRadius.input),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        // Partial: item selection
                        if (_selectedType == 'partial') ...[
                          Text(
                            l10n.inventorySelectProducts,
                            style: AppTypography.sectionTitle.copyWith(color: context.textPri),
                          ),
                          const SizedBox(height: AppSpacing.md),

                          // Search bar
                          TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: l10n.search,
                              prefixIcon: const Icon(Icons.search),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.close),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() {});
                                      },
                                    )
                                  : null,
                            ),
                            onChanged: (value) => setState(() {}),
                          ),
                          const SizedBox(height: AppSpacing.md),

                          // Selected items count
                          if (_selectedItems.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: AppSpacing.sm,
                              ),
                              decoration: BoxDecoration(
                                color: context.isDark
                                    ? AppColors.darkSurface
                                    : AppColors.lightSurfaceHigh,
                                borderRadius: BorderRadius.circular(AppRadius.sm),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    size: 16,
                                    color: context.success,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    l10n.inventoryItemsSelected(_selectedItems.length),
                                    style: AppTypography.bodySmall.copyWith(
                                      color: context.textPri,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: AppSpacing.md),

                          // Items list
                          _buildItemsList(storeId, l10n),
                        ],
                      ],
                    ),
                  ),
                ),

                // Bottom action button
                Container(
                  padding: const EdgeInsets.all(AppSpacing.page),
                  decoration: BoxDecoration(
                    color: context.isDark ? AppColors.darkSurface : AppColors.lightSurface,
                    border: Border(
                      top: BorderSide(color: context.border, width: 0.5),
                    ),
                  ),
                  child: BlocBuilder<InventoryCountBloc, InventoryCountState>(
                    builder: (context, state) {
                      final isCreating = state is InventoryCountLoading;

                      return SizedBox(
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
                          onPressed: isCreating ? null : () => _startCounting(context, storeId!, employeeId!),
                          child: isCreating
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Text(l10n.inventoryStartCounting),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTypeSelector(AppLocalizations l10n) {
    return Column(
      children: [
        _buildTypeCard(
          type: 'full',
          icon: Icons.inventory_2_outlined,
          title: l10n.inventoryTypeFull,
          description: l10n.inventoryTypeFullDesc,
        ),
        const SizedBox(height: AppSpacing.md),
        _buildTypeCard(
          type: 'partial',
          icon: Icons.check_box_outlined,
          title: l10n.inventoryTypePartial,
          description: l10n.inventoryTypePartialDesc,
        ),
      ],
    );
  }

  Widget _buildTypeCard({
    required String type,
    required IconData icon,
    required String title,
    required String description,
  }) {
    final isSelected = _selectedType == type;

    return Card(
      elevation: isSelected ? 2 : 0,
      color: isSelected
          ? (context.isDark ? AppColors.darkSurfaceHigh : AppColors.lightSurfaceHigh)
          : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: BorderSide(
          color: isSelected ? context.accent : context.border,
          width: isSelected ? 2 : 0.5,
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedType = type;
            if (type == 'full') {
              _selectedItems.clear();
            }
          });
        },
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: isSelected
                      ? context.accent.withValues(alpha: 0.15)
                      : (context.isDark ? AppColors.darkSurface : AppColors.lightSurfaceHigh),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(
                  icon,
                  color: isSelected ? context.accent : context.textSec,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.body.copyWith(
                        color: context.textPri,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: AppTypography.bodySmall.copyWith(color: context.textSec),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: context.accent,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemsList(String storeId, AppLocalizations l10n) {
    return BlocBuilder<ItemBloc, ItemState>(
      builder: (context, state) {
        if (state is ItemLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.xxl),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is! ItemsLoaded) {
          return const SizedBox.shrink();
        }

        final query = _searchController.text.toLowerCase();
        var items = state.items;

        if (query.isNotEmpty) {
          items = items.where((item) {
            return item.name.toLowerCase().contains(query) ||
                (item.sku?.toLowerCase().contains(query) ?? false) ||
                (item.barcode?.toLowerCase().contains(query) ?? false);
          }).toList();
        }

        if (items.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Column(
                children: [
                  Icon(
                    Icons.inventory_outlined,
                    size: 48,
                    color: context.textHint,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    l10n.noProducts,
                    style: AppTypography.body.copyWith(color: context.textSec),
                  ),
                ],
              ),
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: context.border, width: 0.5),
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
          constraints: const BoxConstraints(maxHeight: 400),
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: items.length,
            separatorBuilder: (context, index) => Divider(
              height: 0.5,
              color: context.border,
              indent: 60,
            ),
            itemBuilder: (context, index) {
              final item = items[index];
              final isSelected = _selectedItems.contains(item.id);

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                leading: ClipRRect(
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
                              return Icon(
                                Icons.inventory_2_outlined,
                                color: context.textHint,
                                size: 20,
                              );
                            },
                          )
                        : Icon(
                            Icons.inventory_2_outlined,
                            color: context.textHint,
                            size: 20,
                          ),
                  ),
                ),
                title: Text(
                  item.name,
                  style: AppTypography.body.copyWith(color: context.textPri),
                ),
                subtitle: Text(
                  '${l10n.inventoryCurrentStock}: ${item.inStock}',
                  style: AppTypography.bodySmall.copyWith(color: context.textSec),
                ),
                trailing: Checkbox(
                  value: isSelected,
                  onChanged: (value) => _toggleItem(item.id),
                  activeColor: context.accent,
                ),
                onTap: () => _toggleItem(item.id),
              );
            },
          ),
        );
      },
    );
  }
}

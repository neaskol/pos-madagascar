import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/data/local/app_database.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/theme_ext.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/category_bloc.dart';
import '../bloc/category_event.dart';
import '../bloc/category_state.dart';
import '../bloc/item_bloc.dart';
import '../bloc/item_event.dart';
import '../bloc/item_state.dart';

/// Écran liste des produits avec recherche, filtres et pagination
class ProductsListScreen extends StatefulWidget {
  const ProductsListScreen({super.key});

  @override
  State<ProductsListScreen> createState() => _ProductsListScreenState();
}

class _ProductsListScreenState extends State<ProductsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategoryId = '';
  String _stockFilter = 'all'; // 'all', 'low', 'out'
  String? _currentStoreId;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (_currentStoreId != null) {
      if (query.isEmpty) {
        context.read<ItemBloc>().add(LoadStoreItemsEvent(_currentStoreId!));
      } else {
        context.read<ItemBloc>().add(SearchItemsByNameEvent(_currentStoreId!, query));
      }
    }
  }

  List<Item> _filterItems(List<Item> items) {
    var filtered = items;

    // Filter by category
    if (_selectedCategoryId.isNotEmpty) {
      filtered = filtered.where((item) => item.categoryId == _selectedCategoryId).toList();
    }

    // Filter by stock
    switch (_stockFilter) {
      case 'low':
        filtered = filtered
            .where((item) =>
                item.trackStock == 1 &&
                item.inStock > 0 &&
                item.inStock <= item.lowStockThreshold)
            .toList();
        break;
      case 'out':
        filtered = filtered.where((item) => item.trackStock == 1 && item.inStock == 0).toList();
        break;
      default:
        break;
    }

    return filtered;
  }

  Color _getStockColor(Item item, BuildContext context) {
    if (item.trackStock == 0) return context.textSec;
    if (item.inStock == 0) return context.danger;
    if (item.inStock <= item.lowStockThreshold) return context.warning;
    return context.success;
  }

  String _getStockLabel(Item item) {
    final l10n = AppLocalizations.of(context)!;
    if (item.trackStock == 0) return '';
    if (item.inStock == 0) return l10n.productsOutOfStock;
    if (item.inStock <= item.lowStockThreshold) return l10n.productsLowStock;
    return l10n.productsInStock;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final numberFormat = NumberFormat('#,###', 'fr');

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.productsTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_upload_outlined),
            tooltip: l10n.importItems,
            onPressed: () => context.push('/products/import'),
          ),
        ],
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          String? storeId;
          if (authState is AuthAuthenticatedWithStore) {
            storeId = authState.storeId;
          } else if (authState is AuthPinSessionActive) {
            // For PIN session, we need to get the store ID from user data
            // This will be handled in future implementation
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
              context.read<CategoryBloc>().add(LoadStoreCategoriesEvent(currentStore));
              context.read<ItemBloc>().add(LoadStoreItemsEvent(currentStore));
            });
          }

          return Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.all(AppSpacing.page),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: l10n.productsSearch,
                    prefixIcon: Icon(Icons.search, color: context.textHint),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: context.textHint),
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                        : null,
                  ),
                ),
              ),

              // Filters
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
                child: Row(
                  children: [
                    // Category filter
                    Expanded(
                      child: BlocBuilder<CategoryBloc, CategoryState>(
                        builder: (context, categoryState) {
                          if (categoryState is! CategoriesLoaded) {
                            return const SizedBox.shrink();
                          }

                          return DropdownButtonFormField<String>(
                            value: _selectedCategoryId,
                            decoration: InputDecoration(
                              labelText: l10n.productsCategory,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: AppSpacing.sm,
                              ),
                            ),
                            items: [
                              DropdownMenuItem(
                                value: '',
                                child: Text(l10n.productsAllCategories),
                              ),
                              ...categoryState.categories.map((category) {
                                return DropdownMenuItem(
                                  value: category.id,
                                  child: Text(category.name),
                                );
                              }),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedCategoryId = value ?? '';
                              });
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),

                    // Stock filter
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _stockFilter,
                        decoration: InputDecoration(
                          labelText: l10n.productsStock,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'all',
                            child: Text(l10n.productsFilterAll),
                          ),
                          DropdownMenuItem(
                            value: 'low',
                            child: Text(l10n.productsFilterLowStock),
                          ),
                          DropdownMenuItem(
                            value: 'out',
                            child: Text(l10n.productsFilterOutOfStock),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _stockFilter = value ?? 'all';
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Products list
              Expanded(
                child: BlocBuilder<ItemBloc, ItemState>(
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

                    final filteredItems = _filterItems(itemState.items);

                    if (filteredItems.isEmpty) {
                      return _buildEmptyState(l10n);
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        if (storeId != null) {
                          context.read<ItemBloc>().add(LoadStoreItemsEvent(storeId));
                        }
                      },
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                        itemCount: filteredItems.length,
                        separatorBuilder: (context, index) => Divider(
                          height: 0.5,
                          color: context.border,
                          indent: 76,
                        ),
                        itemBuilder: (context, index) {
                          final item = filteredItems[index];
                          return _buildProductItem(item, l10n, numberFormat);
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go('/products/new');
        },
        child: const Icon(Icons.add),
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
              l10n.productsEmptyTitle,
              style: AppTypography.sectionTitle.copyWith(color: context.textPri),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.productsEmptyDescription,
              style: AppTypography.bodySmall.copyWith(color: context.textSec),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
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
                onPressed: () {
                  context.go('/products/new');
                },
                child: Text(l10n.productsAddProduct),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductItem(Item item, AppLocalizations l10n, NumberFormat numberFormat) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      leading: _buildProductImage(item),
      title: Row(
        children: [
          Expanded(
            child: Text(
              item.name,
              style: AppTypography.body.copyWith(color: context.textPri),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (item.availableForSale == 0) ...[
            const SizedBox(width: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 3,
              ),
              decoration: BoxDecoration(
                color: context.isDark
                    ? AppColors.darkSurface
                    : AppColors.lightSurfaceHigh,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Text(
                l10n.productsNotAvailable,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: context.textHint,
                ),
              ),
            ),
          ],
        ],
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
          const SizedBox(height: 4),
          Row(
            children: [
              // Price
              Text(
                '${numberFormat.format(item.price)} Ar',
                style: AppTypography.body.copyWith(
                  color: context.textPri,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              // Stock
              if (item.trackStock == 1) ...[
                Text(
                  '${item.inStock}',
                  style: AppTypography.bodySmall.copyWith(
                    color: _getStockColor(item, context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  _getStockLabel(item),
                  style: AppTypography.bodySmall.copyWith(
                    color: _getStockColor(item, context),
                    fontSize: 11,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
      onTap: () {
        context.go('/products/${item.id}/edit');
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
            : (item.categoryId != null
                ? _getCategoryColor(item.categoryId!)
                : context.isDark
                    ? AppColors.darkSurface
                    : AppColors.lightSurfaceHigh),
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

  Color _getCategoryColor(String categoryId) {
    // This is a placeholder - in a real implementation,
    // we would look up the category color from the CategoryBloc
    final colors = [
      AppColors.successLight,
      AppColors.warningLight,
      AppColors.dangerLight,
    ];
    return colors[categoryId.hashCode % colors.length].withValues(alpha: 0.3);
  }
}

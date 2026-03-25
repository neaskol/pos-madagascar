import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../products/presentation/bloc/item_bloc.dart';
import '../../../products/presentation/bloc/item_event.dart';
import '../../../products/presentation/bloc/item_state.dart';
import '../../../products/presentation/bloc/category_bloc.dart';
import '../../../products/presentation/bloc/category_event.dart';
import '../../../products/presentation/bloc/category_state.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/cart_bloc.dart';

/// Widget affichant la grille des produits disponibles à la caisse
class ProductGrid extends StatefulWidget {
  const ProductGrid({super.key});

  @override
  State<ProductGrid> createState() => _ProductGridState();
}

class _ProductGridState extends State<ProductGrid> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategoryId;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Charger les produits et catégories au démarrage avec storeId
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticatedWithStore) {
      context.read<ItemBloc>().add(LoadStoreItemsEvent(authState.storeId));
      context
          .read<CategoryBloc>()
          .add(LoadStoreCategoriesEvent(authState.storeId));
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Barre de recherche et filtre
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Barre de recherche
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Rechercher un produit',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              // Dropdown catégorie
              BlocBuilder<CategoryBloc, CategoryState>(
                builder: (context, categoriesState) {
                  final categories = categoriesState is CategoriesLoaded
                      ? categoriesState.categories
                      : [];

                  return DropdownButton<String?>(
                    value: _selectedCategoryId,
                    hint: const Text('Toutes'),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Toutes'),
                      ),
                      ...categories.map(
                        (category) => DropdownMenuItem(
                          value: category.id,
                          child: Text(category.name),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedCategoryId = value;
                      });
                    },
                  );
                },
              ),
            ],
          ),
        ),
        // Grille de produits
        Expanded(
          child: BlocBuilder<ItemBloc, ItemState>(
            builder: (context, state) {
              if (state is ItemLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is ItemError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        state.message,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              if (state is ItemsLoaded) {
                // Filtrer les produits
                var filteredProducts = state.items
                    .where((p) => p.availableForSale == 1)
                    .toList();

                // Filtre par catégorie
                if (_selectedCategoryId != null) {
                  filteredProducts = filteredProducts
                      .where((p) => p.categoryId == _selectedCategoryId)
                      .toList();
                }

                // Filtre par recherche
                if (_searchQuery.isNotEmpty) {
                  filteredProducts = filteredProducts.where((p) {
                    return p.name.toLowerCase().contains(_searchQuery) ||
                        (p.sku?.toLowerCase().contains(_searchQuery) ?? false) ||
                        (p.barcode?.toLowerCase().contains(_searchQuery) ??
                            false);
                  }).toList();
                }

                if (filteredProducts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'Aucun produit trouvé pour "$_searchQuery"'
                              : 'Aucun produit disponible',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount:
                        MediaQuery.of(context).size.width >= 600 ? 4 : 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = filteredProducts[index];
                    return _ProductCard(
                      name: product.name,
                      price: product.price,
                      imageUrl: product.imageUrl,
                      inStock: product.trackStock == 1
                          ? product.inStock
                          : null, // null = pas de suivi
                      onTap: () {
                        // Feedback haptique
                        HapticFeedback.lightImpact();
                        // Ajouter au panier
                        context.read<CartBloc>().add(
                              AddItemToCart(
                                itemId: product.id,
                                name: product.name,
                                unitPrice: product.price,
                                cost: product.cost,
                                imageUrl: product.imageUrl,
                              ),
                            );

                        // Feedback visuel
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${product.name} ajouté au panier'),
                            duration: const Duration(seconds: 1),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    );
                  },
                );
              }

              return const Center(
                child: Text('Chargement des produits...'),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Carte représentant un produit dans la grille
class _ProductCard extends StatelessWidget {
  final String name;
  final int price;
  final String? imageUrl;
  final int? inStock; // null = pas de suivi de stock
  final VoidCallback onTap;

  const _ProductCard({
    required this.name,
    required this.price,
    this.imageUrl,
    this.inStock,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image ou placeholder
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  imageUrl != null && imageUrl!.isNotEmpty
                      ? Image.network(
                          imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildPlaceholder(context);
                          },
                        )
                      : _buildPlaceholder(context),
                  // Badge stock si suivi activé
                  if (inStock != null)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: inStock! > 0
                              ? Colors.green.withOpacity(0.9)
                              : Colors.red.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '$inStock',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Nom et prix
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatPrice(price),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.shopping_bag,
        size: 48,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  String _formatPrice(int amount) {
    // Format: "1 500 Ar"
    final formatted = amount.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]} ',
        );
    return '$formatted Ar';
  }
}

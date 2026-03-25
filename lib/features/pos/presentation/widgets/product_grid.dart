import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/cart_bloc.dart';

/// Widget affichant la grille des produits disponibles à la caisse
/// Pour l'instant, affiche un placeholder - sera connecté au ProductsBloc plus tard
class ProductGrid extends StatefulWidget {
  const ProductGrid({super.key});

  @override
  State<ProductGrid> createState() => _ProductGridState();
}

class _ProductGridState extends State<ProductGrid> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategoryId;

  // Données de démonstration pour Phase 2.1
  final List<_DemoProduct> _demoProducts = [
    _DemoProduct(
      id: 'demo-1',
      name: 'Coca-Cola 1.5L',
      price: 2500,
      cost: 1500,
    ),
    _DemoProduct(
      id: 'demo-2',
      name: 'Pain',
      price: 1000,
      cost: 600,
    ),
    _DemoProduct(
      id: 'demo-3',
      name: 'Riz (1kg)',
      price: 3500,
      cost: 2800,
    ),
    _DemoProduct(
      id: 'demo-4',
      name: 'Huile (1L)',
      price: 5000,
      cost: 4200,
    ),
    _DemoProduct(
      id: 'demo-5',
      name: 'Sucre (1kg)',
      price: 4000,
      cost: 3500,
    ),
    _DemoProduct(
      id: 'demo-6',
      name: 'Café',
      price: 1500,
      cost: 1000,
    ),
  ];

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
                    // TODO: Recherche en temps réel
                  },
                ),
              ),
              const SizedBox(width: 12),
              // Dropdown catégorie (placeholder)
              DropdownButton<String?>(
                value: _selectedCategoryId,
                hint: const Text('Toutes'),
                items: const [
                  DropdownMenuItem(
                    value: null,
                    child: Text('Toutes'),
                  ),
                  // TODO: Charger les catégories dynamiquement
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedCategoryId = value;
                  });
                },
              ),
            ],
          ),
        ),
        // Grille de produits
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount:
                  MediaQuery.of(context).size.width >= 600 ? 4 : 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: _demoProducts.length,
            itemBuilder: (context, index) {
              final product = _demoProducts[index];
              return _ProductCard(
                name: product.name,
                price: product.price,
                onTap: () {
                  // Ajouter au panier
                  context.read<CartBloc>().add(
                        AddItemToCart(
                          itemId: product.id,
                          name: product.name,
                          unitPrice: product.price,
                          cost: product.cost,
                        ),
                      );

                  // Feedback visuel
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${product.name} ajouté au panier'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Classe de démonstration pour Phase 2.1
class _DemoProduct {
  final String id;
  final String name;
  final int price;
  final int cost;

  _DemoProduct({
    required this.id,
    required this.name,
    required this.price,
    required this.cost,
  });
}

/// Carte représentant un produit dans la grille
class _ProductCard extends StatelessWidget {
  final String name;
  final int price;
  final VoidCallback onTap;

  const _ProductCard({
    required this.name,
    required this.price,
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
            // Placeholder pour image
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Icon(
                  Icons.shopping_bag,
                  size: 48,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
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

  String _formatPrice(int amount) {
    // Format: "1 500 Ar"
    final formatted = amount.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]} ',
        );
    return '$formatted Ar';
  }
}

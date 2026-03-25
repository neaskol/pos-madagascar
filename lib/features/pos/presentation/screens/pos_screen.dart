import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/cart_bloc.dart';
import '../widgets/product_grid.dart';
import '../widgets/cart_panel.dart';

/// Écran principal de la caisse (POS)
/// Layout: Produits à gauche (ou en haut), Panier à droite (ou en bas)
class PosScreen extends StatelessWidget {
  const PosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CartBloc(),
      child: const _PosScreenContent(),
    );
  }
}

class _PosScreenContent extends StatelessWidget {
  const _PosScreenContent();

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Caisse'),
        actions: [
          // Bouton scan barcode (placeholder)
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () {
              // TODO: Implémenter scan barcode
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('À venir'),
                ),
              );
            },
          ),
          // Bouton open tickets (placeholder)
          IconButton(
            icon: const Icon(Icons.receipt_long),
            onPressed: () {
              // TODO: Naviguer vers liste des tickets ouverts
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('À venir'),
                ),
              );
            },
          ),
          // Menu options
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'clear':
                  _showClearCartDialog(context);
                  break;
                case 'save':
                  // TODO: Sauvegarder ticket
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('À venir'),
                    ),
                  );
                  break;
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'clear',
                child: Text('Vider le ticket'),
              ),
              PopupMenuItem(
                value: 'save',
                child: Text('Sauvegarder'),
              ),
            ],
          ),
        ],
      ),
      body: isTablet ? _buildTabletLayout() : _buildMobileLayout(),
    );
  }

  /// Layout tablette: colonnes côte à côte
  Widget _buildTabletLayout() {
    return Row(
      children: [
        // Zone produits (58%)
        const Expanded(
          flex: 58,
          child: ProductGrid(),
        ),
        // Séparateur
        const VerticalDivider(width: 1),
        // Zone panier (42%)
        const Expanded(
          flex: 42,
          child: CartPanel(),
        ),
      ],
    );
  }

  /// Layout mobile: produits en plein écran + panier en bottom panel
  Widget _buildMobileLayout() {
    return Column(
      children: [
        // Zone produits (flexible)
        const Expanded(
          child: ProductGrid(),
        ),
        // Séparateur
        const Divider(height: 1),
        // Zone panier (fixe 250px)
        const SizedBox(
          height: 250,
          child: CartPanel(),
        ),
      ],
    );
  }

  void _showClearCartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Vider le ticket'),
        content: const Text('Êtes-vous sûr de vouloir vider le panier ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              context.read<CartBloc>().add(const ClearCart());
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }
}

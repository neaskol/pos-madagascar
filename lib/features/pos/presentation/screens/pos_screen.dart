import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../bloc/cart_bloc.dart';
import '../widgets/product_grid.dart';
import '../widgets/cart_panel.dart';
import '../../data/repositories/tax_repository_impl.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../products/presentation/bloc/item_bloc.dart';
import '../../../products/presentation/bloc/item_state.dart';
import 'barcode_scanner_screen.dart';

/// Écran principal de la caisse (POS)
/// Layout: Produits à gauche (ou en haut), Panier à droite (ou en bas)
class PosScreen extends StatelessWidget {
  const PosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final taxRepository = TaxRepositoryImpl(Supabase.instance.client);

    return BlocProvider(
      create: (context) {
        final bloc = CartBloc(taxRepository: taxRepository);

        // Auto-load taxes if store is available
        if (authState is AuthAuthenticatedWithStore) {
          bloc.add(InitializeCart(authState.storeId));
        }

        return bloc;
      },
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
          // Bouton scan barcode
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: 'Scanner code-barres',
            onPressed: () {
              _openBarcodeScanner(context);
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

  Future<void> _openBarcodeScanner(BuildContext context) async {
    final String? barcode = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (context) => const BarcodeScannerScreen(),
      ),
    );

    if (barcode == null || !context.mounted) return;

    // Rechercher le produit par barcode
    final itemState = context.read<ItemBloc>().state;

    if (itemState is! ItemsLoaded) {
      _showMessage(context, 'Produits non chargés');
      return;
    }

    // Chercher produit avec ce barcode
    final product = itemState.items.where((item) {
      final itemBarcode = item.barcode;
      return itemBarcode != null &&
             itemBarcode.isNotEmpty &&
             itemBarcode == barcode;
    }).firstOrNull;

    if (product == null) {
      _showMessage(
        context,
        'Aucun produit trouvé avec le code: $barcode',
        isError: true,
      );
      return;
    }

    // Ajouter au panier
    context.read<CartBloc>().add(AddItemToCart(
      itemId: product.id,
      name: product.name,
      unitPrice: product.price,
      cost: product.cost,
    ));

    _showMessage(
      context,
      '${product.name} ajouté au panier',
      isError: false,
    );
  }

  void _showMessage(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

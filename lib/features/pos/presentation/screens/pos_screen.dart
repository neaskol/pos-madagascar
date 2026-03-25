import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../bloc/cart_bloc.dart';
import '../widgets/product_grid.dart';
import '../widgets/cart_panel.dart';
import '../../data/repositories/tax_repository_impl.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

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
          // Bouton scan barcode (placeholder)
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: 'Scanner code-barres',
            onPressed: () {
              _showBarcodeScannerPlaceholder(context);
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

  void _showBarcodeScannerPlaceholder(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.qr_code_scanner, size: 48),
        title: const Text('Scanner Code-Barres'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Fonctionnalité à venir',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text(
              'Le scanner de code-barres permettra d\'ajouter rapidement des produits au panier en scannant leur code-barres.',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            Text(
              'Pour l\'instant, utilisez la recherche ou sélectionnez directement les produits.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Compris'),
          ),
        ],
      ),
    );
  }
}

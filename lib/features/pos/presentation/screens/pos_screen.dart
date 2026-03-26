import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../l10n/app_localizations.dart';
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

    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.posScreenTitle),
        actions: [
          // Bouton scan barcode
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: l10n.scanBarcode,
            onPressed: () {
              _openBarcodeScanner(context);
            },
          ),
          // Bouton open tickets (placeholder)
          IconButton(
            icon: const Icon(Icons.receipt_long),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.comingSoon),
                ),
              );
            },
          ),
          // Menu options
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'history':
                  context.push('/pos/receipts');
                  break;
                case 'clear':
                  _showClearCartDialog(context);
                  break;
                case 'save':
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.comingSoon),
                    ),
                  );
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'history',
                child: Row(
                  children: [
                    const Icon(Icons.history),
                    const SizedBox(width: 8),
                    Text(l10n.salesHistory),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'clear',
                child: Text(l10n.clearTicket),
              ),
              PopupMenuItem(
                value: 'save',
                child: Text(l10n.saveTicket),
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
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.clearTicket),
        content: Text(l10n.clearTicketConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              context.read<CartBloc>().add(const ClearCart());
              Navigator.of(dialogContext).pop();
            },
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }

  Future<void> _openBarcodeScanner(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final String? barcode = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (context) => const BarcodeScannerScreen(),
      ),
    );

    if (barcode == null || !context.mounted) return;

    // Rechercher le produit par barcode
    final itemState = context.read<ItemBloc>().state;

    if (itemState is! ItemsLoaded) {
      _showMessage(context, l10n.productsNotLoaded);
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
        l10n.productNotFound(barcode),
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
      '${product.name} ${l10n.addedToCart}',
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

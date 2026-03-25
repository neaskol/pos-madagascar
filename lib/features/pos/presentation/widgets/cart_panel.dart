import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/cart_bloc.dart';
import '../screens/payment_screen.dart';
import '../../domain/entities/cart_item.dart';
import 'item_discount_dialog.dart';
import 'cart_discount_dialog.dart';

/// Panel affichant le panier et le bouton de paiement
class CartPanel extends StatelessWidget {
  const CartPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        if (state is CartEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_cart_outlined,
                  size: 64,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  'Panier vide',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          );
        }

        if (state is CartLoaded) {
          return Column(
            children: [
              // Liste des items
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.items.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = state.items[index];
                    return _CartItemTile(item: item);
                  },
                ),
              ),
              // Séparateur
              const Divider(height: 1, thickness: 2),
              // Zone totaux
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Sous-total brut
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Sous-total',
                          style: TextStyle(fontSize: 14),
                        ),
                        Text(
                          _formatPrice(state.grossSubtotal),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    // Remises items (si présentes)
                    if (state.itemDiscountsTotal > 0) ...[
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Remises items',
                            style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                          Text(
                            '- ${_formatPrice(state.itemDiscountsTotal)}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ],
                      ),
                    ],

                    // Remises panier (si présentes)
                    if (state.cartDiscountAmount > 0) ...[
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Remise panier',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.local_offer,
                                size: 14,
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ],
                          ),
                          Text(
                            '- ${_formatPrice(state.cartDiscountAmount)}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ],
                      ),
                    ],

                    // Bouton ajouter remise panier
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => BlocProvider.value(
                            value: BlocProvider.of<CartBloc>(context),
                            child: CartDiscountDialog(
                              subtotal: state.subtotalAfterItemDiscounts,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Remise panier'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),

                    // Taxes (si présentes)
                    if (state.totalTaxAmount > 0) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Taxes',
                            style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            '+ ${_formatPrice(state.totalTaxAmount)}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 12),

                    // Total (en gros, en vert)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'TOTAL',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _formatPrice(state.total),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Bouton Payer
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: FilledButton(
                        onPressed: () {
                          // Feedback haptique
                          HapticFeedback.mediumImpact();
                          // Naviguer vers écran paiement
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => PaymentScreen(
                                items: state.items,
                                subtotal: state.subtotalAfterAllDiscounts,
                                taxAmount: state.totalTaxAmount,
                                discountAmount: state.totalDiscountAmount,
                                total: state.total,
                              ),
                            ),
                          );
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                        ),
                        child: const Text(
                          'PAYER',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }

        return const SizedBox.shrink();
      },
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

/// Tuile représentant un item dans le panier
class _CartItemTile extends StatelessWidget {
  final CartItem item;

  const _CartItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        HapticFeedback.mediumImpact();
        context.read<CartBloc>().add(RemoveItemFromCart(item.id));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.name} retiré du panier'),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      background: Container(
        color: Theme.of(context).colorScheme.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            // Image ou placeholder
            if (item.imageUrl != null && item.imageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  item.imageUrl!,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildPlaceholder(context);
                  },
                ),
              )
            else
              _buildPlaceholder(context),
            const SizedBox(width: 12),
            // Nom et contrôles quantité
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nom du produit (cliquable pour remise)
                  InkWell(
                    onTap: () {
                      // Afficher dialog remise item
                      showDialog(
                        context: context,
                        builder: (context) => BlocProvider.value(
                          value: BlocProvider.of<CartBloc>(context),
                          child: ItemDiscountDialog(item: item),
                        ),
                      );
                    },
                    child: Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Afficher variant si présent
                  if (item.itemVariantId != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Variant: ${item.itemVariantId}', // TODO: Afficher displayLabel depuis DAO
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  // Afficher modifiers si présents
                  if (item.modifiers != null && item.modifiers!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      _formatModifiers(item.modifiers!),
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 8),
                  // Contrôles quantité (+ / TextField / -)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Bouton -
                      IconButton(
                        onPressed: () {
                          final newQty = item.quantity - 1;
                          if (newQty > 0) {
                            context.read<CartBloc>().add(
                                  UpdateItemQuantity(
                                    cartItemId: item.id,
                                    quantity: newQty,
                                  ),
                                );
                          } else {
                            // Si quantité = 0, retirer l'item
                            context
                                .read<CartBloc>()
                                .add(RemoveItemFromCart(item.id));
                          }
                        },
                        icon: const Icon(Icons.remove_circle_outline),
                        iconSize: 24,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Quantité (cliquable pour édition manuelle)
                      InkWell(
                        onTap: () => _showQuantityDialog(context, item),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(context)
                                  .colorScheme
                                  .outlineVariant,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'x${item.quantity.toStringAsFixed(item.quantity.truncateToDouble() == item.quantity ? 0 : 2)}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Bouton +
                      IconButton(
                        onPressed: () {
                          context.read<CartBloc>().add(
                                UpdateItemQuantity(
                                  cartItemId: item.id,
                                  quantity: item.quantity + 1,
                                ),
                              );
                        },
                        icon: const Icon(Icons.add_circle_outline),
                        iconSize: 24,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Prix ligne
            Text(
              _formatPrice(item.lineTotal),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(
        Icons.image,
        size: 24,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  String _formatPrice(int amount) {
    final formatted = amount.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]} ',
        );
    return '$formatted Ar';
  }

  void _showQuantityDialog(BuildContext context, CartItem item) {
    final controller = TextEditingController(
      text: item.quantity.toStringAsFixed(
          item.quantity.truncateToDouble() == item.quantity ? 0 : 2),
    );

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(item.name),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Quantité',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              final newQuantity = double.tryParse(controller.text);
              if (newQuantity != null && newQuantity > 0) {
                context.read<CartBloc>().add(
                      UpdateItemQuantity(
                        cartItemId: item.id,
                        quantity: newQuantity,
                      ),
                    );
              }
              Navigator.of(dialogContext).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Formate les modifiers pour affichage
  /// Ex: "Grande • Lait entier (+500 Ar)"
  String _formatModifiers(Map<String, dynamic> modifiers) {
    if (modifiers['selected_options'] == null) return '';

    final options = modifiers['selected_options'] as List;
    return options.map((opt) {
      final name = opt['option_name'] as String;
      final priceAddition = opt['price_addition'] as int? ?? 0;
      if (priceAddition > 0) {
        return '$name (+${_formatPrice(priceAddition)})';
      }
      return name;
    }).join(' • ');
  }
}

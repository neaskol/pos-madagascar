import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/discount.dart';
import '../bloc/cart_bloc.dart';

/// Dialog pour appliquer une remise sur le panier entier
class CartDiscountDialog extends StatefulWidget {
  final int subtotal; // Subtotal actuel du panier

  const CartDiscountDialog({
    super.key,
    required this.subtotal,
  });

  @override
  State<CartDiscountDialog> createState() => _CartDiscountDialogState();
}

class _CartDiscountDialogState extends State<CartDiscountDialog> {
  DiscountType _discountType = DiscountType.percentage;
  final _valueController = TextEditingController();
  final _nameController = TextEditingController();
  bool _restrictedAccess = false;
  String? _errorMessage;

  @override
  void dispose() {
    _valueController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  String _formatPrice(int amount) {
    return '${NumberFormat('#,###', 'fr').format(amount)} Ar';
  }

  int _calculatePreview() {
    final value = double.tryParse(_valueController.text) ?? 0;
    if (value <= 0) return 0;

    final discount = Discount(
      type: _discountType,
      target: DiscountTarget.cart,
      value: value,
    );

    return discount.calculateAmount(widget.subtotal);
  }

  void _validateAndApply() {
    final value = double.tryParse(_valueController.text);

    if (value == null || value <= 0) {
      setState(() {
        _errorMessage = 'Veuillez entrer une valeur valide';
      });
      return;
    }

    if (_discountType == DiscountType.percentage && value > 100) {
      setState(() {
        _errorMessage = 'La remise ne peut pas dépasser 100%';
      });
      return;
    }

    if (_discountType == DiscountType.fixedAmount && value > widget.subtotal) {
      setState(() {
        _errorMessage = 'La remise ne peut pas dépasser le total du panier';
      });
      return;
    }

    // Créer la remise
    final discount = Discount(
      type: _discountType,
      target: DiscountTarget.cart,
      value: value,
      name: _nameController.text.trim().isEmpty
          ? null
          : _nameController.text.trim(),
      restrictedAccess: _restrictedAccess,
    );

    // Dispatcher l'event
    context.read<CartBloc>().add(ApplyDiscountToCart(discount));

    // Fermer le dialog
    Navigator.of(context).pop();

    // Feedback haptique
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final preview = _calculatePreview();

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.shopping_cart_checkout,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Remise sur panier',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Appliquer une remise globale sur tout le panier',
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),

            // Cart subtotal info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Sous-total panier'),
                  Text(
                    _formatPrice(widget.subtotal),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Discount type toggle
            SegmentedButton<DiscountType>(
              segments: const [
                ButtonSegment(
                  value: DiscountType.percentage,
                  label: Text('Pourcentage (%)'),
                  icon: Icon(Icons.percent),
                ),
                ButtonSegment(
                  value: DiscountType.fixedAmount,
                  label: Text('Montant fixe (Ar)'),
                  icon: Icon(Icons.money),
                ),
              ],
              selected: {_discountType},
              onSelectionChanged: (Set<DiscountType> selection) {
                setState(() {
                  _discountType = selection.first;
                  _valueController.clear();
                  _errorMessage = null;
                });
              },
            ),
            const SizedBox(height: 16),

            // Value input
            TextField(
              controller: _valueController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: _discountType == DiscountType.percentage
                    ? 'Pourcentage'
                    : 'Montant en Ariary',
                hintText: _discountType == DiscountType.percentage
                    ? 'Ex: 5'
                    : 'Ex: 5000',
                suffixText:
                    _discountType == DiscountType.percentage ? '%' : 'Ar',
                errorText: _errorMessage,
                border: const OutlineInputBorder(),
                helperText: _discountType == DiscountType.percentage
                    ? 'La remise s\'appliquera sur le total après remises items'
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _errorMessage = null;
                });
              },
            ),
            const SizedBox(height: 16),

            // Optional name
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nom (optionnel)',
                hintText: 'Ex: Client fidèle',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Restricted access checkbox
            CheckboxListTile(
              value: _restrictedAccess,
              onChanged: (value) {
                setState(() {
                  _restrictedAccess = value ?? false;
                });
              },
              title: const Text('Accès restreint'),
              subtitle: const Text(
                'Seuls les managers peuvent appliquer cette remise',
                style: TextStyle(fontSize: 12),
              ),
              controlAffinity: ListTileControlAffinity.leading,
            ),

            // Preview
            if (preview > 0) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Montant remise',
                          style: TextStyle(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '- ${_formatPrice(preview)}',
                          style: TextStyle(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Nouveau total',
                          style: TextStyle(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _formatPrice(widget.subtotal - preview),
                          style: TextStyle(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Annuler'),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: _validateAndApply,
                  child: const Text('Appliquer'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/entities/discount.dart';
import '../bloc/cart_bloc.dart';

/// Dialog pour appliquer une remise sur un item spécifique du panier
class ItemDiscountDialog extends StatefulWidget {
  final CartItem item;

  const ItemDiscountDialog({
    super.key,
    required this.item,
  });

  @override
  State<ItemDiscountDialog> createState() => _ItemDiscountDialogState();
}

class _ItemDiscountDialogState extends State<ItemDiscountDialog> {
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
      target: DiscountTarget.item,
      value: value,
    );

    return discount.calculateAmount(widget.item.subtotal);
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

    if (_discountType == DiscountType.fixedAmount &&
        value > widget.item.subtotal) {
      setState(() {
        _errorMessage = 'La remise ne peut pas dépasser le prix de l\'item';
      });
      return;
    }

    // Créer la remise
    final discount = Discount(
      type: _discountType,
      target: DiscountTarget.item,
      value: value,
      name: _nameController.text.trim().isEmpty
          ? null
          : _nameController.text.trim(),
      restrictedAccess: _restrictedAccess,
    );

    // Dispatcher l'event
    context.read<CartBloc>().add(
          ApplyDiscountToItem(
            cartItemId: widget.item.id,
            discount: discount,
          ),
        );

    // Fermer le dialog
    Navigator.of(context).pop();

    // Feedback haptique
    HapticFeedback.lightImpact();
  }

  void _removeDiscount(Discount discount) {
    context.read<CartBloc>().add(
          RemoveDiscountFromItem(
            cartItemId: widget.item.id,
            discount: discount,
          ),
        );

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
                  Icons.discount,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Remise sur item',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.item.name,
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Item price info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Prix item'),
                  Text(
                    _formatPrice(widget.item.subtotal),
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
                    ? 'Ex: 10'
                    : 'Ex: 1000',
                suffixText:
                    _discountType == DiscountType.percentage ? '%' : 'Ar',
                errorText: _errorMessage,
                border: const OutlineInputBorder(),
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
                hintText: 'Ex: Promotion été',
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
            const SizedBox(height: 16),

            // Preview
            if (preview > 0)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Montant remise',
                          style: TextStyle(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          _formatPrice(preview),
                          style: TextStyle(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Nouveau prix',
                          style: TextStyle(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          _formatPrice(widget.item.subtotal - preview),
                          style: TextStyle(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            // Existing discounts
            if (widget.item.discounts.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text(
                'Remises actives',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ...widget.item.discounts.map((discount) {
                return Card(
                  child: ListTile(
                    leading: Icon(
                      Icons.local_offer,
                      color: theme.colorScheme.secondary,
                    ),
                    title: Text(discount.toString()),
                    subtitle: Text(
                      'Montant: ${_formatPrice(discount.calculateAmount(widget.item.subtotal))}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _removeDiscount(discount),
                    ),
                  ),
                );
              }),
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

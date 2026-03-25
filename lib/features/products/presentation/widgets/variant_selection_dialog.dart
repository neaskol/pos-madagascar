import 'package:flutter/material.dart';
import '../../domain/entities/item_variant.dart';

/// Dialog de sélection de variant d'un produit
/// Affiché quand un produit a plusieurs variants (taille, couleur, etc.)
class VariantSelectionDialog extends StatefulWidget {
  final String itemName;
  final List<ItemVariant> variants;

  const VariantSelectionDialog({
    super.key,
    required this.itemName,
    required this.variants,
  });

  @override
  State<VariantSelectionDialog> createState() => _VariantSelectionDialogState();
}

class _VariantSelectionDialogState extends State<VariantSelectionDialog> {
  ItemVariant? _selectedVariant;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.itemName),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choisir un variant',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            // Liste des variants
            ...widget.variants.map((variant) {
              final isSelected = _selectedVariant?.id == variant.id;
              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedVariant = variant;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primaryContainer
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Image si disponible
                      if (variant.imageUrl != null &&
                          variant.imageUrl!.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.network(
                            variant.imageUrl!,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildPlaceholder(context);
                            },
                          ),
                        )
                      else
                        _buildPlaceholder(context),
                      const SizedBox(width: 12),
                      // Informations
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              variant.displayLabel,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Theme.of(context).colorScheme.onPrimaryContainer
                                    : null,
                              ),
                            ),
                            if (variant.price != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                _formatPrice(variant.price!),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.onPrimaryContainer
                                      : Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      // Checkmark si sélectionné
                      if (isSelected)
                        Icon(
                          Icons.check_circle,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: _selectedVariant == null
              ? null
              : () => Navigator.of(context).pop(_selectedVariant),
          child: const Text('Ajouter'),
        ),
      ],
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(
        Icons.image,
        size: 20,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  String _formatPrice(int amount) {
    final formatted = amount.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\\d))'),
          (match) => '${match[1]} ',
        );
    return '$formatted Ar';
  }
}

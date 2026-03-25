import 'package:flutter/material.dart';
import '../../domain/entities/modifier.dart';
import '../../domain/entities/modifier_option.dart';

/// Sélections de modifiers pour un item
class ModifiersSelectionResult {
  final Map<String, ModifierOption> selectedOptions;

  ModifiersSelectionResult(this.selectedOptions);

  /// Calcul du prix additionnel total
  int get totalPriceAddition => selectedOptions.values
      .fold(0, (sum, option) => sum + option.priceAddition);
}

/// Dialog de sélection de modifiers
/// Supporte les modifiers obligatoires (forced modifiers = gap Loyverse !)
class ModifiersSelectionDialog extends StatefulWidget {
  final String itemName;
  final List<Modifier> modifiers;

  const ModifiersSelectionDialog({
    super.key,
    required this.itemName,
    required this.modifiers,
  });

  @override
  State<ModifiersSelectionDialog> createState() =>
      _ModifiersSelectionDialogState();
}

class _ModifiersSelectionDialogState extends State<ModifiersSelectionDialog> {
  // Map<modifierId, selectedOptionId>
  final Map<String, ModifierOption> _selectedOptions = {};

  @override
  Widget build(BuildContext context) {
    // Vérifier si tous les modifiers obligatoires ont une sélection
    final canConfirm = widget.modifiers
        .where((m) => m.isRequired)
        .every((m) => _selectedOptions.containsKey(m.id));

    return AlertDialog(
      title: Text(widget.itemName),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Liste des modifiers
              ...widget.modifiers.map((modifier) {
                return _buildModifierSection(modifier);
              }),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: !canConfirm
              ? null
              : () => Navigator.of(context)
                  .pop(ModifiersSelectionResult(_selectedOptions)),
          child: const Text('Ajouter'),
        ),
      ],
    );
  }

  Widget _buildModifierSection(Modifier modifier) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: modifier.isRequired
            ? Border.all(
                color: Theme.of(context).colorScheme.error,
                width: 1.5,
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nom du modifier
          Row(
            children: [
              Text(
                modifier.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (modifier.isRequired) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'OBLIGATOIRE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          // Options
          ...modifier.options.map((option) {
            final isSelected = _selectedOptions[modifier.id]?.id == option.id;
            return InkWell(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    // Toggle off si non obligatoire
                    if (!modifier.isRequired) {
                      _selectedOptions.remove(modifier.id);
                    }
                  } else {
                    _selectedOptions[modifier.id] = option;
                  }
                });
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
                child: Row(
                  children: [
                    // Radio button
                    Icon(
                      isSelected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      size: 20,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 12),
                    // Nom option
                    Expanded(
                      child: Text(
                        option.name,
                        style: TextStyle(
                          fontSize: 13,
                          color: isSelected
                              ? Theme.of(context).colorScheme.onPrimaryContainer
                              : null,
                        ),
                      ),
                    ),
                    // Prix additionnel
                    if (option.priceAddition > 0)
                      Text(
                        '+ ${_formatPrice(option.priceAddition)}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Theme.of(context).colorScheme.onPrimaryContainer
                              : Theme.of(context).colorScheme.primary,
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
        ],
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

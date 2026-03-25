import 'package:flutter/material.dart';
import '../../../products/domain/entities/item_variant.dart';
import '../../../products/domain/entities/modifier.dart';
import '../../../products/presentation/widgets/variant_selection_dialog.dart';
import '../../../products/presentation/widgets/modifiers_selection_dialog.dart';

/// Helper pour gérer la sélection de variants et modifiers
/// avant d'ajouter un produit au panier
class VariantModifierHelper {
  /// Affiche les dialogs de sélection si nécessaire
  /// Retourne un Map avec les données sélectionnées ou null si annulé
  static Future<VariantModifierSelection?> showSelectionDialogs({
    required BuildContext context,
    required String itemName,
    List<ItemVariant>? variants,
    List<Modifier>? modifiers,
  }) async {
    ItemVariant? selectedVariant;
    ModifiersSelectionResult? selectedModifiers;

    // Étape 1 : Sélection variant si présents
    if (variants != null && variants.isNotEmpty) {
      selectedVariant = await showDialog<ItemVariant>(
        context: context,
        builder: (context) => VariantSelectionDialog(
          itemName: itemName,
          variants: variants,
        ),
      );

      // Annulation
      if (selectedVariant == null && context.mounted) return null;
    }

    // Étape 2 : Sélection modifiers si présents
    if (modifiers != null && modifiers.isNotEmpty) {
      if (!context.mounted) return null;

      selectedModifiers = await showDialog<ModifiersSelectionResult>(
        context: context,
        builder: (context) => ModifiersSelectionDialog(
          itemName: itemName,
          modifiers: modifiers,
        ),
      );

      // Annulation
      if (selectedModifiers == null) return null;
    }

    return VariantModifierSelection(
      variant: selectedVariant,
      modifiers: selectedModifiers,
    );
  }
}

/// Résultat de la sélection variant + modifiers
class VariantModifierSelection {
  final ItemVariant? variant;
  final ModifiersSelectionResult? modifiers;

  VariantModifierSelection({
    this.variant,
    this.modifiers,
  });

  /// ID du variant sélectionné (null si pas de variant)
  String? get variantId => variant?.id;

  /// Prix du variant (null si utilise prix parent)
  int? get variantPrice => variant?.price;

  /// Prix additionnel des modifiers
  int get modifiersPriceAddition => modifiers?.totalPriceAddition ?? 0;

  /// Données modifiers en JSON pour CartItem
  Map<String, dynamic>? get modifiersJson {
    if (modifiers == null) return null;
    return {
      'selected_options': modifiers!.selectedOptions.entries
          .map((e) => {
                'modifier_id': e.key,
                'option_id': e.value.id,
                'option_name': e.value.name,
                'price_addition': e.value.priceAddition,
              })
          .toList(),
    };
  }
}

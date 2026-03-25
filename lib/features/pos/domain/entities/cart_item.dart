import 'package:equatable/equatable.dart';
import 'discount.dart';
import 'tax.dart';

/// Entité représentant un item dans le panier de la caisse
class CartItem extends Equatable {
  final String id; // ID temporaire pour le panier
  final String itemId; // ID du produit
  final String? itemVariantId; // ID du variant si applicable
  final String name;
  final int unitPrice; // Prix unitaire en Ariary (int)
  final int cost; // Coût en Ariary
  final double quantity; // Quantité (peut être décimale pour les items au poids)
  final List<Discount> discounts; // Remises appliquées à cet item
  final List<Tax> taxes; // Taxes appliquées à cet item
  final Map<String, dynamic>? modifiers; // Modifiers sélectionnés
  final String? imageUrl;

  const CartItem({
    required this.id,
    required this.itemId,
    this.itemVariantId,
    required this.name,
    required this.unitPrice,
    required this.cost,
    this.quantity = 1.0,
    this.discounts = const [],
    this.taxes = const [],
    this.modifiers,
    this.imageUrl,
  });

  /// Calcule le subtotal de la ligne (quantité × prix)
  int get subtotal {
    return (quantity * unitPrice).round();
  }

  /// Calcule le montant total des remises
  int get totalDiscountAmount {
    if (discounts.isEmpty) return 0;
    final basePrice = subtotal;
    return basePrice - applyMultipleDiscounts(basePrice, discounts);
  }

  /// Calcule le montant total des taxes
  int get totalTaxAmount {
    if (taxes.isEmpty) return 0;
    // Taxes apply to price after discounts
    final priceAfterDiscount = subtotal - totalDiscountAmount;
    return calculateTotalTaxAmount(priceAfterDiscount, taxes);
  }

  /// Calcule le total de la ligne (quantité × prix - remise + taxe)
  int get lineTotal {
    return subtotal - totalDiscountAmount + totalTaxAmount;
  }

  /// Copie avec modifications
  CartItem copyWith({
    String? id,
    String? itemId,
    String? itemVariantId,
    String? name,
    int? unitPrice,
    int? cost,
    double? quantity,
    List<Discount>? discounts,
    List<Tax>? taxes,
    Map<String, dynamic>? modifiers,
    String? imageUrl,
  }) {
    return CartItem(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      itemVariantId: itemVariantId ?? this.itemVariantId,
      name: name ?? this.name,
      unitPrice: unitPrice ?? this.unitPrice,
      cost: cost ?? this.cost,
      quantity: quantity ?? this.quantity,
      discounts: discounts ?? this.discounts,
      taxes: taxes ?? this.taxes,
      modifiers: modifiers ?? this.modifiers,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  @override
  List<Object?> get props => [
        id,
        itemId,
        itemVariantId,
        name,
        unitPrice,
        cost,
        quantity,
        discounts,
        taxes,
        modifiers,
        imageUrl,
      ];
}

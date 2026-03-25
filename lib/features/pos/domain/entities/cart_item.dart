import 'package:equatable/equatable.dart';

/// Entité représentant un item dans le panier de la caisse
class CartItem extends Equatable {
  final String id; // ID temporaire pour le panier
  final String itemId; // ID du produit
  final String? itemVariantId; // ID du variant si applicable
  final String name;
  final int unitPrice; // Prix unitaire en Ariary (int)
  final int cost; // Coût en Ariary
  final double quantity; // Quantité (peut être décimale pour les items au poids)
  final int discountAmount; // Remise en Ariary
  final int taxAmount; // Taxe en Ariary
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
    this.discountAmount = 0,
    this.taxAmount = 0,
    this.modifiers,
    this.imageUrl,
  });

  /// Calcule le total de la ligne (quantité × prix - remise + taxe)
  int get lineTotal {
    final subtotal = (quantity * unitPrice).round();
    return subtotal - discountAmount + taxAmount;
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
    int? discountAmount,
    int? taxAmount,
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
      discountAmount: discountAmount ?? this.discountAmount,
      taxAmount: taxAmount ?? this.taxAmount,
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
        discountAmount,
        taxAmount,
        modifiers,
        imageUrl,
      ];
}

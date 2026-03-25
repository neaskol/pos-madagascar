import 'package:equatable/equatable.dart';

/// Variant d'un item (ex: "Taille: Grande", "Couleur: Rouge")
/// Un item peut avoir jusqu'à 3 options de variants (limitation Loyverse)
class ItemVariant extends Equatable {
  final String id;
  final String itemId;
  final String storeId;

  // Options (max 3)
  final String? option1Name; // ex: "Taille"
  final String? option1Value; // ex: "Grande"
  final String? option2Name; // ex: "Couleur"
  final String? option2Value; // ex: "Rouge"
  final String? option3Name; // ex: "Matériau"
  final String? option3Value; // ex: "Coton"

  // SKU et barcode spécifiques
  final String? sku;
  final String? barcode;

  // Prix et coût (null = hérite du parent item)
  final int? price;
  final int? cost;

  // Stock
  final int inStock;
  final int lowStockThreshold;

  // Image
  final String? imageUrl;

  // Métadonnées
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;

  const ItemVariant({
    required this.id,
    required this.itemId,
    required this.storeId,
    this.option1Name,
    this.option1Value,
    this.option2Name,
    this.option2Value,
    this.option3Name,
    this.option3Value,
    this.sku,
    this.barcode,
    this.price,
    this.cost,
    this.inStock = 0,
    this.lowStockThreshold = 0,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
  });

  /// Label affiché (ex: "Grande - Rouge")
  String get displayLabel {
    final parts = <String>[];
    if (option1Value != null) parts.add(option1Value!);
    if (option2Value != null) parts.add(option2Value!);
    if (option3Value != null) parts.add(option3Value!);
    return parts.join(' - ');
  }

  ItemVariant copyWith({
    String? id,
    String? itemId,
    String? storeId,
    String? option1Name,
    String? option1Value,
    String? option2Name,
    String? option2Value,
    String? option3Name,
    String? option3Value,
    String? sku,
    String? barcode,
    int? price,
    int? cost,
    int? inStock,
    int? lowStockThreshold,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
  }) {
    return ItemVariant(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      storeId: storeId ?? this.storeId,
      option1Name: option1Name ?? this.option1Name,
      option1Value: option1Value ?? this.option1Value,
      option2Name: option2Name ?? this.option2Name,
      option2Value: option2Value ?? this.option2Value,
      option3Name: option3Name ?? this.option3Name,
      option3Value: option3Value ?? this.option3Value,
      sku: sku ?? this.sku,
      barcode: barcode ?? this.barcode,
      price: price ?? this.price,
      cost: cost ?? this.cost,
      inStock: inStock ?? this.inStock,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  @override
  List<Object?> get props => [
        id,
        itemId,
        storeId,
        option1Name,
        option1Value,
        option2Name,
        option2Value,
        option3Name,
        option3Value,
        sku,
        barcode,
        price,
        cost,
        inStock,
        lowStockThreshold,
        imageUrl,
        createdAt,
        updatedAt,
        createdBy,
      ];
}

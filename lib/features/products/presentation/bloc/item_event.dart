import 'package:equatable/equatable.dart';

/// Events pour la gestion des items (produits)
abstract class ItemEvent extends Equatable {
  const ItemEvent();

  @override
  List<Object?> get props => [];
}

/// Charger tous les items d'un magasin
class LoadStoreItemsEvent extends ItemEvent {
  final String storeId;

  const LoadStoreItemsEvent(this.storeId);

  @override
  List<Object?> get props => [storeId];
}

/// Charger un item par ID
class LoadItemByIdEvent extends ItemEvent {
  final String itemId;

  const LoadItemByIdEvent(this.itemId);

  @override
  List<Object?> get props => [itemId];
}

/// Charger un item par SKU
class LoadItemBySkuEvent extends ItemEvent {
  final String storeId;
  final String sku;

  const LoadItemBySkuEvent(this.storeId, this.sku);

  @override
  List<Object?> get props => [storeId, sku];
}

/// Charger un item par code-barres
class LoadItemByBarcodeEvent extends ItemEvent {
  final String storeId;
  final String barcode;

  const LoadItemByBarcodeEvent(this.storeId, this.barcode);

  @override
  List<Object?> get props => [storeId, barcode];
}

/// Charger les items d'une catégorie
class LoadCategoryItemsEvent extends ItemEvent {
  final String categoryId;

  const LoadCategoryItemsEvent(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}

/// Charger les items disponibles à la vente
class LoadAvailableItemsEvent extends ItemEvent {
  final String storeId;

  const LoadAvailableItemsEvent(this.storeId);

  @override
  List<Object?> get props => [storeId];
}

/// Rechercher des items par nom
class SearchItemsByNameEvent extends ItemEvent {
  final String storeId;
  final String query;

  const SearchItemsByNameEvent(this.storeId, this.query);

  @override
  List<Object?> get props => [storeId, query];
}

/// Créer un nouvel item
class CreateItemEvent extends ItemEvent {
  final String id;
  final String storeId;
  final String name;
  final String? description;
  final String? sku;
  final String? barcode;
  final String? categoryId;
  final int price;
  final int cost;
  final bool costIsPercentage;
  final String soldBy;
  final bool availableForSale;
  final bool trackStock;
  final int inStock;
  final int lowStockThreshold;
  final bool isComposite;
  final bool useProduction;
  final String? imageUrl;
  final int averageCost;

  const CreateItemEvent({
    required this.id,
    required this.storeId,
    required this.name,
    this.description,
    this.sku,
    this.barcode,
    this.categoryId,
    required this.price,
    this.cost = 0,
    this.costIsPercentage = false,
    this.soldBy = 'piece',
    this.availableForSale = true,
    this.trackStock = false,
    this.inStock = 0,
    this.lowStockThreshold = 0,
    this.isComposite = false,
    this.useProduction = false,
    this.imageUrl,
    this.averageCost = 0,
  });

  @override
  List<Object?> get props => [
        id,
        storeId,
        name,
        description,
        sku,
        barcode,
        categoryId,
        price,
        cost,
        costIsPercentage,
        soldBy,
        availableForSale,
        trackStock,
        inStock,
        lowStockThreshold,
        isComposite,
        useProduction,
        imageUrl,
        averageCost,
      ];
}

/// Mettre à jour un item
class UpdateItemEvent extends ItemEvent {
  final String id;
  final String? name;
  final String? description;
  final String? sku;
  final String? barcode;
  final String? categoryId;
  final int? price;
  final int? cost;
  final bool? costIsPercentage;
  final String? soldBy;
  final bool? availableForSale;
  final bool? trackStock;
  final int? inStock;
  final int? lowStockThreshold;
  final bool? isComposite;
  final bool? useProduction;
  final String? imageUrl;
  final int? averageCost;

  const UpdateItemEvent({
    required this.id,
    this.name,
    this.description,
    this.sku,
    this.barcode,
    this.categoryId,
    this.price,
    this.cost,
    this.costIsPercentage,
    this.soldBy,
    this.availableForSale,
    this.trackStock,
    this.inStock,
    this.lowStockThreshold,
    this.isComposite,
    this.useProduction,
    this.imageUrl,
    this.averageCost,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        sku,
        barcode,
        categoryId,
        price,
        cost,
        costIsPercentage,
        soldBy,
        availableForSale,
        trackStock,
        inStock,
        lowStockThreshold,
        isComposite,
        useProduction,
        imageUrl,
        averageCost,
      ];
}

/// Supprimer un item
class DeleteItemEvent extends ItemEvent {
  final String itemId;

  const DeleteItemEvent(this.itemId);

  @override
  List<Object?> get props => [itemId];
}

/// Mettre à jour le stock d'un item
class UpdateItemStockEvent extends ItemEvent {
  final String itemId;
  final int newStock;

  const UpdateItemStockEvent(this.itemId, this.newStock);

  @override
  List<Object?> get props => [itemId, newStock];
}

/// Mettre à jour le coût moyen d'un item
class UpdateAverageCostEvent extends ItemEvent {
  final String itemId;
  final int newAverageCost;

  const UpdateAverageCostEvent(this.itemId, this.newAverageCost);

  @override
  List<Object?> get props => [itemId, newAverageCost];
}

/// Charger les items avec stock bas
class LoadLowStockItemsEvent extends ItemEvent {
  final String storeId;

  const LoadLowStockItemsEvent(this.storeId);

  @override
  List<Object?> get props => [storeId];
}

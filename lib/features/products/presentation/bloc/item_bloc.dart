import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/item_repository.dart';
import '../../../../core/data/remote/sync_service.dart';
import 'item_event.dart';
import 'item_state.dart';
import 'dart:developer' as developer;

/// BLoC pour la gestion des items (produits)
/// Pattern : Repository → BLoC → UI
class ItemBloc extends Bloc<ItemEvent, ItemState> {
  final ItemRepository _repository;
  final SyncService? _syncService;

  ItemBloc(this._repository, [this._syncService]) : super(const ItemInitial()) {
    on<LoadStoreItemsEvent>(_onLoadStoreItems);
    on<LoadItemByIdEvent>(_onLoadItemById);
    on<LoadItemBySkuEvent>(_onLoadItemBySku);
    on<LoadItemByBarcodeEvent>(_onLoadItemByBarcode);
    on<LoadCategoryItemsEvent>(_onLoadCategoryItems);
    on<LoadAvailableItemsEvent>(_onLoadAvailableItems);
    on<SearchItemsByNameEvent>(_onSearchItemsByName);
    on<CreateItemEvent>(_onCreateItem);
    on<UpdateItemEvent>(_onUpdateItem);
    on<DeleteItemEvent>(_onDeleteItem);
    on<UpdateItemStockEvent>(_onUpdateItemStock);
    on<UpdateAverageCostEvent>(_onUpdateAverageCost);
    on<LoadLowStockItemsEvent>(_onLoadLowStockItems);
  }

  /// Charger tous les items d'un magasin
  Future<void> _onLoadStoreItems(
    LoadStoreItemsEvent event,
    Emitter<ItemState> emit,
  ) async {
    try {
      emit(const ItemLoading());
      await emit.forEach(
        _repository.watchStoreItems(event.storeId),
        onData: (items) => ItemsLoaded(items),
        onError: (error, stackTrace) => ItemError(error.toString()),
      );
    } catch (e) {
      emit(ItemError(e.toString()));
    }
  }

  /// Charger un item par ID
  Future<void> _onLoadItemById(
    LoadItemByIdEvent event,
    Emitter<ItemState> emit,
  ) async {
    try {
      emit(const ItemLoading());
      final item = await _repository.getItemById(event.itemId);

      if (item != null) {
        emit(ItemLoaded(item));
      } else {
        emit(const ItemError('Item introuvable'));
      }
    } catch (e) {
      emit(ItemError(e.toString()));
    }
  }

  /// Charger un item par SKU
  Future<void> _onLoadItemBySku(
    LoadItemBySkuEvent event,
    Emitter<ItemState> emit,
  ) async {
    try {
      emit(const ItemLoading());
      final item = await _repository.getItemBySku(event.storeId, event.sku);

      if (item != null) {
        emit(ItemLoaded(item));
      } else {
        emit(const ItemError('Item introuvable'));
      }
    } catch (e) {
      emit(ItemError(e.toString()));
    }
  }

  /// Charger un item par code-barres
  Future<void> _onLoadItemByBarcode(
    LoadItemByBarcodeEvent event,
    Emitter<ItemState> emit,
  ) async {
    try {
      emit(const ItemLoading());
      final item = await _repository.getItemByBarcode(event.storeId, event.barcode);

      if (item != null) {
        emit(ItemLoaded(item));
      } else {
        emit(const ItemError('Item introuvable'));
      }
    } catch (e) {
      emit(ItemError(e.toString()));
    }
  }

  /// Charger les items d'une catégorie
  Future<void> _onLoadCategoryItems(
    LoadCategoryItemsEvent event,
    Emitter<ItemState> emit,
  ) async {
    try {
      emit(const ItemLoading());
      await emit.forEach(
        _repository.watchCategoryItems(event.categoryId),
        onData: (items) => ItemsLoaded(items),
        onError: (error, stackTrace) => ItemError(error.toString()),
      );
    } catch (e) {
      emit(ItemError(e.toString()));
    }
  }

  /// Charger les items disponibles à la vente
  Future<void> _onLoadAvailableItems(
    LoadAvailableItemsEvent event,
    Emitter<ItemState> emit,
  ) async {
    try {
      emit(const ItemLoading());
      await emit.forEach(
        _repository.watchAvailableItems(event.storeId),
        onData: (items) => ItemsLoaded(items),
        onError: (error, stackTrace) => ItemError(error.toString()),
      );
    } catch (e) {
      emit(ItemError(e.toString()));
    }
  }

  /// Rechercher des items par nom
  Future<void> _onSearchItemsByName(
    SearchItemsByNameEvent event,
    Emitter<ItemState> emit,
  ) async {
    try {
      emit(const ItemLoading());
      final items = await _repository.searchItemsByName(event.storeId, event.query);
      emit(ItemsLoaded(items));
    } catch (e) {
      emit(ItemError(e.toString()));
    }
  }

  /// Créer un nouvel item
  Future<void> _onCreateItem(
    CreateItemEvent event,
    Emitter<ItemState> emit,
  ) async {
    try {
      emit(const ItemLoading());
      await _repository.createItem(
        id: event.id,
        storeId: event.storeId,
        name: event.name,
        description: event.description,
        sku: event.sku,
        barcode: event.barcode,
        categoryId: event.categoryId,
        price: event.price,
        cost: event.cost,
        costIsPercentage: event.costIsPercentage,
        soldBy: event.soldBy,
        availableForSale: event.availableForSale,
        trackStock: event.trackStock,
        inStock: event.inStock,
        lowStockThreshold: event.lowStockThreshold,
        isComposite: event.isComposite,
        useProduction: event.useProduction,
        imageUrl: event.imageUrl,
        averageCost: event.averageCost,
      );
      emit(const ItemOperationSuccess('Item créé avec succès'));

      // Synchroniser immédiatement avec Supabase pour éviter la perte de données
      _triggerImmediateSync();
    } catch (e) {
      emit(ItemError(e.toString()));
    }
  }

  /// Mettre à jour un item
  Future<void> _onUpdateItem(
    UpdateItemEvent event,
    Emitter<ItemState> emit,
  ) async {
    try {
      emit(const ItemLoading());
      await _repository.updateItem(
        id: event.id,
        name: event.name,
        description: event.description,
        sku: event.sku,
        barcode: event.barcode,
        categoryId: event.categoryId,
        price: event.price,
        cost: event.cost,
        costIsPercentage: event.costIsPercentage,
        soldBy: event.soldBy,
        availableForSale: event.availableForSale,
        trackStock: event.trackStock,
        inStock: event.inStock,
        lowStockThreshold: event.lowStockThreshold,
        isComposite: event.isComposite,
        useProduction: event.useProduction,
        imageUrl: event.imageUrl,
        averageCost: event.averageCost,
      );
      emit(const ItemOperationSuccess('Item mis à jour avec succès'));

      // Synchroniser immédiatement avec Supabase
      _triggerImmediateSync();
    } catch (e) {
      emit(ItemError(e.toString()));
    }
  }

  /// Supprimer un item
  Future<void> _onDeleteItem(
    DeleteItemEvent event,
    Emitter<ItemState> emit,
  ) async {
    try {
      emit(const ItemLoading());
      await _repository.deleteItem(event.itemId);
      emit(const ItemOperationSuccess('Item supprimé avec succès'));

      // Synchroniser immédiatement avec Supabase
      _triggerImmediateSync();
    } catch (e) {
      emit(ItemError(e.toString()));
    }
  }

  /// Mettre à jour le stock d'un item
  Future<void> _onUpdateItemStock(
    UpdateItemStockEvent event,
    Emitter<ItemState> emit,
  ) async {
    try {
      emit(const ItemLoading());
      await _repository.updateItemStock(event.itemId, event.newStock);
      emit(const ItemOperationSuccess('Stock mis à jour avec succès'));
    } catch (e) {
      emit(ItemError(e.toString()));
    }
  }

  /// Mettre à jour le coût moyen d'un item
  Future<void> _onUpdateAverageCost(
    UpdateAverageCostEvent event,
    Emitter<ItemState> emit,
  ) async {
    try {
      emit(const ItemLoading());
      await _repository.updateAverageCost(event.itemId, event.newAverageCost);
      emit(const ItemOperationSuccess('Coût moyen mis à jour avec succès'));
    } catch (e) {
      emit(ItemError(e.toString()));
    }
  }

  /// Charger les items avec stock bas
  Future<void> _onLoadLowStockItems(
    LoadLowStockItemsEvent event,
    Emitter<ItemState> emit,
  ) async {
    try {
      emit(const ItemLoading());
      final items = await _repository.getLowStockItems(event.storeId);
      emit(ItemsLoaded(items));
    } catch (e) {
      emit(ItemError(e.toString()));
    }
  }

  /// Déclenche une synchronisation immédiate en arrière-plan
  void _triggerImmediateSync() {
    if (_syncService != null) {
      _syncService.forceSyncNow().then((result) {
        if (result.isSuccess) {
          developer.log(
            'Immediate sync completed: ${result.summary}',
            name: 'ItemBloc',
          );
        } else if (result.hasErrors) {
          developer.log(
            'Immediate sync had errors: ${result.errors.join(", ")}',
            name: 'ItemBloc',
          );
        }
      }).catchError((e) {
        developer.log(
          'Immediate sync failed',
          name: 'ItemBloc',
          error: e,
        );
      });
    }
  }
}

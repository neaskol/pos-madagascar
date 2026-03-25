import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/custom_page_repository_impl.dart';
import 'custom_page_event.dart';
import 'custom_page_state.dart';

/// BLoC pour gérer les pages personnalisées de produits
class CustomPageBloc extends Bloc<CustomPageEvent, CustomPageState> {
  final CustomPageRepositoryImpl repository;

  CustomPageBloc({required this.repository}) : super(const CustomPageInitial()) {
    on<LoadStorePages>(_onLoadStorePages);
    on<SelectPage>(_onSelectPage);
    on<CreatePage>(_onCreatePage);
    on<UpdatePage>(_onUpdatePage);
    on<DeletePage>(_onDeletePage);
    on<AddItemToCurrentPage>(_onAddItemToCurrentPage);
    on<RemoveItemFromCurrentPage>(_onRemoveItemFromCurrentPage);
    on<ReorderCurrentPageItems>(_onReorderCurrentPageItems);
    on<ClearCurrentPageItems>(_onClearCurrentPageItems);
    on<LoadCurrentPageItems>(_onLoadCurrentPageItems);
  }

  Future<void> _onLoadStorePages(
    LoadStorePages event,
    Emitter<CustomPageState> emit,
  ) async {
    emit(const CustomPageLoading());
    try {
      final pages = await repository.getStorePages(event.storeId);

      // Si aucune page n'existe, créer la page par défaut
      if (pages.isEmpty) {
        await repository.createDefaultPage(event.storeId, 'All Products');
        final updatedPages = await repository.getStorePages(event.storeId);
        emit(CustomPagesLoaded(
          pages: updatedPages,
          selectedPage: updatedPages.isNotEmpty ? updatedPages.first : null,
        ));
      } else {
        // Sélectionner la page par défaut ou la première page
        final defaultPage = pages.firstWhere(
          (p) => p.isDefault,
          orElse: () => pages.first,
        );

        // Charger les items de la page par défaut
        final pageItems = await repository.getPageItems(defaultPage.id);

        emit(CustomPagesLoaded(
          pages: pages,
          selectedPage: defaultPage,
          pageItems: pageItems,
        ));
      }
    } catch (e) {
      emit(CustomPageError('Erreur lors du chargement des pages: $e'));
    }
  }

  Future<void> _onSelectPage(
    SelectPage event,
    Emitter<CustomPageState> emit,
  ) async {
    if (state is! CustomPagesLoaded) return;

    final currentState = state as CustomPagesLoaded;

    try {
      // Trouver la page sélectionnée
      final selectedPage = currentState.pages.firstWhere(
        (p) => p.id == event.pageId,
      );

      // Charger les items de cette page
      final pageItems = await repository.getPageItems(event.pageId);

      emit(currentState.copyWith(
        selectedPage: selectedPage,
        pageItems: pageItems,
      ));
    } catch (e) {
      emit(CustomPageError('Erreur lors de la sélection de la page: $e'));
    }
  }

  Future<void> _onCreatePage(
    CreatePage event,
    Emitter<CustomPageState> emit,
  ) async {
    try {
      final page = await repository.createPage(
        storeId: event.storeId,
        name: event.name,
        sortOrder: event.sortOrder,
        createdBy: event.createdBy,
      );

      emit(PageCreated(page));

      // Recharger les pages
      add(LoadStorePages(event.storeId));
    } catch (e) {
      emit(CustomPageError('Erreur lors de la création de la page: $e'));
    }
  }

  Future<void> _onUpdatePage(
    UpdatePage event,
    Emitter<CustomPageState> emit,
  ) async {
    if (state is! CustomPagesLoaded) return;

    final currentState = state as CustomPagesLoaded;

    try {
      await repository.updatePage(
        pageId: event.pageId,
        name: event.name,
        sortOrder: event.sortOrder,
      );

      emit(const PageUpdated());

      // Recharger les pages
      if (currentState.selectedPage != null) {
        add(LoadStorePages(currentState.selectedPage!.storeId));
      }
    } catch (e) {
      emit(CustomPageError('Erreur lors de la mise à jour de la page: $e'));
    }
  }

  Future<void> _onDeletePage(
    DeletePage event,
    Emitter<CustomPageState> emit,
  ) async {
    if (state is! CustomPagesLoaded) return;

    final currentState = state as CustomPagesLoaded;

    try {
      await repository.deletePage(event.pageId);

      emit(const PageDeleted());

      // Recharger les pages
      if (currentState.selectedPage != null) {
        add(LoadStorePages(currentState.selectedPage!.storeId));
      }
    } catch (e) {
      emit(CustomPageError('Erreur lors de la suppression de la page: $e'));
    }
  }

  Future<void> _onAddItemToCurrentPage(
    AddItemToCurrentPage event,
    Emitter<CustomPageState> emit,
  ) async {
    if (state is! CustomPagesLoaded) return;

    final currentState = state as CustomPagesLoaded;
    if (currentState.selectedPage == null) return;

    try {
      // Vérifier si l'item est déjà sur la page
      final isOnPage = await repository.isItemOnPage(
        pageId: currentState.selectedPage!.id,
        itemId: event.itemId,
      );

      if (isOnPage) {
        emit(const CustomPageError('Cet item est déjà sur cette page'));
        return;
      }

      // Obtenir la prochaine position
      final itemCount =
          await repository.getPageItemCount(currentState.selectedPage!.id);

      await repository.addItemToPage(
        pageId: currentState.selectedPage!.id,
        itemId: event.itemId,
        position: itemCount,
      );

      emit(const ItemAddedToPage());

      // Recharger les items
      add(const LoadCurrentPageItems());
    } catch (e) {
      emit(CustomPageError('Erreur lors de l\'ajout de l\'item: $e'));
    }
  }

  Future<void> _onRemoveItemFromCurrentPage(
    RemoveItemFromCurrentPage event,
    Emitter<CustomPageState> emit,
  ) async {
    if (state is! CustomPagesLoaded) return;

    final currentState = state as CustomPagesLoaded;
    if (currentState.selectedPage == null) return;

    try {
      await repository.removeItemFromPage(
        pageId: currentState.selectedPage!.id,
        itemId: event.itemId,
      );

      emit(const ItemRemovedFromPage());

      // Recharger les items
      add(const LoadCurrentPageItems());
    } catch (e) {
      emit(CustomPageError('Erreur lors de la suppression de l\'item: $e'));
    }
  }

  Future<void> _onReorderCurrentPageItems(
    ReorderCurrentPageItems event,
    Emitter<CustomPageState> emit,
  ) async {
    if (state is! CustomPagesLoaded) return;

    final currentState = state as CustomPagesLoaded;
    if (currentState.selectedPage == null) return;

    try {
      await repository.reorderPageItems(
        pageId: currentState.selectedPage!.id,
        itemIds: event.itemIds,
      );

      emit(const PageItemsReordered());

      // Recharger les items
      add(const LoadCurrentPageItems());
    } catch (e) {
      emit(CustomPageError('Erreur lors de la réorganisation: $e'));
    }
  }

  Future<void> _onClearCurrentPageItems(
    ClearCurrentPageItems event,
    Emitter<CustomPageState> emit,
  ) async {
    if (state is! CustomPagesLoaded) return;

    final currentState = state as CustomPagesLoaded;
    if (currentState.selectedPage == null) return;

    try {
      await repository.clearPageItems(currentState.selectedPage!.id);

      emit(const PageCleared());

      // Recharger les items
      add(const LoadCurrentPageItems());
    } catch (e) {
      emit(CustomPageError('Erreur lors du vidage de la page: $e'));
    }
  }

  Future<void> _onLoadCurrentPageItems(
    LoadCurrentPageItems event,
    Emitter<CustomPageState> emit,
  ) async {
    if (state is! CustomPagesLoaded) return;

    final currentState = state as CustomPagesLoaded;
    if (currentState.selectedPage == null) return;

    try {
      final pageItems =
          await repository.getPageItems(currentState.selectedPage!.id);

      emit(currentState.copyWith(pageItems: pageItems));
    } catch (e) {
      emit(CustomPageError('Erreur lors du chargement des items: $e'));
    }
  }
}

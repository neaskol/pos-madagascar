import 'package:equatable/equatable.dart';
import '../../domain/entities/custom_product_page.dart';

/// États pour le CustomPageBloc
abstract class CustomPageState extends Equatable {
  const CustomPageState();

  @override
  List<Object?> get props => [];
}

/// État initial
class CustomPageInitial extends CustomPageState {
  const CustomPageInitial();
}

/// Chargement en cours
class CustomPageLoading extends CustomPageState {
  const CustomPageLoading();
}

/// Pages chargées
class CustomPagesLoaded extends CustomPageState {
  final List<CustomProductPageEntity> pages;
  final CustomProductPageEntity? selectedPage;
  final List<CustomPageItemEntity> pageItems;

  const CustomPagesLoaded({
    required this.pages,
    this.selectedPage,
    this.pageItems = const [],
  });

  @override
  List<Object?> get props => [pages, selectedPage, pageItems];

  CustomPagesLoaded copyWith({
    List<CustomProductPageEntity>? pages,
    CustomProductPageEntity? selectedPage,
    List<CustomPageItemEntity>? pageItems,
  }) {
    return CustomPagesLoaded(
      pages: pages ?? this.pages,
      selectedPage: selectedPage ?? this.selectedPage,
      pageItems: pageItems ?? this.pageItems,
    );
  }
}

/// Erreur
class CustomPageError extends CustomPageState {
  final String message;

  const CustomPageError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Page créée avec succès
class PageCreated extends CustomPageState {
  final CustomProductPageEntity page;

  const PageCreated(this.page);

  @override
  List<Object?> get props => [page];
}

/// Page mise à jour avec succès
class PageUpdated extends CustomPageState {
  const PageUpdated();
}

/// Page supprimée avec succès
class PageDeleted extends CustomPageState {
  const PageDeleted();
}

/// Item ajouté à la page
class ItemAddedToPage extends CustomPageState {
  const ItemAddedToPage();
}

/// Item supprimé de la page
class ItemRemovedFromPage extends CustomPageState {
  const ItemRemovedFromPage();
}

/// Items réorganisés
class PageItemsReordered extends CustomPageState {
  const PageItemsReordered();
}

/// Page vidée
class PageCleared extends CustomPageState {
  const PageCleared();
}

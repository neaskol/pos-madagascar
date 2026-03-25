import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/cart_item.dart';

// Events
abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

class AddItemToCart extends CartEvent {
  final String itemId;
  final String? itemVariantId;
  final String name;
  final int unitPrice;
  final int cost;
  final double quantity;
  final String? imageUrl;
  final Map<String, dynamic>? modifiers;

  const AddItemToCart({
    required this.itemId,
    this.itemVariantId,
    required this.name,
    required this.unitPrice,
    required this.cost,
    this.quantity = 1.0,
    this.imageUrl,
    this.modifiers,
  });

  @override
  List<Object?> get props => [
        itemId,
        itemVariantId,
        name,
        unitPrice,
        cost,
        quantity,
        imageUrl,
        modifiers,
      ];
}

class RemoveItemFromCart extends CartEvent {
  final String cartItemId;

  const RemoveItemFromCart(this.cartItemId);

  @override
  List<Object?> get props => [cartItemId];
}

class UpdateItemQuantity extends CartEvent {
  final String cartItemId;
  final double quantity;

  const UpdateItemQuantity({
    required this.cartItemId,
    required this.quantity,
  });

  @override
  List<Object?> get props => [cartItemId, quantity];
}

class ClearCart extends CartEvent {
  const ClearCart();
}

// States
abstract class CartState extends Equatable {
  const CartState();

  @override
  List<Object?> get props => [];
}

class CartEmpty extends CartState {
  const CartEmpty();
}

class CartLoaded extends CartState {
  final List<CartItem> items;

  const CartLoaded(this.items);

  /// Calcule le sous-total (somme des lignes)
  int get subtotal {
    return items.fold(0, (sum, item) => sum + item.lineTotal);
  }

  /// Calcule le montant total des taxes
  int get totalTaxAmount {
    return items.fold(0, (sum, item) => sum + item.taxAmount);
  }

  /// Calcule le montant total des remises
  int get totalDiscountAmount {
    return items.fold(0, (sum, item) => sum + item.discountAmount);
  }

  /// Calcule le total final
  int get total {
    return subtotal; // Pour l'instant, simple somme des lignes
  }

  /// Nombre total d'items
  int get itemCount => items.length;

  @override
  List<Object?> get props => [items];
}

// BLoC
class CartBloc extends Bloc<CartEvent, CartState> {
  final Uuid _uuid = const Uuid();

  CartBloc() : super(const CartEmpty()) {
    on<AddItemToCart>(_onAddItemToCart);
    on<RemoveItemFromCart>(_onRemoveItemFromCart);
    on<UpdateItemQuantity>(_onUpdateItemQuantity);
    on<ClearCart>(_onClearCart);
  }

  void _onAddItemToCart(AddItemToCart event, Emitter<CartState> emit) {
    final currentState = state;
    final cartItem = CartItem(
      id: _uuid.v4(),
      itemId: event.itemId,
      itemVariantId: event.itemVariantId,
      name: event.name,
      unitPrice: event.unitPrice,
      cost: event.cost,
      quantity: event.quantity,
      imageUrl: event.imageUrl,
      modifiers: event.modifiers,
    );

    if (currentState is CartEmpty) {
      emit(CartLoaded([cartItem]));
    } else if (currentState is CartLoaded) {
      // Vérifier si un item identique existe déjà (même itemId, variant, modifiers)
      final existingIndex = currentState.items.indexWhere(
        (item) =>
            item.itemId == event.itemId &&
            item.itemVariantId == event.itemVariantId &&
            _areModifiersEqual(item.modifiers, event.modifiers),
      );

      if (existingIndex != -1) {
        // Item existe : incrémenter la quantité
        final updatedItems = List<CartItem>.from(currentState.items);
        final existingItem = updatedItems[existingIndex];
        updatedItems[existingIndex] = existingItem.copyWith(
          quantity: existingItem.quantity + event.quantity,
        );
        emit(CartLoaded(updatedItems));
      } else {
        // Nouvel item : ajouter à la liste
        emit(CartLoaded([...currentState.items, cartItem]));
      }
    }
  }

  void _onRemoveItemFromCart(
      RemoveItemFromCart event, Emitter<CartState> emit) {
    final currentState = state;
    if (currentState is CartLoaded) {
      final updatedItems = currentState.items
          .where((item) => item.id != event.cartItemId)
          .toList();

      if (updatedItems.isEmpty) {
        emit(const CartEmpty());
      } else {
        emit(CartLoaded(updatedItems));
      }
    }
  }

  void _onUpdateItemQuantity(
      UpdateItemQuantity event, Emitter<CartState> emit) {
    final currentState = state;
    if (currentState is CartLoaded) {
      if (event.quantity <= 0) {
        // Si quantité <= 0, supprimer l'item
        add(RemoveItemFromCart(event.cartItemId));
        return;
      }

      final updatedItems = currentState.items.map((item) {
        if (item.id == event.cartItemId) {
          return item.copyWith(quantity: event.quantity);
        }
        return item;
      }).toList();

      emit(CartLoaded(updatedItems));
    }
  }

  void _onClearCart(ClearCart event, Emitter<CartState> emit) {
    emit(const CartEmpty());
  }

  /// Compare deux maps de modifiers pour déterminer si elles sont égales
  bool _areModifiersEqual(
      Map<String, dynamic>? modifiers1, Map<String, dynamic>? modifiers2) {
    if (modifiers1 == null && modifiers2 == null) return true;
    if (modifiers1 == null || modifiers2 == null) return false;
    if (modifiers1.length != modifiers2.length) return false;

    for (final key in modifiers1.keys) {
      if (!modifiers2.containsKey(key) || modifiers1[key] != modifiers2[key]) {
        return false;
      }
    }
    return true;
  }
}

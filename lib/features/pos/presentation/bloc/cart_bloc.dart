import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/entities/discount.dart';
import '../../domain/entities/tax.dart';
import '../../domain/repositories/tax_repository.dart';

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

class ApplyDiscountToItem extends CartEvent {
  final String cartItemId;
  final Discount discount;

  const ApplyDiscountToItem({
    required this.cartItemId,
    required this.discount,
  });

  @override
  List<Object?> get props => [cartItemId, discount];
}

class RemoveDiscountFromItem extends CartEvent {
  final String cartItemId;
  final Discount discount;

  const RemoveDiscountFromItem({
    required this.cartItemId,
    required this.discount,
  });

  @override
  List<Object?> get props => [cartItemId, discount];
}

class ApplyDiscountToCart extends CartEvent {
  final Discount discount;

  const ApplyDiscountToCart(this.discount);

  @override
  List<Object?> get props => [discount];
}

class RemoveDiscountFromCart extends CartEvent {
  final Discount discount;

  const RemoveDiscountFromCart(this.discount);

  @override
  List<Object?> get props => [discount];
}

class SetCartTaxes extends CartEvent {
  final List<Tax> taxes;

  const SetCartTaxes(this.taxes);

  @override
  List<Object?> get props => [taxes];
}

class InitializeCart extends CartEvent {
  final String storeId;

  const InitializeCart(this.storeId);

  @override
  List<Object?> get props => [storeId];
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
  final List<Discount> cartDiscounts; // Remises appliquées au panier entier
  final List<Tax> cartTaxes; // Taxes par défaut du magasin

  const CartLoaded(
    this.items, {
    this.cartDiscounts = const [],
    this.cartTaxes = const [],
  });

  /// Calcule le sous-total brut (somme prix × quantité, avant remises)
  int get grossSubtotal {
    return items.fold(0, (sum, item) => sum + item.subtotal);
  }

  /// Calcule le total des remises par item
  int get itemDiscountsTotal {
    return items.fold(0, (sum, item) => sum + item.totalDiscountAmount);
  }

  /// Calcule le sous-total après remises item (avant remises panier)
  int get subtotalAfterItemDiscounts {
    return grossSubtotal - itemDiscountsTotal;
  }

  /// Calcule le montant des remises panier
  int get cartDiscountAmount {
    if (cartDiscounts.isEmpty) return 0;
    final base = subtotalAfterItemDiscounts;
    return base - applyMultipleDiscounts(base, cartDiscounts);
  }

  /// Sous-total après toutes les remises (items + panier)
  int get subtotalAfterAllDiscounts {
    return subtotalAfterItemDiscounts - cartDiscountAmount;
  }

  /// Calcule le montant total des taxes (sur items + panier)
  int get totalTaxAmount {
    // Taxes on items (already calculated in CartItem)
    final itemTaxes = items.fold(0, (sum, item) => sum + item.totalTaxAmount);

    // If there are cart-level taxes, apply them to the subtotal after discounts
    // For now, taxes are mainly per-item, so we rely on CartItem.totalTaxAmount
    return itemTaxes;
  }

  /// Calcule le total final
  int get total {
    return subtotalAfterAllDiscounts + totalTaxAmount;
  }

  /// Nombre total d'items
  int get itemCount => items.length;

  /// Total de toutes les remises (items + panier)
  int get totalDiscountAmount {
    return itemDiscountsTotal + cartDiscountAmount;
  }

  CartLoaded copyWith({
    List<CartItem>? items,
    List<Discount>? cartDiscounts,
    List<Tax>? cartTaxes,
  }) {
    return CartLoaded(
      items ?? this.items,
      cartDiscounts: cartDiscounts ?? this.cartDiscounts,
      cartTaxes: cartTaxes ?? this.cartTaxes,
    );
  }

  @override
  List<Object?> get props => [items, cartDiscounts, cartTaxes];
}

// BLoC
class CartBloc extends Bloc<CartEvent, CartState> {
  final Uuid _uuid = const Uuid();
  final TaxRepository? _taxRepository;

  CartBloc({TaxRepository? taxRepository})
      : _taxRepository = taxRepository,
        super(const CartEmpty()) {
    on<InitializeCart>(_onInitializeCart);
    on<AddItemToCart>(_onAddItemToCart);
    on<RemoveItemFromCart>(_onRemoveItemFromCart);
    on<UpdateItemQuantity>(_onUpdateItemQuantity);
    on<ClearCart>(_onClearCart);
    on<ApplyDiscountToItem>(_onApplyDiscountToItem);
    on<RemoveDiscountFromItem>(_onRemoveDiscountFromItem);
    on<ApplyDiscountToCart>(_onApplyDiscountToCart);
    on<RemoveDiscountFromCart>(_onRemoveDiscountFromCart);
    on<SetCartTaxes>(_onSetCartTaxes);
  }

  Future<void> _onInitializeCart(
      InitializeCart event, Emitter<CartState> emit) async {
    final repository = _taxRepository;
    if (repository == null) return;

    try {
      // Load default tax for the store
      final defaultTax = await repository.getDefaultTax(event.storeId);

      if (defaultTax != null) {
        // Set the default tax to the cart
        add(SetCartTaxes([defaultTax]));
      }
    } catch (e) {
      // Silently fail - taxes are optional
      // Could log this error in production
    }
  }

  Future<void> _onAddItemToCart(
      AddItemToCart event, Emitter<CartState> emit) async {
    final currentState = state;

    // Determine taxes for this item
    List<Tax> itemTaxes = [];
    final repository = _taxRepository;
    if (repository != null) {
      try {
        // Try to get item-specific taxes
        final specificTaxes = await repository.getTaxesForItem(event.itemId);
        if (specificTaxes.isNotEmpty) {
          itemTaxes = specificTaxes;
        } else if (currentState is CartLoaded) {
          // Fall back to cart default taxes
          itemTaxes = currentState.cartTaxes;
        }
      } catch (e) {
        // Silently fail, use cart default taxes if available
        if (currentState is CartLoaded) {
          itemTaxes = currentState.cartTaxes;
        }
      }
    } else if (currentState is CartLoaded) {
      // No repository, use cart default taxes
      itemTaxes = currentState.cartTaxes;
    }

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
      taxes: itemTaxes,
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
        emit(currentState.copyWith(items: updatedItems));
      } else {
        // Nouvel item : ajouter à la liste
        emit(currentState.copyWith(items: [...currentState.items, cartItem]));
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

  void _onApplyDiscountToItem(
      ApplyDiscountToItem event, Emitter<CartState> emit) {
    final currentState = state;
    if (currentState is CartLoaded) {
      final updatedItems = currentState.items.map((item) {
        if (item.id == event.cartItemId) {
          final updatedDiscounts = [...item.discounts, event.discount];
          return item.copyWith(discounts: updatedDiscounts);
        }
        return item;
      }).toList();

      emit(currentState.copyWith(items: updatedItems));
    }
  }

  void _onRemoveDiscountFromItem(
      RemoveDiscountFromItem event, Emitter<CartState> emit) {
    final currentState = state;
    if (currentState is CartLoaded) {
      final updatedItems = currentState.items.map((item) {
        if (item.id == event.cartItemId) {
          final updatedDiscounts =
              item.discounts.where((d) => d != event.discount).toList();
          return item.copyWith(discounts: updatedDiscounts);
        }
        return item;
      }).toList();

      emit(currentState.copyWith(items: updatedItems));
    }
  }

  void _onApplyDiscountToCart(
      ApplyDiscountToCart event, Emitter<CartState> emit) {
    final currentState = state;
    if (currentState is CartLoaded) {
      final updatedDiscounts = [...currentState.cartDiscounts, event.discount];
      emit(currentState.copyWith(cartDiscounts: updatedDiscounts));
    }
  }

  void _onRemoveDiscountFromCart(
      RemoveDiscountFromCart event, Emitter<CartState> emit) {
    final currentState = state;
    if (currentState is CartLoaded) {
      final updatedDiscounts = currentState.cartDiscounts
          .where((d) => d != event.discount)
          .toList();
      emit(currentState.copyWith(cartDiscounts: updatedDiscounts));
    }
  }

  void _onSetCartTaxes(SetCartTaxes event, Emitter<CartState> emit) {
    final currentState = state;
    if (currentState is CartLoaded) {
      // Apply taxes to all items
      final updatedItems = currentState.items.map((item) {
        return item.copyWith(taxes: event.taxes);
      }).toList();

      emit(currentState.copyWith(
        items: updatedItems,
        cartTaxes: event.taxes,
      ));
    } else if (currentState is CartEmpty) {
      // Store taxes for when items are added
      emit(CartLoaded(const [], cartTaxes: event.taxes));
    }
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

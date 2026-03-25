import '../../domain/entities/discount.dart';
import '../../domain/entities/cart_item.dart';

/// Service for calculating and validating discounts
class DiscountService {
  /// Calculate discount amount for a cart item
  int calculateItemDiscount(CartItem item) {
    if (item.discounts.isEmpty) return 0;

    final basePrice = (item.unitPrice * item.quantity).round();
    int totalDiscount = 0;

    // Sort discounts by effective amount (smallest to largest)
    final sorted = sortDiscountsByAmount(basePrice, item.discounts);

    // Apply discounts sequentially
    int currentPrice = basePrice;
    for (final applied in sorted) {
      final discountAmount = applied.discount.calculateAmount(currentPrice);
      totalDiscount += discountAmount;
      currentPrice -= discountAmount;
    }

    return totalDiscount;
  }

  /// Calculate discount amount for entire cart
  int calculateCartDiscount(List<CartItem> items, List<Discount> cartDiscounts) {
    if (cartDiscounts.isEmpty) return 0;

    // Cart discount applies to subtotal (sum of all items after item discounts)
    final subtotal = items.fold<int>(0, (sum, item) {
      final itemTotal = (item.unitPrice * item.quantity).round();
      final itemDiscount = calculateItemDiscount(item);
      return sum + (itemTotal - itemDiscount);
    });

    // Apply cart-level discounts
    final afterDiscount = applyMultipleDiscounts(subtotal, cartDiscounts);
    return (subtotal - afterDiscount).abs();
  }

  /// Validate if user can apply restricted discount
  bool canApplyRestrictedDiscount(Discount discount, String userRole) {
    if (!discount.restrictedAccess) return true;

    // Only ADMIN, MANAGER, and OWNER can apply restricted discounts
    // CASHIER needs special permission (checked elsewhere)
    return userRole == 'ADMIN' ||
        userRole == 'MANAGER' ||
        userRole == 'OWNER';
  }

  /// Get effective amount for displaying discount preview
  int getDiscountPreview(int price, Discount discount) {
    return discount.calculateAmount(price);
  }

  /// Validate discount value
  String? validateDiscount(Discount discount, int price) {
    if (discount.value <= 0) {
      return 'La remise doit être positive';
    }

    if (discount.type == DiscountType.percentage && discount.value > 100) {
      return 'La remise ne peut pas dépasser 100%';
    }

    if (discount.type == DiscountType.fixedAmount && discount.value > price) {
      return 'La remise ne peut pas dépasser le prix';
    }

    return null; // Valid
  }
}

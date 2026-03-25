enum DiscountType {
  percentage, // Discount as percentage (e.g., 10%)
  fixedAmount, // Discount as fixed amount in Ariary
}

enum DiscountTarget {
  item, // Applied to a specific cart item
  cart, // Applied to entire cart
}

class Discount {
  final String? id; // Null for ad-hoc discounts
  final DiscountType type;
  final DiscountTarget target;
  final double value; // Percentage (10.0) or Amount in Ariary (1000)
  final String? name; // Optional name (e.g., "Summer Sale")
  final bool restrictedAccess; // Requires special permission

  const Discount({
    this.id,
    required this.type,
    required this.target,
    required this.value,
    this.name,
    this.restrictedAccess = false,
  });

  // Calculate effective discount amount for a given price
  int calculateAmount(int price) {
    switch (type) {
      case DiscountType.percentage:
        return (price * value / 100).round();
      case DiscountType.fixedAmount:
        return value.round();
    }
  }

  // Calculate price after applying this discount
  int applyTo(int price) {
    final discountAmount = calculateAmount(price);
    return (price - discountAmount).clamp(0, price); // Never negative
  }

  factory Discount.fromJson(Map<String, dynamic> json) {
    return Discount(
      id: json['id'] as String?,
      type: json['type'] == 'percentage'
          ? DiscountType.percentage
          : DiscountType.fixedAmount,
      target: json['target'] == 'item'
          ? DiscountTarget.item
          : DiscountTarget.cart,
      value: (json['value'] as num).toDouble(),
      name: json['name'] as String?,
      restrictedAccess: json['restricted_access'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'type': type == DiscountType.percentage ? 'percentage' : 'fixed_amount',
      'target': target == DiscountTarget.item ? 'item' : 'cart',
      'value': value,
      if (name != null) 'name': name,
      'restricted_access': restrictedAccess,
    };
  }

  Discount copyWith({
    String? id,
    DiscountType? type,
    DiscountTarget? target,
    double? value,
    String? name,
    bool? restrictedAccess,
  }) {
    return Discount(
      id: id ?? this.id,
      type: type ?? this.type,
      target: target ?? this.target,
      value: value ?? this.value,
      name: name ?? this.name,
      restrictedAccess: restrictedAccess ?? this.restrictedAccess,
    );
  }

  @override
  String toString() {
    final displayValue = type == DiscountType.percentage
        ? '${value.toStringAsFixed(0)}%'
        : '${value.toInt()} Ar';
    return name != null ? '$name ($displayValue)' : displayValue;
  }
}

// Helper class for sorting and applying multiple discounts
class AppliedDiscount {
  final Discount discount;
  final int effectiveAmount;

  const AppliedDiscount({
    required this.discount,
    required this.effectiveAmount,
  });
}

// Sort discounts by effective amount (smallest to largest)
// As per Loyverse behavior: multiple discounts applied smallest to largest
List<AppliedDiscount> sortDiscountsByAmount(
  int basePrice,
  List<Discount> discounts,
) {
  return discounts
      .map((d) => AppliedDiscount(
            discount: d,
            effectiveAmount: d.calculateAmount(basePrice),
          ))
      .toList()
    ..sort((a, b) => a.effectiveAmount.compareTo(b.effectiveAmount));
}

// Apply multiple discounts in correct order
int applyMultipleDiscounts(int basePrice, List<Discount> discounts) {
  if (discounts.isEmpty) return basePrice;

  final sorted = sortDiscountsByAmount(basePrice, discounts);
  int currentPrice = basePrice;

  for (final applied in sorted) {
    currentPrice = applied.discount.applyTo(currentPrice);
  }

  return currentPrice;
}

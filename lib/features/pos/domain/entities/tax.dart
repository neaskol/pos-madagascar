enum TaxType {
  added, // Tax is added on top of the price
  included, // Tax is already included in the price
}

class Tax {
  final String id;
  final String storeId;
  final String name;
  final double rate; // Percentage (e.g., 20.0 for 20%)
  final TaxType type;
  final bool isDefault;
  final bool active;

  const Tax({
    required this.id,
    required this.storeId,
    required this.name,
    required this.rate,
    required this.type,
    required this.isDefault,
    required this.active,
  });

  // Calculate tax amount for a given base price (in Ariary)
  int calculateTaxAmount(int basePrice) {
    if (!active) return 0;

    switch (type) {
      case TaxType.added:
        // Tax added to price: tax = basePrice × rate / 100
        return (basePrice * rate / 100).round();

      case TaxType.included:
        // Tax included in price: tax = price × rate / (100 + rate)
        return (basePrice * rate / (100 + rate)).round();
    }
  }

  // Calculate total price including tax (for added type)
  int calculateTotalWithTax(int basePrice) {
    if (!active) return basePrice;

    switch (type) {
      case TaxType.added:
        return basePrice + calculateTaxAmount(basePrice);
      case TaxType.included:
        return basePrice; // Tax already included
    }
  }

  // Calculate price excluding tax (for included type)
  int calculatePriceExcludingTax(int priceWithTax) {
    if (!active) return priceWithTax;

    switch (type) {
      case TaxType.added:
        return priceWithTax; // Tax not included
      case TaxType.included:
        return priceWithTax - calculateTaxAmount(priceWithTax);
    }
  }

  factory Tax.fromJson(Map<String, dynamic> json) {
    return Tax(
      id: json['id'] as String,
      storeId: json['store_id'] as String,
      name: json['name'] as String,
      rate: (json['rate'] as num).toDouble(),
      type: json['tax_type'] == 'added' ? TaxType.added : TaxType.included,
      isDefault: json['is_default'] as bool? ?? false,
      active: json['active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'store_id': storeId,
      'name': name,
      'rate': rate,
      'tax_type': type == TaxType.added ? 'added' : 'included',
      'is_default': isDefault,
      'active': active,
    };
  }

  Tax copyWith({
    String? id,
    String? storeId,
    String? name,
    double? rate,
    TaxType? type,
    bool? isDefault,
    bool? active,
  }) {
    return Tax(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      name: name ?? this.name,
      rate: rate ?? this.rate,
      type: type ?? this.type,
      isDefault: isDefault ?? this.isDefault,
      active: active ?? this.active,
    );
  }
}

// Calculate total tax amount for multiple taxes on the same item
// Each tax applies to the BASE PRICE (never one on top of another)
int calculateTotalTaxAmount(int basePrice, List<Tax> taxes) {
  return taxes.fold(0, (sum, tax) {
    if (!tax.active) return sum;
    return sum + tax.calculateTaxAmount(basePrice);
  });
}

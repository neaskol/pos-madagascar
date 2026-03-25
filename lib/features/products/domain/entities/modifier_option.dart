import 'package:equatable/equatable.dart';

/// Option d'un modifier (ex: "Petit", "Moyen", "Grand" pour "Taille boisson")
class ModifierOption extends Equatable {
  final String id;
  final String modifierId;
  final String name;

  /// Prix additionnel en Ariary (0 = gratuit)
  final int priceAddition;

  /// Ordre d'affichage
  final int sortOrder;

  final DateTime createdAt;
  final DateTime updatedAt;

  const ModifierOption({
    required this.id,
    required this.modifierId,
    required this.name,
    this.priceAddition = 0,
    this.sortOrder = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  ModifierOption copyWith({
    String? id,
    String? modifierId,
    String? name,
    int? priceAddition,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ModifierOption(
      id: id ?? this.id,
      modifierId: modifierId ?? this.modifierId,
      name: name ?? this.name,
      priceAddition: priceAddition ?? this.priceAddition,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        modifierId,
        name,
        priceAddition,
        sortOrder,
        createdAt,
        updatedAt,
      ];
}

import 'package:equatable/equatable.dart';
import 'modifier_option.dart';

/// Ensemble d'options de modification (ex: "Taille boisson", "Garniture pizza")
class Modifier extends Equatable {
  final String id;
  final String storeId;
  final String name;

  /// Si true, le client DOIT choisir au moins une option
  /// Différenciant vs Loyverse (qui n'a que des modifiers optionnels)
  final bool isRequired;

  /// Options de ce modifier (chargées séparément)
  final List<ModifierOption> options;

  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;

  const Modifier({
    required this.id,
    required this.storeId,
    required this.name,
    this.isRequired = false,
    this.options = const [],
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
  });

  Modifier copyWith({
    String? id,
    String? storeId,
    String? name,
    bool? isRequired,
    List<ModifierOption>? options,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
  }) {
    return Modifier(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      name: name ?? this.name,
      isRequired: isRequired ?? this.isRequired,
      options: options ?? this.options,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  @override
  List<Object?> get props => [
        id,
        storeId,
        name,
        isRequired,
        options,
        createdAt,
        updatedAt,
        createdBy,
      ];
}

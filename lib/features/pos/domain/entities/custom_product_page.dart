/// Entité représentant une page personnalisée de produits
class CustomProductPageEntity {
  final String id;
  final String storeId;
  final String name;
  final int sortOrder;
  final bool isDefault;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool synced;

  const CustomProductPageEntity({
    required this.id,
    required this.storeId,
    required this.name,
    required this.sortOrder,
    required this.isDefault,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    required this.synced,
  });

  CustomProductPageEntity copyWith({
    String? id,
    String? storeId,
    String? name,
    int? sortOrder,
    bool? isDefault,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? synced,
  }) {
    return CustomProductPageEntity(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      name: name ?? this.name,
      sortOrder: sortOrder ?? this.sortOrder,
      isDefault: isDefault ?? this.isDefault,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      synced: synced ?? this.synced,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'store_id': storeId,
      'name': name,
      'sort_order': sortOrder,
      'is_default': isDefault,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'synced': synced,
    };
  }

  factory CustomProductPageEntity.fromJson(Map<String, dynamic> json) {
    return CustomProductPageEntity(
      id: json['id'] as String,
      storeId: json['store_id'] as String,
      name: json['name'] as String,
      sortOrder: json['sort_order'] as int,
      isDefault: json['is_default'] as bool,
      createdBy: json['created_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      synced: json['synced'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomProductPageEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'CustomProductPageEntity{id: $id, name: $name, sortOrder: $sortOrder, isDefault: $isDefault}';
  }
}

/// Entité représentant un item placé sur une page personnalisée
class CustomPageItemEntity {
  final String id;
  final String pageId;
  final String itemId;
  final int position;
  final DateTime createdAt;
  final bool synced;

  const CustomPageItemEntity({
    required this.id,
    required this.pageId,
    required this.itemId,
    required this.position,
    required this.createdAt,
    required this.synced,
  });

  CustomPageItemEntity copyWith({
    String? id,
    String? pageId,
    String? itemId,
    int? position,
    DateTime? createdAt,
    bool? synced,
  }) {
    return CustomPageItemEntity(
      id: id ?? this.id,
      pageId: pageId ?? this.pageId,
      itemId: itemId ?? this.itemId,
      position: position ?? this.position,
      createdAt: createdAt ?? this.createdAt,
      synced: synced ?? this.synced,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'page_id': pageId,
      'item_id': itemId,
      'position': position,
      'created_at': createdAt.toIso8601String(),
      'synced': synced,
    };
  }

  factory CustomPageItemEntity.fromJson(Map<String, dynamic> json) {
    return CustomPageItemEntity(
      id: json['id'] as String,
      pageId: json['page_id'] as String,
      itemId: json['item_id'] as String,
      position: json['position'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      synced: json['synced'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomPageItemEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'CustomPageItemEntity{id: $id, pageId: $pageId, itemId: $itemId, position: $position}';
  }
}

/// Entité représentant une grille de catégorie sur une page personnalisée
class CustomPageCategoryGridEntity {
  final String id;
  final String pageId;
  final String categoryId;
  final int position;
  final DateTime createdAt;
  final bool synced;

  const CustomPageCategoryGridEntity({
    required this.id,
    required this.pageId,
    required this.categoryId,
    required this.position,
    required this.createdAt,
    required this.synced,
  });

  CustomPageCategoryGridEntity copyWith({
    String? id,
    String? pageId,
    String? categoryId,
    int? position,
    DateTime? createdAt,
    bool? synced,
  }) {
    return CustomPageCategoryGridEntity(
      id: id ?? this.id,
      pageId: pageId ?? this.pageId,
      categoryId: categoryId ?? this.categoryId,
      position: position ?? this.position,
      createdAt: createdAt ?? this.createdAt,
      synced: synced ?? this.synced,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'page_id': pageId,
      'category_id': categoryId,
      'position': position,
      'created_at': createdAt.toIso8601String(),
      'synced': synced,
    };
  }

  factory CustomPageCategoryGridEntity.fromJson(Map<String, dynamic> json) {
    return CustomPageCategoryGridEntity(
      id: json['id'] as String,
      pageId: json['page_id'] as String,
      categoryId: json['category_id'] as String,
      position: json['position'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      synced: json['synced'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomPageCategoryGridEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'CustomPageCategoryGridEntity{id: $id, pageId: $pageId, categoryId: $categoryId, position: $position}';
  }
}

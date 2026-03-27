import 'package:drift/drift.dart';
import '../app_database.dart';

part 'modifier_dao.g.dart';

/// DAO pour les modifiers (ensembles d'options)
@DriftAccessor(include: {
  '../tables/modifiers.drift',
  '../tables/modifier_options.drift',
  '../tables/item_modifiers.drift',
})
class ModifierDao extends DatabaseAccessor<AppDatabase>
    with _$ModifierDaoMixin {
  ModifierDao(AppDatabase db) : super(db);

  /// Récupère tous les modifiers d'un magasin
  Future<List<Modifier>> getModifiersByStoreId(String storeId) {
    return (select(modifiers)..where((m) => m.storeId.equals(storeId))).get();
  }

  /// Récupère un modifier par son ID
  Future<Modifier?> getModifierById(String id) {
    return (select(modifiers)..where((m) => m.id.equals(id)))
        .getSingleOrNull();
  }

  /// Récupère les IDs des modifiers liés à un item
  Future<List<String>> getModifierIdsByItemId(String itemId) async {
    final query = select(itemModifiers)
      ..where((im) => im.itemId.equals(itemId))
      ..orderBy([(im) => OrderingTerm(expression: im.sortOrder)]);
    final results = await query.get();
    return results.map((im) => im.modifierId).toList();
  }

  /// Récupère les modifiers liés à un item avec leurs options
  Future<List<ModifierWithOptions>> getModifiersForItem(String itemId) async {
    final modifierIds = await getModifierIdsByItemId(itemId);
    if (modifierIds.isEmpty) return [];

    final results = <ModifierWithOptions>[];
    for (final modifierId in modifierIds) {
      final modifier = await getModifierById(modifierId);
      if (modifier != null) {
        final options = await getOptionsByModifierId(modifierId);
        results.add(ModifierWithOptions(modifier, options));
      }
    }
    return results;
  }

  /// Récupère les options d'un modifier
  Future<List<ModifierOption>> getOptionsByModifierId(String modifierId) {
    return (select(modifierOptions)
          ..where((o) => o.modifierId.equals(modifierId))
          ..orderBy([(o) => OrderingTerm(expression: o.sortOrder)]))
        .get();
  }

  /// Insère ou met à jour un modifier
  Future<void> upsertModifier(ModifiersCompanion modifier) {
    return into(modifiers).insertOnConflictUpdate(modifier);
  }

  /// Insère ou met à jour une option de modifier
  Future<void> upsertModifierOption(ModifierOptionsCompanion option) {
    return into(modifierOptions).insertOnConflictUpdate(option);
  }

  /// Lie un modifier à un item
  Future<void> linkModifierToItem({
    required String itemId,
    required String modifierId,
    int sortOrder = 0,
  }) {
    return into(itemModifiers).insertOnConflictUpdate(
      ItemModifiersCompanion.insert(
        itemId: itemId,
        modifierId: modifierId,
        sortOrder: Value(sortOrder),
        synced: const Value(0),
      ),
    );
  }

  /// Supprime la liaison entre un modifier et un item
  Future<int> unlinkModifierFromItem(String itemId, String modifierId) {
    return (delete(itemModifiers)
          ..where((im) =>
              im.itemId.equals(itemId) & im.modifierId.equals(modifierId)))
        .go();
  }

  /// Supprime toutes les liaisons d'un item
  Future<int> unlinkAllModifiersFromItem(String itemId) {
    return (delete(itemModifiers)..where((im) => im.itemId.equals(itemId)))
        .go();
  }

  /// Récupère tous les modifiers non synchronisés
  @override
  Selectable<Modifier> getUnsyncedModifiers() {
    return select(modifiers)..where((m) => m.synced.equals(0));
  }

  /// Marque un modifier comme synchronisé
  Future<void> markModifierAsSynced(String id) {
    return (update(modifiers)..where((m) => m.id.equals(id)))
        .write(const ModifiersCompanion(synced: Value(1)));
  }

  /// Récupère tous les options de modifiers non synchronisées
  @override
  Selectable<ModifierOption> getUnsyncedModifierOptions() {
    return select(modifierOptions)..where((o) => o.synced.equals(0));
  }

  /// Marque une option comme synchronisée
  Future<void> markOptionAsSynced(String id) {
    return (update(modifierOptions)..where((o) => o.id.equals(id)))
        .write(const ModifierOptionsCompanion(synced: Value(1)));
  }
}

/// Classe helper pour retourner modifier + options
class ModifierWithOptions {
  final Modifier modifier;
  final List<ModifierOption> options;

  ModifierWithOptions(this.modifier, this.options);
}

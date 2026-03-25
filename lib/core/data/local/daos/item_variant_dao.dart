import 'package:drift/drift.dart';
import '../app_database.dart';

part 'item_variant_dao.g.dart';

/// DAO pour les variants d'items (taille, couleur, etc.)
@DriftAccessor(include: {'../tables/item_variants.drift'})
class ItemVariantDao extends DatabaseAccessor<AppDatabase>
    with _$ItemVariantDaoMixin {
  ItemVariantDao(AppDatabase db) : super(db);

  /// Récupère tous les variants d'un item
  Future<List<ItemVariant>> getVariantsByItemId(String itemId) {
    return (select(itemVariants)..where((v) => v.itemId.equals(itemId)))
        .get();
  }

  /// Récupère un variant par son ID
  Future<ItemVariant?> getVariantById(String id) {
    return (select(itemVariants)..where((v) => v.id.equals(id)))
        .getSingleOrNull();
  }

  /// Récupère un variant par son barcode
  Future<ItemVariant?> getVariantByBarcode(String barcode) {
    return (select(itemVariants)..where((v) => v.barcode.equals(barcode)))
        .getSingleOrNull();
  }

  /// Insère ou met à jour un variant
  Future<void> upsertVariant(ItemVariantsCompanion variant) {
    return into(itemVariants).insertOnConflictUpdate(variant);
  }

  /// Insère plusieurs variants en batch
  Future<void> upsertVariants(List<ItemVariantsCompanion> variants) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(itemVariants, variants);
    });
  }

  /// Supprime un variant
  Future<int> deleteVariant(String id) {
    return (delete(itemVariants)..where((v) => v.id.equals(id))).go();
  }

  /// Récupère tous les variants non synchronisés
  Future<List<ItemVariant>> getUnsyncedVariants() {
    return (select(itemVariants)..where((v) => v.synced.equals(0))).get();
  }

  /// Marque un variant comme synchronisé
  Future<void> markAsSynced(String id) {
    return (update(itemVariants)..where((v) => v.id.equals(id)))
        .write(const ItemVariantsCompanion(synced: Value(1)));
  }

  /// Compte le nombre de variants pour un item
  Future<int> countVariantsByItemId(String itemId) async {
    final query = selectOnly(itemVariants)
      ..addColumns([itemVariants.id.count()])
      ..where(itemVariants.itemId.equals(itemId));
    final result = await query.getSingle();
    return result.read(itemVariants.id.count()) ?? 0;
  }

  /// Vérifie si un item a des variants
  Future<bool> hasVariants(String itemId) async {
    final count = await countVariantsByItemId(itemId);
    return count > 0;
  }
}

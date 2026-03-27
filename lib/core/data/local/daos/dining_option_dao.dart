import 'package:drift/drift.dart';
import '../app_database.dart';

part 'dining_option_dao.g.dart';

/// DAO pour la table dining_options
/// Gère les options de service (sur place, à emporter, livraison)
@DriftAccessor(include: {'../tables/dining_options.drift'})
class DiningOptionDao extends DatabaseAccessor<AppDatabase>
    with _$DiningOptionDaoMixin {
  DiningOptionDao(AppDatabase db) : super(db);

  /// Insère une option de service
  Future<int> insertDiningOption(DiningOptionsCompanion option) =>
      into(diningOptions).insert(option);

  /// Met à jour une option de service
  Future<bool> updateDiningOption(DiningOptionsCompanion option) async {
    final rowsAffected = await (update(diningOptions)
          ..where((tbl) => tbl.id.equals(option.id.value)))
        .write(option.copyWith(
      synced: const Value(0),
      updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
    ));
    return rowsAffected > 0;
  }

  /// Suppression logique d'une option
  Future<bool> deleteDiningOption(String id) async {
    final rowsAffected = await (update(diningOptions)
          ..where((tbl) => tbl.id.equals(id)))
        .write(DiningOptionsCompanion(
      deletedAt: Value(DateTime.now().millisecondsSinceEpoch),
      synced: const Value(0),
      updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
    ));
    return rowsAffected > 0;
  }

  /// Marque comme synchronisée
  Future<bool> markDiningOptionSynced(String id) async {
    final rowsAffected = await (update(diningOptions)
          ..where((tbl) => tbl.id.equals(id)))
        .write(const DiningOptionsCompanion(synced: Value(1)));
    return rowsAffected > 0;
  }

  /// Définit l'option par défaut (désactive les autres d'abord)
  Future<void> setDefaultDiningOption(String storeId, String optionId) async {
    await transaction(() async {
      // Désactiver toutes les options par défaut du magasin
      await customStatement(
        "UPDATE dining_options SET is_default = 0, synced = 0, updated_at = ? WHERE store_id = ? AND deleted_at IS NULL",
        [DateTime.now().millisecondsSinceEpoch, storeId],
      );
      // Activer la nouvelle option par défaut
      await (update(diningOptions)
            ..where((tbl) => tbl.id.equals(optionId)))
          .write(DiningOptionsCompanion(
        isDefault: const Value(1),
        synced: const Value(0),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ));
    });
  }

  /// Stream pour écouter les options d'un magasin
  Stream<List<DiningOption>> watchDiningOptionsByStore(String storeId) =>
      getDiningOptionsByStore(storeId).watch();

  // ─── UPSERT (SYNC) ────────────────────────────────────

  /// Upsert (insert ou update) une option de service depuis Supabase
  Future<void> upsertDiningOption(DiningOptionsCompanion option) async {
    await into(diningOptions).insertOnConflictUpdate(option);
  }
}

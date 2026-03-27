import 'package:drift/drift.dart';
import '../app_database.dart';

part 'sync_conflict_dao.g.dart';

@DriftAccessor(include: {'../tables/sync_conflicts.drift'})
class SyncConflictDao extends DatabaseAccessor<AppDatabase>
    with _$SyncConflictDaoMixin {
  SyncConflictDao(AppDatabase db) : super(db);

  /// Récupérer tous les conflits en attente de résolution pour un store
  Future<List<SyncConflict>> getPendingConflictsForStore(String storeId) {
    return getPendingConflicts(storeId).get();
  }

  /// Récupérer les conflits pour une table spécifique
  Future<List<SyncConflict>> getConflictsForTable(
      String tableName, String storeId) {
    return getConflictsByTable(tableName, storeId).get();
  }

  /// Récupérer un conflit par son ID
  Future<SyncConflict?> getConflict(String id) async {
    final results = await getConflictById(id).get();
    return results.isNotEmpty ? results.first : null;
  }

  /// Créer un nouveau conflit
  Future<void> createConflict(SyncConflictsCompanion conflict) {
    return into(syncConflicts).insert(conflict);
  }

  /// Résoudre un conflit (choisir la valeur locale)
  Future<void> resolveWithLocal({
    required String conflictId,
    required String resolvedBy,
    String? notes,
  }) {
    return (update(syncConflicts)..where((t) => t.id.equals(conflictId)))
        .write(SyncConflictsCompanion(
      status: const Value('resolved_local'),
      resolvedAt: Value(DateTime.now().millisecondsSinceEpoch),
      resolvedBy: Value(resolvedBy),
      resolutionNotes: Value(notes),
      synced: const Value(0), // Marquer pour sync vers Supabase
      updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
    ));
  }

  /// Résoudre un conflit (choisir la valeur distante)
  Future<void> resolveWithRemote({
    required String conflictId,
    required String resolvedBy,
    String? notes,
  }) {
    return (update(syncConflicts)..where((t) => t.id.equals(conflictId)))
        .write(SyncConflictsCompanion(
      status: const Value('resolved_remote'),
      resolvedAt: Value(DateTime.now().millisecondsSinceEpoch),
      resolvedBy: Value(resolvedBy),
      resolutionNotes: Value(notes),
      synced: const Value(0),
      updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
    ));
  }

  /// Résoudre un conflit manuellement
  Future<void> resolveManually({
    required String conflictId,
    required String resolvedBy,
    String? notes,
  }) {
    return (update(syncConflicts)..where((t) => t.id.equals(conflictId)))
        .write(SyncConflictsCompanion(
      status: const Value('resolved_manual'),
      resolvedAt: Value(DateTime.now().millisecondsSinceEpoch),
      resolvedBy: Value(resolvedBy),
      resolutionNotes: Value(notes),
      synced: const Value(0),
      updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
    ));
  }

  /// Marquer un conflit comme synchronisé avec Supabase
  Future<void> markSynced(String id) {
    return (update(syncConflicts)..where((t) => t.id.equals(id)))
        .write(const SyncConflictsCompanion(
      synced: Value(1),
      updatedAt: Value.absentIfNull(null),
    ));
  }

  /// Récupérer les conflits non synchronisés
  Selectable<SyncConflict> getUnsyncedConflicts() {
    return getUnsyncedSyncConflicts();
  }

  /// Supprimer tous les conflits résolus pour un store
  Future<int> deleteResolvedConflicts(String storeId) {
    return (delete(syncConflicts)
          ..where((t) =>
              t.storeId.equals(storeId) &
              t.status.isNotValue('pending')))
        .go();
  }
}

import 'dart:convert';
import 'package:drift/drift.dart';
import '../local/app_database.dart';
import 'package:uuid/uuid.dart';

/// Détecte et enregistre les conflits lors de la synchronisation bidirectionnelle
///
/// Stratégie: Last-Write-Wins avec enregistrement des conflits
/// - Compare `updated_at` local vs distant
/// - Si local > distant: garder local (pas de conflit)
/// - Si distant > local: garder distant (pas de conflit)
/// - Si égal mais valeurs différentes: conflit (rare, mais possible)
///
/// Tous les conflits détectés sont enregistrés dans `sync_conflicts` pour:
/// - Audit et traçabilité
/// - Résolution manuelle optionnelle par le gérant
/// - Métriques de qualité des données
class ConflictDetector {
  final AppDatabase _db;
  final String _storeId;
  final _uuid = const Uuid();

  ConflictDetector(this._db, this._storeId);

  /// Merge un record distant avec le local en détectant les conflits
  ///
  /// Retourne:
  /// - `true` si le record distant doit être appliqué (distant plus récent)
  /// - `false` si le record local doit être conservé (local plus récent)
  ///
  /// Enregistre un conflit dans `sync_conflicts` si détecté.
  Future<bool> shouldApplyRemote({
    required String tableName,
    required String recordId,
    required Map<String, dynamic> localData,
    required Map<String, dynamic> remoteData,
    required DateTime localUpdatedAt,
    required DateTime remoteUpdatedAt,
  }) async {
    // Cas 1: Local plus récent → garder local
    if (localUpdatedAt.isAfter(remoteUpdatedAt)) {
      // Pas de conflit, local wins
      return false;
    }

    // Cas 2: Distant plus récent → garder distant
    if (remoteUpdatedAt.isAfter(localUpdatedAt)) {
      // Vérifier s'il y a vraiment des différences (hors updated_at/synced)
      final hasActualDifferences = _hasDataDifferences(
        localData,
        remoteData,
        excludeFields: {'updated_at', 'synced', 'created_at'},
      );

      if (hasActualDifferences) {
        // Enregistrer comme conflit résolu automatiquement (last-write-wins)
        await _recordConflict(
          tableName: tableName,
          recordId: recordId,
          localData: localData,
          remoteData: remoteData,
          localUpdatedAt: localUpdatedAt,
          remoteUpdatedAt: remoteUpdatedAt,
          autoResolved: true,
          resolution: 'resolved_remote',
        );
      }

      return true;
    }

    // Cas 3: Timestamps égaux mais données différentes (rare)
    final hasActualDifferences = _hasDataDifferences(
      localData,
      remoteData,
      excludeFields: {'updated_at', 'synced', 'created_at'},
    );

    if (hasActualDifferences) {
      // Conflit réel nécessitant attention
      await _recordConflict(
        tableName: tableName,
        recordId: recordId,
        localData: localData,
        remoteData: remoteData,
        localUpdatedAt: localUpdatedAt,
        remoteUpdatedAt: remoteUpdatedAt,
        autoResolved: false,
        resolution: 'pending',
      );

      // Par défaut, garder distant (comportement conservateur)
      return true;
    }

    // Pas de différences → pas besoin de mettre à jour
    return false;
  }

  /// Compare deux objets JSON pour détecter des différences
  bool _hasDataDifferences(
    Map<String, dynamic> local,
    Map<String, dynamic> remote, {
    required Set<String> excludeFields,
  }) {
    // Créer des copies sans les champs exclus
    final localFiltered = Map<String, dynamic>.from(local)
      ..removeWhere((key, _) => excludeFields.contains(key));
    final remoteFiltered = Map<String, dynamic>.from(remote)
      ..removeWhere((key, _) => excludeFields.contains(key));

    // Comparer les clés
    final localKeys = localFiltered.keys.toSet();
    final remoteKeys = remoteFiltered.keys.toSet();

    if (localKeys.length != remoteKeys.length) {
      return true;
    }

    // Comparer les valeurs pour chaque clé
    for (final key in localKeys) {
      if (!remoteKeys.contains(key)) {
        return true;
      }

      final localValue = localFiltered[key];
      final remoteValue = remoteFiltered[key];

      // Comparaison stricte (null-safe)
      if (localValue != remoteValue) {
        // Pour les nombres, vérifier la conversion JSON (int vs double)
        if (localValue is num && remoteValue is num) {
          if (localValue.toDouble() != remoteValue.toDouble()) {
            return true;
          }
        } else {
          return true;
        }
      }
    }

    return false;
  }

  /// Enregistre un conflit dans la table sync_conflicts
  Future<void> _recordConflict({
    required String tableName,
    required String recordId,
    required Map<String, dynamic> localData,
    required Map<String, dynamic> remoteData,
    required DateTime localUpdatedAt,
    required DateTime remoteUpdatedAt,
    required bool autoResolved,
    required String resolution,
  }) async {
    try {
      final conflictId = _uuid.v4();
      final now = DateTime.now().millisecondsSinceEpoch;

      await _db.syncConflictDao.createConflict(
        SyncConflictsCompanion.insert(
          id: conflictId,
          storeId: _storeId,
          tableName: tableName,
          recordId: recordId,
          fieldName: const Value(null), // NULL = conflit sur plusieurs champs
          localValue: jsonEncode(localData),
          remoteValue: jsonEncode(remoteData),
          localUpdatedAt: localUpdatedAt.millisecondsSinceEpoch,
          remoteUpdatedAt: remoteUpdatedAt.millisecondsSinceEpoch,
          status: resolution,
          resolvedAt: autoResolved ? Value(now) : const Value.absent(),
          resolvedBy: const Value.absent(), // Système auto-résolu
          resolutionNotes: autoResolved
              ? const Value('Auto-résolu: last-write-wins')
              : const Value.absent(),
          detectedAt: now,
          createdAt: now,
          updatedAt: now,
          synced: 0, // Sync vers Supabase pour audit
        ),
      );
    } catch (e) {
      // Ne pas bloquer la sync si l'enregistrement du conflit échoue
      print('[ConflictDetector] Failed to record conflict: $e');
    }
  }
}

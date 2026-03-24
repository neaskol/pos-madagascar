import 'package:supabase_flutter/supabase_flutter.dart';
import '../local/app_database.dart';

/// Handles bidirectional sync between Drift (local) and Supabase (remote)
///
/// Architecture: Offline-first
/// - Priority: Drift is source of truth
/// - Writes: Always go to Drift first, then sync to Supabase in background
/// - Reads: From Drift for speed, Supabase for initial seed
/// - Conflicts: Last-write-wins (can be customized per table)
///
/// Usage:
/// ```dart
/// final syncService = SyncService(localDb, SupabaseService.client);
/// await syncService.syncToRemote(); // Push unsynced local changes
/// ```
///
/// NOTE: This is a skeleton implementation. Full sync logic will be implemented
/// when DAOs are created with proper `getUnsyncedX()` and `markXSynced()` methods.
class SyncService {
  final AppDatabase _localDb;
  final SupabaseClient _supabase;

  SyncService(this._localDb, this._supabase);

  /// Sync all unsynced local changes to Supabase
  ///
  /// This method pushes all records marked as `synced: false` to Supabase.
  /// On success, marks them as `synced: true` locally.
  /// On error, logs but doesn't throw (offline resilience).
  ///
  /// TODO: Implement when DAOs are created
  Future<void> syncToRemote() async {
    // Implementation will be completed when DAOs are created
    // with getUnsyncedStores(), markStoreSynced(), etc.
    throw UnimplementedError('Sync logic pending DAO implementation');
  }

  /// TODO: Pull changes from Supabase to Drift
  /// This will be implemented when we add real-time subscriptions
  Future<void> syncFromRemote() async {
    // Implementation will come later
    throw UnimplementedError('Pull sync not yet implemented');
  }
}

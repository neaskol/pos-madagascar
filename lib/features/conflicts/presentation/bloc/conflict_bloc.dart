import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/data/local/app_database.dart';
import 'conflict_event.dart';
import 'conflict_state.dart';

class ConflictBloc extends Bloc<ConflictEvent, ConflictState> {
  final AppDatabase _database;

  ConflictBloc(this._database) : super(ConflictInitial()) {
    on<LoadPendingConflicts>(_onLoadPendingConflicts);
    on<ResolveWithLocal>(_onResolveWithLocal);
    on<ResolveWithRemote>(_onResolveWithRemote);
    on<ResolveManually>(_onResolveManually);
    on<DeleteResolvedConflicts>(_onDeleteResolvedConflicts);
  }

  Future<void> _onLoadPendingConflicts(
    LoadPendingConflicts event,
    Emitter<ConflictState> emit,
  ) async {
    try {
      emit(ConflictLoading());

      final conflicts = await _database.syncConflictDao
          .getPendingConflictsForStore(event.storeId);

      final pendingCount = conflicts.where((c) => c.status == 'pending').length;
      final resolvedCount = conflicts.length - pendingCount;

      emit(ConflictLoaded(
        conflicts: conflicts,
        pendingCount: pendingCount,
        resolvedCount: resolvedCount,
      ));
    } catch (e) {
      emit(ConflictError('Failed to load conflicts: $e'));
    }
  }

  Future<void> _onResolveWithLocal(
    ResolveWithLocal event,
    Emitter<ConflictState> emit,
  ) async {
    try {
      emit(ConflictResolving(event.conflictId));

      await _database.syncConflictDao.resolveWithLocal(
        conflictId: event.conflictId,
        resolvedBy: event.resolvedBy,
        notes: event.notes,
      );

      emit(ConflictResolved(
        conflictId: event.conflictId,
        resolution: 'resolved_local',
      ));
    } catch (e) {
      emit(ConflictError('Failed to resolve conflict: $e'));
    }
  }

  Future<void> _onResolveWithRemote(
    ResolveWithRemote event,
    Emitter<ConflictState> emit,
  ) async {
    try {
      emit(ConflictResolving(event.conflictId));

      await _database.syncConflictDao.resolveWithRemote(
        conflictId: event.conflictId,
        resolvedBy: event.resolvedBy,
        notes: event.notes,
      );

      emit(ConflictResolved(
        conflictId: event.conflictId,
        resolution: 'resolved_remote',
      ));
    } catch (e) {
      emit(ConflictError('Failed to resolve conflict: $e'));
    }
  }

  Future<void> _onResolveManually(
    ResolveManually event,
    Emitter<ConflictState> emit,
  ) async {
    try {
      emit(ConflictResolving(event.conflictId));

      await _database.syncConflictDao.resolveManually(
        conflictId: event.conflictId,
        resolvedBy: event.resolvedBy,
        notes: event.notes,
      );

      emit(ConflictResolved(
        conflictId: event.conflictId,
        resolution: 'resolved_manual',
      ));
    } catch (e) {
      emit(ConflictError('Failed to resolve conflict: $e'));
    }
  }

  Future<void> _onDeleteResolvedConflicts(
    DeleteResolvedConflicts event,
    Emitter<ConflictState> emit,
  ) async {
    try {
      emit(ConflictLoading());

      final deletedCount = await _database.syncConflictDao
          .deleteResolvedConflicts(event.storeId);

      // Reload conflicts after deletion
      final conflicts = await _database.syncConflictDao
          .getPendingConflictsForStore(event.storeId);

      final pendingCount = conflicts.where((c) => c.status == 'pending').length;
      final resolvedCount = conflicts.length - pendingCount;

      emit(ConflictLoaded(
        conflicts: conflicts,
        pendingCount: pendingCount,
        resolvedCount: resolvedCount,
      ));
    } catch (e) {
      emit(ConflictError('Failed to delete conflicts: $e'));
    }
  }
}

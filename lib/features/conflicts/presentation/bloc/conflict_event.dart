import 'package:equatable/equatable.dart';

abstract class ConflictEvent extends Equatable {
  const ConflictEvent();

  @override
  List<Object?> get props => [];
}

/// Load all pending conflicts for the current store
class LoadPendingConflicts extends ConflictEvent {
  final String storeId;

  const LoadPendingConflicts(this.storeId);

  @override
  List<Object?> get props => [storeId];
}

/// Resolve conflict by choosing the local value
class ResolveWithLocal extends ConflictEvent {
  final String conflictId;
  final String resolvedBy;
  final String? notes;

  const ResolveWithLocal({
    required this.conflictId,
    required this.resolvedBy,
    this.notes,
  });

  @override
  List<Object?> get props => [conflictId, resolvedBy, notes];
}

/// Resolve conflict by choosing the remote value
class ResolveWithRemote extends ConflictEvent {
  final String conflictId;
  final String resolvedBy;
  final String? notes;

  const ResolveWithRemote({
    required this.conflictId,
    required this.resolvedBy,
    this.notes,
  });

  @override
  List<Object?> get props => [conflictId, resolvedBy, notes];
}

/// Resolve conflict manually (custom resolution)
class ResolveManually extends ConflictEvent {
  final String conflictId;
  final String resolvedBy;
  final String? notes;

  const ResolveManually({
    required this.conflictId,
    required this.resolvedBy,
    this.notes,
  });

  @override
  List<Object?> get props => [conflictId, resolvedBy, notes];
}

/// Delete all resolved conflicts
class DeleteResolvedConflicts extends ConflictEvent {
  final String storeId;

  const DeleteResolvedConflicts(this.storeId);

  @override
  List<Object?> get props => [storeId];
}

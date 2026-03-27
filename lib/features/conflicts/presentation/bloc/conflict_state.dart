import 'package:equatable/equatable.dart';
import '../../../../core/data/local/app_database.dart';

abstract class ConflictState extends Equatable {
  const ConflictState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class ConflictInitial extends ConflictState {}

/// Loading conflicts
class ConflictLoading extends ConflictState {}

/// Conflicts loaded successfully
class ConflictLoaded extends ConflictState {
  final List<SyncConflict> conflicts;
  final int pendingCount;
  final int resolvedCount;

  const ConflictLoaded({
    required this.conflicts,
    required this.pendingCount,
    required this.resolvedCount,
  });

  @override
  List<Object?> get props => [conflicts, pendingCount, resolvedCount];
}

/// Resolving a conflict
class ConflictResolving extends ConflictState {
  final String conflictId;

  const ConflictResolving(this.conflictId);

  @override
  List<Object?> get props => [conflictId];
}

/// Conflict resolved successfully
class ConflictResolved extends ConflictState {
  final String conflictId;
  final String resolution;

  const ConflictResolved({
    required this.conflictId,
    required this.resolution,
  });

  @override
  List<Object?> get props => [conflictId, resolution];
}

/// Error occurred
class ConflictError extends ConflictState {
  final String message;

  const ConflictError(this.message);

  @override
  List<Object?> get props => [message];
}

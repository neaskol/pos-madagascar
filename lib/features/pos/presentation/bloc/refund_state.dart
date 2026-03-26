import 'package:equatable/equatable.dart';
import '../../../../core/data/local/app_database.dart';

abstract class RefundState extends Equatable {
  const RefundState();

  @override
  List<Object?> get props => [];
}

/// État initial
class RefundInitial extends RefundState {}

/// Chargement en cours
class RefundLoading extends RefundState {}

/// Remboursements chargés
class RefundLoaded extends RefundState {
  final List<Refund> refunds;
  final bool isSaleRefunded;

  const RefundLoaded({
    required this.refunds,
    this.isSaleRefunded = false,
  });

  @override
  List<Object?> get props => [refunds, isSaleRefunded];

  RefundLoaded copyWith({
    List<Refund>? refunds,
    bool? isSaleRefunded,
  }) {
    return RefundLoaded(
      refunds: refunds ?? this.refunds,
      isSaleRefunded: isSaleRefunded ?? this.isSaleRefunded,
    );
  }
}

/// Remboursement créé avec succès
class RefundCreated extends RefundState {
  final String refundId;

  const RefundCreated(this.refundId);

  @override
  List<Object?> get props => [refundId];
}

/// Erreur
class RefundError extends RefundState {
  final String message;

  const RefundError(this.message);

  @override
  List<Object?> get props => [message];
}

import 'package:equatable/equatable.dart';
import '../../data/repositories/refund_repository.dart';

abstract class RefundEvent extends Equatable {
  const RefundEvent();

  @override
  List<Object?> get props => [];
}

/// Charger les remboursements d'un magasin
class LoadRefunds extends RefundEvent {
  final String storeId;

  const LoadRefunds(this.storeId);

  @override
  List<Object?> get props => [storeId];
}

/// Charger les remboursements d'une vente spécifique
class LoadRefundsBySale extends RefundEvent {
  final String saleId;

  const LoadRefundsBySale(this.saleId);

  @override
  List<Object?> get props => [saleId];
}

/// Créer un remboursement
class CreateRefund extends RefundEvent {
  final String saleId;
  final String storeId;
  final String employeeId;
  final List<RefundItemData> items;
  final String reason;

  const CreateRefund({
    required this.saleId,
    required this.storeId,
    required this.employeeId,
    required this.items,
    required this.reason,
  });

  @override
  List<Object?> get props => [saleId, storeId, employeeId, items, reason];
}

/// Vérifier si une vente est remboursée
class CheckSaleRefunded extends RefundEvent {
  final String saleId;

  const CheckSaleRefunded(this.saleId);

  @override
  List<Object?> get props => [saleId];
}

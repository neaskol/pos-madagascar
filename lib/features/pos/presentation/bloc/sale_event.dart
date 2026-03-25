import 'package:equatable/equatable.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/entities/sale.dart';

/// Events pour la gestion des ventes
abstract class SaleEvent extends Equatable {
  const SaleEvent();

  @override
  List<Object?> get props => [];
}

/// Représente un paiement dans le CreateSaleEvent
class PaymentData {
  final PaymentType type;
  final int amount;
  final String? reference;

  const PaymentData({
    required this.type,
    required this.amount,
    this.reference,
  });
}

/// Créer une vente (paiement)
class CreateSaleEvent extends SaleEvent {
  final String storeId;
  final String employeeId;
  final List<CartItem> items;
  final int subtotal;
  final int taxAmount;
  final int discountAmount;
  final int total;

  // Mode single payment (rétrocompatibilité)
  final PaymentType? paymentType;
  final int? amountReceived; // montant reçu du client
  final String? paymentReference; // pour MVola/Orange Money

  // Mode multi-payment (nouveau)
  final List<PaymentData>? payments;

  final String? customerId;
  final String? note;

  const CreateSaleEvent({
    required this.storeId,
    required this.employeeId,
    required this.items,
    required this.subtotal,
    required this.taxAmount,
    required this.discountAmount,
    required this.total,
    // Single payment
    this.paymentType,
    this.amountReceived,
    this.paymentReference,
    // Multi-payment
    this.payments,
    this.customerId,
    this.note,
  });

  @override
  List<Object?> get props => [
        storeId,
        employeeId,
        items,
        subtotal,
        taxAmount,
        discountAmount,
        total,
        paymentType,
        amountReceived,
        paymentReference,
        payments,
        customerId,
        note,
      ];
}

/// Charger les ventes d'un magasin
class LoadSalesEvent extends SaleEvent {
  final String storeId;
  final DateTime? startDate;
  final DateTime? endDate;

  const LoadSalesEvent({
    required this.storeId,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [storeId, startDate, endDate];
}

/// Charger une vente spécifique
class LoadSaleByIdEvent extends SaleEvent {
  final String saleId;

  const LoadSaleByIdEvent(this.saleId);

  @override
  List<Object?> get props => [saleId];
}

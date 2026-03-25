import 'package:equatable/equatable.dart';
import 'cart_item.dart';

/// Entité représentant une vente finalisée
class Sale extends Equatable {
  final String id;
  final String storeId;
  final String? posDeviceId;
  final String receiptNumber;
  final String employeeId;
  final String? customerId;
  final int subtotal; // en Ariary
  final int taxAmount; // en Ariary
  final int discountAmount; // en Ariary
  final int total; // en Ariary
  final int changeDue; // en Ariary
  final String? note;
  final DateTime createdAt;
  final List<CartItem> items;
  final List<SalePayment> payments;

  const Sale({
    required this.id,
    required this.storeId,
    this.posDeviceId,
    required this.receiptNumber,
    required this.employeeId,
    this.customerId,
    required this.subtotal,
    required this.taxAmount,
    required this.discountAmount,
    required this.total,
    required this.changeDue,
    this.note,
    required this.createdAt,
    required this.items,
    required this.payments,
  });

  @override
  List<Object?> get props => [
        id,
        storeId,
        posDeviceId,
        receiptNumber,
        employeeId,
        customerId,
        subtotal,
        taxAmount,
        discountAmount,
        total,
        changeDue,
        note,
        createdAt,
        items,
        payments,
      ];

  Sale copyWith({
    String? id,
    String? storeId,
    String? posDeviceId,
    String? receiptNumber,
    String? employeeId,
    String? customerId,
    int? subtotal,
    int? taxAmount,
    int? discountAmount,
    int? total,
    int? changeDue,
    String? note,
    DateTime? createdAt,
    List<CartItem>? items,
    List<SalePayment>? payments,
  }) {
    return Sale(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      posDeviceId: posDeviceId ?? this.posDeviceId,
      receiptNumber: receiptNumber ?? this.receiptNumber,
      employeeId: employeeId ?? this.employeeId,
      customerId: customerId ?? this.customerId,
      subtotal: subtotal ?? this.subtotal,
      taxAmount: taxAmount ?? this.taxAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      total: total ?? this.total,
      changeDue: changeDue ?? this.changeDue,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      items: items ?? this.items,
      payments: payments ?? this.payments,
    );
  }
}

/// Paiement associé à une vente (multi-paiement possible)
class SalePayment extends Equatable {
  final String id;
  final String saleId;
  final PaymentType paymentType;
  final int amount; // en Ariary
  final String? paymentReference; // numéro transaction MVola/Orange Money
  final PaymentStatus status;

  const SalePayment({
    required this.id,
    required this.saleId,
    required this.paymentType,
    required this.amount,
    this.paymentReference,
    required this.status,
  });

  @override
  List<Object?> get props => [
        id,
        saleId,
        paymentType,
        amount,
        paymentReference,
        status,
      ];

  SalePayment copyWith({
    String? id,
    String? saleId,
    PaymentType? paymentType,
    int? amount,
    String? paymentReference,
    PaymentStatus? status,
  }) {
    return SalePayment(
      id: id ?? this.id,
      saleId: saleId ?? this.saleId,
      paymentType: paymentType ?? this.paymentType,
      amount: amount ?? this.amount,
      paymentReference: paymentReference ?? this.paymentReference,
      status: status ?? this.status,
    );
  }
}

/// Types de paiement supportés
enum PaymentType {
  cash,
  card,
  mvola,
  orangeMoney,
  credit, // Vente à crédit - Différenciant #3
  custom,
}

/// Statuts de paiement
enum PaymentStatus {
  pending,
  completed,
  failed,
  refunded,
}

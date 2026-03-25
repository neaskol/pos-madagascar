import 'package:uuid/uuid.dart';
import '../../../../core/data/local/app_database.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/entities/sale.dart';
import '../../presentation/bloc/sale_event.dart';

/// Repository pour les ventes
class SaleRepository {
  final AppDatabase database;
  final _uuid = const Uuid();

  SaleRepository(this.database);

  /// Créer une vente (paiement)
  /// Supporte à la fois single payment (rétrocompatibilité) et multi-payment
  Future<Sale> createSale({
    required String storeId,
    required String employeeId,
    required List<CartItem> items,
    required int subtotal,
    required int taxAmount,
    required int discountAmount,
    required int total,
    // Single payment (rétrocompatibilité)
    PaymentType? paymentType,
    int? amountReceived,
    String? paymentReference,
    // Multi-payment (nouveau)
    List<PaymentData>? payments,
    String? customerId,
    String? note,
  }) async {
    try {
      final saleId = _uuid.v4();
      final now = DateTime.now();

      // Générer numéro de reçu unique
      final receiptNumber = await _generateReceiptNumber(storeId, now);

      // Créer les paiements selon le mode
      final List<SalePayment> salePayments;
      final int changeDue;

      if (payments != null && payments.isNotEmpty) {
        // Mode multi-payment
        salePayments = payments.map((p) {
          return SalePayment(
            id: _uuid.v4(),
            saleId: saleId,
            paymentType: p.type,
            amount: p.amount,
            paymentReference: p.reference,
            status: PaymentStatus.completed,
          );
        }).toList();

        // Pas de monnaie à rendre en multi-payment (doit être exact)
        changeDue = 0;
      } else {
        // Mode single payment (rétrocompatibilité)
        if (paymentType == null || amountReceived == null) {
          throw Exception(
              'paymentType et amountReceived sont requis pour single payment');
        }

        changeDue = amountReceived - total;

        salePayments = [
          SalePayment(
            id: _uuid.v4(),
            saleId: saleId,
            paymentType: paymentType,
            amount: amountReceived,
            paymentReference: paymentReference,
            status: PaymentStatus.completed,
          ),
        ];
      }

      // Créer l'entité Sale pour retour
      final sale = Sale(
        id: saleId,
        storeId: storeId,
        receiptNumber: receiptNumber,
        employeeId: employeeId,
        customerId: customerId,
        subtotal: subtotal,
        taxAmount: taxAmount,
        discountAmount: discountAmount,
        total: total,
        changeDue: changeDue,
        note: note,
        createdAt: now,
        items: items,
        payments: salePayments,
      );

      // Sauvegarder dans Drift (local first)
      await _saveSaleToLocal(sale);

      // TODO: Sync vers Supabase en arrière-plan

      return sale;
    } catch (e) {
      throw Exception('Erreur création vente: $e');
    }
  }

  /// Charger les ventes d'un magasin
  Future<List<Sale>> getSales({
    required String storeId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // TODO: Implémenter après création des DAOs
    return [];
  }

  /// Charger une vente par ID
  Future<Sale?> getSaleById(String saleId) async {
    // TODO: Implémenter après création des DAOs
    return null;
  }

  /// Générer un numéro de reçu unique
  /// Format: YYYYMMDD-XXXX (ex: 20260325-0001)
  Future<String> _generateReceiptNumber(
      String storeId, DateTime date) async {
    final datePrefix =
        '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';

    // TODO: Query database for today's count
    // Pour l'instant, utiliser un compteur simple
    final count = 1; // Sera remplacé par query DB

    final sequence = count.toString().padLeft(4, '0');
    return '$datePrefix-$sequence';
  }

  /// Sauvegarder vente dans Drift
  Future<void> _saveSaleToLocal(Sale sale) async {
    // TODO: Implémenter avec les DAOs Drift
    // Pour l'instant, juste retourner (données en mémoire)
    return;
  }
}

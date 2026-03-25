import 'package:uuid/uuid.dart';
import '../../../../core/data/local/app_database.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/entities/sale.dart';

/// Repository pour les ventes
class SaleRepository {
  final AppDatabase database;
  final _uuid = const Uuid();

  SaleRepository(this.database);

  /// Créer une vente (paiement)
  Future<Sale> createSale({
    required String storeId,
    required String employeeId,
    required List<CartItem> items,
    required int subtotal,
    required int taxAmount,
    required int discountAmount,
    required int total,
    required PaymentType paymentType,
    required int amountReceived,
    String? paymentReference,
    String? customerId,
    String? note,
  }) async {
    try {
      final saleId = _uuid.v4();
      final paymentId = _uuid.v4();
      final now = DateTime.now();

      // Calculer la monnaie à rendre
      final changeDue = amountReceived - total;

      // Générer numéro de reçu unique
      final receiptNumber = await _generateReceiptNumber(storeId, now);

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
        payments: [
          SalePayment(
            id: paymentId,
            saleId: saleId,
            paymentType: paymentType,
            amount: amountReceived,
            paymentReference: paymentReference,
            status: PaymentStatus.completed,
          ),
        ],
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

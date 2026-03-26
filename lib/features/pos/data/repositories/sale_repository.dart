import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/data/local/app_database.dart' hide Sale, SalePayment;
import '../../../../core/data/remote/sync_service.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/entities/sale.dart';
import '../../presentation/bloc/sale_event.dart';

/// Repository pour les ventes
class SaleRepository {
  final AppDatabase database;
  final SyncService? syncService;
  final _uuid = const Uuid();

  SaleRepository(this.database, {this.syncService});

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

      // Sync immédiat vers Supabase en arrière-plan (non-blocking)
      syncService?.forceSyncNow().catchError((e) {
        // Log silencieux — ne pas bloquer si sync échoue (offline resilience)
        print('Background sync failed after sale creation: $e');
      });

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

    // Récupérer le prochain numéro séquentiel depuis la DB
    final sequence = await database.saleDao.generateReceiptNumber(storeId);

    return '$datePrefix-$sequence';
  }

  /// Sauvegarder vente dans Drift (offline-first)
  Future<void> _saveSaleToLocal(Sale sale) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    // Créer le SalesCompanion
    final saleCompanion = SalesCompanion.insert(
      id: sale.id,
      storeId: sale.storeId,
      posDeviceId: Value(sale.posDeviceId),
      receiptNumber: sale.receiptNumber,
      employeeId: Value(sale.employeeId),
      customerId: Value(sale.customerId),
      subtotal: Value(sale.subtotal),
      taxAmount: Value(sale.taxAmount),
      discountAmount: Value(sale.discountAmount),
      total: sale.total,
      changeDue: Value(sale.changeDue),
      note: Value(sale.note),
      synced: const Value(0), // Pas encore synchronisé
      createdAt: now,
      updatedAt: now,
    );

    // Créer les SaleItemsCompanion
    final itemCompanions = sale.items.map((item) {
      return SaleItemsCompanion.insert(
        id: _uuid.v4(),
        saleId: sale.id,
        itemId: Value(item.itemId),
        itemVariantId: Value(item.itemVariantId),
        itemName: item.name,
        quantity: Value(item.quantity),
        unitPrice: item.unitPrice,
        cost: Value(item.cost),
        discountAmount: Value(item.totalDiscountAmount),
        taxAmount: Value(item.totalTaxAmount),
        total: item.lineTotal,
        synced: const Value(0),
        createdAt: now,
        updatedAt: now,
      );
    }).toList();

    // Créer les SalePaymentsCompanion
    final paymentCompanions = sale.payments.map((payment) {
      return SalePaymentsCompanion.insert(
        id: payment.id,
        saleId: payment.saleId,
        paymentType: payment.paymentType.name, // Enum → String
        amount: payment.amount,
        paymentReference: Value(payment.paymentReference),
        synced: const Value(0),
        createdAt: now,
        updatedAt: now,
      );
    }).toList();

    // Insérer tout en transaction atomique
    await database.saleDao.insertFullSale(
      sale: saleCompanion,
      items: itemCompanions,
      payments: paymentCompanions,
    );
  }
}

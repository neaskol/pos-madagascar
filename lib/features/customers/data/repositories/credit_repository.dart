import 'package:drift/drift.dart';
import '../../../../core/data/local/app_database.dart';

/// Repository for store credit management
/// Handles offline-first credit sales with payment tracking
/// Différenciant #3 - inexistant chez tous les concurrents
class CreditRepository {
  final AppDatabase database;
  final CreditDao _creditDao;
  final CustomerDao _customerDao;

  CreditRepository({required this.database})
      : _creditDao = database.creditDao,
        _customerDao = database.customerDao;

  /// Get all credits for a store
  Future<List<Credit>> getCredits(String storeId) {
    return _creditDao.getCreditsByStore(storeId);
  }

  /// Get credits by customer
  Future<List<Credit>> getCreditsByCustomer(String customerId) {
    return _creditDao.getCreditsByCustomer(customerId);
  }

  /// Get credit by ID
  Future<Credit?> getCreditById(String id) {
    return _creditDao.getCreditById(id);
  }

  /// Get overdue credits
  Future<List<Credit>> getOverdueCredits(String storeId) {
    return _creditDao.getOverdueCredits(storeId);
  }

  /// Get credits by status
  Future<List<Credit>> getCreditsByStatus(String storeId, String status) {
    return _creditDao.getCreditsByStatus(storeId, status);
  }

  /// Create new credit sale
  Future<String> createCredit({
    required String storeId,
    required String customerId,
    String? saleId,
    required int amountTotal,
    DateTime? dueDate,
    String? notes,
    String? createdBy,
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final now = DateTime.now().millisecondsSinceEpoch;

    await _creditDao.createCredit(CreditsCompanion.insert(
      id: id,
      storeId: storeId,
      customerId: customerId,
      saleId: saleId != null ? Value(saleId) : const Value.absent(),
      amountTotal: amountTotal,
      amountRemaining: amountTotal, // Initially, full amount is remaining
      dueDate: dueDate != null
          ? Value(dueDate.millisecondsSinceEpoch)
          : const Value.absent(),
      notes: notes != null ? Value(notes) : const Value.absent(),
      createdAt: now,
      updatedAt: now,
      createdBy: createdBy != null ? Value(createdBy) : const Value.absent(),
    ));

    // Update customer credit balance
    await _customerDao.updateCustomerCreditBalance(customerId);

    return id;
  }

  /// Record credit payment
  Future<String> recordCreditPayment({
    required String creditId,
    required int amount,
    required String paymentType,
    String? paymentReference,
    String? notes,
    String? createdBy,
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final now = DateTime.now().millisecondsSinceEpoch;

    // Create payment record (this will automatically update credit via DAO)
    await _creditDao.createCreditPayment(CreditPaymentsCompanion.insert(
      id: id,
      creditId: creditId,
      amount: amount,
      paymentType: paymentType,
      paymentReference:
          paymentReference != null ? Value(paymentReference) : const Value.absent(),
      notes: notes != null ? Value(notes) : const Value.absent(),
      createdAt: now,
      updatedAt: now,
      createdBy: createdBy != null ? Value(createdBy) : const Value.absent(),
    ));

    // Get the credit to find customer ID
    final credit = await _creditDao.getCreditById(creditId);
    if (credit != null) {
      // Update customer credit balance
      await _customerDao.updateCustomerCreditBalance(credit.customerId);
    }

    return id;
  }

  /// Get credit payments
  Future<List<CreditPayment>> getCreditPayments(String creditId) {
    return _creditDao.getCreditPayments(creditId);
  }

  /// Get total amount owed by customer
  Future<int> getTotalCreditForCustomer(String customerId) {
    return _creditDao.getTotalCreditForCustomer(customerId);
  }

  /// Update overdue credits (call periodically)
  Future<void> updateOverdueCredits(String storeId) {
    return _creditDao.updateOverdueCredits(storeId);
  }

  /// Get credit summary for customer
  Future<Map<String, dynamic>> getCreditSummary(String customerId) async {
    final credits = await getCreditsByCustomer(customerId);

    int totalOwed = 0;
    int overdueAmount = 0;
    int totalPaid = 0;

    for (final credit in credits) {
      totalPaid += credit.amountPaid;
      if (credit.status == 'paid') continue;

      totalOwed += credit.amountRemaining;
      if (credit.status == 'overdue') {
        overdueAmount += credit.amountRemaining;
      }
    }

    return {
      'total_credits': credits.length,
      'total_owed': totalOwed,
      'overdue_amount': overdueAmount,
      'total_paid': totalPaid,
      'active_credits': credits.where((c) => c.status != 'paid').length,
    };
  }

  /// Get store credit summary
  Future<Map<String, dynamic>> getStoreCreditSummary(String storeId) async {
    final credits = await getCredits(storeId);

    int totalOwed = 0;
    int overdueAmount = 0;
    int totalPaid = 0;
    int customersWithCredit = 0;

    final customerIds = <String>{};

    for (final credit in credits) {
      totalPaid += credit.amountPaid;
      if (credit.status != 'paid') {
        totalOwed += credit.amountRemaining;
        customerIds.add(credit.customerId);
      }
      if (credit.status == 'overdue') {
        overdueAmount += credit.amountRemaining;
      }
    }

    customersWithCredit = customerIds.length;

    return {
      'total_credits': credits.length,
      'total_owed': totalOwed,
      'overdue_amount': overdueAmount,
      'total_paid': totalPaid,
      'customers_with_credit': customersWithCredit,
      'pending_credits': credits.where((c) => c.status == 'pending').length,
      'partial_credits': credits.where((c) => c.status == 'partial').length,
      'overdue_credits': credits.where((c) => c.status == 'overdue').length,
    };
  }
}

import 'package:drift/drift.dart';
import '../app_database.dart';

part 'credit_dao.g.dart';

@DriftAccessor(include: {'../tables/credits.drift'})
class CreditDao extends DatabaseAccessor<AppDatabase> with _$CreditDaoMixin {
  CreditDao(AppDatabase db) : super(db);

  // === CREDITS ===

  /// Get all credits for a store
  Future<List<Credit>> getCreditsByStore(String storeId) {
    return (select(credits)
          ..where((t) => t.storeId.equals(storeId))
          ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)]))
        .get();
  }

  /// Get credits by customer
  Future<List<Credit>> getCreditsByCustomer(String customerId) {
    return (select(credits)
          ..where((t) => t.customerId.equals(customerId))
          ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)]))
        .get();
  }

  /// Get credit by ID
  Future<Credit?> getCreditById(String id) {
    return (select(credits)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Get overdue credits
  Future<List<Credit>> getOverdueCredits(String storeId) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return (select(credits)
          ..where((t) =>
              t.storeId.equals(storeId) &
              t.status.equals('overdue') |
              (t.dueDate.isSmallerThanValue(now) & t.amountRemaining.isBiggerThanValue(0))))
        .get();
  }

  /// Get unpaid credits by status
  Future<List<Credit>> getCreditsByStatus(String storeId, String status) {
    return (select(credits)
          ..where((t) => t.storeId.equals(storeId) & t.status.equals(status))
          ..orderBy([(t) => OrderingTerm(expression: t.dueDate)]))
        .get();
  }

  /// Create credit
  Future<int> createCredit(CreditsCompanion credit) {
    return into(credits).insert(credit);
  }

  /// Update credit
  Future<bool> updateCredit(CreditsCompanion credit) {
    return update(credits).replace(credit);
  }

  /// Delete credit
  Future<int> deleteCredit(String id) {
    return (delete(credits)..where((t) => t.id.equals(id))).go();
  }

  /// Update credit after payment
  Future<void> updateCreditAfterPayment(String creditId, int paymentAmount) async {
    final credit = await getCreditById(creditId);
    if (credit == null) return;

    final newAmountPaid = credit.amountPaid + paymentAmount;
    final newAmountRemaining = credit.amountTotal - newAmountPaid;

    // Determine new status
    String newStatus;
    if (newAmountRemaining == 0) {
      newStatus = 'paid';
    } else if (newAmountPaid > 0 && newAmountRemaining > 0) {
      newStatus = 'partial';
    } else if (credit.dueDate != null &&
        credit.dueDate! < DateTime.now().millisecondsSinceEpoch &&
        newAmountRemaining > 0) {
      newStatus = 'overdue';
    } else {
      newStatus = 'pending';
    }

    await (update(credits)..where((t) => t.id.equals(creditId)))
        .write(CreditsCompanion(
      amountPaid: Value(newAmountPaid),
      amountRemaining: Value(newAmountRemaining),
      status: Value(newStatus),
      updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
    ));
  }

  /// Check and update overdue credits
  Future<void> updateOverdueCredits(String storeId) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await (update(credits)
          ..where((t) =>
              t.storeId.equals(storeId) &
              t.dueDate.isSmallerThanValue(now) &
              t.amountRemaining.isBiggerThanValue(0) &
              t.status.equals('pending')))
        .write(const CreditsCompanion(status: Value('overdue')));
  }

  /// Get total credit amount for a customer
  Future<int> getTotalCreditForCustomer(String customerId) async {
    final customerCredits = await (select(credits)
          ..where((t) =>
              t.customerId.equals(customerId) &
              t.status.isIn(['pending', 'partial', 'overdue'])))
        .get();
    return customerCredits.fold<int>(0, (sum, c) => sum + c.amountRemaining);
  }

  /// Get unsynced credits
  Future<List<Credit>> getUnsyncedCredits() {
    return (select(credits)..where((t) => t.synced.equals(0))).get();
  }

  /// Mark credit as synced
  Future<void> markCreditAsSynced(String id) {
    return (update(credits)..where((t) => t.id.equals(id)))
        .write(const CreditsCompanion(synced: Value(1)));
  }

  // === CREDIT PAYMENTS ===

  /// Get payments for a credit
  Future<List<CreditPayment>> getCreditPayments(String creditId) {
    return (select(creditPayments)
          ..where((t) => t.creditId.equals(creditId))
          ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)]))
        .get();
  }

  /// Create credit payment
  Future<String> createCreditPayment(CreditPaymentsCompanion payment) async {
    final id = await into(creditPayments).insert(payment);

    // Update credit after payment
    final paymentRecord = await (select(creditPayments)..where((t) => t.id.equals(id.toString()))).getSingle();
    await updateCreditAfterPayment(paymentRecord.creditId, paymentRecord.amount);

    return id.toString();
  }

  /// Get unsynced credit payments
  Future<List<CreditPayment>> getUnsyncedCreditPayments() {
    return (select(creditPayments)..where((t) => t.synced.equals(0))).get();
  }

  /// Mark credit payment as synced
  Future<void> markCreditPaymentAsSynced(String id) {
    return (update(creditPayments)..where((t) => t.id.equals(id)))
        .write(const CreditPaymentsCompanion(synced: Value(1)));
  }

  /// Get total payments for a credit
  Future<int> getTotalPaymentsForCredit(String creditId) async {
    final payments = await getCreditPayments(creditId);
    return payments.fold<int>(0, (sum, p) => sum + p.amount);
  }
}

import 'package:drift/drift.dart';
import '../app_database.dart';

part 'customer_dao.g.dart';

@DriftAccessor(include: {'../tables/customers.drift', '../tables/credits.drift'})
class CustomerDao extends DatabaseAccessor<AppDatabase> with _$CustomerDaoMixin {
  CustomerDao(AppDatabase db) : super(db);

  // === CUSTOMERS ===

  /// Get all customers for a store
  Future<List<Customer>> getCustomersByStore(String storeId) {
    return (select(customers)
          ..where((t) => t.storeId.equals(storeId))
          ..orderBy([(t) => OrderingTerm(expression: t.name)]))
        .get();
  }

  /// Get customer by ID
  Future<Customer?> getCustomerById(String id) {
    return (select(customers)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Search customers by name or phone
  Future<List<Customer>> searchCustomers(String storeId, String query) {
    final lowerQuery = query.toLowerCase();
    return (select(customers)
          ..where((t) =>
              t.storeId.equals(storeId) &
              (t.name.lower().contains(lowerQuery) |
                  t.phone.lower().contains(lowerQuery) |
                  t.email.lower().contains(lowerQuery))))
        .get();
  }

  /// Get customer by phone
  Future<Customer?> getCustomerByPhone(String storeId, String phone) {
    return (select(customers)
          ..where((t) => t.storeId.equals(storeId) & t.phone.equals(phone)))
        .getSingleOrNull();
  }

  /// Get customer by loyalty card barcode
  Future<Customer?> getCustomerByLoyaltyCard(String storeId, String barcode) {
    return (select(customers)
          ..where((t) =>
              t.storeId.equals(storeId) & t.loyaltyCardBarcode.equals(barcode)))
        .getSingleOrNull();
  }

  /// Create or update customer
  Future<int> upsertCustomer(CustomersCompanion customer) {
    return into(customers).insertOnConflictUpdate(customer);
  }

  /// Delete customer
  Future<int> deleteCustomer(String id) {
    return (delete(customers)..where((t) => t.id.equals(id))).go();
  }

  /// Update customer stats after sale
  Future<void> updateCustomerStats(
    String customerId,
    int saleAmount,
  ) async {
    final customer = await getCustomerById(customerId);
    if (customer == null) return;

    await update(customers).replace(CustomersCompanion(
      id: Value(customerId),
      totalVisits: Value(customer.totalVisits + 1),
      totalSpent: Value(customer.totalSpent + saleAmount),
      updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
    ));
  }

  /// Update customer credit balance
  Future<void> updateCustomerCreditBalance(String customerId) async {
    final unpaidCredits = await (select(credits)
          ..where((t) =>
              t.customerId.equals(customerId) &
              t.status.isIn(['pending', 'partial', 'overdue'])))
        .get();

    final totalOwed =
        unpaidCredits.fold<int>(0, (sum, c) => sum + c.amountRemaining);

    await (update(customers)..where((t) => t.id.equals(customerId)))
        .write(CustomersCompanion(
      creditBalance: Value(totalOwed),
      updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
    ));
  }

  /// Get customers with outstanding credit
  Future<List<Customer>> getCustomersWithCredit(String storeId) {
    return (select(customers)
          ..where((t) => t.storeId.equals(storeId) & t.creditBalance.isBiggerThanValue(0))
          ..orderBy([(t) => OrderingTerm(expression: t.creditBalance, mode: OrderingMode.desc)]))
        .get();
  }

  /// Get unsynced customers
  Future<List<Customer>> getUnsyncedCustomers() {
    return (select(customers)..where((t) => t.synced.equals(0))).get();
  }

  /// Mark customer as synced
  Future<void> markCustomerAsSynced(String id) {
    return (update(customers)..where((t) => t.id.equals(id)))
        .write(const CustomersCompanion(synced: Value(1)));
  }

  // === LOYALTY POINTS ===

  /// Get loyalty points for customer
  Future<LoyaltyPoint?> getLoyaltyPoints(String customerId) {
    return (select(loyaltyPoints)..where((t) => t.customerId.equals(customerId)))
        .getSingleOrNull();
  }

  /// Update loyalty points
  Future<void> updateLoyaltyPoints(String customerId, String storeId, int points) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return into(loyaltyPoints).insertOnConflictUpdate(LoyaltyPointsCompanion.insert(
      id: customerId, // Use customer ID as primary key for 1:1 relationship
      customerId: customerId,
      storeId: storeId,
      createdAt: now,
      updatedAt: now,
      points: Value(points),
    ));
  }
}

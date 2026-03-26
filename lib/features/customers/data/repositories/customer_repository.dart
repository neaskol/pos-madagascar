import 'package:drift/drift.dart';
import '../../../../core/data/local/app_database.dart';

/// Repository for customer management
/// Handles offline-first customer data with Supabase sync
class CustomerRepository {
  final AppDatabase database;
  final CustomerDao _customerDao;

  CustomerRepository({required this.database})
      : _customerDao = database.customerDao;

  /// Get all customers for a store
  Future<List<Customer>> getCustomers(String storeId) {
    return _customerDao.getCustomersByStore(storeId);
  }

  /// Get customer by ID
  Future<Customer?> getCustomerById(String id) {
    return _customerDao.getCustomerById(id);
  }

  /// Search customers by name or phone
  Future<List<Customer>> searchCustomers(String storeId, String query) {
    return _customerDao.searchCustomers(storeId, query);
  }

  /// Get customer by phone
  Future<Customer?> getCustomerByPhone(String storeId, String phone) {
    return _customerDao.getCustomerByPhone(storeId, phone);
  }

  /// Get customer by loyalty card barcode
  Future<Customer?> getCustomerByLoyaltyCard(String storeId, String barcode) {
    return _customerDao.getCustomerByLoyaltyCard(storeId, barcode);
  }

  /// Create new customer
  Future<String> createCustomer({
    required String storeId,
    required String name,
    String? phone,
    String? email,
    String? loyaltyCardBarcode,
    String? notes,
    String? createdBy,
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final now = DateTime.now().millisecondsSinceEpoch;

    await _customerDao.upsertCustomer(CustomersCompanion.insert(
      id: id,
      storeId: storeId,
      name: name,
      phone: phone != null ? Value(phone) : const Value.absent(),
      email: email != null ? Value(email) : const Value.absent(),
      loyaltyCardBarcode: loyaltyCardBarcode != null
          ? Value(loyaltyCardBarcode)
          : const Value.absent(),
      notes: notes != null ? Value(notes) : const Value.absent(),
      createdAt: now,
      updatedAt: now,
      createdBy: createdBy != null ? Value(createdBy) : const Value.absent(),
    ));

    return id;
  }

  /// Update existing customer
  Future<void> updateCustomer({
    required String id,
    String? name,
    String? phone,
    String? email,
    String? loyaltyCardBarcode,
    String? notes,
  }) async {
    final customer = await _customerDao.getCustomerById(id);
    if (customer == null) return;

    await _customerDao.upsertCustomer(CustomersCompanion(
      id: Value(id),
      storeId: Value(customer.storeId),
      name: name != null ? Value(name) : Value(customer.name),
      phone: phone != null ? Value(phone) : Value(customer.phone),
      email: email != null ? Value(email) : Value(customer.email),
      loyaltyCardBarcode: loyaltyCardBarcode != null
          ? Value(loyaltyCardBarcode)
          : Value(customer.loyaltyCardBarcode),
      notes: notes != null ? Value(notes) : Value(customer.notes),
      createdAt: Value(customer.createdAt),
      updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      synced: const Value(0), // Mark as unsynced
    ));
  }

  /// Delete customer
  Future<void> deleteCustomer(String id) {
    return _customerDao.deleteCustomer(id);
  }

  /// Update customer stats after sale
  Future<void> updateCustomerStats(String customerId, int saleAmount) {
    return _customerDao.updateCustomerStats(customerId, saleAmount);
  }

  /// Get customers with outstanding credit
  Future<List<Customer>> getCustomersWithCredit(String storeId) {
    return _customerDao.getCustomersWithCredit(storeId);
  }

  /// Update customer credit balance
  Future<void> updateCustomerCreditBalance(String customerId) {
    return _customerDao.updateCustomerCreditBalance(customerId);
  }

  /// Get loyalty points for customer
  Future<int> getLoyaltyPoints(String customerId) async {
    final loyaltyPoint = await _customerDao.getLoyaltyPoints(customerId);
    return loyaltyPoint?.points ?? 0;
  }

  /// Update loyalty points
  Future<void> updateLoyaltyPoints(
      String customerId, String storeId, int points) {
    return _customerDao.updateLoyaltyPoints(customerId, storeId, points);
  }

  /// Add loyalty points after sale
  Future<void> addLoyaltyPoints(
      String customerId, String storeId, int saleAmount) async {
    // 1 point per 1000 Ar spent (configurable)
    final pointsToAdd = (saleAmount / 1000).floor();
    if (pointsToAdd <= 0) return;

    final currentPoints = await getLoyaltyPoints(customerId);
    await updateLoyaltyPoints(customerId, storeId, currentPoints + pointsToAdd);
  }
}

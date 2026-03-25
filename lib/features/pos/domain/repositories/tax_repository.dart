import '../entities/tax.dart';

abstract class TaxRepository {
  /// Get all active taxes for a store
  Future<List<Tax>> getTaxes(String storeId);

  /// Get the default tax for a store (if configured)
  Future<Tax?> getDefaultTax(String storeId);

  /// Get specific taxes for an item (if configured)
  /// Returns empty list if item uses default tax
  Future<List<Tax>> getTaxesForItem(String itemId);

  /// Create or update a tax
  Future<Tax> saveTax(Tax tax);

  /// Delete a tax
  Future<void> deleteTax(String taxId);

  /// Set a tax as default (unsets previous default)
  Future<void> setAsDefault(String taxId, String storeId);
}

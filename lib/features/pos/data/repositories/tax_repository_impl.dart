import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/tax.dart';
import '../../domain/repositories/tax_repository.dart';

class TaxRepositoryImpl implements TaxRepository {
  final SupabaseClient _supabase;

  TaxRepositoryImpl(this._supabase);

  @override
  Future<List<Tax>> getTaxes(String storeId) async {
    try {
      final response = await _supabase
          .from('taxes')
          .select()
          .eq('store_id', storeId)
          .eq('active', true)
          .order('name');

      return (response as List)
          .map((json) => Tax.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to load taxes: $e');
    }
  }

  @override
  Future<Tax?> getDefaultTax(String storeId) async {
    try {
      final response = await _supabase
          .from('taxes')
          .select()
          .eq('store_id', storeId)
          .eq('active', true)
          .eq('is_default', true)
          .maybeSingle();

      if (response == null) return null;
      return Tax.fromJson(response);
    } catch (e) {
      throw Exception('Failed to load default tax: $e');
    }
  }

  @override
  Future<List<Tax>> getTaxesForItem(String itemId) async {
    try {
      final response = await _supabase
          .from('item_taxes')
          .select('tax_id, taxes(*)')
          .eq('item_id', itemId);

      if (response.isEmpty) return [];

      return (response as List)
          .map((row) => Tax.fromJson(row['taxes'] as Map<String, dynamic>))
          .where((tax) => tax.active)
          .toList();
    } catch (e) {
      throw Exception('Failed to load item taxes: $e');
    }
  }

  @override
  Future<Tax> saveTax(Tax tax) async {
    try {
      final data = tax.toJson();
      data['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabase
          .from('taxes')
          .upsert(data)
          .select()
          .single();

      return Tax.fromJson(response);
    } catch (e) {
      throw Exception('Failed to save tax: $e');
    }
  }

  @override
  Future<void> deleteTax(String taxId) async {
    try {
      await _supabase.from('taxes').delete().eq('id', taxId);
    } catch (e) {
      throw Exception('Failed to delete tax: $e');
    }
  }

  @override
  Future<void> setAsDefault(String taxId, String storeId) async {
    try {
      // Use transaction-like behavior: first unset all defaults, then set new one
      await _supabase
          .from('taxes')
          .update({'is_default': false})
          .eq('store_id', storeId);

      await _supabase
          .from('taxes')
          .update({'is_default': true})
          .eq('id', taxId);
    } catch (e) {
      throw Exception('Failed to set default tax: $e');
    }
  }
}

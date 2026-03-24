import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Singleton service for Supabase client initialization and access
///
/// Usage:
/// ```dart
/// // Initialize in main()
/// await SupabaseService.initialize();
///
/// // Access client anywhere
/// final client = SupabaseService.client;
/// ```
class SupabaseService {
  static SupabaseClient? _client;

  /// Initialize Supabase with credentials from .env.local
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );
    _client = Supabase.instance.client;
  }

  /// Get the Supabase client instance
  ///
  /// Throws an exception if [initialize] hasn't been called
  static SupabaseClient get client {
    if (_client == null) {
      throw Exception(
        'Supabase not initialized. Call SupabaseService.initialize() first.',
      );
    }
    return _client!;
  }

  /// Check if Supabase is initialized
  static bool get isInitialized => _client != null;
}

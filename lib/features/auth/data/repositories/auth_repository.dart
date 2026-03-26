import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:supabase_flutter/supabase_flutter.dart' as supabase_auth;
import 'package:drift/drift.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../../../../core/data/local/app_database.dart';
import '../../../../core/data/local/daos/user_dao.dart';
import '../../../../core/data/local/daos/store_dao.dart';

class AuthRepository {
  final SupabaseClient _supabase;
  final UserDao _userDao;
  final StoreDao _storeDao;

  AuthRepository({
    required SupabaseClient supabase,
    required UserDao userDao,
    required StoreDao storeDao,
  })  : _supabase = supabase,
        _userDao = userDao,
        _storeDao = storeDao;

  /// Connexion avec email et mot de passe
  Future<supabase_auth.User?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Récupérer les infos utilisateur depuis Supabase
        final userRecord = await _supabase
            .from('users')
            .select()
            .eq('id', response.user!.id)
            .maybeSingle();

        if (userRecord != null) {
          // Si l'user a un store_id, charger le store d'abord
          if (userRecord['store_id'] != null) {
            final storeRecord = await _supabase
                .from('stores')
                .select()
                .eq('id', userRecord['store_id'])
                .maybeSingle();

            if (storeRecord != null) {
              // Sauvegarder le store localement d'abord
              final store = StoresCompanion.insert(
                id: storeRecord['id'],
                name: storeRecord['name'],
                address: Value(storeRecord['address']),
                phone: Value(storeRecord['phone']),
                logoUrl: Value(storeRecord['logo_url']),
                currency: Value(storeRecord['currency'] ?? 'MGA'),
                timezone: Value(storeRecord['timezone'] ?? 'Indian/Antananarivo'),
                synced: const Value(1),
                updatedAt: DateTime.now().millisecondsSinceEpoch,
              );
              await _storeDao.insertStore(store);
            }
          }

          // Sauvegarder l'utilisateur localement
          final user = UsersCompanion.insert(
            id: userRecord['id'],
            storeId: Value(userRecord['store_id']),
            name: userRecord['name'],
            email: Value(userRecord['email']),
            phone: Value(userRecord['phone']),
            role: userRecord['role'],
            pinHash: Value(userRecord['pin_hash']),
            emailVerified: Value(userRecord['email_verified'] == true ? 1 : 0),
            active: Value(userRecord['active'] == true ? 1 : 0),
            synced: const Value(1),
            updatedAt: DateTime.now().millisecondsSinceEpoch,
          );
          await _userDao.upsertUser(user);
        }

        return response.user;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  /// Inscription avec email et mot de passe
  Future<supabase_auth.User?> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    try {
      print('🔵 [AUTH SIGNUP] Starting signup for: $email');

      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'name': name, 'phone': phone},
      );

      print('🔵 [AUTH SIGNUP] Signup response user: ${response.user?.id}');
      print('🔵 [AUTH SIGNUP] Session exists: ${response.session != null}');
      print('🔵 [AUTH SIGNUP] Current user after signup: ${_supabase.auth.currentUser?.id}');

      return response.user;
    } catch (e) {
      print('❌ [AUTH SIGNUP] Signup failed: $e');
      rethrow;
    }
  }

  /// Connexion avec PIN (offline-first)
  Future<User?> signInWithPin({
    required String userId,
    required String pin,
  }) async {
    try {
      // Vérifier localement d'abord
      final user = await _userDao.getUserById(userId).getSingleOrNull();
      if (user != null && user.pinHash != null && _verifyPin(pin, user.pinHash!)) {
        return user;
      }

      // Si offline ou pas trouvé localement, vérifier en ligne
      if (_supabase.auth.currentUser != null) {
        final userRecord = await _supabase
            .from('users')
            .select()
            .eq('id', userId)
            .maybeSingle();

        if (userRecord != null &&
            userRecord['pin_hash'] != null &&
            _verifyPin(pin, userRecord['pin_hash'])) {
          // Si l'user a un store_id, charger le store d'abord
          if (userRecord['store_id'] != null) {
            final storeRecord = await _supabase
                .from('stores')
                .select()
                .eq('id', userRecord['store_id'])
                .maybeSingle();

            if (storeRecord != null) {
              // Sauvegarder le store localement d'abord
              final store = StoresCompanion.insert(
                id: storeRecord['id'],
                name: storeRecord['name'],
                address: Value(storeRecord['address']),
                phone: Value(storeRecord['phone']),
                logoUrl: Value(storeRecord['logo_url']),
                currency: Value(storeRecord['currency'] ?? 'MGA'),
                timezone: Value(storeRecord['timezone'] ?? 'Indian/Antananarivo'),
                synced: const Value(1),
                updatedAt: DateTime.now().millisecondsSinceEpoch,
              );
              await _storeDao.insertStore(store);
            }
          }

          // Mettre à jour localement
          final userCompanion = UsersCompanion.insert(
            id: userRecord['id'],
            storeId: Value(userRecord['store_id']),
            name: userRecord['name'],
            email: Value(userRecord['email']),
            phone: Value(userRecord['phone']),
            role: userRecord['role'],
            pinHash: Value(userRecord['pin_hash']),
            emailVerified: Value(userRecord['email_verified'] == true ? 1 : 0),
            active: Value(userRecord['active'] == true ? 1 : 0),
            synced: const Value(1),
            updatedAt: DateTime.now().millisecondsSinceEpoch,
          );
          await _userDao.insertUser(userCompanion);
          return await _userDao.getUserById(userId).getSingleOrNull();
        }
      }

      return null;
    } catch (e) {
      rethrow;
    }
  }

  /// Déconnexion
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  /// Récupérer l'utilisateur actuellement connecté
  Future<User?> getCurrentUser() async {
    final authUser = _supabase.auth.currentUser;
    if (authUser == null) return null;

    return await _userDao.getUserById(authUser.id).getSingleOrNull();
  }

  /// Stream de l'état d'authentification
  Stream<supabase_auth.AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  /// Créer le magasin initial lors du setup wizard
  Future<String> createInitialStore({
    required String name,
    String? address,
    String? phone,
    String? logoUrl,
    String currency = 'MGA',
    String timezone = 'Indian/Antananarivo',
  }) async {
    try {
      print('🔵 [AUTH] Creating store: $name');
      print('🔵 [AUTH] User ID: ${_supabase.auth.currentUser?.id}');

      // Créer le magasin dans Supabase
      print('🔵 [AUTH] Inserting into stores table...');
      final storeRecord = await _supabase.from('stores').insert({
        'name': name,
        'address': address,
        'phone': phone,
        'logo_url': logoUrl,
        'currency': currency,
        'timezone': timezone,
      }).select().single();

      print('✅ [AUTH] Store created: ${storeRecord['id']}');

      // Sauvegarder localement
      final store = StoresCompanion.insert(
        id: storeRecord['id'],
        name: name,
        address: Value(address),
        phone: Value(phone),
        logoUrl: Value(logoUrl),
        currency: Value(currency),
        timezone: Value(timezone),
        synced: const Value(1),
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      );
      await _storeDao.insertStore(store);

      // Mettre à jour l'utilisateur avec le store_id
      final currentUser = _supabase.auth.currentUser;
      if (currentUser != null) {
        print('🔵 [AUTH] Updating user ${currentUser.id} with store_id...');
        await _supabase.from('users').update({
          'store_id': storeRecord['id'],
          'role': 'OWNER',
        }).eq('id', currentUser.id);

        print('✅ [AUTH] User updated with store_id in Supabase');

        // Récupérer les données complètes depuis Supabase
        final userRecord = await _supabase
            .from('users')
            .select()
            .eq('id', currentUser.id)
            .maybeSingle();

        if (userRecord != null) {
          // Upsert local (créer si absent, sinon mettre à jour)
          final userCompanion = UsersCompanion.insert(
            id: userRecord['id'],
            storeId: Value(userRecord['store_id']),
            name: userRecord['name'] ?? 'Utilisateur',
            email: Value(userRecord['email']),
            phone: Value(userRecord['phone']),
            role: userRecord['role'] ?? 'OWNER',
            pinHash: Value(userRecord['pin_hash']),
            emailVerified: Value(userRecord['email_verified'] == true ? 1 : 0),
            active: Value(userRecord['active'] == true ? 1 : 0),
            synced: const Value(1),
            updatedAt: DateTime.now().millisecondsSinceEpoch,
          );
          await _userDao.upsertUser(userCompanion);
          print('✅ [AUTH] User upserted locally with store_id');
        }
      }

      print('✅ [AUTH] Store creation completed successfully');
      return storeRecord['id'];
    } catch (e, stackTrace) {
      print('❌ [AUTH] Store creation failed!');
      print('❌ [AUTH] Error type: ${e.runtimeType}');
      print('❌ [AUTH] Error: $e');
      print('❌ [AUTH] Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Vérifier si c'est la première connexion (pas de magasin)
  Future<bool> isFirstTimeUser() async {
    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null) return false;

    final userRecord = await _supabase
        .from('users')
        .select('store_id')
        .eq('id', currentUser.id)
        .maybeSingle();

    return userRecord?['store_id'] == null;
  }

  /// Réinitialiser le mot de passe
  Future<void> resetPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }

  /// Vérifier le PIN avec SHA-256
  bool _verifyPin(String pin, String hash) {
    return hashPin(pin) == hash;
  }

  /// Hasher le PIN avec SHA-256
  /// Note: Pour une sécurité maximale en production, considérer bcrypt avec salt
  /// SHA-256 est suffisant pour les PINs car ils sont courts (4-6 chiffres)
  String hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Configuration initiale du PIN (après setup wizard)
  Future<void> setupPin({required String userId, required String pin}) async {
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('🔵 [AUTH REPO] setupPin START');
    print('🔵 [AUTH REPO] User ID: $userId');
    final pinHash = hashPin(pin);
    print('🔵 [AUTH REPO] PIN hash generated');

    // Mettre à jour en base
    print('🔵 [AUTH REPO] Updating Supabase...');
    await _supabase
        .from('users')
        .update({'pin_hash': pinHash})
        .eq('id', userId);
    print('✅ [AUTH REPO] Supabase updated');

    // Récupérer l'utilisateur local actuel
    print('🔵 [AUTH REPO] Fetching local user...');
    final existingUser = await _userDao.getUserById(userId).getSingleOrNull();
    print('🔵 [AUTH REPO] Local user found: ${existingUser != null}');

    if (existingUser != null) {
      print('🔵 [AUTH REPO] Updating local Drift database...');
      await _userDao.updateUser(
        UsersCompanion(
          id: Value(userId),
          storeId: Value(existingUser.storeId),
          name: Value(existingUser.name),
          email: Value(existingUser.email),
          phone: Value(existingUser.phone),
          role: Value(existingUser.role),
          pinHash: Value(pinHash),
          emailVerified: Value(existingUser.emailVerified),
          active: Value(existingUser.active),
          synced: const Value(0),
          updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
        ),
      );
      print('✅ [AUTH REPO] Local database updated');
    } else {
      print('⚠️ [AUTH REPO] User not found locally — PIN saved only to Supabase');
    }
    print('🔵 [AUTH REPO] setupPin END');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  }

  /// Récupérer tous les employés d'un magasin (pour l'écran PIN)
  Future<List<User>> getStoreEmployees(String storeId) async {
    try {
      // Essayer localement d'abord
      final localUsers = await _userDao.getUsersByStore(storeId).get();
      if (localUsers.isNotEmpty) {
        return localUsers;
      }

      // Sinon récupérer en ligne
      final usersRecords = await _supabase
          .from('users')
          .select()
          .eq('store_id', storeId)
          .eq('active', true) as List<dynamic>;

      // Sauvegarder localement
      for (final record in usersRecords) {
        final user = UsersCompanion.insert(
          id: record['id'],
          storeId: Value(record['store_id']),
          name: record['name'],
          email: Value(record['email']),
          phone: Value(record['phone']),
          role: record['role'],
          pinHash: Value(record['pin_hash']),
          emailVerified: Value(record['email_verified'] == true ? 1 : 0),
          active: Value(record['active'] == true ? 1 : 0),
          synced: const Value(1),
          updatedAt: DateTime.now().millisecondsSinceEpoch,
        );
        await _userDao.insertUser(user);
      }

      return await _userDao.getUsersByStore(storeId).get();
    } catch (e) {
      // En cas d'erreur (offline), retourner les données locales
      return await _userDao.getUsersByStore(storeId).get();
    }
  }
}

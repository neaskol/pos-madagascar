import 'package:supabase_flutter/supabase_flutter.dart';
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
  Future<User?> signInWithEmail({
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
          // Sauvegarder localement
          final user = UsersCompanion.insert(
            id: userRecord['id'],
            storeId: userRecord['store_id'],
            name: userRecord['name'],
            email: userRecord['email'],
            phone: userRecord['phone'],
            role: userRecord['role'],
            pinHash: userRecord['pin_hash'] ?? '',
            emailVerified: userRecord['email_verified'] ?? false,
            active: userRecord['active'] ?? true,
            synced: true,
          );
          await _userDao.insertUser(user);
        }

        return response.user;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  /// Inscription avec email et mot de passe
  Future<User?> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'name': name, 'phone': phone},
      );

      return response.user;
    } catch (e) {
      rethrow;
    }
  }

  /// Connexion avec PIN (offline-first)
  Future<UsersTableData?> signInWithPin({
    required String userId,
    required String pin,
  }) async {
    try {
      // Vérifier localement d'abord
      final user = await _userDao.getUserById(userId);
      if (user != null && _verifyPin(pin, user.pinHash)) {
        return user;
      }

      // Si offline ou pas trouvé localement, vérifier en ligne
      if (_supabase.auth.currentUser != null) {
        final userRecord = await _supabase
            .from('users')
            .select()
            .eq('id', userId)
            .maybeSingle();

        if (userRecord != null && _verifyPin(pin, userRecord['pin_hash'])) {
          // Mettre à jour localement
          final userCompanion = UsersCompanion.insert(
            id: userRecord['id'],
            storeId: userRecord['store_id'],
            name: userRecord['name'],
            email: userRecord['email'],
            phone: userRecord['phone'],
            role: userRecord['role'],
            pinHash: userRecord['pin_hash'] ?? '',
            emailVerified: userRecord['email_verified'] ?? false,
            active: userRecord['active'] ?? true,
            synced: true,
          );
          await _userDao.insertUser(userCompanion);
          return await _userDao.getUserById(userId);
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
  Future<UsersTableData?> getCurrentUser() async {
    final authUser = _supabase.auth.currentUser;
    if (authUser == null) return null;

    return await _userDao.getUserById(authUser.id);
  }

  /// Stream de l'état d'authentification
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

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
      // Créer le magasin dans Supabase
      final storeRecord = await _supabase.from('stores').insert({
        'name': name,
        'address': address,
        'phone': phone,
        'logo_url': logoUrl,
        'currency': currency,
        'timezone': timezone,
      }).select().single();

      // Sauvegarder localement
      final store = StoresCompanion.insert(
        id: storeRecord['id'],
        name: name,
        address: address ?? '',
        phone: phone ?? '',
        logoUrl: logoUrl ?? '',
        currency: currency,
        timezone: timezone,
        synced: true,
      );
      await _storeDao.insertStore(store);

      // Mettre à jour l'utilisateur avec le store_id
      final currentUser = _supabase.auth.currentUser;
      if (currentUser != null) {
        await _supabase.from('users').update({
          'store_id': storeRecord['id'],
          'role': 'OWNER', // Premier utilisateur = OWNER
        }).eq('id', currentUser.id);

        // Mettre à jour localement
        final user = await _userDao.getUserById(currentUser.id);
        if (user != null) {
          await _userDao.updateUser(
            user.copyWith(
              storeId: storeRecord['id'],
              role: 'OWNER',
              synced: false,
            ),
          );
        }
      }

      return storeRecord['id'];
    } catch (e) {
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

  /// Vérifier le PIN (simple hash pour l'instant, à sécuriser en production)
  bool _verifyPin(String pin, String hash) {
    // TODO: Utiliser bcrypt ou un algorithme de hash sécurisé
    // Pour l'instant, simple vérification directe
    return pin.hashCode.toString() == hash;
  }

  /// Hasher le PIN
  String hashPin(String pin) {
    // TODO: Utiliser bcrypt ou un algorithme de hash sécurisé
    return pin.hashCode.toString();
  }

  /// Récupérer tous les employés d'un magasin (pour l'écran PIN)
  Future<List<UsersTableData>> getStoreEmployees(String storeId) async {
    try {
      // Essayer localement d'abord
      final localUsers = await _userDao.getUsersByStore(storeId);
      if (localUsers.isNotEmpty) {
        return localUsers;
      }

      // Sinon récupérer en ligne
      final usersRecords = await _supabase
          .from('users')
          .select()
          .eq('store_id', storeId)
          .eq('active', true);

      // Sauvegarder localement
      for (final record in usersRecords) {
        final user = UsersCompanion.insert(
          id: record['id'],
          storeId: record['store_id'],
          name: record['name'],
          email: record['email'],
          phone: record['phone'],
          role: record['role'],
          pinHash: record['pin_hash'] ?? '',
          emailVerified: record['email_verified'] ?? false,
          active: record['active'] ?? true,
          synced: true,
        );
        await _userDao.insertUser(user);
      }

      return await _userDao.getUsersByStore(storeId);
    } catch (e) {
      // En cas d'erreur (offline), retourner les données locales
      return await _userDao.getUsersByStore(storeId);
    }
  }
}

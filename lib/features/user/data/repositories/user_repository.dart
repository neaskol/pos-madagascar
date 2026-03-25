import 'package:drift/drift.dart';
import '../../../../core/data/local/app_database.dart';

/// Repository pour la gestion des utilisateurs
/// Couche intermédiaire entre les DAOs Drift et les BLoCs
class UserRepository {
  final AppDatabase _database;

  UserRepository(this._database);

  // Getters pour accéder aux DAOs
  UserDao get _userDao => _database.userDao;

  /// Récupérer tous les utilisateurs d'un magasin
  Stream<List<User>> watchStoreUsers(String storeId) {
    return _userDao.getUsersByStore(storeId).watch();
  }

  /// Récupérer un utilisateur par ID
  Future<User?> getUserById(String userId) {
    return _userDao.getUserById(userId).getSingleOrNull();
  }

  /// Récupérer un utilisateur par email
  Future<User?> getUserByEmail(String email) {
    return _userDao.getUserByEmail(email).getSingleOrNull();
  }

  /// Récupérer tous les utilisateurs actifs d'un magasin
  Stream<List<User>> watchActiveUsers(String storeId) {
    return _userDao.getActiveUsers().watch();
  }

  /// Récupérer tous les utilisateurs par rôle
  Stream<List<User>> watchUsersByRole(String storeId, String role) async* {
    final users = await _userDao.getUsersByRole(storeId, role);
    yield users;
    // TODO: Implement proper streaming for filtered role queries
  }

  /// Créer un nouvel utilisateur
  Future<void> createUser({
    required String id,
    required String storeId,
    required String name,
    required String email,
    String? phone,
    required String role,
    String? pinHash,
    bool emailVerified = false,
    bool active = true,
  }) async {
    final companion = UsersCompanion(
      id: Value(id),
      storeId: Value(storeId),
      name: Value(name),
      email: Value(email),
      phone: Value(phone),
      role: Value(role),
      pinHash: Value(pinHash),
      emailVerified: Value(emailVerified ? 1 : 0),
      active: Value(active ? 1 : 0),
      updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      synced: const Value(0),
    );

    await _userDao.insertUser(companion);
  }

  /// Mettre à jour un utilisateur
  Future<void> updateUser({
    required String id,
    String? name,
    String? email,
    String? phone,
    String? role,
    String? pinHash,
    bool? emailVerified,
    bool? active,
  }) async {
    final companion = UsersCompanion(
      id: Value(id),
      name: name != null ? Value(name) : const Value.absent(),
      email: email != null ? Value(email) : const Value.absent(),
      phone: phone != null ? Value(phone) : const Value.absent(),
      role: role != null ? Value(role) : const Value.absent(),
      pinHash: pinHash != null ? Value(pinHash) : const Value.absent(),
      emailVerified: emailVerified != null ? Value(emailVerified ? 1 : 0) : const Value.absent(),
      active: active != null ? Value(active ? 1 : 0) : const Value.absent(),
      updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      synced: const Value(0),
    );

    await _userDao.updateUser(companion);
  }

  /// Supprimer un utilisateur
  Future<void> deleteUser(String userId) {
    return _userDao.deleteUser(userId);
  }

  /// Vérifier le PIN d'un utilisateur
  Future<bool> verifyUserPin(String userId, String pinHash) async {
    final user = await getUserById(userId);
    if (user == null || user.pinHash == null) return false;
    return user.pinHash == pinHash;
  }

  /// Récupérer les utilisateurs non synchronisés
  Future<List<User>> getUnsyncedUsers() {
    return _userDao.getUnsyncedUsers().get();
  }

  /// Marquer un utilisateur comme synchronisé
  Future<void> markUserAsSynced(String userId) {
    return _userDao.markUserSynced(userId);
  }

  /// Compter le nombre d'utilisateurs d'un magasin
  Future<int> countStoreUsers(String storeId) {
    return _userDao.countActiveUsersByStore(storeId);
  }
}

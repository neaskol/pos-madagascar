import 'package:drift/drift.dart';
import '../app_database.dart';

part 'user_dao.g.dart';

/// DAO pour la table users
/// Gère toutes les opérations CRUD sur les utilisateurs/employés en local
@DriftAccessor(include: {'../tables/users.drift'})
class UserDao extends DatabaseAccessor<AppDatabase> with _$UserDaoMixin {
  UserDao(AppDatabase db) : super(db);

  /// Récupère tous les utilisateurs d'un magasin
  Future<List<User>> getUsersByStore(String storeId) =>
      getUsersByStoreQuery(storeId).get();

  /// Récupère un utilisateur par ID
  Future<User?> getUserById(String id) =>
      getUserByIdQuery(id).getSingleOrNull();

  /// Récupère tous les utilisateurs actifs
  Future<List<User>> getActiveUsers() =>
      getActiveUsersQuery().get();

  /// Récupère un utilisateur par email
  Future<User?> getUserByEmail(String email) =>
      getUserByEmailQuery(email).getSingleOrNull();

  /// Récupère tous les utilisateurs non synchronisés
  Future<List<User>> getUnsyncedUsers() =>
      getUnsyncedUsersQuery().get();

  /// Insère un nouvel utilisateur
  Future<int> insertUser(UsersCompanion user) =>
      into(users).insert(user);

  /// Met à jour un utilisateur existant et marque comme non synchronisé
  Future<bool> updateUser(UsersCompanion user) async {
    return await (update(users)
          ..where((tbl) => tbl.id.equals(user.id.value)))
        .write(user.copyWith(
      synced: const Value(false),
      updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
    ));
  }

  /// Suppression logique (soft delete) d'un utilisateur
  Future<bool> deleteUser(String id) async {
    return await (update(users)..where((tbl) => tbl.id.equals(id))).write(
      UsersCompanion(
        deletedAt: Value(DateTime.now().millisecondsSinceEpoch),
        synced: const Value(false),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  /// Marque un utilisateur comme synchronisé avec Supabase
  Future<bool> markUserSynced(String id) async {
    return await (update(users)..where((tbl) => tbl.id.equals(id))).write(
      const UsersCompanion(
        synced: Value(true),
      ),
    );
  }

  /// Compte le nombre d'utilisateurs actifs dans un magasin
  Future<int> countActiveUsersByStore(String storeId) async {
    final query = selectOnly(users)
      ..addColumns([users.id.count()])
      ..where(users.storeId.equals(storeId))
      ..where(users.active.equals(true))
      ..where(users.deletedAt.isNull());
    final result = await query.getSingleOrNull();
    return result?.read(users.id.count()) ?? 0;
  }

  /// Récupère les utilisateurs par rôle dans un magasin
  Future<List<User>> getUsersByRole(String storeId, String role) {
    return (select(users)
          ..where((tbl) =>
              tbl.storeId.equals(storeId) &
              tbl.role.equals(role) &
              tbl.deletedAt.isNull())
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.name)]))
        .get();
  }

  /// Active ou désactive un utilisateur
  Future<bool> setUserActive(String id, bool active) async {
    return await (update(users)..where((tbl) => tbl.id.equals(id))).write(
      UsersCompanion(
        active: Value(active),
        synced: const Value(false),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  /// Stream pour écouter les changements sur les utilisateurs d'un magasin
  Stream<List<User>> watchUsersByStore(String storeId) =>
      getUsersByStoreQuery(storeId).watch();

  /// Stream pour écouter les changements sur un utilisateur spécifique
  Stream<User?> watchUserById(String id) =>
      getUserByIdQuery(id).watchSingleOrNull();
}

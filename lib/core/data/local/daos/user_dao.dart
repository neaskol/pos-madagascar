import 'package:drift/drift.dart';
import '../app_database.dart';

part 'user_dao.g.dart';

/// DAO pour la table users
/// Gère toutes les opérations CRUD sur les utilisateurs/employés en local
@DriftAccessor(include: {'../tables/users.drift'})
class UserDao extends DatabaseAccessor<AppDatabase> with _$UserDaoMixin {
  UserDao(AppDatabase db) : super(db);

  // Les queries définies dans users.drift sont automatiquement générées
  // et disponibles via le mixin _$UserDaoMixin:
  // - getUsersByStore(storeId) retourne Selectable<User>
  // - getUserById(id) retourne Selectable<User>
  // - getActiveUsers() retourne Selectable<User>
  // - getUserByEmail(email) retourne Selectable<User>
  // - getUnsyncedUsers() retourne Selectable<User>
  //
  // Utiliser .get() pour Future<List<T>>, .getSingleOrNull() pour Future<T?>,
  // .watch() pour Stream<List<T>>, .watchSingleOrNull() pour Stream<T?>

  /// Insère un nouvel utilisateur
  Future<int> insertUser(UsersCompanion user) =>
      into(users).insert(user);

  /// Met à jour un utilisateur existant et marque comme non synchronisé
  Future<bool> updateUser(UsersCompanion user) async {
    final rowsAffected = await (update(users)
          ..where((tbl) => tbl.id.equals(user.id.value)))
        .write(user.copyWith(
      synced: const Value(0),
      updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
    ));
    return rowsAffected > 0;
  }

  /// Suppression logique (soft delete) d'un utilisateur
  Future<bool> deleteUser(String id) async {
    final rowsAffected = await (update(users)..where((tbl) => tbl.id.equals(id))).write(
      UsersCompanion(
        deletedAt: Value(DateTime.now().millisecondsSinceEpoch),
        synced: const Value(0),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
    return rowsAffected > 0;
  }

  /// Marque un utilisateur comme synchronisé avec Supabase
  Future<bool> markUserSynced(String id) async {
    final rowsAffected = await (update(users)..where((tbl) => tbl.id.equals(id))).write(
      const UsersCompanion(
        synced: Value(1),
      ),
    );
    return rowsAffected > 0;
  }

  /// Compte le nombre d'utilisateurs actifs dans un magasin
  Future<int> countActiveUsersByStore(String storeId) async {
    final query = selectOnly(users)
      ..addColumns([users.id.count()])
      ..where(users.storeId.equals(storeId))
      ..where(users.active.equals(1))
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
    final rowsAffected = await (update(users)..where((tbl) => tbl.id.equals(id))).write(
      UsersCompanion(
        active: Value(active ? 1 : 0),
        synced: const Value(0),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
    return rowsAffected > 0;
  }

  /// Stream pour écouter les changements sur les utilisateurs d'un magasin
  Stream<List<User>> watchUsersByStore(String storeId) =>
      getUsersByStore(storeId).watch();

  /// Stream pour écouter les changements sur un utilisateur spécifique
  Stream<User?> watchUserById(String id) =>
      getUserById(id).watchSingleOrNull();
}

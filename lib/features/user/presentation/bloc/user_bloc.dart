import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/user_repository.dart';
import 'user_event.dart';
import 'user_state.dart';

/// BLoC pour la gestion des utilisateurs
/// Pattern : Repository → BLoC → UI
class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository _repository;

  UserBloc(this._repository) : super(const UserInitial()) {
    on<LoadStoreUsersEvent>(_onLoadStoreUsers);
    on<LoadUserByIdEvent>(_onLoadUserById);
    on<LoadUserByEmailEvent>(_onLoadUserByEmail);
    on<LoadActiveUsersEvent>(_onLoadActiveUsers);
    on<LoadUsersByRoleEvent>(_onLoadUsersByRole);
    on<CreateUserEvent>(_onCreateUser);
    on<UpdateUserEvent>(_onUpdateUser);
    on<DeleteUserEvent>(_onDeleteUser);
    on<VerifyUserPinEvent>(_onVerifyUserPin);
  }

  /// Charger tous les utilisateurs d'un magasin
  Future<void> _onLoadStoreUsers(
    LoadStoreUsersEvent event,
    Emitter<UserState> emit,
  ) async {
    try {
      emit(const UserLoading());
      await emit.forEach(
        _repository.watchStoreUsers(event.storeId),
        onData: (users) => UsersLoaded(users),
        onError: (error, stackTrace) => UserError(error.toString()),
      );
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  /// Charger un utilisateur par ID
  Future<void> _onLoadUserById(
    LoadUserByIdEvent event,
    Emitter<UserState> emit,
  ) async {
    try {
      emit(const UserLoading());
      final user = await _repository.getUserById(event.userId);

      if (user != null) {
        emit(UserLoaded(user));
      } else {
        emit(const UserError('Utilisateur introuvable'));
      }
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  /// Charger un utilisateur par email
  Future<void> _onLoadUserByEmail(
    LoadUserByEmailEvent event,
    Emitter<UserState> emit,
  ) async {
    try {
      emit(const UserLoading());
      final user = await _repository.getUserByEmail(event.email);

      if (user != null) {
        emit(UserLoaded(user));
      } else {
        emit(const UserError('Utilisateur introuvable'));
      }
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  /// Charger les utilisateurs actifs
  Future<void> _onLoadActiveUsers(
    LoadActiveUsersEvent event,
    Emitter<UserState> emit,
  ) async {
    try {
      emit(const UserLoading());
      await emit.forEach(
        _repository.watchActiveUsers(event.storeId),
        onData: (users) => UsersLoaded(users),
        onError: (error, stackTrace) => UserError(error.toString()),
      );
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  /// Charger les utilisateurs par rôle
  Future<void> _onLoadUsersByRole(
    LoadUsersByRoleEvent event,
    Emitter<UserState> emit,
  ) async {
    try {
      emit(const UserLoading());
      await emit.forEach(
        _repository.watchUsersByRole(event.storeId, event.role),
        onData: (users) => UsersLoaded(users),
        onError: (error, stackTrace) => UserError(error.toString()),
      );
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  /// Créer un nouvel utilisateur
  Future<void> _onCreateUser(
    CreateUserEvent event,
    Emitter<UserState> emit,
  ) async {
    try {
      emit(const UserLoading());
      await _repository.createUser(
        id: event.id,
        storeId: event.storeId,
        name: event.name,
        email: event.email,
        phone: event.phone,
        role: event.role,
        pinHash: event.pinHash,
        emailVerified: event.emailVerified,
        active: event.active,
      );
      emit(const UserOperationSuccess('Utilisateur créé avec succès'));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  /// Mettre à jour un utilisateur
  Future<void> _onUpdateUser(
    UpdateUserEvent event,
    Emitter<UserState> emit,
  ) async {
    try {
      emit(const UserLoading());
      await _repository.updateUser(
        id: event.id,
        name: event.name,
        email: event.email,
        phone: event.phone,
        role: event.role,
        pinHash: event.pinHash,
        emailVerified: event.emailVerified,
        active: event.active,
      );
      emit(const UserOperationSuccess('Utilisateur mis à jour avec succès'));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  /// Supprimer un utilisateur
  Future<void> _onDeleteUser(
    DeleteUserEvent event,
    Emitter<UserState> emit,
  ) async {
    try {
      emit(const UserLoading());
      await _repository.deleteUser(event.userId);
      emit(const UserOperationSuccess('Utilisateur supprimé avec succès'));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  /// Vérifier le PIN d'un utilisateur
  Future<void> _onVerifyUserPin(
    VerifyUserPinEvent event,
    Emitter<UserState> emit,
  ) async {
    try {
      emit(const UserLoading());
      final isValid = await _repository.verifyUserPin(event.userId, event.pinHash);
      emit(UserPinVerified(isValid));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }
}

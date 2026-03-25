import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthEmailSignInRequested>(_onEmailSignInRequested);
    on<AuthEmailSignUpRequested>(_onEmailSignUpRequested);
    on<AuthPinSignInRequested>(_onPinSignInRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
    on<AuthPasswordResetRequested>(_onPasswordResetRequested);
    on<AuthStoreCreationRequested>(_onStoreCreationRequested);
    on<AuthLoadStoreEmployeesRequested>(_onLoadStoreEmployeesRequested);
  }

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.getCurrentUser();
      if (user == null) {
        emit(AuthUnauthenticated());
        return;
      }

      // Vérifier si l'utilisateur a un magasin
      if (user.storeId.isEmpty) {
        emit(AuthAuthenticatedNoStore(userId: user.id));
        return;
      }

      emit(AuthAuthenticatedWithStore(user: user, storeId: user.storeId));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onEmailSignInRequested(
    AuthEmailSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final authUser = await _authRepository.signInWithEmail(
        email: event.email,
        password: event.password,
      );

      if (authUser == null) {
        emit(const AuthError(message: 'Identifiants incorrects'));
        return;
      }

      // Récupérer l'utilisateur local
      final user = await _authRepository.getCurrentUser();
      if (user == null) {
        emit(const AuthError(message: 'Utilisateur non trouvé'));
        return;
      }

      // Vérifier si l'utilisateur a un magasin
      final isFirstTime = await _authRepository.isFirstTimeUser();
      if (isFirstTime) {
        emit(AuthAuthenticatedNoStore(userId: user.id));
        return;
      }

      emit(AuthAuthenticatedWithStore(user: user, storeId: user.storeId));
    } catch (e) {
      emit(AuthError(message: _formatError(e.toString())));
    }
  }

  Future<void> _onEmailSignUpRequested(
    AuthEmailSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final authUser = await _authRepository.signUpWithEmail(
        email: event.email,
        password: event.password,
        name: event.name,
        phone: event.phone,
      );

      if (authUser == null) {
        emit(const AuthError(message: 'Erreur lors de l\'inscription'));
        return;
      }

      // Rediriger vers le setup wizard
      emit(AuthAuthenticatedNoStore(userId: authUser.id));
    } catch (e) {
      emit(AuthError(message: _formatError(e.toString())));
    }
  }

  Future<void> _onPinSignInRequested(
    AuthPinSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.signInWithPin(
        userId: event.userId,
        pin: event.pin,
      );

      if (user == null) {
        emit(const AuthError(message: 'PIN incorrect'));
        return;
      }

      emit(AuthPinSessionActive(user: user));
    } catch (e) {
      emit(AuthError(message: _formatError(e.toString())));
    }
  }

  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authRepository.signOut();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(message: _formatError(e.toString())));
    }
  }

  Future<void> _onPasswordResetRequested(
    AuthPasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authRepository.resetPassword(event.email);
      emit(AuthPasswordResetSent(email: event.email));
    } catch (e) {
      emit(AuthError(message: _formatError(e.toString())));
    }
  }

  Future<void> _onStoreCreationRequested(
    AuthStoreCreationRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final storeId = await _authRepository.createInitialStore(
        name: event.name,
        address: event.address,
        phone: event.phone,
        logoUrl: event.logoUrl,
        currency: event.currency,
        timezone: event.timezone,
      );

      emit(AuthStoreCreated(storeId: storeId));

      // Recharger l'utilisateur avec le nouveau store_id
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        emit(AuthAuthenticatedWithStore(user: user, storeId: storeId));
      }
    } catch (e) {
      emit(AuthError(message: _formatError(e.toString())));
    }
  }

  Future<void> _onLoadStoreEmployeesRequested(
    AuthLoadStoreEmployeesRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final employees = await _authRepository.getStoreEmployees(event.storeId);
      emit(AuthStoreEmployeesLoaded(
        employees: employees,
        storeId: event.storeId,
      ));
    } catch (e) {
      emit(AuthError(message: _formatError(e.toString())));
    }
  }

  String _formatError(String error) {
    if (error.contains('Invalid login credentials')) {
      return 'Email ou mot de passe incorrect';
    } else if (error.contains('Email not confirmed')) {
      return 'Veuillez vérifier votre email';
    } else if (error.contains('User already registered')) {
      return 'Cet email est déjà utilisé';
    } else if (error.contains('Password should be at least')) {
      return 'Le mot de passe doit contenir au moins 8 caractères';
    } else if (error.contains('Invalid email')) {
      return 'Email invalide';
    } else if (error.contains('Network request failed')) {
      return 'Pas de connexion internet';
    }
    return error;
  }
}

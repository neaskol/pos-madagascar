import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/auth_repository.dart';
import '../../../../core/data/remote/sync_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import 'dart:developer' as developer;

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final SyncService? _syncService;

  AuthBloc({required AuthRepository authRepository, SyncService? syncService})
      : _authRepository = authRepository,
        _syncService = syncService,
        super(AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthEmailSignInRequested>(_onEmailSignInRequested);
    on<AuthEmailSignUpRequested>(_onEmailSignUpRequested);
    on<AuthPinSignInRequested>(_onPinSignInRequested);
    on<AuthPinSetupRequested>(_onPinSetupRequested);
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
      if (user.storeId == null || user.storeId!.isEmpty) {
        emit(AuthAuthenticatedNoStore(userId: user.id));
        return;
      }

      emit(AuthAuthenticatedWithStore(user: user, storeId: user.storeId!));

      // Synchroniser les données depuis Supabase vers Drift (pull initial)
      _pullDataFromSupabase(user.storeId!);
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
      if (isFirstTime || user.storeId == null || user.storeId!.isEmpty) {
        emit(AuthAuthenticatedNoStore(userId: user.id));
        return;
      }

      emit(AuthAuthenticatedWithStore(user: user, storeId: user.storeId!));

      // Synchroniser les données depuis Supabase vers Drift (pull initial)
      _pullDataFromSupabase(user.storeId!);
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

  Future<void> _onPinSetupRequested(
    AuthPinSetupRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (kDebugMode) debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    if (kDebugMode) debugPrint('🔵 [AUTH BLOC] _onPinSetupRequested START');
    if (kDebugMode) debugPrint('🔵 [AUTH BLOC] User ID: ${event.userId}');
    emit(AuthLoading());
    if (kDebugMode) debugPrint('🔵 [AUTH BLOC] Emitted AuthLoading');
    try {
      if (kDebugMode) debugPrint('🔵 [AUTH BLOC] Calling authRepository.setupPin()...');
      await _authRepository.setupPin(
        userId: event.userId,
        pin: event.pin,
      );
      if (kDebugMode) debugPrint('✅ [AUTH BLOC] setupPin() completed');

      if (kDebugMode) debugPrint('🔵 [AUTH BLOC] Fetching current user...');
      final user = await _authRepository.getCurrentUser();
      if (kDebugMode) debugPrint('🔵 [AUTH BLOC] Current user: ${user?.id}');
      if (user == null) {
        if (kDebugMode) debugPrint('❌ [AUTH BLOC] User not found after setupPin!');
        emit(const AuthError(message: 'Utilisateur non trouvé'));
        return;
      }

      if (kDebugMode) debugPrint('✅ [AUTH BLOC] Emitting AuthPinSessionActive');
      emit(AuthPinSessionActive(user: user));
      if (kDebugMode) debugPrint('✅ [AUTH BLOC] AuthPinSessionActive emitted');
    } catch (e, stackTrace) {
      if (kDebugMode) debugPrint('❌ [AUTH BLOC] Error in _onPinSetupRequested: $e');
      if (kDebugMode) debugPrint('❌ [AUTH BLOC] Stack: $stackTrace');
      emit(AuthError(message: _formatError(e.toString())));
    }
    if (kDebugMode) debugPrint('🔵 [AUTH BLOC] _onPinSetupRequested END');
    if (kDebugMode) debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
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

      // Recharger l'utilisateur avec le nouveau store_id
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        emit(AuthAuthenticatedWithStore(user: user, storeId: storeId));
      } else {
        // Fallback si l'utilisateur n'est pas trouvé localement
        emit(AuthStoreCreated(storeId: storeId));
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

  /// Récupère les données depuis Supabase en arrière-plan
  void _pullDataFromSupabase(String storeId) {
    if (_syncService != null) {
      developer.log('Triggering pull sync from Supabase for store: $storeId', name: 'AuthBloc');
      _syncService.syncFromRemote(storeId).then((result) {
        if (result.isSuccess) {
          developer.log(
            'Pull sync completed: ${result.summary}',
            name: 'AuthBloc',
          );
        } else if (result.hasErrors) {
          developer.log(
            'Pull sync had errors: ${result.errors.join(", ")}',
            name: 'AuthBloc',
          );
        } else if (result.skipped) {
          developer.log(
            'Pull sync skipped (no connection or no data)',
            name: 'AuthBloc',
          );
        }
      }).catchError((e) {
        developer.log(
          'Pull sync failed',
          name: 'AuthBloc',
          error: e,
        );
      });
    }
  }
}

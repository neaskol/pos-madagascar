import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/store_repository.dart';
import 'store_event.dart';
import 'store_state.dart';

/// BLoC pour la gestion des magasins
/// Pattern : Repository → BLoC → UI
class StoreBloc extends Bloc<StoreEvent, StoreState> {
  final StoreRepository _repository;

  StoreBloc(this._repository) : super(const StoreInitial()) {
    on<LoadStoresEvent>(_onLoadStores);
    on<LoadStoreByIdEvent>(_onLoadStoreById);
    on<CreateStoreEvent>(_onCreateStore);
    on<UpdateStoreEvent>(_onUpdateStore);
    on<DeleteStoreEvent>(_onDeleteStore);
  }

  /// Charger tous les magasins
  Future<void> _onLoadStores(
    LoadStoresEvent event,
    Emitter<StoreState> emit,
  ) async {
    try {
      emit(const StoreLoading());

      // Utiliser un stream pour les mises à jour en temps réel
      await emit.forEach(
        _repository.watchAllStores(),
        onData: (stores) => StoresLoaded(stores),
        onError: (error, stackTrace) => StoreError(error.toString()),
      );
    } catch (e) {
      emit(StoreError(e.toString()));
    }
  }

  /// Charger un magasin par ID
  Future<void> _onLoadStoreById(
    LoadStoreByIdEvent event,
    Emitter<StoreState> emit,
  ) async {
    try {
      emit(const StoreLoading());
      final store = await _repository.getStoreById(event.storeId);

      if (store != null) {
        emit(StoreLoaded(store));
      } else {
        emit(const StoreError('Magasin introuvable'));
      }
    } catch (e) {
      emit(StoreError(e.toString()));
    }
  }

  /// Créer un nouveau magasin
  Future<void> _onCreateStore(
    CreateStoreEvent event,
    Emitter<StoreState> emit,
  ) async {
    try {
      emit(const StoreLoading());
      await _repository.createStore(
        id: event.id,
        name: event.name,
        address: event.address,
        phone: event.phone,
        logoUrl: event.logoUrl,
        currency: event.currency ?? 'MGA',
        timezone: event.timezone ?? 'Indian/Antananarivo',
      );
      emit(const StoreOperationSuccess('Magasin créé avec succès'));
    } catch (e) {
      emit(StoreError(e.toString()));
    }
  }

  /// Mettre à jour un magasin
  Future<void> _onUpdateStore(
    UpdateStoreEvent event,
    Emitter<StoreState> emit,
  ) async {
    try {
      emit(const StoreLoading());
      await _repository.updateStore(
        id: event.id,
        name: event.name,
        address: event.address,
        phone: event.phone,
        logoUrl: event.logoUrl,
        currency: event.currency,
        timezone: event.timezone,
      );
      emit(const StoreOperationSuccess('Magasin mis à jour avec succès'));
    } catch (e) {
      emit(StoreError(e.toString()));
    }
  }

  /// Supprimer un magasin
  Future<void> _onDeleteStore(
    DeleteStoreEvent event,
    Emitter<StoreState> emit,
  ) async {
    try {
      emit(const StoreLoading());
      await _repository.deleteStore(event.storeId);
      emit(const StoreOperationSuccess('Magasin supprimé avec succès'));
    } catch (e) {
      emit(StoreError(e.toString()));
    }
  }
}

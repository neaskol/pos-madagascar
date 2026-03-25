import 'package:equatable/equatable.dart';
import '../../../../core/data/local/app_database.dart';

/// States pour la gestion des réglages du magasin
abstract class StoreSettingsState extends Equatable {
  const StoreSettingsState();

  @override
  List<Object?> get props => [];
}

/// État initial
class StoreSettingsInitial extends StoreSettingsState {
  const StoreSettingsInitial();
}

/// Chargement en cours
class StoreSettingsLoading extends StoreSettingsState {
  const StoreSettingsLoading();
}

/// Réglages chargés avec succès
class StoreSettingsLoaded extends StoreSettingsState {
  final StoreSetting settings;

  const StoreSettingsLoaded(this.settings);

  @override
  List<Object?> get props => [settings];
}

/// Réglages non trouvés (magasin sans réglages initialisés)
class StoreSettingsNotFound extends StoreSettingsState {
  const StoreSettingsNotFound();
}

/// Opération réussie (création, mise à jour)
class StoreSettingsOperationSuccess extends StoreSettingsState {
  final String message;

  const StoreSettingsOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

/// Erreur
class StoreSettingsError extends StoreSettingsState {
  final String message;

  const StoreSettingsError(this.message);

  @override
  List<Object?> get props => [message];
}

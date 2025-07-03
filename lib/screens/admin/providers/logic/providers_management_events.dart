import '../../../../models/models.dart';

/// Événements pour l'écran ProvidersManagementScreen
abstract class ProvidersManagementEvent {}

/// Événement de chargement initial des prestataires
class LoadProvidersEvent extends ProvidersManagementEvent {}

/// Événement de changement d'onglet
class TabChangedEvent extends ProvidersManagementEvent {
  final int tabIndex;

  TabChangedEvent(this.tabIndex);
}

/// Événement de recherche
class SearchChangedEvent extends ProvidersManagementEvent {
  final String query;

  SearchChangedEvent(this.query);
}

/// Événement de changement de spécialité
class SpecialtyChangedEvent extends ProvidersManagementEvent {
  final String specialty;

  SpecialtyChangedEvent(this.specialty);
}

/// Événement de sélection d'un prestataire
class ProviderSelectionToggleEvent extends ProvidersManagementEvent {
  final ProviderModel provider;

  ProviderSelectionToggleEvent(this.provider);
}

/// Événement de suppression de la sélection
class ClearSelectionEvent extends ProvidersManagementEvent {}

/// Événement de navigation vers l'édition d'un prestataire
class NavigateToEditProviderEvent extends ProvidersManagementEvent {
  final ProviderModel provider;

  NavigateToEditProviderEvent(this.provider);
}

/// Événement de création d'un nouveau prestataire
class NavigateToCreateProviderEvent extends ProvidersManagementEvent {}

/// Événements d'actions bulk
class BulkActivateEvent extends ProvidersManagementEvent {
  final List<ProviderModel> providers;

  BulkActivateEvent(this.providers);
}

class BulkDeactivateEvent extends ProvidersManagementEvent {
  final List<ProviderModel> providers;

  BulkDeactivateEvent(this.providers);
}

class BulkDeleteEvent extends ProvidersManagementEvent {
  final List<ProviderModel> providers;

  BulkDeleteEvent(this.providers);
}

/// Événements d'actions individuelles
class ActivateProviderEvent extends ProvidersManagementEvent {
  final ProviderModel provider;

  ActivateProviderEvent(this.provider);
}

class DeactivateProviderEvent extends ProvidersManagementEvent {
  final ProviderModel provider;

  DeactivateProviderEvent(this.provider);
}

class DeleteProviderEvent extends ProvidersManagementEvent {
  final ProviderModel provider;

  DeleteProviderEvent(this.provider);
}

class VerifyProviderEvent extends ProvidersManagementEvent {
  final ProviderModel provider;

  VerifyProviderEvent(this.provider);
}

/// Événements de réponse
class ProvidersLoadedEvent extends ProvidersManagementEvent {
  final List<ProviderModel> providers;
  final Map<String, int> stats;

  ProvidersLoadedEvent({required this.providers, required this.stats});
}

class FiltersAppliedEvent extends ProvidersManagementEvent {
  final List<ProviderModel> filteredProviders;

  FiltersAppliedEvent(this.filteredProviders);
}

class ProviderActionCompletedEvent extends ProvidersManagementEvent {
  final String message;
  final bool isSuccess;

  ProviderActionCompletedEvent({
    required this.message,
    required this.isSuccess,
  });
}

class ErrorEvent extends ProvidersManagementEvent {
  final String message;

  ErrorEvent(this.message);
}

class LoadingStateChangedEvent extends ProvidersManagementEvent {
  final bool isLoading;

  LoadingStateChangedEvent(this.isLoading);
}

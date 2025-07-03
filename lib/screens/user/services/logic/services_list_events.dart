import '../../../../models/service_model.dart';
import '../dialogs/services_dialogs.dart';

/// Événements pour l'écran ServicesListScreen
abstract class ServicesListEvent {}

/// Événement de chargement initial des données
class LoadInitialDataEvent extends ServicesListEvent {}

/// Événement de recherche et filtrage
class SearchAndFilterEvent extends ServicesListEvent {
  final String query;
  final String categoryId;
  final ServiceFilters filters;

  SearchAndFilterEvent({
    required this.query,
    required this.categoryId,
    required this.filters,
  });
}

/// Événement de basculement des favoris
class ToggleFavoriteEvent extends ServicesListEvent {
  final String serviceId;

  ToggleFavoriteEvent(this.serviceId);
}

/// Événement de changement de catégorie
class CategoryChangedEvent extends ServicesListEvent {
  final String categoryId;

  CategoryChangedEvent(this.categoryId);
}

/// Événement de modification des filtres
class FiltersChangedEvent extends ServicesListEvent {
  final ServiceFilters filters;

  FiltersChangedEvent(this.filters);
}

/// Événement de réinitialisation des filtres
class ResetFiltersEvent extends ServicesListEvent {}

/// Événement de navigation vers les détails d'un service
class NavigateToServiceDetailEvent extends ServicesListEvent {
  final ServiceModel service;

  NavigateToServiceDetailEvent(this.service);
}

/// Événement d'affichage des filtres
class ShowFiltersDialogEvent extends ServicesListEvent {}

/// Événements de réponse
class ServicesDataLoadedEvent extends ServicesListEvent {
  final List<ServiceModel> services;
  final Set<String> favoriteIds;
  final List<ServiceCategory> categories;

  ServicesDataLoadedEvent({
    required this.services,
    required this.favoriteIds,
    required this.categories,
  });
}

class SearchResultsEvent extends ServicesListEvent {
  final List<ServiceModel> services;
  final Set<String> favoriteIds;

  SearchResultsEvent({required this.services, required this.favoriteIds});
}

class FavoriteToggledEvent extends ServicesListEvent {
  final String serviceId;
  final bool isNowFavorite;

  FavoriteToggledEvent({required this.serviceId, required this.isNowFavorite});
}

class ErrorEvent extends ServicesListEvent {
  final String message;

  ErrorEvent(this.message);
}

class LoadingStateChangedEvent extends ServicesListEvent {
  final bool isLoading;

  LoadingStateChangedEvent(this.isLoading);
}

import 'dart:async';
import 'services_list_data.dart';
import 'services_list_events.dart';
import '../services/services_service.dart';
import '../../../../utils/event_bus.dart';
import '../../../../models/service_model.dart';

/// Handler pour le chargement et la gestion des données
class ServicesListDataHandler {
  final ServicesListData _data;
  final ServicesService _servicesService = ServicesService();

  ServicesListDataHandler(this._data);

  /// Charge les données initiales
  Future<void> loadInitialData() async {
    print('🚀 ServicesListDataHandler: Début du chargement des données...');

    EventBus.instance.emit(LoadingStateChangedEvent(true));

    try {
      // Charger les catégories et les services en parallèle
      final futures = await Future.wait([
        _servicesService.getServiceCategories(),
        _servicesService.getAllServicesWithFavorites(),
      ]);

      final categories = futures[0] as List<ServiceCategory>;
      final servicesData = futures[1] as ServicesData;

      print(
        '📊 ServicesListDataHandler: Catégories reçues: ${categories.length}',
      );
      print(
        '📊 ServicesListDataHandler: Services reçus: ${servicesData.services.length}',
      );

      _data.categories = categories;
      _data.services = servicesData.services;
      _data.favoriteIds = servicesData.favoriteIds;
      _data.isLoading = false;
      _data.error = null;

      EventBus.instance.emit(
        ServicesDataLoadedEvent(
          services: servicesData.services,
          favoriteIds: servicesData.favoriteIds,
          categories: categories,
        ),
      );

      print('✅ ServicesListDataHandler: Données chargées avec succès');
    } catch (e) {
      print('❌ ServicesListDataHandler: Erreur lors du chargement: $e');
      _data.isLoading = false;
      _data.error = 'Erreur lors du chargement des données';

      EventBus.instance.emit(
        ErrorEvent('Erreur lors du chargement des données'),
      );
    }

    EventBus.instance.emit(LoadingStateChangedEvent(false));
  }

  /// Recherche et filtre les services
  Future<void> searchAndFilterServices() async {
    EventBus.instance.emit(LoadingStateChangedEvent(true));

    try {
      final servicesData = await _servicesService.searchServicesWithFilters(
        query: _data.searchController.text,
        categoryId: _data.selectedCategoryId,
        minPrice: _data.currentFilters.minPrice,
        maxPrice: _data.currentFilters.maxPrice,
        minRating: _data.currentFilters.minRating,
        availableOnly: _data.currentFilters.availableOnly,
      );

      _data.services = servicesData.services;
      _data.favoriteIds = servicesData.favoriteIds;
      _data.isLoading = false;
      _data.error = null;

      EventBus.instance.emit(
        SearchResultsEvent(
          services: servicesData.services,
          favoriteIds: servicesData.favoriteIds,
        ),
      );
    } catch (e) {
      _data.isLoading = false;
      _data.error = 'Erreur lors de la recherche';

      EventBus.instance.emit(ErrorEvent('Erreur lors de la recherche'));
    }

    EventBus.instance.emit(LoadingStateChangedEvent(false));
  }

  /// Bascule le statut favori d'un service
  Future<void> toggleFavorite(String serviceId) async {
    if (_data.isLoadingFavoriteAction) return;

    _data.isLoadingFavoriteAction = true;

    try {
      final isNowFavorite = await _servicesService.toggleServiceFavorite(
        serviceId,
      );

      if (isNowFavorite) {
        _data.favoriteIds.add(serviceId);
      } else {
        _data.favoriteIds.remove(serviceId);
      }

      _data.isLoadingFavoriteAction = false;

      EventBus.instance.emit(
        FavoriteToggledEvent(
          serviceId: serviceId,
          isNowFavorite: isNowFavorite,
        ),
      );
    } catch (e) {
      _data.isLoadingFavoriteAction = false;
      EventBus.instance.emit(
        ErrorEvent('Erreur lors de la modification des favoris'),
      );
    }
  }

  /// Crée des données d'exemple si nécessaire
  Future<void> createSampleDataIfNeeded() async {
    try {
      EventBus.instance.emit(LoadingStateChangedEvent(true));

      // Create categories if only "Tous" exists
      if (_data.categories.length <= 1) {
        await _servicesService.createSampleCategories();
      }

      // Create services if none exist
      if (_data.services.isEmpty) {
        await _servicesService.createSampleServices();
      }

      // Reload data
      await loadInitialData();
    } catch (e) {
      EventBus.instance.emit(
        ErrorEvent('Erreur lors de la création des données: $e'),
      );
    } finally {
      EventBus.instance.emit(LoadingStateChangedEvent(false));
    }
  }
}

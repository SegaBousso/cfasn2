import 'package:flutter/material.dart';
import '../../../../models/service_model.dart';
import '../../../../services/favorite_service.dart';
import 'services_data_service.dart';
import 'services_mock_service.dart';

class ServicesService {
  final ServicesDataService _dataService = ServicesDataService();
  final FavoriteService _favoriteService = FavoriteService();
  final ServicesMockService _mockService = ServicesMockService();

  /// Récupère tous les services avec gestion des favoris
  Future<ServicesData> getAllServicesWithFavorites() async {
    try {
      final services = await _dataService.getAllServices();
      final favoriteIds = await _favoriteService.getUserFavoriteServices();

      return ServicesData(services: services, favoriteIds: favoriteIds.toSet());
    } catch (e) {
      print('Erreur lors de la récupération des services: $e');
      return ServicesData(services: [], favoriteIds: {});
    }
  }

  /// Recherche de services avec filtrage
  Future<ServicesData> searchServicesWithFilters({
    String query = '',
    String? categoryId,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    bool? availableOnly,
  }) async {
    try {
      List<ServiceModel> services;

      if (query.isNotEmpty) {
        services = await _dataService.searchServices(query);
      } else if (categoryId != null && categoryId != 'all') {
        services = await _dataService.getServicesByCategory(categoryId);
      } else {
        services = await _dataService.getAllServices();
      }

      // Appliquer les filtres
      services = _applyFilters(
        services,
        minPrice: minPrice,
        maxPrice: maxPrice,
        minRating: minRating,
        availableOnly: availableOnly,
      );

      final favorites = await _favoriteService.getUserFavoriteServices();

      return ServicesData(services: services, favoriteIds: favorites.toSet());
    } catch (e) {
      print('Erreur lors de la recherche de services: $e');
      return ServicesData(services: [], favoriteIds: {});
    }
  }

  /// Récupère les catégories de services
  Future<List<ServiceCategory>> getServiceCategories() async {
    try {
      print('🔍 ServicesService: Récupération des catégories...');
      final categories = await _dataService.getServiceCategories();
      print('📊 ServicesService: Catégories reçues: ${categories.length}');

      print(
        '✅ ServicesService: Total catégories finales: ${categories.length}',
      );
      for (final cat in categories) {
        print('   - ${cat.name} (${cat.id})');
      }

      return categories;
    } catch (e) {
      print('Erreur lors de la récupération des catégories: $e');
      return [
        ServiceCategory(
          id: 'all',
          name: 'Tous',
          icon: Icons.apps,
          servicesCount: 0,
        ),
      ];
    }
  }

  /// Bascule le statut favori d'un service
  Future<bool> toggleServiceFavorite(String serviceId) async {
    try {
      return await _favoriteService.toggleFavorite(serviceId);
    } catch (e) {
      print('Erreur lors de la modification des favoris: $e');
      return false;
    }
  }

  /// Vérifie si un service est en favori
  Future<bool> isServiceFavorite(String serviceId) async {
    try {
      return await _favoriteService.isFavorite(serviceId);
    } catch (e) {
      print('Erreur lors de la vérification des favoris: $e');
      return false;
    }
  }

  /// Applique les filtres aux services
  List<ServiceModel> _applyFilters(
    List<ServiceModel> services, {
    double? minPrice,
    double? maxPrice,
    double? minRating,
    bool? availableOnly,
  }) {
    return services.where((service) {
      // Filtre par prix minimum
      if (minPrice != null && service.price < minPrice) {
        return false;
      }

      // Filtre par prix maximum
      if (maxPrice != null && service.price > maxPrice) {
        return false;
      }

      // Filtre par rating minimum
      if (minRating != null && service.rating < minRating) {
        return false;
      }

      // Filtre par disponibilité
      if (availableOnly == true && !service.isAvailable) {
        return false;
      }

      return true;
    }).toList();
  }

  /// Helper method to create sample categories during development
  Future<void> createSampleCategories() async {
    return await _mockService.createSampleCategories();
  }

  /// Helper method to create sample services during development
  Future<void> createSampleServices() async {
    return await _mockService.createSampleServices();
  }

  /// Helper method to create all sample data during development
  Future<void> createAllSampleData() async {
    return await _mockService.createAllSampleData();
  }
}

/// Classe pour encapsuler les données de services avec favoris
class ServicesData {
  final List<ServiceModel> services;
  final Set<String> favoriteIds;

  ServicesData({required this.services, required this.favoriteIds});
}

/// Classe pour les détails d'un service
class ServiceDetailsData {
  final ServiceModel service;
  final bool isFavorite;

  ServiceDetailsData({required this.service, required this.isFavorite});
}

import 'package:flutter/material.dart';
import '../../../../models/service_model.dart';
import '../../../../services/favorite_service.dart';
import 'services_data_service.dart';

class ServicesService {
  final ServicesDataService _dataService = ServicesDataService();
  final FavoriteService _favoriteService = FavoriteService();

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

      // Filtrer les catégories qui ont déjà l'id 'all' pour éviter les doublons
      final filteredCategories = categories
          .where((cat) => cat['id'] != 'all')
          .toList();

      print(
        '📂 ServicesService: Catégories filtrées: ${filteredCategories.length}',
      );

      // Ajouter la catégorie "Tous" en premier
      final allCategories = [
        ServiceCategory(
          id: 'all',
          name: 'Tous',
          icon: Icons.apps,
          servicesCount: 0,
        ),
        ...filteredCategories.map(
          (cat) => ServiceCategory(
            id: cat['id'],
            name: cat['name'],
            icon: _getIconFromString(cat['icon']),
            servicesCount: cat['servicesCount'],
          ),
        ),
      ];

      print(
        '✅ ServicesService: Total catégories finales: ${allCategories.length}',
      );
      for (final cat in allCategories) {
        print('   - ${cat.name} (${cat.id})');
      }

      return allCategories;
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

  /// Récupère un service par son ID avec ses détails
  Future<ServiceDetailsData?> getServiceDetails(String serviceId) async {
    try {
      final service = await _dataService.getServiceById(serviceId);
      if (service == null) return null;

      final isFavorite = await _favoriteService.isFavorite(serviceId);

      // Incrémenter le nombre de vues
      await _dataService.incrementServiceViews(serviceId);

      return ServiceDetailsData(service: service, isFavorite: isFavorite);
    } catch (e) {
      print('Erreur lors de la récupération des détails du service: $e');
      return null;
    }
  }

  /// Récupère les services populaires
  Future<List<ServiceModel>> getPopularServices({int limit = 10}) async {
    try {
      return await _dataService.getPopularServices(limit: limit);
    } catch (e) {
      print('Erreur lors de la récupération des services populaires: $e');
      return [];
    }
  }

  /// Récupère les services récents
  Future<List<ServiceModel>> getRecentServices({int limit = 10}) async {
    try {
      return await _dataService.getRecentServices(limit: limit);
    } catch (e) {
      print('Erreur lors de la récupération des services récents: $e');
      return [];
    }
  }

  /// Stream pour écouter les changements de services
  Stream<List<ServiceModel>> getServicesStream({String? categoryId}) {
    if (categoryId != null && categoryId != 'all') {
      return _dataService.getServicesByCategoryStream(categoryId);
    }
    return _dataService.getServicesStream();
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

  /// Convertit une string d'icône en IconData
  IconData _getIconFromString(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'plumbing':
      case 'plomberie':
        return Icons.plumbing;
      case 'electrical_services':
      case 'electricite':
        return Icons.electrical_services;
      case 'cleaning_services':
      case 'menage':
        return Icons.cleaning_services;
      case 'grass':
      case 'jardinage':
        return Icons.grass;
      case 'build':
      case 'construction':
        return Icons.build;
      case 'car_repair':
      case 'automobile':
        return Icons.car_repair;
      case 'computer':
      case 'informatique':
        return Icons.computer;
      default:
        return Icons.build;
    }
  }

  /// Helper method to create sample categories during development
  Future<void> createSampleCategories() async {
    return await _dataService.createSampleCategories();
  }

  /// Helper method to create sample services during development
  Future<void> createSampleServices() async {
    return await _dataService.createSampleServices();
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

/// Classe pour représenter une catégorie de service
class ServiceCategory {
  final String id;
  final String name;
  final IconData icon;
  final int servicesCount;

  ServiceCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.servicesCount,
  });
}

import 'package:service/screens/admin/providers/logic/provider_form_data.dart';

import '../../../../models/models.dart';
import '../../../admin/services/services/admin_service_manager.dart';

/// Gestionnaire pour le chargement et la sélection des services
class ProviderServicesHandler {
  final AdminServiceManager _serviceManager = AdminServiceManager();

  List<ServiceModel> availableServices = [];
  bool isLoading = true;
  String? error;

  /// Charger tous les services disponibles
  Future<void> loadAvailableServices() async {
    try {
      isLoading = true;
      error = null;

      // Essayer de charger les services actifs
      try {
        final services = await _serviceManager.activeServices;
        availableServices = services;
      } catch (e) {
        // Fallback: charger tous les services et filtrer
        final allServices = await _serviceManager.allServices;
        availableServices = allServices
            .where((service) => service.isActive)
            .toList();
      }
    } catch (e) {
      error = 'Erreur lors du chargement des services: $e';
      availableServices = [];
    } finally {
      isLoading = false;
    }
  }

  /// Initialiser les services et synchroniser avec un provider existant
  Future<String?> initializeServices({
    ProviderFormData? formData,
    ProviderModel? existingProvider,
  }) async {
    try {
      isLoading = true;
      error = null;

      // Essayer de charger les services actifs avec fallback
      try {
        final services = await _serviceManager.activeServices;
        availableServices = services;
      } catch (e) {
        // Fallback: charger tous les services et filtrer
        final allServices = await _serviceManager.allServices;
        availableServices = allServices
            .where((service) => service.isActive)
            .toList();
      }

      // Synchroniser avec le provider existant si fourni
      if (existingProvider != null && formData != null) {
        formData.syncSelectedServices(availableServices);
      }

      return null; // Pas d'erreur
    } catch (e) {
      final errorMessage = 'Erreur lors du chargement des services: $e';
      error = errorMessage;
      availableServices = [];
      return errorMessage;
    } finally {
      isLoading = false;
    }
  }

  /// Obtenir les services sélectionnés basés sur une liste d'IDs
  List<ServiceModel> getSelectedServices(List<String> serviceIds) {
    return availableServices
        .where((service) => serviceIds.contains(service.id))
        .toList();
  }

  /// Vérifier si un service est sélectionné
  bool isServiceSelected(
    ServiceModel service,
    List<ServiceModel> selectedServices,
  ) {
    return selectedServices.contains(service);
  }

  /// Filtrer les services par nom ou catégorie
  List<ServiceModel> filterServices(String query) {
    if (query.trim().isEmpty) return availableServices;

    final lowercaseQuery = query.toLowerCase();
    return availableServices.where((service) {
      return service.name.toLowerCase().contains(lowercaseQuery) ||
          service.categoryName.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  /// Obtenir les services par catégorie
  Map<String, List<ServiceModel>> getServicesByCategory() {
    final Map<String, List<ServiceModel>> servicesByCategory = {};

    for (final service in availableServices) {
      final category = service.categoryName;
      if (!servicesByCategory.containsKey(category)) {
        servicesByCategory[category] = [];
      }
      servicesByCategory[category]!.add(service);
    }

    return servicesByCategory;
  }

  /// Obtenir les statistiques des services
  ServicesStats getServicesStats() {
    final totalServices = availableServices.length;
    final categories = getServicesByCategory().keys.length;
    final priceRange = _calculatePriceRange();

    return ServicesStats(
      totalServices: totalServices,
      totalCategories: categories,
      minPrice: priceRange.min,
      maxPrice: priceRange.max,
      averagePrice: priceRange.average,
    );
  }

  /// Calculer la plage de prix des services
  PriceRange _calculatePriceRange() {
    if (availableServices.isEmpty) {
      return PriceRange(min: 0, max: 0, average: 0);
    }

    final prices = availableServices.map((s) => s.price).toList();
    final min = prices.reduce((a, b) => a < b ? a : b);
    final max = prices.reduce((a, b) => a > b ? a : b);
    final average = prices.reduce((a, b) => a + b) / prices.length;

    return PriceRange(min: min, max: max, average: average);
  }

  /// Réinitialiser l'état
  void reset() {
    availableServices.clear();
    isLoading = true;
    error = null;
  }

  /// Vérifier si des services sont disponibles
  bool get hasServices => availableServices.isNotEmpty;

  /// Obtenir le nombre de services disponibles
  int get servicesCount => availableServices.length;
}

/// Classe pour les statistiques des services
class ServicesStats {
  final int totalServices;
  final int totalCategories;
  final double minPrice;
  final double maxPrice;
  final double averagePrice;

  const ServicesStats({
    required this.totalServices,
    required this.totalCategories,
    required this.minPrice,
    required this.maxPrice,
    required this.averagePrice,
  });
}

/// Classe pour la plage de prix
class PriceRange {
  final double min;
  final double max;
  final double average;

  const PriceRange({
    required this.min,
    required this.max,
    required this.average,
  });
}

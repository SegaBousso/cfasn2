import 'package:flutter/material.dart';
import '../../../../models/service_model.dart';
import '../dialogs/services_dialogs.dart';

/// Classe de données pour l'écran ServicesListScreen
/// Contient tous les états et données nécessaires à l'écran
class ServicesListData {
  // Controllers
  final TextEditingController searchController = TextEditingController();

  // État de l'écran
  List<ServiceModel> services = [];
  Set<String> favoriteIds = {};
  List<ServiceCategory> categories = [];
  String selectedCategoryId = 'all';
  ServiceFilters currentFilters = ServiceFilters();
  bool isLoading = true;
  bool isLoadingFavoriteAction = false;
  String? error;

  // Getters pour les données calculées
  List<ServiceModel> get availableServices =>
      services.where((s) => s.isAvailable).toList();

  int get totalServicesCount => services.length;
  int get availableServicesCount => availableServices.length;

  ServiceCategory get selectedCategory => categories.firstWhere(
    (c) => c.id == selectedCategoryId,
    orElse: () => categories.isNotEmpty
        ? categories.first
        : ServiceCategory(
            id: 'all',
            name: 'Tous',
            icon: Icons.apps,
            servicesCount: 0,
          ),
  );

  bool get hasActiveFilters => currentFilters.hasFilters;

  /// Dispose des ressources
  void dispose() {
    searchController.dispose();
  }
}

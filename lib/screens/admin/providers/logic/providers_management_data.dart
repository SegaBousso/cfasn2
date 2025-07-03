import 'package:flutter/material.dart';
import '../../../../models/models.dart';

/// Classe de données pour l'écran ProvidersManagementScreen
/// Contient tous les états et données nécessaires à l'écran
class ProvidersManagementData {
  // Tab Controller
  late TabController tabController;

  // État de l'écran
  List<ProviderModel> providers = [];
  List<ProviderModel> filteredProviders = [];
  List<ProviderModel> selectedProviders = [];
  bool isLoading = true;
  String searchQuery = '';
  String selectedSpecialty = 'all';
  String? error;

  // Statistiques
  int totalProvidersCount = 0;
  int activeProvidersCount = 0;
  int verifiedProvidersCount = 0;
  int availableProvidersCount = 0;

  // Getters pour les données calculées
  bool get hasSelection => selectedProviders.isNotEmpty;
  int get selectedCount => selectedProviders.length;

  List<ProviderModel> get allProviders => providers;
  List<ProviderModel> get activeProviders =>
      providers.where((p) => p.isActive).toList();
  List<ProviderModel> get verifiedProviders =>
      providers.where((p) => p.isVerified).toList();
  List<ProviderModel> get availableProviders =>
      providers.where((p) => p.isAvailable && p.isActive).toList();

  /// Initialise le TabController
  void initializeTabController(TickerProvider vsync) {
    tabController = TabController(length: 4, vsync: vsync);
  }

  /// Nettoie la sélection
  void clearSelection() {
    selectedProviders.clear();
  }

  /// Ajoute un prestataire à la sélection
  void addToSelection(ProviderModel provider) {
    if (!selectedProviders.contains(provider)) {
      selectedProviders.add(provider);
    }
  }

  /// Retire un prestataire de la sélection
  void removeFromSelection(ProviderModel provider) {
    selectedProviders.remove(provider);
  }

  /// Bascule la sélection d'un prestataire
  void toggleSelection(ProviderModel provider) {
    if (selectedProviders.contains(provider)) {
      removeFromSelection(provider);
    } else {
      addToSelection(provider);
    }
  }

  /// Vérifie si un prestataire est sélectionné
  bool isSelected(ProviderModel provider) {
    return selectedProviders.contains(provider);
  }

  /// Dispose des ressources
  void dispose() {
    tabController.dispose();
  }
}

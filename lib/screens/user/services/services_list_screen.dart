import 'package:flutter/material.dart';
import '../../../models/service_model.dart';
import 'services/services_service.dart';
import 'sections/services_sections.dart';
import 'dialogs/services_dialogs.dart';
import 'service_detail_screen.dart';

class ServicesListScreen extends StatefulWidget {
  const ServicesListScreen({super.key});

  @override
  State<ServicesListScreen> createState() => _ServicesListScreenState();
}

class _ServicesListScreenState extends State<ServicesListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ServicesService _servicesService = ServicesService();

  // État de l'écran
  List<ServiceModel> _services = [];
  Set<String> _favoriteIds = {};
  List<ServiceCategory> _categories = [];
  String _selectedCategoryId = 'all';
  ServiceFilters _currentFilters = ServiceFilters();
  bool _isLoading = true;
  bool _isLoadingFavoriteAction = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Charge les données initiales
  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);

    try {
      print('🚀 ServicesListScreen: Début du chargement des données...');
      // Charger les catégories et les services en parallèle
      final futures = await Future.wait([
        _servicesService.getServiceCategories(),
        _servicesService.getAllServicesWithFavorites(),
      ]);

      final categories = futures[0] as List<ServiceCategory>;
      final servicesData = futures[1] as ServicesData;

      print('📊 ServicesListScreen: Catégories reçues: ${categories.length}');
      print(
        '📊 ServicesListScreen: Services reçus: ${servicesData.services.length}',
      );

      setState(() {
        _categories = categories;
        _services = servicesData.services;
        _favoriteIds = servicesData.favoriteIds;
        _isLoading = false;
      });

      print('✅ ServicesListScreen: Données chargées avec succès');
    } catch (e) {
      print('❌ ServicesListScreen: Erreur lors du chargement: $e');
      setState(() => _isLoading = false);
      _showErrorMessage('Erreur lors du chargement des données');
    }
  }

  /// Recherche et filtre les services
  Future<void> _searchAndFilterServices() async {
    setState(() => _isLoading = true);

    try {
      final servicesData = await _servicesService.searchServicesWithFilters(
        query: _searchController.text,
        categoryId: _selectedCategoryId,
        minPrice: _currentFilters.minPrice,
        maxPrice: _currentFilters.maxPrice,
        minRating: _currentFilters.minRating,
        availableOnly: _currentFilters.availableOnly,
      );

      setState(() {
        _services = servicesData.services;
        _favoriteIds = servicesData.favoriteIds;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorMessage('Erreur lors de la recherche');
    }
  }

  /// Bascule le statut favori d'un service
  Future<void> _toggleFavorite(String serviceId) async {
    if (_isLoadingFavoriteAction) return;

    setState(() => _isLoadingFavoriteAction = true);

    try {
      final isNowFavorite = await _servicesService.toggleServiceFavorite(
        serviceId,
      );

      setState(() {
        if (isNowFavorite) {
          _favoriteIds.add(serviceId);
        } else {
          _favoriteIds.remove(serviceId);
        }
        _isLoadingFavoriteAction = false;
      });

      final service = _services.firstWhere((s) => s.id == serviceId);
      _showSuccessMessage(
        isNowFavorite
            ? '${service.name} ajouté aux favoris'
            : '${service.name} retiré des favoris',
      );
    } catch (e) {
      setState(() => _isLoadingFavoriteAction = false);
      _showErrorMessage('Erreur lors de la modification des favoris');
    }
  }

  /// Navigue vers les détails d'un service
  void _navigateToServiceDetail(ServiceModel service) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ServiceDetailScreen(service: service),
      ),
    );
  }

  /// Affiche le dialog des filtres
  Future<void> _showFiltersDialog() async {
    final newFilters = await ServicesDialogs.showFiltersDialog(
      context,
      currentFilters: _currentFilters,
      categories: _categories.where((c) => c.id != 'all').toList(),
    );

    if (newFilters != null) {
      setState(() {
        _currentFilters = newFilters;
        if (newFilters.categoryId != null) {
          _selectedCategoryId = newFilters.categoryId!;
        }
      });
      _searchAndFilterServices();
    }
  }

  /// Réinitialise les filtres et la recherche
  void _resetFiltersAndSearch() {
    _searchController.clear();
    setState(() {
      _selectedCategoryId = 'all';
      _currentFilters = ServiceFilters();
    });
    _searchAndFilterServices();
  }

  /// Change la catégorie sélectionnée
  void _onCategoryChanged(String categoryId) {
    setState(() {
      _selectedCategoryId = categoryId;
      _currentFilters = _currentFilters.copyWith(categoryId: categoryId);
    });
    _searchAndFilterServices();
  }

  /// Affiche un message d'erreur
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  /// Affiche un message de succès
  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedCategory = _categories.firstWhere(
      (c) => c.id == _selectedCategoryId,
      orElse: () => _categories.isNotEmpty
          ? _categories.first
          : ServiceCategory(
              id: 'all',
              name: 'Tous',
              icon: Icons.apps,
              servicesCount: 0,
            ),
    );

    final availableServices = _services.where((s) => s.isAvailable).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Services'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _currentFilters.hasFilters ? Icons.filter_alt : Icons.filter_list,
            ),
            onPressed: _showFiltersDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Section de recherche et filtres
          ServicesSearchSection(
            searchController: _searchController,
            onSearchChanged: (_) => _searchAndFilterServices(),
            categories: _categories,
            selectedCategory: _selectedCategoryId,
            onCategoryChanged: _onCategoryChanged,
            onFiltersTap: _showFiltersDialog,
            hasActiveFilters: _currentFilters.hasFilters,
          ),

          // Statistiques
          if (!_isLoading)
            ServicesStatsSection(
              totalServices: _services.length,
              availableServices: availableServices,
              selectedCategoryName: selectedCategory.name,
            ),

          // Liste des services
          ServicesListSection(
            services: _services,
            favoriteIds: _favoriteIds,
            onServiceTap: _navigateToServiceDetail,
            onFavoriteToggle: _toggleFavorite,
            isLoading: _isLoading,
            onEmptyStateReset: _resetFiltersAndSearch,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Debug: Create sample data if needed
          if (_categories.length <= 1 || _services.isEmpty) {
            try {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Création des données de test...'),
                ),
              );

              // Create categories if only "Tous" exists
              if (_categories.length <= 1) {
                await _servicesService.createSampleCategories();
              }

              // Create services if none exist
              if (_services.isEmpty) {
                await _servicesService.createSampleServices();
              }

              // Reload data
              await _loadInitialData();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Données créées avec succès!')),
              );
            } catch (e) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Fonctionnalité de demande de service à venir'),
              ),
            );
          }
        },
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

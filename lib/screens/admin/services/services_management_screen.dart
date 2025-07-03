import 'package:flutter/material.dart';
import '../../../models/models.dart';
import 'widgets/service_card.dart';
import 'widgets/service_detail_dialog.dart';
import 'services/admin_service_manager.dart';
import '../../../services/admin_category_manager.dart';
import 'add_edit_service_screen.dart';

class ServicesManagementScreen extends StatefulWidget {
  const ServicesManagementScreen({super.key});

  @override
  State<ServicesManagementScreen> createState() =>
      _ServicesManagementScreenState();
}

class _ServicesManagementScreenState extends State<ServicesManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AdminServiceManager _serviceManager = AdminServiceManager();
  final AdminCategoryManager _categoryManager = AdminCategoryManager();

  String _searchQuery = '';
  String _selectedCategory = 'Tous';
  bool _isLoading = false;

  List<String> _categories = ['Tous'];

  // Cache des données pour éviter les appels répétés
  List<ServiceModel> _allServices = [];
  List<ServiceModel> _activeServices = [];
  List<ServiceModel> _inactiveServices = [];
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadInitialData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await Future.wait([_loadServices(), _loadCategories(), _loadStats()]);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadServices() async {
    try {
      final results = await Future.wait([
        _serviceManager.allServices,
        _serviceManager.activeServices,
        _serviceManager.inactiveServices,
      ]);

      setState(() {
        _allServices = results[0];
        _activeServices = results[1];
        _inactiveServices = results[2];
      });
    } catch (e) {
      print('Erreur lors du chargement des services: $e');
    }
  }

  Future<void> _loadStats() async {
    try {
      final stats = await _serviceManager.getServiceStats();
      setState(() {
        _stats = stats;
      });
    } catch (e) {
      print('Erreur lors du chargement des statistiques: $e');
    }
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _categoryManager.getActiveCategories();
      setState(() {
        _categories = ['Tous', ...categories.map((c) => c.name)];
      });
    } catch (e) {
      print('Erreur lors du chargement des catégories: $e');
      // En cas d'erreur, ne pas utiliser de données statiques
      // Laisser seulement "Tous" pour permettre l'affichage
      setState(() {
        _categories = ['Tous'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Services'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshServices,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'export':
                  _exportServices();
                  break;
                case 'import':
                  _importServices();
                  break;
                case 'analytics':
                  Navigator.pushNamed(context, '/admin/analytics/services');
                  break;
                case 'settings':
                  Navigator.pushNamed(context, '/admin/settings/services');
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download),
                    SizedBox(width: 8),
                    Text('Exporter'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'import',
                child: Row(
                  children: [
                    Icon(Icons.upload),
                    SizedBox(width: 8),
                    Text('Importer'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'analytics',
                child: Row(
                  children: [
                    Icon(Icons.analytics),
                    SizedBox(width: 8),
                    Text('Analytics'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 8),
                    Text('Paramètres'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Statistiques
          _buildStatsSection(),

          // Barre de recherche et filtres
          _buildSearchAndFilters(),

          // Onglets
          _buildTabBar(),

          // Contenu des onglets
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildServicesList(_allServices),
                      _buildServicesList(_activeServices),
                      _buildServicesList(_inactiveServices),
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "services_management_fab",
        onPressed: _navigateToCreateService,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              'Total',
              '${_stats['totalServices'] ?? _allServices.length}',
              Icons.build,
              Colors.blue,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatItem(
              'Actifs',
              '${_stats['activeServices'] ?? _activeServices.length}',
              Icons.check_circle,
              Colors.green,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatItem(
              'Note',
              '${(_stats['averageRating'] ?? 0.0).toStringAsFixed(1)}',
              Icons.star,
              Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Barre de recherche
          TextField(
            decoration: const InputDecoration(
              hintText: 'Rechercher des services...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 16),
          // Filtre par catégorie
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: const InputDecoration(
              labelText: 'Catégorie',
              border: OutlineInputBorder(),
            ),
            items: _categories.map((category) {
              return DropdownMenuItem(value: category, child: Text(category));
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCategory = value ?? 'Tous';
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        tabs: [
          Tab(text: 'Tous (${_allServices.length})'),
          Tab(text: 'Actifs (${_activeServices.length})'),
          Tab(text: 'Inactifs (${_inactiveServices.length})'),
        ],
        indicatorColor: Colors.deepPurple,
        labelColor: Colors.deepPurple,
        unselectedLabelColor: Colors.grey,
      ),
    );
  }

  Widget _buildServicesList(List<ServiceModel> services) {
    List<ServiceModel> filteredServices = _filterServices(services);

    if (filteredServices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty || _selectedCategory != 'Tous'
                  ? 'Aucun service trouvé'
                  : 'Aucun service disponible',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty || _selectedCategory != 'Tous'
                  ? 'Essayez de modifier vos critères de recherche'
                  : 'Commencez par créer votre premier service',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _navigateToCreateService,
              icon: const Icon(Icons.add),
              label: const Text('Créer un service'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshServices,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredServices.length,
        itemBuilder: (context, index) {
          final service = filteredServices[index];
          return ServiceCard(
            service: service,
            onEdit: () => _navigateToEditService(service),
            onDelete: () => _deleteService(service),
            onToggleStatus: () => _toggleServiceStatus(service),
            onViewDetails: () => _showServiceDetails(service),
          );
        },
      ),
    );
  }

  List<ServiceModel> _filterServices(List<ServiceModel> services) {
    return services.where((service) {
      bool matchesSearch =
          _searchQuery.isEmpty ||
          service.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          service.description.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );

      bool matchesCategory =
          _selectedCategory == 'Tous' ||
          service.categoryName == _selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();
  }

  Future<void> _refreshServices() async {
    await _serviceManager.forceReload();
    await Future.wait([_loadServices(), _loadStats()]);
  }

  Future<void> _navigateToCreateService() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AddEditServiceScreen()),
    );

    if (result != null && result is ServiceModel) {
      await _serviceManager.createService(result);
      _refreshServices();
    }
  }

  Future<void> _navigateToEditService(ServiceModel service) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditServiceScreen(service: service),
      ),
    );

    if (result != null && result is ServiceModel) {
      await _serviceManager.updateService(result);
      _refreshServices();
    }
  }

  void _showServiceDetails(ServiceModel service) {
    showDialog(
      context: context,
      builder: (context) => ServiceDetailDialog(service: service),
    );
  }

  Future<void> _deleteService(ServiceModel service) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le service'),
        content: Text('Êtes-vous sûr de vouloir supprimer "${service.name}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _serviceManager.deleteService(service.id);
        await _refreshServices();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Service supprimé avec succès')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Future<void> _toggleServiceStatus(ServiceModel service) async {
    try {
      final updatedService = service.copyWith(isActive: !service.isActive);
      await _serviceManager.updateService(updatedService);
      await _refreshServices();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              service.isActive ? 'Service désactivé' : 'Service activé',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _exportServices() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fonctionnalité d\'export à venir')),
    );
  }

  void _importServices() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fonctionnalité d\'import à venir')),
    );
  }
}

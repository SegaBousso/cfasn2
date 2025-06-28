import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/responsive_helper.dart';
import '../../widgets/overflow_safe_widgets.dart';
import 'home/widgets/hero_section.dart';
import 'home/widgets/quick_search_bar.dart';
import 'home/widgets/categories_section.dart';
import 'home/widgets/popular_services_section.dart';
import 'home/widgets/recommended_providers_section.dart';
import 'home/widgets/recent_services_section.dart';
import 'home/services/mock_data_service.dart';
import '../../services/user_service_manager.dart';
import '../../models/models.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final UserServiceManager _serviceManager = UserServiceManager();
  List<ServiceModel> _popularServices = [];
  List<ServiceModel> _recentServices = [];
  int _totalServices = 0;
  int _totalCategories = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final popularServices = await _serviceManager.getPopularServices(
        limit: 10,
      );
      final recentServices = await _serviceManager.getRecentServices(limit: 10);
      final allServices = await _serviceManager.getActiveServices();
      
      // Calculer le nombre de catégories uniques
      final uniqueCategories = allServices.map((s) => s.categoryId).toSet();

      setState(() {
        _popularServices = popularServices;
        _recentServices = recentServices;
        _totalServices = allServices.length;
        _totalCategories = uniqueCategories.length;
        _isLoading = false;
      });
    } catch (e) {
      print('Erreur lors du chargement des services: $e');
      // Fallback vers les données mock en cas d'erreur
      setState(() {
        _popularServices = MockDataService.getMockServices();
        _recentServices = MockDataService.getMockServices();
        _totalServices = MockDataService.getMockServices().length;
        _totalCategories = 3; // Nombre par défaut
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.user;

          return ResponsiveBuilder(
            builder: (context, dimensions) {
              return OverflowSafeSliverArea(
                child: CustomScrollView(
                  slivers: [
                    // AppBar avec recherche
                    SliverAppBar(
                      expandedHeight: 120,
                      floating: true,
                      pinned: true,
                      backgroundColor: Colors.deepPurple,
                      automaticallyImplyLeading:
                          false, // Empêche l'affichage de l'icône de retour
                      flexibleSpace: FlexibleSpaceBar(
                        title: user != null
                            ? Text(
                                'Bonjour, ${user.firstName}',
                                style: const TextStyle(fontSize: 16),
                              )
                            : const Text('Bienvenue'),
                        background: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.deepPurple, Colors.purple],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),
                      ),
                      actions: [
                        IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () => _showSearchDialog(context),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: _isLoading ? null : _loadServices,
                        ),
                        IconButton(
                          icon: const Icon(Icons.notifications_outlined),
                          onPressed: () => _showNotifications(context),
                        ),
                      ],
                    ),

                    // Contenu principal
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          // Hero Section
                          HeroSection(
                            featuredServices: _popularServices.take(3).toList(),
                            totalServices: _totalServices,
                            totalCategories: _totalCategories,
                          ),

                          const SizedBox(height: 24),

                          // Barre de recherche rapide
                          QuickSearchBar(
                            onTap: () => _showSearchDialog(context),
                          ),

                          const SizedBox(height: 24),

                          // Section Catégories
                          const CategoriesSection(),

                          const SizedBox(height: 24),

                          // Section Services Populaires
                          _isLoading
                              ? const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(24.0),
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              : PopularServicesSection(
                                  services: _popularServices,
                                  onSeeAll: () {
                                    // TODO: Navigation vers tous les services
                                  },
                                ),

                          const SizedBox(height: 24),

                          // Section Prestataires Recommandés
                          RecommendedProvidersSection(
                            providers: MockDataService.getMockProviders(),
                            onSeeAll: () {
                              // TODO: Navigation vers tous les prestataires
                            },
                          ),

                          const SizedBox(height: 24),

                          // Section Services Récents
                          _isLoading
                              ? const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(24.0),
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              : RecentServicesSection(
                                  services: _recentServices,
                                  onSeeAll: () {
                                    // TODO: Navigation vers nouveaux services
                                  },
                                ),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rechercher un service'),
        content: const TextField(
          decoration: InputDecoration(
            hintText: 'Tapez votre recherche...',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implémenter la recherche
            },
            child: const Text('Rechercher'),
          ),
        ],
      ),
    );
  }

  void _showNotifications(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notifications'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.info, color: Colors.blue),
              title: Text('Bienvenue !'),
              subtitle: Text('Découvrez nos services'),
            ),
            ListTile(
              leading: Icon(Icons.local_offer, color: Colors.green),
              title: Text('Promotion'),
              subtitle: Text('10% de réduction sur votre première réservation'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
}

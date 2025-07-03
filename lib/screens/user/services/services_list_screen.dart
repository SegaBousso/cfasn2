import 'package:flutter/material.dart';

// Logic Handlers
import 'logic/services_list_data.dart';
import 'logic/services_list_event_handler.dart';

// Modular Widgets
import 'widgets/services_search_bar.dart';
import 'widgets/services_categories_section.dart';
import 'widgets/services_stats_section.dart';
import 'widgets/services_list_view.dart';

class ServicesListScreen extends StatefulWidget {
  const ServicesListScreen({super.key});

  @override
  State<ServicesListScreen> createState() => _ServicesListScreenState();
}

class _ServicesListScreenState extends State<ServicesListScreen> {
  late final ServicesListData _data;
  late final ServicesListEventHandler _eventHandler;

  @override
  void initState() {
    super.initState();
    _initializeHandlers();
    _eventHandler.initialize();
  }

  /// Initialise les handlers de logique métier
  void _initializeHandlers() {
    _data = ServicesListData();
    _eventHandler = ServicesListEventHandler(
      context: context,
      data: _data,
      onStateChanged: () {
        if (mounted) setState(() {});
      },
    );
  }

  @override
  void dispose() {
    _data.dispose();
    _eventHandler.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Services'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _data.hasActiveFilters ? Icons.filter_alt : Icons.filter_list,
            ),
            onPressed: _eventHandler.handleShowFiltersDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche
          ServicesSearchBar(
            controller: _data.searchController,
            onChanged: _eventHandler.handleSearchChanged,
            hasActiveFilters: _data.hasActiveFilters,
            onFiltersTap: _eventHandler.handleShowFiltersDialog,
          ),

          // Section de sélection des catégories
          ServicesCategoriesSection(
            categories: _data.categories,
            selectedCategoryId: _data.selectedCategoryId,
            onCategoryChanged: _eventHandler.handleCategoryChanged,
          ),

          // Statistiques
          if (!_data.isLoading)
            ServicesStatsSection(
              totalServices: _data.totalServicesCount,
              availableServices: _data.availableServicesCount,
              selectedCategoryName: _data.selectedCategory.name,
            ),

          // Liste des services
          ServicesListView(
            services: _data.services,
            favoriteIds: _data.favoriteIds,
            onServiceTap: _eventHandler.handleNavigateToServiceDetail,
            onFavoriteToggle: _eventHandler.handleToggleFavorite,
            isLoading: _data.isLoading,
            onEmptyStateReset: _eventHandler.handleResetFilters,
            hasActiveFilters: _data.hasActiveFilters,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "services_list_fab",
        onPressed: _eventHandler.handleFloatingActionButton,
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:service/models/service_model.dart';
import '../widgets/service_widgets.dart';
import '../services/services_service.dart';

/// Section pour la barre de recherche et les filtres
class ServicesSearchSection extends StatelessWidget {
  final TextEditingController searchController;
  final ValueChanged<String>? onSearchChanged;
  final List<ServiceCategory> categories;
  final String selectedCategory;
  final ValueChanged<String>? onCategoryChanged;
  final VoidCallback? onFiltersTap;
  final bool hasActiveFilters;

  const ServicesSearchSection({
    super.key,
    required this.searchController,
    this.onSearchChanged,
    required this.categories,
    required this.selectedCategory,
    this.onCategoryChanged,
    this.onFiltersTap,
    this.hasActiveFilters = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.deepPurple,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Barre de recherche
          Row(
            children: [
              Expanded(
                child: ServiceSearchBar(
                  controller: searchController,
                  onChanged: onSearchChanged,
                ),
              ),
              const SizedBox(width: 12),
              // Bouton filtres
              Container(
                decoration: BoxDecoration(
                  color: hasActiveFilters
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.filter_list,
                    color: hasActiveFilters ? Colors.deepPurple : Colors.white,
                  ),
                  onPressed: onFiltersTap,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Filtres rapides par catégorie
          if (categories.isNotEmpty)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categories
                    // S'assurer qu'il n'y a pas de doublons d'IDs
                    .fold<Map<String, ServiceCategory>>({}, (map, category) {
                      map[category.id] = category;
                      return map;
                    })
                    .values
                    .map((category) {
                      final isSelected = selectedCategory == category.id;
                      return CategoryFilterChip(
                        category: category.name,
                        isSelected: isSelected,
                        onTap: () => onCategoryChanged?.call(category.id),
                      );
                    })
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}

/// Section pour afficher les statistiques des services
class ServicesStatsSection extends StatelessWidget {
  final int totalServices;
  final int availableServices;
  final String? selectedCategoryName;

  const ServicesStatsSection({
    super.key,
    required this.totalServices,
    required this.availableServices,
    this.selectedCategoryName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            selectedCategoryName != null && selectedCategoryName != 'Tous'
                ? '$totalServices services en $selectedCategoryName'
                : '$totalServices services trouvés',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          if (availableServices != totalServices)
            Text(
              '$availableServices disponibles',
              style: TextStyle(
                fontSize: 14,
                color: Colors.green[600],
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }
}

/// Section pour la liste des services
class ServicesListSection extends StatelessWidget {
  final List<ServiceModel> services;
  final Set<String> favoriteIds;
  final Function(ServiceModel)? onServiceTap;
  final Function(String)? onFavoriteToggle;
  final bool isLoading;
  final String? emptyStateTitle;
  final String? emptyStateSubtitle;
  final VoidCallback? onEmptyStateReset;

  const ServicesListSection({
    super.key,
    required this.services,
    required this.favoriteIds,
    this.onServiceTap,
    this.onFavoriteToggle,
    this.isLoading = false,
    this.emptyStateTitle,
    this.emptyStateSubtitle,
    this.onEmptyStateReset,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Expanded(child: Center(child: CircularProgressIndicator()));
    }

    if (services.isEmpty) {
      return Expanded(
        child: ServicesEmptyState(
          title: emptyStateTitle ?? 'Aucun service trouvé',
          subtitle:
              emptyStateSubtitle ??
              'Essayez de modifier vos critères de recherche',
          onReset: onEmptyStateReset,
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: services.length,
        itemBuilder: (context, index) {
          final service = services[index];
          final isFavorite = favoriteIds.contains(service.id);

          return ServiceCard(
            service: service,
            isFavorite: isFavorite,
            onTap: () => onServiceTap?.call(service),
            onFavoriteToggle: () => onFavoriteToggle?.call(service.id),
          );
        },
      ),
    );
  }
}

/// Section pour les services populaires (vue horizontale)
class PopularServicesSection extends StatelessWidget {
  final List<ServiceModel> services;
  final Set<String> favoriteIds;
  final Function(ServiceModel)? onServiceTap;
  final Function(String)? onFavoriteToggle;
  final bool isLoading;

  const PopularServicesSection({
    super.key,
    required this.services,
    required this.favoriteIds,
    this.onServiceTap,
    this.onFavoriteToggle,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Services populaires',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        if (isLoading)
          const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          )
        else if (services.isEmpty)
          const SizedBox(
            height: 100,
            child: Center(
              child: Text(
                'Aucun service populaire',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          SizedBox(
            height: 240,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: services.length,
              itemBuilder: (context, index) {
                final service = services[index];
                final isFavorite = favoriteIds.contains(service.id);

                return Container(
                  width: 280,
                  margin: const EdgeInsets.only(right: 16),
                  child: ServiceCard(
                    service: service,
                    isFavorite: isFavorite,
                    onTap: () => onServiceTap?.call(service),
                    onFavoriteToggle: () => onFavoriteToggle?.call(service.id),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

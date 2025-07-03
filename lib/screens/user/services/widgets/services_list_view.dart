import 'package:flutter/material.dart';
import '../../../../models/service_model.dart';
import 'service_card.dart';

/// Liste des services avec gestion des états
class ServicesListView extends StatelessWidget {
  final List<ServiceModel> services;
  final Set<String> favoriteIds;
  final ValueChanged<ServiceModel> onServiceTap;
  final ValueChanged<String> onFavoriteToggle;
  final bool isLoading;
  final VoidCallback onEmptyStateReset;
  final bool hasActiveFilters;

  const ServicesListView({
    super.key,
    required this.services,
    required this.favoriteIds,
    required this.onServiceTap,
    required this.onFavoriteToggle,
    required this.isLoading,
    required this.onEmptyStateReset,
    this.hasActiveFilters = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Expanded(child: Center(child: CircularProgressIndicator()));
    }

    if (services.isEmpty) {
      return Expanded(child: _buildEmptyState());
    }

    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: services.length,
        itemBuilder: (context, index) {
          final service = services[index];
          final isFavorite = favoriteIds.contains(service.id);

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ServiceCard(
              service: service,
              isFavorite: isFavorite,
              onTap: () => onServiceTap(service),
              onFavoriteToggle: () => onFavoriteToggle(service.id),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasActiveFilters ? Icons.search_off : Icons.hourglass_empty,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              hasActiveFilters
                  ? 'Aucun service trouvé'
                  : 'Aucun service disponible',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              hasActiveFilters
                  ? 'Essayez de modifier vos critères de recherche ou vos filtres.'
                  : 'Il semble qu\'aucun service ne soit encore disponible.',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (hasActiveFilters)
              ElevatedButton.icon(
                onPressed: onEmptyStateReset,
                icon: const Icon(Icons.refresh),
                label: const Text('Réinitialiser les filtres'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

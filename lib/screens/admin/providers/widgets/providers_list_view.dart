import 'package:flutter/material.dart';
import '../../../../models/models.dart';
import 'provider_card.dart';

/// Liste des prestataires avec gestion des états
class ProvidersListView extends StatelessWidget {
  final List<ProviderModel> providers;
  final List<ProviderModel> selectedProviders;
  final bool isLoading;
  final ValueChanged<ProviderModel> onProviderTap;
  final ValueChanged<ProviderModel> onProviderSelectionToggle;
  final ValueChanged<ProviderModel> onEdit;
  final ValueChanged<ProviderModel> onDelete;
  final ValueChanged<ProviderModel> onToggleStatus;
  final ValueChanged<ProviderModel>? onVerify;
  final VoidCallback onRefresh;

  const ProvidersListView({
    super.key,
    required this.providers,
    required this.selectedProviders,
    required this.isLoading,
    required this.onProviderTap,
    required this.onProviderSelectionToggle,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleStatus,
    this.onVerify,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Expanded(child: Center(child: CircularProgressIndicator()));
    }

    if (providers.isEmpty) {
      return Expanded(child: _buildEmptyState());
    }

    return Expanded(
      child: RefreshIndicator(
        onRefresh: () async => onRefresh(),
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: providers.length,
          itemBuilder: (context, index) {
            final provider = providers[index];
            final isSelected = selectedProviders.contains(provider);

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ProviderCard(
                provider: provider,
                isSelected: isSelected,
                onTap: () => onProviderTap(provider),
                onSelected: (_) => onProviderSelectionToggle(provider),
                onEdit: () => onEdit(provider),
                onDelete: () => onDelete(provider),
                onToggleStatus: () => onToggleStatus(provider),
                onVerify: onVerify != null ? () => onVerify!(provider) : null,
              ),
            );
          },
        ),
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
            Icon(Icons.people_outline, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 24),
            const Text(
              'Aucun prestataire trouvé',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Aucun prestataire ne correspond aux critères de recherche.',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Actualiser'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
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

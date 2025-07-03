import 'package:flutter/material.dart';

/// App Bar avec tabs pour la gestion des prestataires
class ProvidersAppBar extends StatelessWidget implements PreferredSizeWidget {
  final TabController tabController;
  final int totalCount;
  final int activeCount;
  final int verifiedCount;
  final int availableCount;
  final bool hasSelection;
  final VoidCallback? onRefresh;
  final VoidCallback? onBulkActivate;
  final VoidCallback? onBulkDeactivate;
  final VoidCallback? onBulkDelete;
  final ValueChanged<int>? onTabChanged;

  const ProvidersAppBar({
    super.key,
    required this.tabController,
    required this.totalCount,
    required this.activeCount,
    required this.verifiedCount,
    required this.availableCount,
    required this.hasSelection,
    this.onRefresh,
    this.onBulkActivate,
    this.onBulkDeactivate,
    this.onBulkDelete,
    this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Gestion des Prestataires'),
      backgroundColor: Colors.purple,
      foregroundColor: Colors.white,
      automaticallyImplyLeading: false,
      bottom: TabBar(
        controller: tabController,
        onTap: onTabChanged,
        indicatorColor: Colors.white,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        tabs: [
          Tab(text: 'Tous ($totalCount)'),
          Tab(text: 'Actifs ($activeCount)'),
          Tab(text: 'Vérifiés ($verifiedCount)'),
          Tab(text: 'Disponibles ($availableCount)'),
        ],
      ),
      actions: [
        if (hasSelection) ...[
          IconButton(
            icon: const Icon(Icons.check_circle),
            onPressed: onBulkActivate,
            tooltip: 'Activer sélectionnés',
          ),
          IconButton(
            icon: const Icon(Icons.cancel),
            onPressed: onBulkDeactivate,
            tooltip: 'Désactiver sélectionnés',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: onBulkDelete,
            tooltip: 'Supprimer sélectionnés',
          ),
        ],
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: onRefresh,
          tooltip: 'Actualiser',
        ),
      ],
    );
  }

  @override
  Size get preferredSize =>
      const Size.fromHeight(kToolbarHeight + kTextTabBarHeight);
}

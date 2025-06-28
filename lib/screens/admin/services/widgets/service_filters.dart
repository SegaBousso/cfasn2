import 'package:flutter/material.dart';
import '../../../../models/models.dart';

class ServiceSearchBar extends StatefulWidget {
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final String selectedCategory;
  final ValueChanged<String> onCategoryChanged;
  final List<String> categories;

  const ServiceSearchBar({
    super.key,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.categories,
  });

  @override
  State<ServiceSearchBar> createState() => _ServiceSearchBarState();
}

class _ServiceSearchBarState extends State<ServiceSearchBar> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        children: [
          // Barre de recherche
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Rechercher un service...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: widget.searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        widget.onSearchChanged('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            onChanged: widget.onSearchChanged,
          ),

          const SizedBox(height: 12),

          // Filtres de catégorie
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: widget.categories.map((category) {
                final isSelected = widget.selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      widget.onCategoryChanged(category);
                    },
                    backgroundColor: Colors.grey[200],
                    selectedColor: Colors.deepPurple.withOpacity(0.2),
                    checkmarkColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class ServiceListFilter extends StatelessWidget {
  final int totalCount;
  final int filteredCount;
  final VoidCallback? onExport;
  final VoidCallback? onRefresh;

  const ServiceListFilter({
    super.key,
    required this.totalCount,
    required this.filteredCount,
    this.onExport,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey[50],
      child: Row(
        children: [
          Text(
            'Affichage: $filteredCount sur $totalCount services',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          const Spacer(),
          if (onRefresh != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: onRefresh,
              tooltip: 'Actualiser',
            ),
          if (onExport != null)
            IconButton(
              icon: const Icon(Icons.file_download),
              onPressed: onExport,
              tooltip: 'Exporter',
            ),
        ],
      ),
    );
  }
}

class ServiceBulkActions extends StatelessWidget {
  final List<ServiceModel> selectedServices;
  final VoidCallback? onBulkDelete;
  final VoidCallback? onBulkActivate;
  final VoidCallback? onBulkDeactivate;
  final VoidCallback? onClearSelection;

  const ServiceBulkActions({
    super.key,
    required this.selectedServices,
    this.onBulkDelete,
    this.onBulkActivate,
    this.onBulkDeactivate,
    this.onClearSelection,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedServices.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.deepPurple.withOpacity(0.1),
        border: Border(
          top: BorderSide(color: Colors.deepPurple.withOpacity(0.3)),
        ),
      ),
      child: Row(
        children: [
          Text(
            '${selectedServices.length} service(s) sélectionné(s)',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          TextButton(
            onPressed: onClearSelection,
            child: const Text('Tout déselectionner'),
          ),
          const SizedBox(width: 8),
          if (onBulkActivate != null)
            ElevatedButton.icon(
              onPressed: onBulkActivate,
              icon: const Icon(Icons.play_arrow, size: 16),
              label: const Text('Activer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 36),
              ),
            ),
          const SizedBox(width: 8),
          if (onBulkDeactivate != null)
            ElevatedButton.icon(
              onPressed: onBulkDeactivate,
              icon: const Icon(Icons.pause, size: 16),
              label: const Text('Désactiver'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 36),
              ),
            ),
          const SizedBox(width: 8),
          if (onBulkDelete != null)
            ElevatedButton.icon(
              onPressed: () => _showBulkDeleteConfirmation(context),
              icon: const Icon(Icons.delete, size: 16),
              label: const Text('Supprimer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 36),
              ),
            ),
        ],
      ),
    );
  }

  void _showBulkDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer ${selectedServices.length} service(s) ?\n\n'
          'Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onBulkDelete?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}

class EmptyServicesList extends StatelessWidget {
  final String message;
  final String? subtitle;
  final VoidCallback? onCreateService;

  const EmptyServicesList({
    super.key,
    required this.message,
    this.subtitle,
    this.onCreateService,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 24),
            Text(
              message,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
            if (onCreateService != null) ...[
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: onCreateService,
                icon: const Icon(Icons.add),
                label: const Text('Créer un service'),
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
          ],
        ),
      ),
    );
  }
}

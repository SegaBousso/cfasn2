import 'package:flutter/material.dart';

class CategoryFilters extends StatelessWidget {
  final String searchQuery;
  final bool showActiveOnly;
  final String sortBy;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<bool> onActiveFilterChanged;
  final ValueChanged<String> onSortChanged;

  const CategoryFilters({
    super.key,
    required this.searchQuery,
    required this.showActiveOnly,
    required this.sortBy,
    required this.onSearchChanged,
    required this.onActiveFilterChanged,
    required this.onSortChanged,
  });

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
        mainAxisSize: MainAxisSize.min,
        children: [
          // Barre de recherche
          TextField(
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Rechercher une catégorie...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[100],
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Filtres et tri
          Row(
            children: [
              // Filtre actif/inactif
              Flexible(
                fit: FlexFit.loose,
                child: CheckboxListTile(
                  title: const Text(
                    'Actives seulement',
                    style: TextStyle(fontSize: 14),
                  ),
                  value: showActiveOnly,
                  onChanged: (value) => onActiveFilterChanged(value ?? false),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),

              const SizedBox(width: 16),

              // Dropdown pour le tri
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: sortBy,
                    onChanged: (value) {
                      if (value != null) {
                        onSortChanged(value);
                      }
                    },
                    items: const [
                      DropdownMenuItem(
                        value: 'name',
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.sort_by_alpha, size: 16),
                            SizedBox(width: 8),
                            Text('Nom'),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'created',
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.schedule, size: 16),
                            SizedBox(width: 8),
                            Text('Date création'),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'services',
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.business_center, size: 16),
                            SizedBox(width: 8),
                            Text('Nb services'),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'order',
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.reorder, size: 16),
                            SizedBox(width: 8),
                            Text('Ordre'),
                          ],
                        ),
                      ),
                    ],
                    hint: const Text('Trier par'),
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

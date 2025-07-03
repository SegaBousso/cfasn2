import 'package:flutter/material.dart';

/// Barre de recherche pour les services
class ServicesSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool hasActiveFilters;
  final VoidCallback onFiltersTap;

  const ServicesSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.hasActiveFilters,
    required this.onFiltersTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: 'Rechercher un service...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          controller.clear();
                          onChanged('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: Icon(
              hasActiveFilters ? Icons.filter_alt : Icons.filter_list,
              color: hasActiveFilters ? Colors.deepPurple : null,
            ),
            onPressed: onFiltersTap,
            tooltip: 'Filtres',
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class UserFilters extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;

  const UserFilters({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final filters = [
      'Tous',
      'Actifs',
      'Inactifs',
      'Clients',
      'Prestataires',
      'Admins',
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) => _buildFilterChip(filter)).toList(),
      ),
    );
  }

  Widget _buildFilterChip(String filter) {
    final isSelected = selectedFilter == filter;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(filter),
        selected: isSelected,
        onSelected: (selected) {
          onFilterChanged(selected ? filter : 'Tous');
        },
        backgroundColor: Colors.grey[100],
        selectedColor: Colors.blue[100],
        labelStyle: TextStyle(
          color: isSelected ? Colors.blue[700] : Colors.grey[700],
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}

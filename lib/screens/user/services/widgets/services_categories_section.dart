import 'package:flutter/material.dart';
import '../../../../models/service_model.dart';

/// Section de sélection des catégories
class ServicesCategoriesSection extends StatelessWidget {
  final List<ServiceCategory> categories;
  final String selectedCategoryId;
  final ValueChanged<String> onCategoryChanged;

  const ServicesCategoriesSection({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category.id == selectedCategoryId;

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    category.icon,
                    size: 16,
                    color: isSelected ? Colors.white : Colors.grey[600],
                  ),
                  const SizedBox(width: 6),
                  Text(
                    category.name,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[600],
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  if (category.servicesCount > 0) ...[
                    const SizedBox(width: 4),
                    Text(
                      '(${category.servicesCount})',
                      style: TextStyle(
                        color: isSelected ? Colors.white70 : Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
              selected: isSelected,
              onSelected: (_) => onCategoryChanged(category.id),
              selectedColor: Colors.deepPurple,
              backgroundColor: Colors.grey[100],
              checkmarkColor: Colors.white,
              showCheckmark: false,
            ),
          );
        },
      ),
    );
  }
}

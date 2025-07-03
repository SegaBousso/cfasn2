import 'package:flutter/material.dart';

/// Section des statistiques des services
class ServicesStatsSection extends StatelessWidget {
  final int totalServices;
  final int availableServices;
  final String selectedCategoryName;

  const ServicesStatsSection({
    super.key,
    required this.totalServices,
    required this.availableServices,
    required this.selectedCategoryName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.deepPurple.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.apps,
            label: 'Total',
            value: totalServices.toString(),
            color: Colors.blue,
          ),
          _buildStatItem(
            icon: Icons.check_circle,
            label: 'Disponibles',
            value: availableServices.toString(),
            color: Colors.green,
          ),
          _buildStatItem(
            icon: Icons.category,
            label: 'Catégorie',
            value: selectedCategoryName,
            color: Colors.deepPurple,
            isText: true,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool isText = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: isText ? 12 : 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}

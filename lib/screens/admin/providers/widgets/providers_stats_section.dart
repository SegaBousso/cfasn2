import 'package:flutter/material.dart';

/// Section des statistiques des prestataires
class ProvidersStatsSection extends StatelessWidget {
  final int totalCount;
  final int activeCount;
  final int verifiedCount;
  final int availableCount;

  const ProvidersStatsSection({
    super.key,
    required this.totalCount,
    required this.activeCount,
    required this.verifiedCount,
    required this.availableCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.people,
            label: 'Total',
            value: totalCount.toString(),
            color: Colors.blue,
          ),
          _buildStatItem(
            icon: Icons.verified_user,
            label: 'Actifs',
            value: activeCount.toString(),
            color: Colors.green,
          ),
          _buildStatItem(
            icon: Icons.check_circle,
            label: 'Vérifiés',
            value: verifiedCount.toString(),
            color: Colors.orange,
          ),
          _buildStatItem(
            icon: Icons.schedule,
            label: 'Disponibles',
            value: availableCount.toString(),
            color: Colors.purple,
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
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}

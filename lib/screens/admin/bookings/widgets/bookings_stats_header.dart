import 'package:flutter/material.dart';

/// Statistics header widget for bookings management
class BookingsStatsHeader extends StatelessWidget {
  final Map<String, dynamic> stats;

  const BookingsStatsHeader({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    if (stats.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red[700]!, Colors.red[500]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildStatItem(
            'Total',
            stats['total']?.toString() ?? '0',
            Icons.bookmark,
          ),
          _buildStatItem(
            'Ce mois',
            stats['thisMonth']?.toString() ?? '0',
            Icons.calendar_today,
          ),
          _buildStatItem(
            'Revenue',
            '${(stats['totalRevenue'] ?? 0).toStringAsFixed(0)}€',
            Icons.euro,
          ),
          _buildStatItem(
            'Croissance',
            '${(stats['monthlyGrowth'] ?? 0).toStringAsFixed(1)}%',
            Icons.trending_up,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

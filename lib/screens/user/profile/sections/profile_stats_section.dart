import 'package:flutter/material.dart';
import '../../../../models/models.dart';
import '../../../../utils/responsive_helper.dart';
import '../../../../widgets/overflow_safe_widgets.dart';
import '../widgets/profile_widgets.dart';
import '../services/profile_service.dart';

/// Section des statistiques utilisateur
class ProfileStatsSection extends StatelessWidget {
  final UserModel user;

  const ProfileStatsSection({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final userStats = ProfileService.getUserStats(user);

    return AdaptiveContainer(
      padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdaptiveText(
            'Mes statistiques',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: ResponsiveHelper.getSpacing(context)),
          _buildStatsGrid(context, userStats),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, Map<String, dynamic> userStats) {
    return ResponsiveBuilder(
      builder: (context, dimensions) {
        final crossAxisCount = dimensions.isDesktop
            ? 6
            : dimensions.isTablet
            ? 3
            : 2;
        final aspectRatio = dimensions.isDesktop
            ? 1.4
            : dimensions.isTablet
            ? 1.3
            : 1.6;

        return GridView.count(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: ResponsiveHelper.getSpacing(context) * 0.75,
          mainAxisSpacing: ResponsiveHelper.getSpacing(context) * 0.75,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: aspectRatio,
          children: [
            StatCard(
              icon: Icons.book_online,
              label: 'Réservations',
              value: '${userStats['totalBookings']}',
              color: Colors.blue,
            ),
            StatCard(
              icon: Icons.check_circle,
              label: 'Terminées',
              value: '${userStats['completedBookings']}',
              color: Colors.green,
            ),
            StatCard(
              icon: Icons.favorite,
              label: 'Favoris',
              value: '${userStats['favoriteServices']}',
              color: Colors.red,
            ),
            StatCard(
              icon: Icons.euro,
              label: 'Dépensé',
              value: '${userStats['totalSpent'].toStringAsFixed(0)}€',
              color: Colors.purple,
            ),
            StatCard(
              icon: Icons.star,
              label: 'Avis donnés',
              value: '${userStats['reviewsGiven']}',
              color: Colors.amber,
            ),
            StatCard(
              icon: Icons.calendar_today,
              label: 'Membre depuis',
              value: '${ProfileService.getDaysSinceRegistration(user)}j',
              color: Colors.orange,
            ),
          ],
        );
      },
    );
  }
}

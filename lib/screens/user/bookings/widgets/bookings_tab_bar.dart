import 'package:flutter/material.dart';
import '../logic/my_bookings_data.dart';
import '../../../../models/models.dart';

/// Custom AppBar with tab bar for My Bookings screen
class BookingsTabBar extends StatelessWidget implements PreferredSizeWidget {
  final MyBookingsData data;
  final VoidCallback? onRefresh;
  final Function(int)? onTabChanged;

  const BookingsTabBar({
    super.key,
    required this.data,
    this.onRefresh,
    this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Mes Réservations'),
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Colors.white,
      actions: [
        if (onRefresh != null)
          IconButton(
            icon: data.isRefreshing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.refresh),
            onPressed: data.isRefreshing ? null : onRefresh,
            tooltip: 'Actualiser',
          ),
      ],
      bottom: TabBar(
        controller: data.tabController,
        onTap: onTabChanged,
        isScrollable: true,
        tabs: [
          _buildTab('Confirmées', BookingStatus.confirmed),
          _buildTab('En attente', BookingStatus.pending),
          _buildTab('En cours', BookingStatus.inProgress),
          _buildTab('Terminées', BookingStatus.completed),
          _buildTab('Annulées', BookingStatus.cancelled),
        ],
        indicatorColor: Colors.white,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
      ),
    );
  }

  Widget _buildTab(String title, BookingStatus status) {
    final count = data.getCountForStatus(status);

    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title),
          if (count > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Size get preferredSize =>
      const Size.fromHeight(kToolbarHeight + kTextTabBarHeight);
}

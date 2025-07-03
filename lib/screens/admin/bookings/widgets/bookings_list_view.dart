import 'package:flutter/material.dart';
import '../../../../models/models.dart';
import '../widgets/booking_card.dart';

/// Bookings list widget for bookings management
class BookingsListView extends StatelessWidget {
  final List<BookingModel> bookings;
  final Set<String> selectedBookingIds;
  final bool isLoading;
  final bool isLoadingMore;
  final ScrollController scrollController;
  final VoidCallback onRefresh;
  final Function(String) onBookingTap;
  final Function(String) onBookingSelectionToggle;
  final Function(String, BookingStatus) onStatusChanged;

  const BookingsListView({
    super.key,
    required this.bookings,
    required this.selectedBookingIds,
    required this.isLoading,
    required this.isLoadingMore,
    required this.scrollController,
    required this.onRefresh,
    required this.onBookingTap,
    required this.onBookingSelectionToggle,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (bookings.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView.builder(
        controller: scrollController,
        itemCount: bookings.length + (isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= bookings.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final booking = bookings[index];
          final isSelected = selectedBookingIds.contains(booking.id);

          return BookingCard(
            booking: booking,
            isSelected: isSelected,
            onTap: () => onBookingTap(booking.id),
            onSelect: () => onBookingSelectionToggle(booking.id),
            onStatusChanged: (newStatus) =>
                onStatusChanged(booking.id, newStatus),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bookmark_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Aucune réservation trouvée',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Essayez de modifier vos filtres de recherche',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'booking_card.dart';
import 'empty_bookings_state.dart';
import '../../../../models/models.dart';

/// List view for bookings with pull-to-refresh and empty/error states
class BookingListView extends StatelessWidget {
  final List<BookingModel> bookings;
  final bool isRefreshing;
  final Future<void> Function() onRefresh;
  final Function(BookingModel) onBookingTap;
  final Function(BookingModel) onBookingAction;
  final String emptyStateTitle;
  final String emptyStateMessage;
  final IconData emptyStateIcon;
  final String? error;
  final VoidCallback? onRetry;

  const BookingListView({
    super.key,
    required this.bookings,
    this.isRefreshing = false,
    required this.onRefresh,
    required this.onBookingTap,
    required this.onBookingAction,
    required this.emptyStateTitle,
    required this.emptyStateMessage,
    required this.emptyStateIcon,
    this.error,
    this.onRetry,
  });

  /// Constructor for error state
  const BookingListView.error({
    super.key,
    required String this.error,
    required VoidCallback this.onRetry,
  }) : bookings = const [],
       isRefreshing = false,
       onRefresh = _defaultRefresh,
       onBookingTap = _defaultBookingTap,
       onBookingAction = _defaultBookingAction,
       emptyStateTitle = 'Erreur de chargement',
       emptyStateMessage = 'Impossible de charger vos réservations.',
       emptyStateIcon = Icons.error_outline;

  static Future<void> _defaultRefresh() async {}
  static void _defaultBookingTap(BookingModel booking) {}
  static void _defaultBookingAction(BookingModel booking) {}

  @override
  Widget build(BuildContext context) {
    // Show error state
    if (error != null) {
      return EmptyBookingsState.error(onRetry: onRetry);
    }

    // Show empty state
    if (bookings.isEmpty) {
      return EmptyBookingsState(
        title: emptyStateTitle,
        message: emptyStateMessage,
        icon: emptyStateIcon,
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];

          return BookingCard(
            booking: booking,
            onTap: () => onBookingTap(booking),
            onActionPressed: () => onBookingAction(booking),
          );
        },
      ),
    );
  }
}

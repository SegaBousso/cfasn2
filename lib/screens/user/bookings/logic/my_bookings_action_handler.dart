import 'package:flutter/material.dart';
import 'my_bookings_data.dart';
import 'my_bookings_data_handler.dart';
import 'my_bookings_events.dart';
import '../../../../utils/event_bus.dart';
import '../../../../models/models.dart';

/// Handles user actions for My Bookings screen
class MyBookingsActionHandler {
  final MyBookingsData _data;
  final MyBookingsDataHandler _dataHandler;

  MyBookingsActionHandler(this._data, this._dataHandler);

  /// Handle booking details view
  Future<void> handleViewBookingDetails(
    BuildContext context,
    BookingModel booking,
  ) async {
    EventBus.instance.emit(BookingDetailsRequestedEvent(booking));

    // TODO: Navigate to booking details screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Détails de la réservation: ${booking.service.name}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Handle booking cancellation with confirmation
  Future<void> handleCancelBooking(
    BuildContext context,
    BookingModel booking,
  ) async {
    EventBus.instance.emit(BookingCancellationRequestedEvent(booking));

    final confirmed = await _showCancellationDialog(context, booking);

    if (confirmed == true) {
      await _performBookingCancellation(context, booking);
    }
  }

  /// Show cancellation confirmation dialog
  Future<bool?> _showCancellationDialog(
    BuildContext context,
    BookingModel booking,
  ) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Annuler la réservation'),
        content: Text(
          'Êtes-vous sûr de vouloir annuler "${booking.service.name}" ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Non'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Oui, annuler'),
          ),
        ],
      ),
    );
  }

  /// Perform the actual booking cancellation
  Future<void> _performBookingCancellation(
    BuildContext context,
    BookingModel booking,
  ) async {
    try {
      EventBus.instance.emit(BookingCancellationStartedEvent(booking.id));

      await _dataHandler.updateBookingStatus(
        booking.id,
        BookingStatus.cancelled,
      );

      EventBus.instance.emit(BookingCancelledEvent(booking.id));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Réservation annulée avec succès'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      EventBus.instance.emit(
        BookingCancellationFailedEvent(booking.id, e.toString()),
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'annulation: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  /// Handle refresh request
  Future<void> handleRefresh(BuildContext context) async {
    EventBus.instance.emit(RefreshRequestedEvent());
    await _dataHandler.refreshBookings(context);
  }

  /// Handle retry request
  Future<void> handleRetry(BuildContext context) async {
    EventBus.instance.emit(RetryRequestedEvent());
    await _dataHandler.loadBookings(context);
  }

  /// Handle review booking request
  Future<void> handleReviewBooking(
    BuildContext context,
    BookingModel booking,
  ) async {
    // TODO: Navigate to review screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Évaluer la réservation: ${booking.service.name}'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  /// Check if booking can be cancelled
  bool canCancelBooking(BookingModel booking) {
    return booking.status == BookingStatus.pending ||
        booking.status == BookingStatus.confirmed;
  }

  /// Get formatted date string
  String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} à ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  /// Get formatted amount string
  String formatAmount(double amount) {
    return '${amount.toStringAsFixed(2)} €';
  }
}

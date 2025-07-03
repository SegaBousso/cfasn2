import 'package:flutter/material.dart';
import '../admin_booking_manager.dart';
import 'bookings_management_data.dart';
import 'bookings_management_events.dart';
import '../../../../utils/event_bus.dart';
import '../../../../models/models.dart';

/// Handles status update operations for bookings management
class BookingsStatusHandler {
  final AdminBookingManager _bookingManager;
  final BookingsManagementData _data;

  BookingsStatusHandler(this._bookingManager, this._data);

  /// Update single booking status
  Future<void> updateBookingStatus(
    String bookingId,
    BookingStatus newStatus,
  ) async {
    try {
      EventBus.instance.emit(
        BookingStatusUpdateStartedEvent(bookingId, newStatus.name),
      );

      final success = await _bookingManager.updateBookingStatus(
        bookingId,
        newStatus,
      );

      if (success) {
        EventBus.instance.emit(
          BookingStatusUpdatedEvent(bookingId, newStatus.name),
        );
      } else {
        EventBus.instance.emit(
          BookingStatusUpdateFailedEvent('Failed to update status'),
        );
      }
    } catch (e) {
      EventBus.instance.emit(BookingStatusUpdateFailedEvent(e.toString()));
    }
  }

  /// Update multiple bookings status
  Future<void> bulkUpdateStatus(
    List<String> bookingIds,
    BookingStatus newStatus,
  ) async {
    try {
      EventBus.instance.emit(
        BulkStatusUpdateStartedEvent(bookingIds, newStatus.name),
      );

      final success = await _bookingManager.bulkUpdateStatus(
        bookingIds,
        newStatus,
      );

      if (success) {
        _data.clearSelection();
        EventBus.instance.emit(
          BulkStatusUpdatedEvent(bookingIds, newStatus.name),
        );
      } else {
        EventBus.instance.emit(
          BulkStatusUpdateFailedEvent('Failed to update statuses'),
        );
      }
    } catch (e) {
      EventBus.instance.emit(BulkStatusUpdateFailedEvent(e.toString()));
    }
  }

  /// Show confirmation dialog for bulk status update
  Future<bool> showBulkUpdateConfirmation(
    BuildContext context,
    int count,
    BookingStatus newStatus,
  ) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirmation'),
            content: Text(
              'Modifier le statut de $count réservation(s) vers "${newStatus.label}" ?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red[700]),
                child: const Text('Confirmer'),
              ),
            ],
          ),
        ) ??
        false;
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'my_bookings_data.dart';
import 'my_bookings_events.dart';
import '../../../../utils/event_bus.dart';
import '../../../../services/booking_service.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../models/models.dart';

/// Handles data operations for My Bookings screen
class MyBookingsDataHandler {
  final MyBookingsData _data;
  final BookingService _bookingService = BookingService();

  MyBookingsDataHandler(this._data);

  /// Load user bookings
  Future<void> loadBookings(BuildContext context) async {
    try {
      _data.setLoading(true);
      EventBus.instance.emit(LoadingStateChangedEvent(true));

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user;

      if (user == null) {
        throw Exception('Utilisateur non connecté');
      }

      final bookings = await _bookingService.getUserBookings(user.uid);

      _data.updateBookings(bookings);
      EventBus.instance.emit(BookingsLoadedEvent(bookings));
      EventBus.instance.emit(LoadingStateChangedEvent(false));
    } catch (e) {
      final error = 'Erreur lors du chargement: $e';
      _data.setError(error);
      EventBus.instance.emit(BookingsLoadFailedEvent(error));
      EventBus.instance.emit(ErrorStateChangedEvent(error));
    }
  }

  /// Refresh bookings data
  Future<void> refreshBookings(BuildContext context) async {
    try {
      _data.setRefreshing(true);
      EventBus.instance.emit(BookingsRefreshStartedEvent());

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user;

      if (user == null) {
        throw Exception('Utilisateur non connecté');
      }

      final bookings = await _bookingService.getUserBookings(user.uid);

      _data.updateBookings(bookings);
      _data.setRefreshing(false);

      EventBus.instance.emit(BookingsLoadedEvent(bookings));
      EventBus.instance.emit(BookingsRefreshCompletedEvent());
    } catch (e) {
      final error = 'Erreur lors du rafraîchissement: $e';
      _data.setError(error);
      _data.setRefreshing(false);

      EventBus.instance.emit(BookingsLoadFailedEvent(error));
      EventBus.instance.emit(ErrorStateChangedEvent(error));
    }
  }

  /// Update booking status
  Future<void> updateBookingStatus(
    String bookingId,
    BookingStatus newStatus,
  ) async {
    try {
      await _bookingService.updateBookingStatus(bookingId, newStatus);

      // Find and update the booking in local data
      final bookingIndex = _data.allBookings.indexWhere(
        (b) => b.id == bookingId,
      );
      if (bookingIndex != -1) {
        final updatedBooking = _data.allBookings[bookingIndex].copyWith(
          status: newStatus,
          updatedAt: DateTime.now(),
        );
        _data.updateBooking(updatedBooking);
      }
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour: $e');
    }
  }

  /// Get bookings for specific status
  List<BookingModel> getBookingsForStatus(BookingStatus status) {
    return _data.getBookingsForStatus(status);
  }

  /// Get count for specific status
  int getCountForStatus(BookingStatus status) {
    return _data.getCountForStatus(status);
  }

  /// Check if data is available
  bool get hasData => _data.hasData;

  /// Check if currently loading
  bool get isLoading => _data.isLoading;

  /// Check if currently refreshing
  bool get isRefreshing => _data.isRefreshing;

  /// Get current error
  String? get error => _data.error;

  /// Get total bookings count
  int get totalBookings => _data.totalBookings;
}

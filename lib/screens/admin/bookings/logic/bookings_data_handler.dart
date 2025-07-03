import 'dart:async';
import '../admin_booking_manager.dart';
import 'bookings_management_data.dart';
import 'bookings_management_events.dart';
import '../../../../utils/event_bus.dart';

/// Handles data loading operations for bookings management
class BookingsDataHandler {
  final AdminBookingManager _bookingManager;
  final BookingsManagementData _data;

  BookingsDataHandler(this._bookingManager, this._data);

  /// Load initial bookings data
  Future<void> loadBookings() async {
    try {
      EventBus.instance.emit(BookingsLoadStartedEvent());

      final bookings = await _bookingManager.getAllBookings(
        limit: BookingsManagementData.pageSize,
        statusFilter: _data.selectedStatus,
        searchQuery: _data.searchQuery,
        startDate: _data.selectedDateRange?.start,
        endDate: _data.selectedDateRange?.end,
      );

      _data.bookings = bookings;
      _data.hasMoreData = bookings.length == BookingsManagementData.pageSize;
      _data.applyFilters();

      EventBus.instance.emit(BookingsLoadedEvent(bookings, _data.hasMoreData));
    } catch (e) {
      EventBus.instance.emit(BookingsLoadFailedEvent(e.toString()));
    }
  }

  /// Load more bookings for pagination
  Future<void> loadMoreBookings() async {
    if (_data.bookings.isEmpty || !_data.hasMoreData) return;

    try {
      final moreBookings = await _bookingManager.getAllBookings(
        limit: BookingsManagementData.pageSize,
        statusFilter: _data.selectedStatus,
        searchQuery: _data.searchQuery,
        startDate: _data.selectedDateRange?.start,
        endDate: _data.selectedDateRange?.end,
      );

      _data.addMoreBookings(moreBookings);
      _data.hasMoreData =
          moreBookings.length == BookingsManagementData.pageSize;
      _data.applyFilters();

      EventBus.instance.emit(
        MoreBookingsLoadedEvent(moreBookings, _data.hasMoreData),
      );
    } catch (e) {
      EventBus.instance.emit(BookingsLoadFailedEvent(e.toString()));
    }
  }

  /// Load statistics data
  Future<void> loadStats() async {
    try {
      final stats = await _bookingManager.getBookingStats();
      _data.stats = stats;

      EventBus.instance.emit(StatsLoadedEvent(stats));
    } catch (e) {
      EventBus.instance.emit(StatsLoadFailedEvent(e.toString()));
    }
  }

  /// Refresh all data
  Future<void> refreshData() async {
    _data.clearSelection();
    await Future.wait([loadBookings(), loadStats()]);
  }
}

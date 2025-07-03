import 'package:flutter/material.dart';
import 'my_bookings_data.dart';
import 'my_bookings_events.dart';
import '../../../../utils/event_bus.dart';
import '../../../../models/models.dart';

/// Handles tab navigation and filtering for My Bookings screen
class MyBookingsFilterHandler {
  final MyBookingsData _data;

  MyBookingsFilterHandler(this._data);

  /// Handle tab change
  void handleTabChanged(int index) {
    _data.selectedTabIndex = index;

    // Map tab index to booking status
    final status = _getStatusForTabIndex(index);

    EventBus.instance.emit(TabChangedEvent(index, status));
  }

  /// Get booking status for tab index
  BookingStatus _getStatusForTabIndex(int index) {
    switch (index) {
      case 0:
        return BookingStatus.confirmed;
      case 1:
        return BookingStatus.pending;
      case 2:
        return BookingStatus.inProgress;
      case 3:
        return BookingStatus.completed;
      case 4:
        return BookingStatus.cancelled;
      default:
        return BookingStatus.confirmed;
    }
  }

  /// Get tab index for booking status
  int getTabIndexForStatus(BookingStatus status) {
    switch (status) {
      case BookingStatus.confirmed:
        return 0;
      case BookingStatus.pending:
        return 1;
      case BookingStatus.inProgress:
        return 2;
      case BookingStatus.completed:
        return 3;
      case BookingStatus.cancelled:
        return 4;
      case BookingStatus.refunded:
        return 4; // Group with cancelled
    }
  }

  /// Get current selected status
  BookingStatus get currentStatus =>
      _getStatusForTabIndex(_data.selectedTabIndex);

  /// Get current selected tab index
  int get currentTabIndex => _data.selectedTabIndex;

  /// Get tab controller
  TabController get tabController => _data.tabController;

  /// Get bookings for current tab
  List<BookingModel> getCurrentBookings() {
    return _data.getBookingsForStatus(currentStatus);
  }

  /// Get count for current tab
  int getCurrentCount() {
    return _data.getCountForStatus(currentStatus);
  }

  /// Get tab title with count
  String getTabTitleWithCount(int tabIndex) {
    final status = _getStatusForTabIndex(tabIndex);
    final count = _data.getCountForStatus(status);
    final title = _getTabTitle(tabIndex);

    return count > 0 ? '$title ($count)' : title;
  }

  /// Get tab title without count
  String _getTabTitle(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return 'Confirmées';
      case 1:
        return 'En attente';
      case 2:
        return 'En cours';
      case 3:
        return 'Terminées';
      case 4:
        return 'Annulées';
      default:
        return 'Inconnu';
    }
  }

  /// Get status icon
  IconData getStatusIcon(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return Icons.schedule;
      case BookingStatus.confirmed:
        return Icons.check_circle;
      case BookingStatus.inProgress:
        return Icons.play_circle;
      case BookingStatus.completed:
        return Icons.check_circle_outline;
      case BookingStatus.cancelled:
        return Icons.cancel;
      case BookingStatus.refunded:
        return Icons.money_off;
    }
  }

  /// Get empty message for status
  String getEmptyMessage(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return 'Aucune réservation en attente';
      case BookingStatus.confirmed:
        return 'Aucune réservation confirmée';
      case BookingStatus.inProgress:
        return 'Aucune réservation en cours';
      case BookingStatus.completed:
        return 'Aucune réservation terminée';
      case BookingStatus.cancelled:
        return 'Aucune réservation annulée';
      case BookingStatus.refunded:
        return 'Aucune réservation remboursée';
    }
  }
}

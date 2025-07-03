import 'bookings_management_data.dart';
import 'bookings_management_events.dart';
import '../../../../utils/event_bus.dart';

/// Handles selection operations for bookings management
class BookingsSelectionHandler {
  final BookingsManagementData _data;

  BookingsSelectionHandler(this._data);

  /// Handle booking selection toggle
  void handleBookingSelectionToggle(String bookingId) {
    if (_data.isSelected(bookingId)) {
      _data.removeSelection(bookingId);
      EventBus.instance.emit(BookingDeselectedEvent(bookingId));
    } else {
      _data.addSelection(bookingId);
      EventBus.instance.emit(BookingSelectedEvent(bookingId));
    }
  }

  /// Handle clear all selections
  void handleClearSelection() {
    _data.clearSelection();
    EventBus.instance.emit(SelectionClearedEvent());
  }

  /// Check if any bookings are selected
  bool hasSelection() {
    return _data.selectedBookingIds.isNotEmpty;
  }

  /// Get selected booking IDs count
  int getSelectionCount() {
    return _data.selectedBookingIds.length;
  }

  /// Get list of selected booking IDs
  List<String> getSelectedIds() {
    return _data.selectedBookingIds.toList();
  }
}

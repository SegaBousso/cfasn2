import '../../../../models/models.dart';

/// Base class for all My Bookings events
abstract class MyBookingsEvent {}

// =============================================================================
// DATA EVENTS
// =============================================================================

/// Event emitted when bookings are loaded successfully
class BookingsLoadedEvent extends MyBookingsEvent {
  final List<BookingModel> bookings;

  BookingsLoadedEvent(this.bookings);
}

/// Event emitted when bookings loading fails
class BookingsLoadFailedEvent extends MyBookingsEvent {
  final String error;

  BookingsLoadFailedEvent(this.error);
}

/// Event emitted when bookings refresh starts
class BookingsRefreshStartedEvent extends MyBookingsEvent {}

/// Event emitted when bookings refresh completes
class BookingsRefreshCompletedEvent extends MyBookingsEvent {}

// =============================================================================
// TAB EVENTS
// =============================================================================

/// Event emitted when tab is changed
class TabChangedEvent extends MyBookingsEvent {
  final int tabIndex;
  final BookingStatus status;

  TabChangedEvent(this.tabIndex, this.status);
}

// =============================================================================
// ACTION EVENTS
// =============================================================================

/// Event emitted when booking details are requested
class BookingDetailsRequestedEvent extends MyBookingsEvent {
  final BookingModel booking;

  BookingDetailsRequestedEvent(this.booking);
}

/// Event emitted when booking cancellation is requested
class BookingCancellationRequestedEvent extends MyBookingsEvent {
  final BookingModel booking;

  BookingCancellationRequestedEvent(this.booking);
}

/// Event emitted when booking cancellation starts
class BookingCancellationStartedEvent extends MyBookingsEvent {
  final String bookingId;

  BookingCancellationStartedEvent(this.bookingId);
}

/// Event emitted when booking is cancelled successfully
class BookingCancelledEvent extends MyBookingsEvent {
  final String bookingId;

  BookingCancelledEvent(this.bookingId);
}

/// Event emitted when booking cancellation fails
class BookingCancellationFailedEvent extends MyBookingsEvent {
  final String bookingId;
  final String error;

  BookingCancellationFailedEvent(this.bookingId, this.error);
}

// =============================================================================
// UI EVENTS
// =============================================================================

/// Event emitted when refresh is requested by user
class RefreshRequestedEvent extends MyBookingsEvent {}

/// Event emitted when error retry is requested
class RetryRequestedEvent extends MyBookingsEvent {}

/// Event emitted when loading state changes
class LoadingStateChangedEvent extends MyBookingsEvent {
  final bool isLoading;

  LoadingStateChangedEvent(this.isLoading);
}

/// Event emitted when error state changes
class ErrorStateChangedEvent extends MyBookingsEvent {
  final String? error;

  ErrorStateChangedEvent(this.error);
}

import 'package:flutter/material.dart';

/// Typed events for the bookings management screen
abstract class BookingsManagementEvent {}

// Data loading events
class BookingsLoadStartedEvent extends BookingsManagementEvent {}

class BookingsLoadedEvent extends BookingsManagementEvent {
  final List<dynamic> bookings;
  final bool hasMoreData;

  BookingsLoadedEvent(this.bookings, this.hasMoreData);
}

class BookingsLoadFailedEvent extends BookingsManagementEvent {
  final String error;

  BookingsLoadFailedEvent(this.error);
}

class MoreBookingsLoadedEvent extends BookingsManagementEvent {
  final List<dynamic> bookings;
  final bool hasMoreData;

  MoreBookingsLoadedEvent(this.bookings, this.hasMoreData);
}

// Stats events
class StatsLoadedEvent extends BookingsManagementEvent {
  final Map<String, dynamic> stats;

  StatsLoadedEvent(this.stats);
}

class StatsLoadFailedEvent extends BookingsManagementEvent {
  final String error;

  StatsLoadFailedEvent(this.error);
}

// Search events
class SearchQueryChangedEvent extends BookingsManagementEvent {
  final String query;

  SearchQueryChangedEvent(this.query);
}

// Filter events
class FilterStatusChangedEvent extends BookingsManagementEvent {
  final String? status;

  FilterStatusChangedEvent(this.status);
}

class FilterPaymentStatusChangedEvent extends BookingsManagementEvent {
  final String? paymentStatus;

  FilterPaymentStatusChangedEvent(this.paymentStatus);
}

class FilterDateRangeChangedEvent extends BookingsManagementEvent {
  final DateTimeRange? dateRange;

  FilterDateRangeChangedEvent(this.dateRange);
}

class FilterAmountRangeChangedEvent extends BookingsManagementEvent {
  final double? minAmount;
  final double? maxAmount;

  FilterAmountRangeChangedEvent(this.minAmount, this.maxAmount);
}

class FiltersAppliedEvent extends BookingsManagementEvent {}

class FiltersClearedEvent extends BookingsManagementEvent {}

// Selection events
class BookingSelectedEvent extends BookingsManagementEvent {
  final String bookingId;

  BookingSelectedEvent(this.bookingId);
}

class BookingDeselectedEvent extends BookingsManagementEvent {
  final String bookingId;

  BookingDeselectedEvent(this.bookingId);
}

class SelectionClearedEvent extends BookingsManagementEvent {}

// Status update events
class BookingStatusUpdateStartedEvent extends BookingsManagementEvent {
  final String bookingId;
  final String newStatus;

  BookingStatusUpdateStartedEvent(this.bookingId, this.newStatus);
}

class BookingStatusUpdatedEvent extends BookingsManagementEvent {
  final String bookingId;
  final String newStatus;

  BookingStatusUpdatedEvent(this.bookingId, this.newStatus);
}

class BookingStatusUpdateFailedEvent extends BookingsManagementEvent {
  final String error;

  BookingStatusUpdateFailedEvent(this.error);
}

// Bulk operations events
class BulkStatusUpdateStartedEvent extends BookingsManagementEvent {
  final List<String> bookingIds;
  final String newStatus;

  BulkStatusUpdateStartedEvent(this.bookingIds, this.newStatus);
}

class BulkStatusUpdatedEvent extends BookingsManagementEvent {
  final List<String> bookingIds;
  final String newStatus;

  BulkStatusUpdatedEvent(this.bookingIds, this.newStatus);
}

class BulkStatusUpdateFailedEvent extends BookingsManagementEvent {
  final String error;

  BulkStatusUpdateFailedEvent(this.error);
}

// UI events
class RefreshRequestedEvent extends BookingsManagementEvent {}

class LoadMoreRequestedEvent extends BookingsManagementEvent {}

class ShowSnackbarEvent extends BookingsManagementEvent {
  final String message;
  final bool isError;

  ShowSnackbarEvent(this.message, {this.isError = false});
}

class NavigateToDetailsEvent extends BookingsManagementEvent {
  final String bookingId;

  NavigateToDetailsEvent(this.bookingId);
}

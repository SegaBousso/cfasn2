import 'dart:async';
import 'package:flutter/material.dart';
import '../admin_booking_manager.dart';
import 'bookings_management_data.dart';
import 'bookings_management_events.dart';
import 'bookings_data_handler.dart';
import 'bookings_filter_handler.dart';
import 'bookings_selection_handler.dart';
import 'bookings_status_handler.dart';
import '../../../../utils/event_bus.dart';
import '../../../../models/models.dart';

/// Main event handler for the bookings management screen
class BookingsManagementEventHandler {
  final BuildContext context;
  final BookingsManagementData data;
  final VoidCallback? onStateChanged;

  late final BookingsDataHandler dataHandler;
  late final BookingsFilterHandler filterHandler;
  late final BookingsSelectionHandler selectionHandler;
  late final BookingsStatusHandler statusHandler;

  late final StreamSubscription _eventSubscription;

  BookingsManagementEventHandler({
    required this.context,
    required this.data,
    this.onStateChanged,
  }) {
    final bookingManager = AdminBookingManager();

    dataHandler = BookingsDataHandler(bookingManager, data);
    filterHandler = BookingsFilterHandler(data);
    selectionHandler = BookingsSelectionHandler(data);
    statusHandler = BookingsStatusHandler(bookingManager, data);

    _setupEventListeners();
  }

  void _setupEventListeners() {
    _eventSubscription = EventBus.instance.on<BookingsManagementEvent>().listen(
      (event) {
        _handleEvent(event);
      },
    );
  }

  void _handleEvent(BookingsManagementEvent event) {
    switch (event.runtimeType) {
      // Data loading events
      case BookingsLoadStartedEvent:
        data.isLoading = true;
        onStateChanged?.call();
        break;

      case BookingsLoadedEvent:
        final e = event as BookingsLoadedEvent;
        data.isLoading = false;
        data.hasMoreData = e.hasMoreData;
        onStateChanged?.call();
        break;

      case BookingsLoadFailedEvent:
        final e = event as BookingsLoadFailedEvent;
        data.isLoading = false;
        _showSnackbar(e.error, true);
        onStateChanged?.call();
        break;

      case MoreBookingsLoadedEvent:
        final e = event as MoreBookingsLoadedEvent;
        data.isLoadingMore = false;
        data.hasMoreData = e.hasMoreData;
        onStateChanged?.call();
        break;

      // Search and filter events
      case SearchQueryChangedEvent:
        dataHandler.loadBookings();
        break;

      case FilterStatusChangedEvent:
        dataHandler.loadBookings();
        break;

      case FilterPaymentStatusChangedEvent:
        filterHandler.applyFilters();
        onStateChanged?.call();
        break;

      case FilterDateRangeChangedEvent:
        dataHandler.loadBookings();
        break;

      case FilterAmountRangeChangedEvent:
        filterHandler.applyFilters();
        onStateChanged?.call();
        break;

      case FiltersClearedEvent:
        dataHandler.loadBookings();
        break;

      // Selection events
      case BookingSelectedEvent:
      case BookingDeselectedEvent:
      case SelectionClearedEvent:
        onStateChanged?.call();
        break;

      // Status update events
      case BookingStatusUpdatedEvent:
        dataHandler.refreshData();
        _showSnackbar('Statut mis à jour avec succès');
        break;

      case BookingStatusUpdateFailedEvent:
        final e = event as BookingStatusUpdateFailedEvent;
        _showSnackbar(e.error, true);
        break;

      case BulkStatusUpdatedEvent:
        dataHandler.refreshData();
        _showSnackbar('Statuts mis à jour avec succès');
        break;

      case BulkStatusUpdateFailedEvent:
        final e = event as BulkStatusUpdateFailedEvent;
        _showSnackbar(e.error, true);
        break;

      // Navigation events
      case NavigateToDetailsEvent:
        final e = event as NavigateToDetailsEvent;
        _navigateToDetails(e.bookingId);
        break;

      // Refresh events
      case RefreshRequestedEvent:
        dataHandler.refreshData();
        break;

      case LoadMoreRequestedEvent:
        if (!data.isLoadingMore && data.hasMoreData) {
          data.isLoadingMore = true;
          onStateChanged?.call();
          dataHandler.loadMoreBookings();
        }
        break;

      // Snackbar events
      case ShowSnackbarEvent:
        final e = event as ShowSnackbarEvent;
        _showSnackbar(e.message, e.isError);
        break;
    }
  }

  // Public methods for UI interactions
  void handleSearchChanged(String query) {
    filterHandler.handleSearchChanged(query);
  }

  void handleBookingSelectionToggle(String bookingId) {
    selectionHandler.handleBookingSelectionToggle(bookingId);
  }

  void handleRefresh() {
    EventBus.instance.emit(RefreshRequestedEvent());
  }

  void handleLoadMore() {
    EventBus.instance.emit(LoadMoreRequestedEvent());
  }

  void handleBookingTap(String bookingId) {
    EventBus.instance.emit(NavigateToDetailsEvent(bookingId));
  }

  Future<void> handleStatusUpdate(
    String bookingId,
    BookingStatus newStatus,
  ) async {
    await statusHandler.updateBookingStatus(bookingId, newStatus);
  }

  Future<void> handleBulkStatusUpdate(BookingStatus newStatus) async {
    if (!selectionHandler.hasSelection()) return;

    final confirmed = await statusHandler.showBulkUpdateConfirmation(
      context,
      selectionHandler.getSelectionCount(),
      newStatus,
    );

    if (confirmed) {
      await statusHandler.bulkUpdateStatus(
        selectionHandler.getSelectedIds(),
        newStatus,
      );
    }
  }

  // Filter handlers
  void handleStatusFilter(BookingStatus? status) {
    filterHandler.handleStatusFilterChanged(status);
  }

  void handlePaymentStatusFilter(PaymentStatus? paymentStatus) {
    filterHandler.handlePaymentStatusFilterChanged(paymentStatus);
  }

  void handleDateRangeFilter(DateTimeRange? dateRange) {
    filterHandler.handleDateRangeFilterChanged(dateRange);
  }

  void handleAmountRangeFilter(double? minAmount, double? maxAmount) {
    filterHandler.handleAmountRangeFilterChanged(minAmount, maxAmount);
  }

  void handleClearFilters() {
    filterHandler.clearFilters();
  }

  // Initialize data loading
  Future<void> initialize() async {
    await dataHandler.loadBookings();
    await dataHandler.loadStats();
  }

  void _showSnackbar(String message, [bool isError = false]) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : null,
      ),
    );
  }

  void _navigateToDetails(String bookingId) {
    Navigator.pushNamed(
      context,
      '/admin/bookings/details',
      arguments: bookingId,
    );
  }

  void dispose() {
    _eventSubscription.cancel();
    filterHandler.dispose();
  }
}

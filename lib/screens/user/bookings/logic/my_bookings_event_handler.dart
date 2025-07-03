import 'dart:async';
import 'package:flutter/material.dart';
import 'my_bookings_data.dart';
import 'my_bookings_data_handler.dart';
import 'my_bookings_filter_handler.dart';
import 'my_bookings_action_handler.dart';
import 'my_bookings_events.dart';
import '../../../../utils/event_bus.dart';
import '../../../../models/models.dart';

/// Main event handler for My Bookings screen
class MyBookingsEventHandler {
  final BuildContext context;
  final MyBookingsData _data;
  final VoidCallback onStateChanged;

  late final MyBookingsDataHandler _dataHandler;
  late final MyBookingsFilterHandler _filterHandler;
  late final MyBookingsActionHandler _actionHandler;

  StreamSubscription<MyBookingsEvent>? _eventSubscription;

  MyBookingsEventHandler({
    required this.context,
    required MyBookingsData data,
    required this.onStateChanged,
  }) : _data = data {
    _dataHandler = MyBookingsDataHandler(_data);
    _filterHandler = MyBookingsFilterHandler(_data);
    _actionHandler = MyBookingsActionHandler(_data, _dataHandler);
  }

  /// Initialize event listeners
  void initialize() {
    _setupEventListeners();
    _loadInitialData();
  }

  /// Setup EventBus listeners
  void _setupEventListeners() {
    _eventSubscription = EventBus.instance.on<MyBookingsEvent>().listen((
      event,
    ) {
      _handleEvent(event);
    });
  }

  /// Handle incoming events
  void _handleEvent(MyBookingsEvent event) {
    switch (event.runtimeType) {
      case BookingsLoadedEvent:
        final e = event as BookingsLoadedEvent;
        _data.updateBookings(e.bookings);
        _data.isLoading = false;
        onStateChanged();
        break;

      case BookingsLoadFailedEvent:
        final e = event as BookingsLoadFailedEvent;
        _data.error = e.error;
        _data.isLoading = false;
        onStateChanged();
        break;

      case LoadingStateChangedEvent:
        final e = event as LoadingStateChangedEvent;
        _data.isLoading = e.isLoading;
        onStateChanged();
        break;

      case ErrorStateChangedEvent:
        final e = event as ErrorStateChangedEvent;
        _data.error = e.error;
        onStateChanged();
        break;

      case TabChangedEvent:
        final e = event as TabChangedEvent;
        _data.selectedTabIndex = e.tabIndex;
        onStateChanged();
        break;

      case BookingCancelledEvent:
        // Refresh data after cancellation
        handleRefresh();
        break;

      case BookingsRefreshCompletedEvent:
        _data.isRefreshing = false;
        onStateChanged();
        break;

      default:
        // Other events don't require state updates
        break;
    }
  }

  /// Load initial data
  Future<void> _loadInitialData() async {
    await _dataHandler.loadBookings(context);
  }

  // =============================================================================
  // PUBLIC INTERFACE - Handlers for UI events
  // =============================================================================

  /// Handle tab change
  void handleTabChanged(int index) {
    _filterHandler.handleTabChanged(index);
  }

  /// Handle booking tap
  Future<void> handleBookingTap(BookingModel booking) async {
    await _actionHandler.handleViewBookingDetails(context, booking);
  }

  /// Handle booking action (cancel, review, etc.)
  Future<void> handleBookingAction(BookingModel booking) async {
    switch (booking.status) {
      case BookingStatus.pending:
      case BookingStatus.confirmed:
        await _actionHandler.handleCancelBooking(context, booking);
        break;
      case BookingStatus.completed:
        await _actionHandler.handleReviewBooking(context, booking);
        break;
      default:
        await _actionHandler.handleViewBookingDetails(context, booking);
        break;
    }
  }

  /// Handle booking cancellation
  Future<void> handleBookingCancellation(BookingModel booking) async {
    await _actionHandler.handleCancelBooking(context, booking);
  }

  /// Handle refresh
  Future<void> handleRefresh() async {
    await _actionHandler.handleRefresh(context);
  }

  /// Handle retry
  Future<void> handleRetry() async {
    await _actionHandler.handleRetry(context);
  }

  // =============================================================================
  // GETTERS - Data access for UI
  // =============================================================================

  /// Get all bookings
  List<BookingModel> get allBookings => _data.allBookings;

  /// Get bookings for specific status
  List<BookingModel> getBookingsForStatus(BookingStatus status) {
    return _dataHandler.getBookingsForStatus(status);
  }

  /// Get current tab bookings
  List<BookingModel> get currentTabBookings =>
      _filterHandler.getCurrentBookings();

  /// Get loading state
  bool get isLoading => _dataHandler.isLoading;

  /// Get refreshing state
  bool get isRefreshing => _dataHandler.isRefreshing;

  /// Get error state
  String? get error => _dataHandler.error;

  /// Get data availability
  bool get hasData => _dataHandler.hasData;

  /// Check if data is ready
  bool get isReady => _data.isReady;

  /// Get tab controller
  TabController get tabController => _filterHandler.tabController;

  /// Get current tab index
  int get currentTabIndex => _filterHandler.currentTabIndex;

  /// Get tab title with count
  String getTabTitleWithCount(int tabIndex) {
    return _filterHandler.getTabTitleWithCount(tabIndex);
  }

  /// Get status icon
  IconData getStatusIcon(BookingStatus status) {
    return _filterHandler.getStatusIcon(status);
  }

  /// Get empty message
  String getEmptyMessage(BookingStatus status) {
    return _filterHandler.getEmptyMessage(status);
  }

  /// Check if booking can be cancelled
  bool canCancelBooking(BookingModel booking) {
    return _actionHandler.canCancelBooking(booking);
  }

  /// Format date
  String formatDate(DateTime date) {
    return _actionHandler.formatDate(date);
  }

  /// Format amount
  String formatAmount(double amount) {
    return _actionHandler.formatAmount(amount);
  }

  /// Get total bookings count
  int get totalBookings => _dataHandler.totalBookings;

  /// Get count for status
  int getCountForStatus(BookingStatus status) {
    return _dataHandler.getCountForStatus(status);
  }

  /// Dispose resources
  void dispose() {
    _eventSubscription?.cancel();
    _data.dispose();
  }
}

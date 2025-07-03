import 'dart:async';
import 'package:flutter/material.dart';
import 'bookings_management_data.dart';
import 'bookings_management_events.dart';
import '../../../../utils/event_bus.dart';
import '../../../../models/models.dart';

/// Handles search and filtering operations for bookings management
class BookingsFilterHandler {
  final BookingsManagementData _data;
  Timer? _searchDebounce;

  BookingsFilterHandler(this._data);

  /// Handle search query changes with debouncing
  void handleSearchChanged(String query) {
    _data.searchQuery = query;
    _debounceSearch();
  }

  void _debounceSearch() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      EventBus.instance.emit(SearchQueryChangedEvent(_data.searchQuery));
    });
  }

  /// Handle status filter changes
  void handleStatusFilterChanged(BookingStatus? status) {
    _data.selectedStatus = status;
    EventBus.instance.emit(FilterStatusChangedEvent(status?.name));
  }

  /// Handle payment status filter changes
  void handlePaymentStatusFilterChanged(PaymentStatus? paymentStatus) {
    _data.selectedPaymentStatus = paymentStatus;
    EventBus.instance.emit(
      FilterPaymentStatusChangedEvent(paymentStatus?.name),
    );
  }

  /// Handle date range filter changes
  void handleDateRangeFilterChanged(DateTimeRange? dateRange) {
    _data.selectedDateRange = dateRange;
    EventBus.instance.emit(FilterDateRangeChangedEvent(dateRange));
  }

  /// Handle amount range filter changes
  void handleAmountRangeFilterChanged(double? minAmount, double? maxAmount) {
    _data.minAmount = minAmount;
    _data.maxAmount = maxAmount;
    EventBus.instance.emit(FilterAmountRangeChangedEvent(minAmount, maxAmount));
  }

  /// Apply all filters to the current data
  void applyFilters() {
    _data.applyFilters();
    EventBus.instance.emit(FiltersAppliedEvent());
  }

  /// Clear all filters
  void clearFilters() {
    _data.clearFilters();
    EventBus.instance.emit(FiltersClearedEvent());
  }

  /// Get current filter state
  Map<String, dynamic> get currentFilter => {
    'searchQuery': _data.searchQuery,
    'selectedStatus': _data.selectedStatus,
    'selectedPaymentStatus': _data.selectedPaymentStatus,
    'selectedDateRange': _data.selectedDateRange,
    'minAmount': _data.minAmount,
    'maxAmount': _data.maxAmount,
  };

  /// Check if any filters are active
  bool get hasActiveFilters =>
      _data.searchQuery.isNotEmpty ||
      _data.selectedStatus != null ||
      _data.selectedPaymentStatus != null ||
      _data.selectedDateRange != null ||
      _data.minAmount != null ||
      _data.maxAmount != null;

  /// Export filtered data
  Future<String> exportFilteredData({String format = 'csv'}) async {
    // Export logic would go here
    return 'exported_bookings.$format';
  }

  void dispose() {
    _searchDebounce?.cancel();
  }
}

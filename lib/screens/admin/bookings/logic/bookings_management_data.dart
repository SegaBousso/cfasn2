import 'package:flutter/material.dart';
import '../../../../models/models.dart';

/// Manages data and state for the bookings management screen
class BookingsManagementData {
  List<BookingModel> _bookings = [];
  List<BookingModel> _filteredBookings = [];
  Set<String> _selectedBookingIds = {};
  Map<String, dynamic> _stats = {};

  // Loading states
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;

  // Search and filters
  String _searchQuery = '';
  BookingStatus? _selectedStatus;
  PaymentStatus? _selectedPaymentStatus;
  DateTimeRange? _selectedDateRange;
  double? _minAmount;
  double? _maxAmount;

  // Pagination
  static const int pageSize = 20;

  // Getters
  List<BookingModel> get bookings => _bookings;
  List<BookingModel> get filteredBookings => _filteredBookings;
  Set<String> get selectedBookingIds => _selectedBookingIds;
  Map<String, dynamic> get stats => _stats;

  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMoreData => _hasMoreData;

  String get searchQuery => _searchQuery;
  BookingStatus? get selectedStatus => _selectedStatus;
  PaymentStatus? get selectedPaymentStatus => _selectedPaymentStatus;
  DateTimeRange? get selectedDateRange => _selectedDateRange;
  double? get minAmount => _minAmount;
  double? get maxAmount => _maxAmount;

  // Setters
  set bookings(List<BookingModel> value) => _bookings = value;
  set filteredBookings(List<BookingModel> value) => _filteredBookings = value;
  set stats(Map<String, dynamic> value) => _stats = value;

  set isLoading(bool value) => _isLoading = value;
  set isLoadingMore(bool value) => _isLoadingMore = value;
  set hasMoreData(bool value) => _hasMoreData = value;

  set searchQuery(String value) => _searchQuery = value;
  set selectedStatus(BookingStatus? value) => _selectedStatus = value;
  set selectedPaymentStatus(PaymentStatus? value) =>
      _selectedPaymentStatus = value;
  set selectedDateRange(DateTimeRange? value) => _selectedDateRange = value;
  set minAmount(double? value) => _minAmount = value;
  set maxAmount(double? value) => _maxAmount = value;

  // Selection management
  void addSelection(String bookingId) {
    _selectedBookingIds.add(bookingId);
  }

  void removeSelection(String bookingId) {
    _selectedBookingIds.remove(bookingId);
  }

  void clearSelection() {
    _selectedBookingIds.clear();
  }

  bool isSelected(String bookingId) {
    return _selectedBookingIds.contains(bookingId);
  }

  void toggleSelection(String bookingId) {
    if (isSelected(bookingId)) {
      removeSelection(bookingId);
    } else {
      addSelection(bookingId);
    }
  }

  // Data management
  void addMoreBookings(List<BookingModel> newBookings) {
    _bookings.addAll(newBookings);
  }

  void applyFilters() {
    List<BookingModel> filtered = List.from(_bookings);

    // Filter by amount
    if (_minAmount != null) {
      filtered = filtered
          .where((booking) => booking.totalAmount >= _minAmount!)
          .toList();
    }
    if (_maxAmount != null) {
      filtered = filtered
          .where((booking) => booking.totalAmount <= _maxAmount!)
          .toList();
    }

    // Filter by payment status
    if (_selectedPaymentStatus != null) {
      filtered = filtered
          .where((booking) => booking.paymentStatus == _selectedPaymentStatus)
          .toList();
    }

    _filteredBookings = filtered;
  }

  // Clear all filters
  void clearFilters() {
    _selectedStatus = null;
    _selectedPaymentStatus = null;
    _selectedDateRange = null;
    _minAmount = null;
    _maxAmount = null;
  }

  // Clear all data
  void clear() {
    _bookings.clear();
    _filteredBookings.clear();
    _selectedBookingIds.clear();
    _stats.clear();
    _searchQuery = '';
    clearFilters();
    _isLoading = false;
    _isLoadingMore = false;
    _hasMoreData = true;
  }
}

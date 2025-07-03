import 'package:flutter/material.dart';
import 'logic/bookings_management_data.dart';
import 'logic/bookings_management_event_handler.dart';
import 'widgets/bookings_stats_header.dart';
import 'widgets/bookings_search_bar.dart';
import 'widgets/bookings_selection_indicator.dart';
import 'widgets/bookings_list_view.dart';
import 'widgets/bookings_app_bar_actions.dart';
import 'widgets/booking_filters.dart';

class BookingsManagementScreen extends StatefulWidget {
  const BookingsManagementScreen({super.key});

  @override
  State<BookingsManagementScreen> createState() =>
      _BookingsManagementScreenState();
}

class _BookingsManagementScreenState extends State<BookingsManagementScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  late final BookingsManagementData _data;
  late final BookingsManagementEventHandler _eventHandler;

  @override
  void initState() {
    super.initState();
    _data = BookingsManagementData();
    _eventHandler = BookingsManagementEventHandler(
      context: context,
      data: _data,
      onStateChanged: () {
        if (mounted) setState(() {});
      },
    );
    _setupScrollListener();
    _eventHandler.initialize();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_data.isLoadingMore &&
          _data.hasMoreData) {
        _eventHandler.handleLoadMore();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des réservations'),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          BookingsAppBarActions(
            hasSelection: _data.selectedBookingIds.isNotEmpty,
            onRefresh: _eventHandler.handleRefresh,
            onBulkStatusUpdate: _eventHandler.handleBulkStatusUpdate,
          ),
        ],
      ),
      body: Column(
        children: [
          // Statistics header
          BookingsStatsHeader(stats: _data.stats),

          // Search bar
          BookingsSearchBar(
            controller: _searchController,
            onChanged: _eventHandler.handleSearchChanged,
          ),

          // Filters
          BookingFilters(
            selectedStatus: _data.selectedStatus,
            selectedPaymentStatus: _data.selectedPaymentStatus,
            dateRange: _data.selectedDateRange,
            minAmount: _data.minAmount,
            maxAmount: _data.maxAmount,
            onStatusChanged: _eventHandler.handleStatusFilter,
            onPaymentStatusChanged: _eventHandler.handlePaymentStatusFilter,
            onDateRangeChanged: _eventHandler.handleDateRangeFilter,
            onAmountRangeChanged: _eventHandler.handleAmountRangeFilter,
            onClearFilters: _eventHandler.handleClearFilters,
          ),

          // Selection indicator
          BookingsSelectionIndicator(
            selectedCount: _data.selectedBookingIds.length,
          ),

          // Bookings list
          Expanded(
            child: BookingsListView(
              bookings: _data.filteredBookings,
              selectedBookingIds: _data.selectedBookingIds,
              isLoading: _data.isLoading,
              isLoadingMore: _data.isLoadingMore,
              scrollController: _scrollController,
              onRefresh: _eventHandler.handleRefresh,
              onBookingTap: _eventHandler.handleBookingTap,
              onBookingSelectionToggle:
                  _eventHandler.handleBookingSelectionToggle,
              onStatusChanged: _eventHandler.handleStatusUpdate,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _eventHandler.dispose();
    super.dispose();
  }
}

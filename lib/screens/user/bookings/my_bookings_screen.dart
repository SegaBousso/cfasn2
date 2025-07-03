import 'package:flutter/material.dart';
import '../../../models/models.dart';

// Logic Handlers
import 'logic/my_bookings_data.dart';
import 'logic/my_bookings_event_handler.dart';

// Modular Widgets
import 'widgets/bookings_tab_bar.dart';
import 'widgets/booking_list_view.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen>
    with TickerProviderStateMixin {
  late final MyBookingsData _data;
  late final MyBookingsEventHandler _eventHandler;

  @override
  void initState() {
    super.initState();
    _initializeHandlers();
    _eventHandler.initialize();
  }

  /// Initialise les handlers de logique métier
  void _initializeHandlers() {
    _data = MyBookingsData();
    _data.initializeTabController(this);

    _eventHandler = MyBookingsEventHandler(
      context: context,
      data: _data,
      onStateChanged: () {
        if (mounted) setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BookingsTabBar(
        data: _data,
        onRefresh: _eventHandler.handleRefresh,
        onTabChanged: _eventHandler.handleTabChanged,
      ),
      body: _data.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _data.error != null
          ? _buildErrorState()
          : TabBarView(
              controller: _data.tabController,
              children: [
                _buildTabContent(BookingStatus.confirmed),
                _buildTabContent(BookingStatus.pending),
                _buildTabContent(BookingStatus.inProgress),
                _buildTabContent(BookingStatus.completed),
                _buildTabContent(BookingStatus.cancelled),
              ],
            ),
    );
  }

  /// Construit le contenu d'un onglet pour un statut donné
  Widget _buildTabContent(BookingStatus status) {
    return BookingListView(
      bookings: _data.getBookingsForStatus(status),
      isRefreshing: _data.isRefreshing,
      onRefresh: _eventHandler.handleRefresh,
      onBookingTap: _eventHandler.handleBookingTap,
      onBookingAction: _eventHandler.handleBookingAction,
      emptyStateTitle: _getEmptyStateTitle(status),
      emptyStateMessage: _getEmptyStateMessage(status),
      emptyStateIcon: _getEmptyStateIcon(status),
    );
  }

  /// Construit l'état d'erreur
  Widget _buildErrorState() {
    return BookingListView.error(
      error: _data.error!,
      onRetry: _eventHandler.handleRetry,
    );
  }

  String _getEmptyStateTitle(BookingStatus status) {
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

  String _getEmptyStateMessage(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return 'Vos réservations en attente de confirmation apparaîtront ici.';
      case BookingStatus.confirmed:
        return 'Vos réservations confirmées apparaîtront ici.';
      case BookingStatus.inProgress:
        return 'Vos réservations en cours apparaîtront ici.';
      case BookingStatus.completed:
        return 'Vos réservations terminées apparaîtront ici.';
      case BookingStatus.cancelled:
        return 'Vos réservations annulées apparaîtront ici.';
      case BookingStatus.refunded:
        return 'Vos réservations remboursées apparaîtront ici.';
    }
  }

  IconData _getEmptyStateIcon(BookingStatus status) {
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

  @override
  void dispose() {
    _eventHandler.dispose();
    super.dispose();
  }
}

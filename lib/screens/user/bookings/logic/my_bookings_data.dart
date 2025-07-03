import 'package:flutter/material.dart';
import '../../../../models/models.dart';

/// Data model for My Bookings screen state
class MyBookingsData {
  // État des réservations
  List<BookingModel> allBookings = [];
  Map<BookingStatus, List<BookingModel>> bookingsByStatus = {};

  // État de l'interface
  bool isLoading = true;
  bool isRefreshing = false;
  String? error;

  // Onglets et filtrage
  int selectedTabIndex = 0;
  late TabController tabController;

  // Statistiques par statut
  Map<BookingStatus, int> statusCounts = {};

  /// Initialise le TabController
  void initializeTabController(TickerProvider vsync) {
    tabController = TabController(length: 5, vsync: vsync);
  }

  /// Met à jour la liste des réservations et recalcule les groupes
  void updateBookings(List<BookingModel> bookings) {
    allBookings = bookings;
    _groupBookingsByStatus();
    _calculateStatusCounts();
    isLoading = false;
    error = null;
  }

  /// Définit l'état de chargement
  void setLoading(bool loading) {
    isLoading = loading;
    if (loading) {
      error = null;
    }
  }

  /// Définit l'état de rafraîchissement
  void setRefreshing(bool refreshing) {
    isRefreshing = refreshing;
  }

  /// Définit une erreur
  void setError(String errorMessage) {
    error = errorMessage;
    isLoading = false;
    isRefreshing = false;
  }

  /// Groupe les réservations par statut
  void _groupBookingsByStatus() {
    bookingsByStatus.clear();

    for (final status in BookingStatus.values) {
      bookingsByStatus[status] = allBookings
          .where((booking) => booking.status == status)
          .toList();
    }
  }

  /// Calcule le nombre de réservations par statut
  void _calculateStatusCounts() {
    statusCounts.clear();

    for (final status in BookingStatus.values) {
      statusCounts[status] = bookingsByStatus[status]?.length ?? 0;
    }
  }

  /// Retourne les réservations pour un statut donné
  List<BookingModel> getBookingsForStatus(BookingStatus status) {
    return bookingsByStatus[status] ?? [];
  }

  /// Retourne le nombre de réservations pour un statut
  int getCountForStatus(BookingStatus status) {
    return statusCounts[status] ?? 0;
  }

  /// Met à jour une réservation existante
  void updateBooking(BookingModel updatedBooking) {
    final index = allBookings.indexWhere((b) => b.id == updatedBooking.id);
    if (index != -1) {
      allBookings[index] = updatedBooking;
      _groupBookingsByStatus();
      _calculateStatusCounts();
    }
  }

  /// Supprime une réservation
  void removeBooking(String bookingId) {
    allBookings.removeWhere((b) => b.id == bookingId);
    _groupBookingsByStatus();
    _calculateStatusCounts();
  }

  /// Nettoie les ressources
  void dispose() {
    tabController.dispose();
  }

  /// Retourne vrai si des données sont chargées
  bool get hasData => allBookings.isNotEmpty;

  /// Retourne vrai si pas d'erreur et pas de chargement
  bool get isReady => !isLoading && error == null;

  /// Retourne le total des réservations
  int get totalBookings => allBookings.length;
}

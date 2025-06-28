import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/booking_model.dart';

class AdminBookingManager {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'bookings';

  // Cache pour optimiser les performances
  static List<BookingModel>? _cachedBookings;
  static DateTime? _lastCacheUpdate;
  static const Duration _cacheTimeout = Duration(minutes: 5);

  // Stream pour les mises à jour en temps réel
  static Stream<List<BookingModel>> getBookingsStream() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => BookingModel.fromFirestore(doc))
              .toList(),
        );
  }

  // Récupérer toutes les réservations avec pagination
  static Future<List<BookingModel>> getAllBookings({
    int limit = 50,
    DocumentSnapshot? startAfter,
    BookingStatus? statusFilter,
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _firestore.collection(_collection);

      // Filtres
      if (statusFilter != null) {
        query = query.where('status', isEqualTo: statusFilter.name);
      }

      if (startDate != null && endDate != null) {
        query = query
            .where('serviceDate', isGreaterThanOrEqualTo: startDate)
            .where('serviceDate', isLessThanOrEqualTo: endDate);
      }

      // Tri et pagination
      query = query.orderBy('createdAt', descending: true);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      query = query.limit(limit);

      final snapshot = await query.get();
      List<BookingModel> bookings = snapshot.docs
          .map((doc) => BookingModel.fromFirestore(doc))
          .toList();

      // Filtrer par recherche textuelle si nécessaire
      if (searchQuery != null && searchQuery.isNotEmpty) {
        bookings = bookings.where((booking) {
          return booking.userName.toLowerCase().contains(
                searchQuery.toLowerCase(),
              ) ||
              booking.userEmail.toLowerCase().contains(
                searchQuery.toLowerCase(),
              ) ||
              booking.service.name.toLowerCase().contains(
                searchQuery.toLowerCase(),
              ) ||
              (booking.providerName?.toLowerCase().contains(
                    searchQuery.toLowerCase(),
                  ) ??
                  false);
        }).toList();
      }

      return bookings;
    } catch (e) {
      print('Erreur lors de la récupération des réservations: $e');
      return [];
    }
  }

  // Récupérer une réservation par ID
  static Future<BookingModel?> getBookingById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        return BookingModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Erreur lors de la récupération de la réservation: $e');
      return null;
    }
  }

  // Mettre à jour le statut d'une réservation
  static Future<bool> updateBookingStatus(
    String bookingId,
    BookingStatus newStatus, {
    String? reason,
  }) async {
    try {
      final updateData = {
        'status': newStatus.name,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (newStatus == BookingStatus.cancelled && reason != null) {
        updateData['cancellationReason'] = reason;
        updateData['cancelledAt'] = FieldValue.serverTimestamp();
      }

      await _firestore
          .collection(_collection)
          .doc(bookingId)
          .update(updateData);

      // Invalider le cache
      _invalidateCache();

      return true;
    } catch (e) {
      print('Erreur lors de la mise à jour du statut: $e');
      return false;
    }
  }

  // Mettre à jour le statut de paiement
  static Future<bool> updatePaymentStatus(
    String bookingId,
    PaymentStatus newStatus,
  ) async {
    try {
      await _firestore.collection(_collection).doc(bookingId).update({
        'paymentStatus': newStatus.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _invalidateCache();
      return true;
    } catch (e) {
      print('Erreur lors de la mise à jour du paiement: $e');
      return false;
    }
  }

  // Assigner un prestataire à une réservation
  static Future<bool> assignProvider(
    String bookingId,
    String providerId,
    String providerName,
  ) async {
    try {
      await _firestore.collection(_collection).doc(bookingId).update({
        'providerId': providerId,
        'providerName': providerName,
        'status': BookingStatus.confirmed.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _invalidateCache();
      return true;
    } catch (e) {
      print('Erreur lors de l\'assignation du prestataire: $e');
      return false;
    }
  }

  // Supprimer une réservation (admin seulement)
  static Future<bool> deleteBooking(String bookingId) async {
    try {
      await _firestore.collection(_collection).doc(bookingId).delete();
      _invalidateCache();
      return true;
    } catch (e) {
      print('Erreur lors de la suppression de la réservation: $e');
      return false;
    }
  }

  // Actions en lot
  static Future<bool> bulkUpdateStatus(
    List<String> bookingIds,
    BookingStatus newStatus,
  ) async {
    try {
      final batch = _firestore.batch();

      for (String id in bookingIds) {
        final docRef = _firestore.collection(_collection).doc(id);
        batch.update(docRef, {
          'status': newStatus.name,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
      _invalidateCache();
      return true;
    } catch (e) {
      print('Erreur lors de la mise à jour en lot: $e');
      return false;
    }
  }

  // Statistiques des réservations
  static Future<Map<String, dynamic>> getBookingStats() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      final bookings = snapshot.docs
          .map((doc) => BookingModel.fromFirestore(doc))
          .toList();

      // Stats par statut
      final statusCounts = <String, int>{};
      for (BookingStatus status in BookingStatus.values) {
        statusCounts[status.label] = bookings
            .where((b) => b.status == status)
            .length;
      }

      // Revenue total
      final totalRevenue = bookings
          .where((b) => b.status == BookingStatus.completed)
          .fold(0.0, (sum, booking) => sum + booking.totalAmount);

      // Stats mensuelles
      final now = DateTime.now();
      final thisMonth = bookings
          .where(
            (b) =>
                b.createdAt.year == now.year && b.createdAt.month == now.month,
          )
          .length;

      final lastMonth = bookings.where((b) {
        final lastMonthDate = DateTime(now.year, now.month - 1);
        return b.createdAt.year == lastMonthDate.year &&
            b.createdAt.month == lastMonthDate.month;
      }).length;

      final growth = lastMonth > 0
          ? ((thisMonth - lastMonth) / lastMonth * 100)
          : 0.0;

      return {
        'total': bookings.length,
        'statusCounts': statusCounts,
        'totalRevenue': totalRevenue,
        'monthlyGrowth': growth,
        'thisMonth': thisMonth,
        'lastMonth': lastMonth,
        'averageBookingValue': bookings.isNotEmpty
            ? totalRevenue / bookings.length
            : 0.0,
      };
    } catch (e) {
      print('Erreur lors du calcul des statistiques: $e');
      return {};
    }
  }

  // Recherche avancée
  static Future<List<BookingModel>> searchBookings({
    String? query,
    BookingStatus? status,
    PaymentStatus? paymentStatus,
    DateTime? startDate,
    DateTime? endDate,
    double? minAmount,
    double? maxAmount,
  }) async {
    try {
      Query firestoreQuery = _firestore.collection(_collection);

      // Application des filtres Firestore
      if (status != null) {
        firestoreQuery = firestoreQuery.where('status', isEqualTo: status.name);
      }

      if (paymentStatus != null) {
        firestoreQuery = firestoreQuery.where(
          'paymentStatus',
          isEqualTo: paymentStatus.name,
        );
      }

      if (startDate != null && endDate != null) {
        firestoreQuery = firestoreQuery
            .where('serviceDate', isGreaterThanOrEqualTo: startDate)
            .where('serviceDate', isLessThanOrEqualTo: endDate);
      }

      firestoreQuery = firestoreQuery.orderBy('createdAt', descending: true);

      final snapshot = await firestoreQuery.get();
      List<BookingModel> results = snapshot.docs
          .map((doc) => BookingModel.fromFirestore(doc))
          .toList();

      // Filtres locaux
      if (query != null && query.isNotEmpty) {
        results = results.where((booking) {
          final searchLower = query.toLowerCase();
          return booking.userName.toLowerCase().contains(searchLower) ||
              booking.userEmail.toLowerCase().contains(searchLower) ||
              booking.service.name.toLowerCase().contains(searchLower) ||
              (booking.providerName?.toLowerCase().contains(searchLower) ??
                  false);
        }).toList();
      }

      if (minAmount != null) {
        results = results
            .where((booking) => booking.totalAmount >= minAmount)
            .toList();
      }

      if (maxAmount != null) {
        results = results
            .where((booking) => booking.totalAmount <= maxAmount)
            .toList();
      }

      return results;
    } catch (e) {
      print('Erreur lors de la recherche: $e');
      return [];
    }
  }

  // Gestion du cache
  static void _invalidateCache() {
    _cachedBookings = null;
    _lastCacheUpdate = null;
  }

  static bool _isCacheValid() {
    return _cachedBookings != null &&
        _lastCacheUpdate != null &&
        DateTime.now().difference(_lastCacheUpdate!) < _cacheTimeout;
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/booking_model.dart';
import '../services/admin_firebase_manager.dart';
import '../utils/admin_cache_manager.dart';

/// Gestionnaire des réservations pour l'administration
/// Utilise l'architecture unifiée avec cache et Firebase manager
class AdminBookingManager {
  static final AdminBookingManager _instance = AdminBookingManager._internal();
  factory AdminBookingManager() => _instance;
  AdminBookingManager._internal();

  final AdminFirebaseManager _firebase = AdminFirebaseManager();
  final AdminCacheManager _cache = AdminCacheManager();
  final String _collectionName = 'bookings';

  /// Stream pour les mises à jour en temps réel des réservations
  Stream<List<BookingModel>> getBookingsStream({
    BookingStatus? statusFilter,
    int? limit,
  }) {
    final filters = <QueryFilter>[];

    if (statusFilter != null) {
      filters.add(
        QueryFilter(
          field: 'status',
          operator: FilterOperator.isEqualTo,
          value: statusFilter.name,
        ),
      );
    }

    return _firebase
        .createDocumentsStream(
          _collectionName,
          filters: filters,
          sorts: [QuerySort(field: 'createdAt', descending: true)],
          limit: limit,
          streamKey: 'bookings_stream',
        )
        .map((docs) {
          return docs.map((doc) => BookingModel.fromFirestore(doc)).toList();
        });
  }

  /// Récupère toutes les réservations avec filtres et pagination
  Future<List<BookingModel>> getAllBookings({
    int? limit,
    DocumentSnapshot? startAfter,
    BookingStatus? statusFilter,
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // Construire la clé de cache
    final cacheKey =
        'bookings_filtered_${statusFilter}_${searchQuery}_${startDate}_${endDate}_${limit}';
    final cached = _cache.get<List<BookingModel>>(cacheKey);
    if (cached != null) return cached;

    // Construire les filtres
    final filters = <QueryFilter>[];

    if (statusFilter != null) {
      filters.add(
        QueryFilter(
          field: 'status',
          operator: FilterOperator.isEqualTo,
          value: statusFilter.name,
        ),
      );
    }

    if (startDate != null) {
      filters.add(
        QueryFilter(
          field: 'serviceDate',
          operator: FilterOperator.isGreaterThanOrEqualTo,
          value: Timestamp.fromDate(startDate),
        ),
      );
    }

    if (endDate != null) {
      filters.add(
        QueryFilter(
          field: 'serviceDate',
          operator: FilterOperator.isLessThanOrEqualTo,
          value: Timestamp.fromDate(endDate),
        ),
      );
    }

    final docs = await _firebase.getDocuments(
      _collectionName,
      filters: filters,
      sorts: [QuerySort(field: 'createdAt', descending: true)],
      limit: limit,
      startAfter: startAfter,
      cacheKey: cacheKey,
    );

    final bookings = docs
        .map((doc) => BookingModel.fromFirestore(doc))
        .toList();

    // Si une recherche textuelle est demandée, filtrer localement
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      return bookings.where((booking) {
        return booking.service.name.toLowerCase().contains(query) ||
            booking.userName.toLowerCase().contains(query) ||
            (booking.providerName?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    return bookings;
  }

  /// Récupère une réservation par ID
  Future<BookingModel?> getBookingById(String id) async {
    final cacheKey = AdminCacheKeys.bookingById(id);
    final cached = _cache.get<BookingModel>(cacheKey);
    if (cached != null) return cached;

    try {
      final doc = await FirebaseFirestore.instance
          .collection(_collectionName)
          .doc(id)
          .get();

      if (!doc.exists) return null;

      final booking = BookingModel.fromFirestore(doc);
      _cache.set(cacheKey, booking);
      return booking;
    } catch (e) {
      print('❌ Erreur lors de la récupération de la réservation: $e');
      return null;
    }
  }

  /// Met à jour le statut d'une réservation
  Future<bool> updateBookingStatus(
    String bookingId,
    BookingStatus newStatus, {
    String? reason,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'status': newStatus.name,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (newStatus == BookingStatus.cancelled && reason != null) {
        updateData['cancellationReason'] = reason;
        updateData['cancelledAt'] = FieldValue.serverTimestamp();
      }

      final docRef = FirebaseFirestore.instance
          .collection(_collectionName)
          .doc(bookingId);

      final operation = BatchOperation.update(docRef, updateData);
      await _firebase.executeBatch([operation]);

      // Invalider le cache
      _cache.clearByPrefix('bookings_');

      print('✅ Statut de réservation mis à jour avec succès');
      return true;
    } catch (e) {
      print('❌ Erreur lors de la mise à jour du statut: $e');
      return false;
    }
  }

  /// Met à jour le statut de paiement
  Future<bool> updatePaymentStatus(
    String bookingId,
    PaymentStatus newStatus,
  ) async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection(_collectionName)
          .doc(bookingId);

      final operation = BatchOperation.update(docRef, {
        'paymentStatus': newStatus.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await _firebase.executeBatch([operation]);

      // Invalider le cache
      _cache.clearByPrefix('bookings_');

      print('✅ Statut de paiement mis à jour avec succès');
      return true;
    } catch (e) {
      print('❌ Erreur lors de la mise à jour du paiement: $e');
      return false;
    }
  }

  /// Assigne un prestataire à une réservation
  Future<bool> assignProvider(
    String bookingId,
    String providerId,
    String providerName,
  ) async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection(_collectionName)
          .doc(bookingId);

      final operation = BatchOperation.update(docRef, {
        'providerId': providerId,
        'providerName': providerName,
        'status': BookingStatus.confirmed.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await _firebase.executeBatch([operation]);

      // Invalider le cache
      _cache.clearByPrefix('bookings_');

      print('✅ Prestataire assigné avec succès');
      return true;
    } catch (e) {
      print('❌ Erreur lors de l\'assignation du prestataire: $e');
      return false;
    }
  }

  /// Supprime une réservation (admin seulement)
  Future<bool> deleteBooking(String bookingId) async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection(_collectionName)
          .doc(bookingId);

      final operation = BatchOperation.delete(docRef);
      await _firebase.executeBatch([operation]);

      // Invalider le cache
      _cache.clearByPrefix('bookings_');

      print('✅ Réservation supprimée avec succès');
      return true;
    } catch (e) {
      print('❌ Erreur lors de la suppression de la réservation: $e');
      return false;
    }
  }

  /// Actions en lot pour le statut
  Future<bool> bulkUpdateStatus(
    List<String> bookingIds,
    BookingStatus newStatus,
  ) async {
    try {
      final operations = bookingIds.map((id) {
        final docRef = FirebaseFirestore.instance
            .collection(_collectionName)
            .doc(id);
        return BatchOperation.update(docRef, {
          'status': newStatus.name,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }).toList();

      await _firebase.executeBatch(operations);

      // Invalider le cache
      _cache.clearByPrefix('bookings_');

      print('✅ ${bookingIds.length} réservations mises à jour avec succès');
      return true;
    } catch (e) {
      print('❌ Erreur lors de la mise à jour en lot: $e');
      return false;
    }
  }

  /// Supprime plusieurs réservations
  Future<bool> bulkDeleteBookings(List<String> bookingIds) async {
    try {
      final operations = bookingIds.map((id) {
        final docRef = FirebaseFirestore.instance
            .collection(_collectionName)
            .doc(id);
        return BatchOperation.delete(docRef);
      }).toList();

      await _firebase.executeBatch(operations);

      // Invalider le cache
      _cache.clearByPrefix('bookings_');

      print('✅ ${bookingIds.length} réservations supprimées avec succès');
      return true;
    } catch (e) {
      print('❌ Erreur lors de la suppression en lot: $e');
      return false;
    }
  }

  /// Obtient les statistiques des réservations
  Future<Map<String, dynamic>> getBookingStats() async {
    const cacheKey = 'bookings_stats';
    final cached = _cache.get<Map<String, dynamic>>(cacheKey);
    if (cached != null) return cached;

    try {
      // Utiliser le service de statistiques pour des calculs optimisés
      final results = await Future.wait([
        _firebase.countDocuments(
          _collectionName,
          cacheKey: 'bookings_count_total',
        ),
        _firebase.countDocuments(
          _collectionName,
          filters: [
            QueryFilter(
              field: 'status',
              operator: FilterOperator.isEqualTo,
              value: BookingStatus.pending.name,
            ),
          ],
          cacheKey: 'bookings_count_pending',
        ),
        _firebase.countDocuments(
          _collectionName,
          filters: [
            QueryFilter(
              field: 'status',
              operator: FilterOperator.isEqualTo,
              value: BookingStatus.confirmed.name,
            ),
          ],
          cacheKey: 'bookings_count_confirmed',
        ),
        _firebase.countDocuments(
          _collectionName,
          filters: [
            QueryFilter(
              field: 'status',
              operator: FilterOperator.isEqualTo,
              value: BookingStatus.completed.name,
            ),
          ],
          cacheKey: 'bookings_count_completed',
        ),
        _firebase.countDocuments(
          _collectionName,
          filters: [
            QueryFilter(
              field: 'status',
              operator: FilterOperator.isEqualTo,
              value: BookingStatus.cancelled.name,
            ),
          ],
          cacheKey: 'bookings_count_cancelled',
        ),
      ]);

      // Calculer la croissance mensuelle
      final now = DateTime.now();
      final thisMonthStart = DateTime(now.year, now.month, 1);
      final lastMonthStart = DateTime(now.year, now.month - 1, 1);
      final lastMonthEnd = DateTime(now.year, now.month, 0, 23, 59, 59);

      final monthlyResults = await Future.wait([
        _firebase.countDocuments(
          _collectionName,
          filters: [
            QueryFilter(
              field: 'createdAt',
              operator: FilterOperator.isGreaterThanOrEqualTo,
              value: Timestamp.fromDate(thisMonthStart),
            ),
          ],
          cacheKey: 'bookings_count_this_month',
        ),
        _firebase.countDocuments(
          _collectionName,
          filters: [
            QueryFilter(
              field: 'createdAt',
              operator: FilterOperator.isGreaterThanOrEqualTo,
              value: Timestamp.fromDate(lastMonthStart),
            ),
            QueryFilter(
              field: 'createdAt',
              operator: FilterOperator.isLessThanOrEqualTo,
              value: Timestamp.fromDate(lastMonthEnd),
            ),
          ],
          cacheKey: 'bookings_count_last_month',
        ),
      ]);

      final thisMonth = monthlyResults[0];
      final lastMonth = monthlyResults[1];
      final growth = lastMonth > 0
          ? ((thisMonth - lastMonth) / lastMonth * 100)
          : 0.0;

      final stats = {
        'total': results[0],
        'pending': results[1],
        'confirmed': results[2],
        'completed': results[3],
        'cancelled': results[4],
        'thisMonth': thisMonth,
        'lastMonth': lastMonth,
        'monthlyGrowth': growth,
        'last_updated': DateTime.now().toIso8601String(),
      };

      _cache.set(cacheKey, stats, timeout: const Duration(minutes: 5));
      return stats;
    } catch (e) {
      print('❌ Erreur lors du calcul des statistiques: $e');
      return {};
    }
  }

  /// Recherche avancée avec critères multiples
  Future<List<BookingModel>> searchBookings({
    String? query,
    BookingStatus? status,
    PaymentStatus? paymentStatus,
    DateTime? startDate,
    DateTime? endDate,
    double? minAmount,
    double? maxAmount,
  }) async {
    // Construire les filtres Firestore
    final filters = <QueryFilter>[];

    if (status != null) {
      filters.add(
        QueryFilter(
          field: 'status',
          operator: FilterOperator.isEqualTo,
          value: status.name,
        ),
      );
    }

    if (paymentStatus != null) {
      filters.add(
        QueryFilter(
          field: 'paymentStatus',
          operator: FilterOperator.isEqualTo,
          value: paymentStatus.name,
        ),
      );
    }

    if (startDate != null) {
      filters.add(
        QueryFilter(
          field: 'serviceDate',
          operator: FilterOperator.isGreaterThanOrEqualTo,
          value: Timestamp.fromDate(startDate),
        ),
      );
    }

    if (endDate != null) {
      filters.add(
        QueryFilter(
          field: 'serviceDate',
          operator: FilterOperator.isLessThanOrEqualTo,
          value: Timestamp.fromDate(endDate),
        ),
      );
    }

    final docs = await _firebase.getDocuments(
      _collectionName,
      filters: filters,
      sorts: [QuerySort(field: 'createdAt', descending: true)],
    );

    var results = docs.map((doc) => BookingModel.fromFirestore(doc)).toList();

    // Filtres locaux
    if (query != null && query.isNotEmpty) {
      final searchLower = query.toLowerCase();
      results = results.where((booking) {
        return booking.service.name.toLowerCase().contains(searchLower) ||
            booking.userName.toLowerCase().contains(searchLower) ||
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
  }

  /// Forcer le rechargement en vidant le cache
  Future<void> forceReload() async {
    _cache.clearByPrefix('bookings_');
  }

  /// Nettoie les ressources (streams, etc.)
  void dispose() {
    _firebase.closeStream('bookings_stream');
  }
}

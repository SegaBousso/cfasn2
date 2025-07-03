import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'bookings';

  // Créer une nouvelle réservation
  Future<String?> createBooking(BookingModel booking) async {
    try {
      print('Tentative de création de réservation: ${booking.id}');
      print('Données: ${booking.toFirestore()}');

      // Validation des données avant création
      if (!_validateBookingData(booking)) {
        throw Exception('Données de réservation invalides');
      }

      // Vérifier si la réservation existe déjà
      final existingDoc = await _firestore
          .collection(_collection)
          .doc(booking.id)
          .get();

      if (existingDoc.exists) {
        throw Exception('Une réservation avec cet ID existe déjà');
      }

      // Vérifier la disponibilité du service (optionnel)
      final serviceAvailable = await _checkServiceAvailability(
        booking.service.id,
        booking.serviceDate,
      );

      if (!serviceAvailable) {
        throw Exception('Service non disponible à cette date');
      }

      // Créer la réservation avec un timestamp serveur
      final bookingData = booking.toFirestore();
      bookingData['createdAt'] = FieldValue.serverTimestamp();
      bookingData['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore.collection(_collection).doc(booking.id).set(bookingData);

      // Optionnel: Mettre à jour les statistiques du service
      await _updateServiceBookingCount(booking.service.id, increment: true);

      print('Réservation créée avec succès: ${booking.id}');
      return booking.id;
    } catch (e) {
      print('Erreur lors de la création de la réservation: $e');
      print('Stack trace: ${StackTrace.current}');
      rethrow; // Relancer l'exception pour que l'appelant puisse la gérer
    }
  }

  // Créer une réservation complète avec transaction
  Future<String?> createBookingWithTransaction(
    BookingModel booking, {
    bool sendNotification = true,
    bool processPayment = false,
  }) async {
    WriteBatch batch = _firestore.batch();

    try {
      print('🚀 Début de la transaction de réservation: ${booking.id}');

      // Validation des données
      if (!_validateBookingData(booking)) {
        throw Exception('Données de réservation invalides');
      }

      // Vérifier la disponibilité
      final serviceAvailable = await _checkServiceAvailability(
        booking.service.id,
        booking.serviceDate,
      );

      if (!serviceAvailable) {
        throw Exception('Service non disponible à cette date');
      }

      // 1. Créer la réservation
      final bookingRef = _firestore.collection(_collection).doc(booking.id);
      final bookingData = booking.toFirestore();
      bookingData['createdAt'] = FieldValue.serverTimestamp();
      bookingData['updatedAt'] = FieldValue.serverTimestamp();

      batch.set(bookingRef, bookingData);

      // 2. Mettre à jour les statistiques du service
      final serviceRef = _firestore
          .collection('services')
          .doc(booking.service.id);
      batch.update(serviceRef, {
        'bookingCount': FieldValue.increment(1),
        'lastBookedAt': FieldValue.serverTimestamp(),
      });

      // 3. Créer une notification pour le prestataire (si demandé)
      if (sendNotification && booking.providerId != null) {
        final notificationRef = _firestore.collection('notifications').doc();
        batch.set(notificationRef, {
          'userId': booking.providerId,
          'title': 'Nouvelle réservation',
          'body':
              'Vous avez une nouvelle réservation pour ${booking.service.name}',
          'type': 'booking_new',
          'data': {'bookingId': booking.id, 'serviceId': booking.service.id},
          'isRead': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      // 4. Créer une entrée d'audit
      final auditRef = _firestore.collection('bookingAudit').doc();
      batch.set(auditRef, {
        'bookingId': booking.id,
        'action': 'created',
        'userId': booking.userId,
        'details': {
          'serviceId': booking.service.id,
          'serviceName': booking.service.name,
          'amount': booking.totalAmount,
          'serviceDate': Timestamp.fromDate(booking.serviceDate),
        },
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Exécuter la transaction
      await batch.commit();

      print('✅ Réservation et transaction créées avec succès: ${booking.id}');
      return booking.id;
    } catch (e) {
      print('❌ Erreur lors de la transaction de réservation: $e');
      rethrow;
    }
  }

  // Validation des données de réservation
  bool _validateBookingData(BookingModel booking) {
    // Vérifications de base
    if (booking.id.isEmpty) {
      print('❌ ID de réservation vide');
      return false;
    }

    if (booking.userId.isEmpty) {
      print('❌ ID utilisateur vide');
      return false;
    }

    if (booking.service.id.isEmpty) {
      print('❌ ID service vide');
      return false;
    }

    // Le prestataire peut être assigné plus tard pour certains services
    // Permettre les réservations sans prestataire assigné (sera assigné par l'admin)
    if (booking.providerId != null && booking.providerId!.isEmpty) {
      print('⚠️ ID prestataire fourni mais vide - sera assigné plus tard');
    }

    // Vérifier que la date n'est pas dans le passé
    if (booking.serviceDate.isBefore(DateTime.now())) {
      print('❌ Date de réservation dans le passé');
      return false;
    }

    // Vérifier que le prix est positif
    if (booking.totalAmount <= 0) {
      print('❌ Prix total invalide');
      return false;
    }

    return true;
  }

  // Vérifier la disponibilité du service
  Future<bool> _checkServiceAvailability(
    String serviceId,
    DateTime serviceDate,
  ) async {
    try {
      // Vérifier si le service existe et est actif
      final serviceDoc = await _firestore
          .collection('services')
          .doc(serviceId)
          .get();

      if (!serviceDoc.exists) {
        print('❌ Service introuvable: $serviceId');
        return false;
      }

      final serviceData = serviceDoc.data() as Map<String, dynamic>;
      if (serviceData['isActive'] != true ||
          serviceData['isAvailable'] != true) {
        print('❌ Service non disponible: $serviceId');
        return false;
      }

      // Optionnel: Vérifier s'il n'y a pas trop de réservations pour cette date
      final sameDateBookings = await _firestore
          .collection(_collection)
          .where('serviceId', isEqualTo: serviceId)
          .where(
            'serviceDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(
              DateTime(serviceDate.year, serviceDate.month, serviceDate.day),
            ),
          )
          .where(
            'serviceDate',
            isLessThan: Timestamp.fromDate(
              DateTime(
                serviceDate.year,
                serviceDate.month,
                serviceDate.day + 1,
              ),
            ),
          )
          .where(
            'status',
            whereIn: [
              BookingStatus.pending.toString().split('.').last,
              BookingStatus.confirmed.toString().split('.').last,
            ],
          )
          .get();

      // Limite arbitraire de 10 réservations par jour pour un service
      const maxBookingsPerDay = 10;
      if (sameDateBookings.docs.length >= maxBookingsPerDay) {
        print('❌ Trop de réservations pour cette date');
        return false;
      }

      return true;
    } catch (e) {
      print('Erreur lors de la vérification de disponibilité: $e');
      return false;
    }
  }

  // Mettre à jour le nombre de réservations d'un service
  Future<void> _updateServiceBookingCount(
    String serviceId, {
    required bool increment,
  }) async {
    try {
      await _firestore.collection('services').doc(serviceId).update({
        'bookingCount': FieldValue.increment(increment ? 1 : -1),
        'lastBookedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Erreur lors de la mise à jour du compteur de réservations: $e');
      // Ne pas faire échouer la réservation si cette mise à jour échoue
    }
  }

  // Récupérer les réservations d'un utilisateur
  Future<List<BookingModel>> getUserBookings(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => BookingModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Erreur lors de la récupération des réservations: $e');
      return [];
    }
  }

  // Récupérer les réservations d'un prestataire
  Future<List<BookingModel>> getProviderBookings(String providerId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('providerId', isEqualTo: providerId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => BookingModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Erreur lors de la récupération des réservations: $e');
      return [];
    }
  }

  // Mettre à jour le statut d'une réservation
  Future<bool> updateBookingStatus(
    String bookingId,
    BookingStatus status,
  ) async {
    try {
      await _firestore.collection(_collection).doc(bookingId).update({
        'status': status.toString().split('.').last,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Erreur lors de la mise à jour du statut: $e');
      return false;
    }
  }

  // Annuler une réservation
  Future<bool> cancelBooking(String bookingId, String reason) async {
    try {
      await _firestore.collection(_collection).doc(bookingId).update({
        'status': BookingStatus.cancelled.toString().split('.').last,
        'cancellationReason': reason,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Erreur lors de l\'annulation: $e');
      return false;
    }
  }

  // Stream des réservations en temps réel
  Stream<List<BookingModel>> getUserBookingsStream(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => BookingModel.fromFirestore(doc))
              .toList(),
        );
  }

  // Obtenir les statistiques de réservation
  Future<Map<String, dynamic>> getBookingStats({
    String? userId,
    String? providerId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _firestore.collection(_collection);

      // Filtrer par utilisateur ou prestataire
      if (userId != null) {
        query = query.where('userId', isEqualTo: userId);
      } else if (providerId != null) {
        query = query.where('providerId', isEqualTo: providerId);
      }

      // Filtrer par période
      if (startDate != null) {
        query = query.where(
          'createdAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
        );
      }
      if (endDate != null) {
        query = query.where(
          'createdAt',
          isLessThanOrEqualTo: Timestamp.fromDate(endDate),
        );
      }

      final snapshot = await query.get();
      final bookings = snapshot.docs
          .map((doc) => BookingModel.fromFirestore(doc))
          .toList();

      // Calculer les statistiques
      int totalBookings = bookings.length;
      int confirmedBookings = bookings
          .where((b) => b.status == BookingStatus.confirmed)
          .length;
      int completedBookings = bookings
          .where((b) => b.status == BookingStatus.completed)
          .length;
      int cancelledBookings = bookings
          .where((b) => b.status == BookingStatus.cancelled)
          .length;

      double totalRevenue = bookings
          .where(
            (b) =>
                b.status == BookingStatus.completed ||
                b.status == BookingStatus.confirmed,
          )
          .fold(0.0, (sum, booking) => sum + booking.totalAmount);

      double averageBookingValue = totalBookings > 0
          ? totalRevenue / totalBookings
          : 0.0;

      // Répartition par statut
      Map<BookingStatus, int> statusDistribution = {};
      for (BookingStatus status in BookingStatus.values) {
        statusDistribution[status] = bookings
            .where((b) => b.status == status)
            .length;
      }

      return {
        'totalBookings': totalBookings,
        'confirmedBookings': confirmedBookings,
        'completedBookings': completedBookings,
        'cancelledBookings': cancelledBookings,
        'totalRevenue': totalRevenue,
        'averageBookingValue': averageBookingValue,
        'statusDistribution': statusDistribution.map(
          (k, v) => MapEntry(k.toString(), v),
        ),
        'conversionRate': totalBookings > 0
            ? (completedBookings / totalBookings) * 100
            : 0.0,
      };
    } catch (e) {
      print('Erreur lors du calcul des statistiques: $e');
      return {};
    }
  }

  // Obtenir les créneaux occupés pour un service à une date donnée
  Future<List<DateTime>> getOccupiedTimeSlots(
    String serviceId,
    DateTime date,
  ) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final snapshot = await _firestore
          .collection(_collection)
          .where('service.id', isEqualTo: serviceId)
          .where(
            'serviceDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
          )
          .where(
            'serviceDate',
            isLessThanOrEqualTo: Timestamp.fromDate(endOfDay),
          )
          .where(
            'status',
            whereIn: [
              BookingStatus.pending.toString().split('.').last,
              BookingStatus.confirmed.toString().split('.').last,
              BookingStatus.inProgress.toString().split('.').last,
            ],
          )
          .get();

      return snapshot.docs
          .map((doc) => BookingModel.fromFirestore(doc))
          .map((booking) => booking.serviceDate)
          .toList();
    } catch (e) {
      print('Erreur lors de la récupération des créneaux occupés: $e');
      return [];
    }
  }
}

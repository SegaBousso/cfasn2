import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'bookings';

  // Créer une nouvelle réservation
  Future<bool> createBooking(BookingModel booking) async {
    try {
      print('Tentative de création de réservation: ${booking.id}');
      print('Données: ${booking.toFirestore()}');

      await _firestore
          .collection(_collection)
          .doc(booking.id)
          .set(booking.toFirestore());

      print('Réservation créée avec succès: ${booking.id}');
      return true;
    } catch (e) {
      print('Erreur lors de la création de la réservation: $e');
      print('Stack trace: ${StackTrace.current}');
      return false;
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
}

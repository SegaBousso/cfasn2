import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

class ReviewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'reviews';

  // Récupérer les avis d'un service
  Future<List<ReviewModel>> getServiceReviews(String serviceId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('serviceId', isEqualTo: serviceId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ReviewModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Erreur lors de la récupération des avis: $e');
      return [];
    }
  }

  // Ajouter un avis
  Future<bool> addReview(ReviewModel review) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(review.id)
          .set(review.toFirestore());
      return true;
    } catch (e) {
      print('Erreur lors de l\'ajout de l\'avis: $e');
      return false;
    }
  }

  // Mettre à jour un avis
  Future<bool> updateReview(ReviewModel review) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(review.id)
          .update(review.toFirestore());
      return true;
    } catch (e) {
      print('Erreur lors de la mise à jour de l\'avis: $e');
      return false;
    }
  }

  // Supprimer un avis
  Future<bool> deleteReview(String reviewId) async {
    try {
      await _firestore.collection(_collection).doc(reviewId).delete();
      return true;
    } catch (e) {
      print('Erreur lors de la suppression de l\'avis: $e');
      return false;
    }
  }

  // Calculer la note moyenne d'un service
  Future<Map<String, dynamic>> getServiceRatingStats(String serviceId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('serviceId', isEqualTo: serviceId)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return {'averageRating': 0.0, 'totalReviews': 0};
      }

      double totalRating = 0;
      for (var doc in querySnapshot.docs) {
        totalRating += (doc.data()['rating'] as num).toDouble();
      }

      return {
        'averageRating': totalRating / querySnapshot.docs.length,
        'totalReviews': querySnapshot.docs.length,
      };
    } catch (e) {
      print('Erreur lors du calcul des statistiques: $e');
      return {'averageRating': 0.0, 'totalReviews': 0};
    }
  }
}

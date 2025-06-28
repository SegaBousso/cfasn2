import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/models.dart';

class FavoriteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String _collection = 'favorites';

  // Ajouter/Retirer un service des favoris
  Future<bool> toggleFavorite(String serviceId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return false;

      final favoriteId = '${userId}_$serviceId';
      final docRef = _firestore.collection(_collection).doc(favoriteId);
      final doc = await docRef.get();

      if (doc.exists) {
        // Retirer des favoris
        await docRef.delete();
        return false;
      } else {
        // Ajouter aux favoris
        await docRef.set({
          'userId': userId,
          'serviceId': serviceId,
          'createdAt': FieldValue.serverTimestamp(),
        });
        return true;
      }
    } catch (e) {
      print('Erreur lors de la gestion des favoris: $e');
      return false;
    }
  }

  // Vérifier si un service est en favori
  Future<bool> isFavorite(String serviceId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return false;

      final favoriteId = '${userId}_$serviceId';
      final doc = await _firestore
          .collection(_collection)
          .doc(favoriteId)
          .get();
      return doc.exists;
    } catch (e) {
      print('Erreur lors de la vérification des favoris: $e');
      return false;
    }
  }

  // Récupérer tous les services favoris de l'utilisateur
  Future<List<String>> getUserFavoriteServices() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return [];

      final querySnapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .get();

      return querySnapshot.docs
          .map((doc) => doc.data()['serviceId'] as String)
          .toList();
    } catch (e) {
      print('Erreur lors de la récupération des favoris: $e');
      return [];
    }
  }

  // Compter le nombre de fois qu'un service a été mis en favori
  Future<int> getServiceFavoriteCount(String serviceId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('serviceId', isEqualTo: serviceId)
          .get();

      return querySnapshot.docs.length;
    } catch (e) {
      print('Erreur lors du comptage des favoris: $e');
      return 0;
    }
  }
}

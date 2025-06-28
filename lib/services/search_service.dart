import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

class SearchService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Recherche générale de services
  Future<List<ServiceModel>> searchServices({
    String? query,
    String? categoryId,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    List<String>? tags,
    int limit = 20,
  }) async {
    try {
      Query servicesQuery = _firestore
          .collection('services')
          .where('isActive', isEqualTo: true)
          .where('isAvailable', isEqualTo: true);

      // Filtrer par catégorie
      if (categoryId != null && categoryId.isNotEmpty) {
        servicesQuery = servicesQuery.where(
          'categoryId',
          isEqualTo: categoryId,
        );
      }

      // Filtrer par prix minimum
      if (minPrice != null) {
        servicesQuery = servicesQuery.where(
          'price',
          isGreaterThanOrEqualTo: minPrice,
        );
      }

      // Filtrer par prix maximum
      if (maxPrice != null) {
        servicesQuery = servicesQuery.where(
          'price',
          isLessThanOrEqualTo: maxPrice,
        );
      }

      // Filtrer par note minimum
      if (minRating != null) {
        servicesQuery = servicesQuery.where(
          'rating',
          isGreaterThanOrEqualTo: minRating,
        );
      }

      // Filtrer par tags
      if (tags != null && tags.isNotEmpty) {
        servicesQuery = servicesQuery.where('tags', arrayContainsAny: tags);
      }

      servicesQuery = servicesQuery.limit(limit);

      final querySnapshot = await servicesQuery.get();
      List<ServiceModel> services = querySnapshot.docs
          .map(
            (doc) => ServiceModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();

      // Filtrer par requête de recherche (côté client pour les recherches textuelles)
      if (query != null && query.isNotEmpty) {
        services = services.where((service) {
          final searchTerm = query.toLowerCase();
          return service.name.toLowerCase().contains(searchTerm) ||
              service.description.toLowerCase().contains(searchTerm) ||
              service.categoryName.toLowerCase().contains(searchTerm) ||
              service.tags.any((tag) => tag.toLowerCase().contains(searchTerm));
        }).toList();
      }

      return services;
    } catch (e) {
      print('Erreur lors de la recherche: $e');
      return [];
    }
  }

  // Recherche par localisation (à implémenter avec les coordonnées)
  Future<List<ServiceModel>> searchServicesByLocation({
    required double latitude,
    required double longitude,
    double radiusKm = 10.0,
    int limit = 20,
  }) async {
    try {
      // TODO: Implémenter la recherche géographique avec GeoFirestore
      // Pour l'instant, retourner tous les services actifs
      final querySnapshot = await _firestore
          .collection('services')
          .where('isActive', isEqualTo: true)
          .where('isAvailable', isEqualTo: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map(
            (doc) => ServiceModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();
    } catch (e) {
      print('Erreur lors de la recherche par localisation: $e');
      return [];
    }
  }

  // Suggestions de recherche basées sur l'historique
  Future<List<String>> getSearchSuggestions(String query) async {
    try {
      if (query.length < 2) return [];

      // Récupérer les services qui correspondent au début de la requête
      final querySnapshot = await _firestore
          .collection('services')
          .where('isActive', isEqualTo: true)
          .get();

      Set<String> suggestions = {};

      for (var doc in querySnapshot.docs) {
        final service = ServiceModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
        final searchTerm = query.toLowerCase();

        // Suggestions basées sur le nom du service
        if (service.name.toLowerCase().contains(searchTerm)) {
          suggestions.add(service.name);
        }

        // Suggestions basées sur la catégorie
        if (service.categoryName.toLowerCase().contains(searchTerm)) {
          suggestions.add(service.categoryName);
        }

        // Suggestions basées sur les tags
        for (var tag in service.tags) {
          if (tag.toLowerCase().contains(searchTerm)) {
            suggestions.add(tag);
          }
        }
      }

      return suggestions.take(10).toList();
    } catch (e) {
      print('Erreur lors de la récupération des suggestions: $e');
      return [];
    }
  }

  // Recherche populaire et tendances
  Future<List<String>> getPopularSearches() async {
    try {
      // TODO: Implémenter un système de tracking des recherches populaires
      // Pour l'instant, retourner des recherches prédéfinies
      return [
        'Nettoyage',
        'Plomberie',
        'Jardinage',
        'Réparation',
        'Peinture',
        'Électricité',
        'Transport',
        'Informatique',
      ];
    } catch (e) {
      print('Erreur lors de la récupération des recherches populaires: $e');
      return [];
    }
  }
}

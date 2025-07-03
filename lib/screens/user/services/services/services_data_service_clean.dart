import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../../models/service_model.dart';

/// Service d'accès aux données pour les services
/// Responsabilité : Interface avec Firestore pour les opérations CRUD des services
class ServicesDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  CollectionReference get _servicesCollection =>
      _firestore.collection('services');
  CollectionReference get _categoriesCollection =>
      _firestore.collection('categories');

  /// Récupère tous les services actifs
  Future<List<ServiceModel>> getAllServices() async {
    try {
      final querySnapshot = await _servicesCollection
          .where('isActive', isEqualTo: true)
          .orderBy('name')
          .get();

      return querySnapshot.docs
          .map(
            (doc) => ServiceModel.fromFirestore(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();
    } catch (e) {
      print('Erreur lors de la récupération des services: $e');
      return [];
    }
  }

  /// Récupère les services par catégorie
  Future<List<ServiceModel>> getServicesByCategory(String categoryId) async {
    try {
      final querySnapshot = await _servicesCollection
          .where('isActive', isEqualTo: true)
          .where('categoryId', isEqualTo: categoryId)
          .orderBy('name')
          .get();

      return querySnapshot.docs
          .map(
            (doc) => ServiceModel.fromFirestore(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();
    } catch (e) {
      print('Erreur lors de la récupération des services par catégorie: $e');
      return [];
    }
  }

  /// Recherche de services par nom ou description
  Future<List<ServiceModel>> searchServices(String query) async {
    try {
      final lowerQuery = query.toLowerCase();
      final querySnapshot = await _servicesCollection
          .where('isActive', isEqualTo: true)
          .orderBy('name')
          .get();

      return querySnapshot.docs
          .map(
            (doc) => ServiceModel.fromFirestore(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .where(
            (service) =>
                service.name.toLowerCase().contains(lowerQuery) ||
                service.description.toLowerCase().contains(lowerQuery),
          )
          .toList();
    } catch (e) {
      print('Erreur lors de la recherche de services: $e');
      return [];
    }
  }

  /// Récupère toutes les catégories avec compteur de services
  Future<List<ServiceCategory>> getServiceCategories() async {
    try {
      final categoriesSnapshot = await _categoriesCollection
          .orderBy('name')
          .get();

      final categories = <ServiceCategory>[];

      // Ajouter la catégorie "Tous" en premier
      final allServicesSnapshot = await _servicesCollection
          .where('isActive', isEqualTo: true)
          .get();

      categories.add(
        ServiceCategory(
          id: 'all',
          name: 'Tous',
          icon: Icons.apps,
          servicesCount: allServicesSnapshot.docs.length,
        ),
      );

      // Ajouter les autres catégories
      for (final doc in categoriesSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final categoryId = doc.id;

        // Compter les services pour cette catégorie
        final servicesSnapshot = await _servicesCollection
            .where('isActive', isEqualTo: true)
            .where('categoryId', isEqualTo: categoryId)
            .get();

        categories.add(
          ServiceCategory(
            id: categoryId,
            name: data['name'] ?? 'Catégorie',
            icon: _getIconFromString(data['icon']),
            servicesCount: servicesSnapshot.docs.length,
          ),
        );
      }

      return categories;
    } catch (e) {
      print('Erreur lors de la récupération des catégories: $e');
      return [
        ServiceCategory(
          id: 'all',
          name: 'Tous',
          icon: Icons.apps,
          servicesCount: 0,
        ),
      ];
    }
  }

  /// Récupère un service par son ID
  Future<ServiceModel?> getServiceById(String serviceId) async {
    try {
      final doc = await _servicesCollection.doc(serviceId).get();

      if (doc.exists) {
        return ServiceModel.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }
      return null;
    } catch (e) {
      print('Erreur lors de la récupération du service $serviceId: $e');
      return null;
    }
  }

  /// Met à jour les statistiques d'un service (vues, likes, etc.)
  Future<void> updateServiceStats(
    String serviceId, {
    int? viewsIncrement,
    int? likesIncrement,
  }) async {
    try {
      final updateData = <String, dynamic>{};

      if (viewsIncrement != null) {
        updateData['viewsCount'] = FieldValue.increment(viewsIncrement);
      }

      if (likesIncrement != null) {
        updateData['likesCount'] = FieldValue.increment(likesIncrement);
      }

      if (updateData.isNotEmpty) {
        await _servicesCollection.doc(serviceId).update(updateData);
      }
    } catch (e) {
      print('Erreur lors de la mise à jour des statistiques du service: $e');
    }
  }

  /// Récupère les services populaires (les plus vus/likés)
  Future<List<ServiceModel>> getPopularServices({int limit = 10}) async {
    try {
      final querySnapshot = await _servicesCollection
          .where('isActive', isEqualTo: true)
          .orderBy('viewsCount', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map(
            (doc) => ServiceModel.fromFirestore(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();
    } catch (e) {
      print('Erreur lors de la récupération des services populaires: $e');
      return [];
    }
  }

  /// Récupère les services les mieux notés
  Future<List<ServiceModel>> getTopRatedServices({int limit = 10}) async {
    try {
      final querySnapshot = await _servicesCollection
          .where('isActive', isEqualTo: true)
          .where('rating', isGreaterThan: 4.0)
          .orderBy('rating', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map(
            (doc) => ServiceModel.fromFirestore(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();
    } catch (e) {
      print('Erreur lors de la récupération des services les mieux notés: $e');
      return [];
    }
  }

  /// Convertit une chaîne d'icône en IconData
  IconData _getIconFromString(String? iconName) {
    if (iconName != null) {
      switch (iconName.toLowerCase()) {
        case 'cleaning':
          return Icons.cleaning_services;
        case 'repair':
          return Icons.build;
        case 'streaming':
          return Icons.live_tv;
        case 'internet':
          return Icons.wifi;
        case 'fitness':
          return Icons.fitness_center;
        case 'education':
          return Icons.school;
        default:
          return Icons.category;
      }
    }
    return Icons.category;
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../models/service_model.dart';

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
      print('🔍 Recherche de services avec requête: "$query"');

      if (query.isEmpty) {
        print('📄 Requête vide, retour de tous les services');
        return getAllServices();
      }

      // Convertir la requête en minuscules pour la recherche
      final lowerQuery = query.toLowerCase();
      print('🔍 Requête en minuscules: "$lowerQuery"');

      // D'abord, récupérer tous les services actifs
      final allServicesQuery = await _servicesCollection
          .where('isActive', isEqualTo: true)
          .get();

      print(
        '📊 Nombre total de services actifs: ${allServicesQuery.docs.length}',
      );

      if (allServicesQuery.docs.isEmpty) {
        print('⚠️  Aucun service trouvé dans Firestore!');
        return [];
      }

      // Filtrer côté client pour une recherche plus flexible
      final List<ServiceModel> results = [];

      for (final doc in allServicesQuery.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final service = ServiceModel.fromFirestore(data, doc.id);

        // Recherche dans le nom et la description
        final nameMatch = service.name.toLowerCase().contains(lowerQuery);
        final descMatch = service.description.toLowerCase().contains(
          lowerQuery,
        );

        if (nameMatch || descMatch) {
          results.add(service);
          print('✅ Service trouvé: ${service.name}');
        }
      }

      print(
        '🎯 Résultats de recherche: ${results.length} service(s) trouvé(s)',
      );
      return results;
    } catch (e) {
      print('❌ Erreur lors de la recherche de services: $e');
      return [];
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
      print('Erreur lors de la récupération du service: $e');
      return null;
    }
  }

  /// Récupère les catégories de services
  Future<List<Map<String, dynamic>>> getServiceCategories() async {
    try {
      print('🔍 Récupération des catégories depuis Firestore...');
      print('📍 Collection path: ${_categoriesCollection.path}');

      final querySnapshot = await _categoriesCollection
          .where('isActive', isEqualTo: true)
          .orderBy('name')
          .get();

      print('📊 Nombre de catégories trouvées: ${querySnapshot.docs.length}');

      if (querySnapshot.docs.isEmpty) {
        print('⚠️  Aucune catégorie trouvée dans Firestore!');
        print('🔧 Vérifiez que:');
        print('   - La collection "serviceCategories" existe');
        print('   - Elle contient des documents avec isActive=true');
        print('   - Les règles Firestore permettent la lecture');
      }

      final categories = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final category = {
          'id': doc.id,
          'name': data['name'] ?? '',
          'icon': data['icon'] ?? 'build',
          'servicesCount': data['servicesCount'] ?? 0,
        };
        print(
          '📂 Catégorie trouvée: ${category['name']} (ID: ${category['id']})',
        );
        return category;
      }).toList();

      print('✅ Catégories récupérées: ${categories.length}');
      return categories;
    } catch (e) {
      print('❌ Erreur lors de la récupération des catégories: $e');
      print('🔧 Vérifiez la connexion Firestore et les permissions');
      return [];
    }
  }

  /// Met à jour le nombre de vues d'un service
  Future<void> incrementServiceViews(String serviceId) async {
    try {
      await _servicesCollection.doc(serviceId).update({
        'viewsCount': FieldValue.increment(1),
      });
    } catch (e) {
      print('Erreur lors de l\'incrémentation des vues: $e');
    }
  }

  /// Récupère les services populaires (basés sur le rating et les vues)
  Future<List<ServiceModel>> getPopularServices({int limit = 10}) async {
    try {
      final querySnapshot = await _servicesCollection
          .where('isActive', isEqualTo: true)
          .where('isAvailable', isEqualTo: true)
          .orderBy('rating', descending: true)
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

  /// Récupère les services récemment ajoutés
  Future<List<ServiceModel>> getRecentServices({int limit = 10}) async {
    try {
      final querySnapshot = await _servicesCollection
          .where('isActive', isEqualTo: true)
          .where('isAvailable', isEqualTo: true)
          .orderBy('createdAt', descending: true)
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
      print('Erreur lors de la récupération des services récents: $e');
      return [];
    }
  }

  /// Stream pour écouter les changements en temps réel
  Stream<List<ServiceModel>> getServicesStream() {
    return _servicesCollection
        .where('isActive', isEqualTo: true)
        .orderBy('name')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => ServiceModel.fromFirestore(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList(),
        );
  }

  /// Stream pour une catégorie spécifique
  Stream<List<ServiceModel>> getServicesByCategoryStream(String categoryId) {
    return _servicesCollection
        .where('isActive', isEqualTo: true)
        .where('categoryId', isEqualTo: categoryId)
        .orderBy('name')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => ServiceModel.fromFirestore(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList(),
        );
  }

  /// Helper method to create sample categories for testing
  /// Only call this method during development to populate test data
  Future<void> createSampleCategories() async {
    try {
      print('🔧 Création des catégories d\'exemple...');

      final now = Timestamp.now();
      final sampleCategories = [
        {
          'name': 'Internet',
          'icon': 'wifi',
          'isActive': true,
          'servicesCount': 0,
          'createdAt': now,
        },
        {
          'name': 'Fitness',
          'icon': 'fitness_center',
          'isActive': true,
          'servicesCount': 0,
          'createdAt': now,
        },
        {
          'name': 'Streaming',
          'icon': 'play_circle',
          'isActive': true,
          'servicesCount': 0,
          'createdAt': now,
        },
        {
          'name': 'Éducation',
          'icon': 'school',
          'isActive': true,
          'servicesCount': 0,
          'createdAt': now,
        },
        {
          'name': 'Santé',
          'icon': 'local_hospital',
          'isActive': true,
          'servicesCount': 0,
          'createdAt': now,
        },
      ];

      for (final category in sampleCategories) {
        await _categoriesCollection.add(category);
        print('✅ Catégorie créée: ${category['name']}');
      }

      print('🎉 Toutes les catégories d\'exemple ont été créées!');
    } catch (e) {
      print('❌ Erreur lors de la création des catégories: $e');
    }
  }

  /// Helper method to create sample services for testing
  /// Only call this method during development to populate test data
  Future<void> createSampleServices() async {
    try {
      print('🔧 Création des services d\'exemple...');

      final now = Timestamp.now();
      final sampleServices = [
        {
          'name': 'Netflix Premium',
          'description': 'Service de streaming vidéo avec contenu HD et 4K',
          'price': 15.99,
          'categoryId': 'streaming',
          'providerId': 'netflix_provider',
          'providerName': 'Netflix Inc.',
          'rating': 4.5,
          'reviewCount': 1250,
          'isActive': true,
          'isAvailable': true,
          'features': ['HD', '4K', 'Multi-appareils', 'Téléchargement'],
          'imageUrl':
              'https://via.placeholder.com/300x200/E50914/FFFFFF?text=Netflix',
          'viewCount': 0,
          'createdAt': now,
          'updatedAt': now,
        },
        {
          'name': 'Spotify Premium',
          'description': 'Musique en streaming illimitée sans publicité',
          'price': 9.99,
          'categoryId': 'streaming',
          'providerId': 'spotify_provider',
          'providerName': 'Spotify AB',
          'rating': 4.3,
          'reviewCount': 890,
          'isActive': true,
          'isAvailable': true,
          'features': ['Sans pub', 'Qualité haute', 'Offline', 'Playlists'],
          'imageUrl':
              'https://via.placeholder.com/300x200/1DB954/FFFFFF?text=Spotify',
          'viewCount': 0,
          'createdAt': now,
          'updatedAt': now,
        },
        {
          'name': 'Orange Fiber',
          'description': 'Internet haut débit fibre optique jusqu\'à 1GB/s',
          'price': 29.99,
          'categoryId': 'internet',
          'providerId': 'orange_provider',
          'providerName': 'Orange France',
          'rating': 4.1,
          'reviewCount': 560,
          'isActive': true,
          'isAvailable': true,
          'features': ['1GB/s', 'Fibre optique', 'TV incluse', 'WiFi 6'],
          'imageUrl':
              'https://via.placeholder.com/300x200/FF6600/FFFFFF?text=Orange',
          'viewCount': 0,
          'createdAt': now,
          'updatedAt': now,
        },
        {
          'name': 'Basic-Fit Gym',
          'description': 'Abonnement salle de sport avec accès illimité',
          'price': 19.99,
          'categoryId': 'fitness',
          'providerId': 'basicfit_provider',
          'providerName': 'Basic-Fit',
          'rating': 4.2,
          'reviewCount': 340,
          'isActive': true,
          'isAvailable': true,
          'features': [
            '24/7',
            'Toutes salles',
            'App mobile',
            'Cours collectifs',
          ],
          'imageUrl':
              'https://via.placeholder.com/300x200/9B59B6/FFFFFF?text=Basic-Fit',
          'viewCount': 0,
          'createdAt': now,
          'updatedAt': now,
        },
        {
          'name': 'Coursera Plus',
          'description':
              'Plateforme d\'apprentissage en ligne avec certificats',
          'price': 59.99,
          'categoryId': 'education',
          'providerId': 'coursera_provider',
          'providerName': 'Coursera Inc.',
          'rating': 4.4,
          'reviewCount': 720,
          'isActive': true,
          'isAvailable': true,
          'features': [
            'Certificats',
            'Cours universitaires',
            'Projets pratiques',
            'Support',
          ],
          'imageUrl':
              'https://via.placeholder.com/300x200/0056D3/FFFFFF?text=Coursera',
          'viewCount': 0,
          'createdAt': now,
          'updatedAt': now,
        },
      ];

      for (final service in sampleServices) {
        await _servicesCollection.add(service);
        print('✅ Service créé: ${service['name']}');
      }

      print('🎉 Tous les services d\'exemple ont été créés!');
    } catch (e) {
      print('❌ Erreur lors de la création des services: $e');
    }
  }
}

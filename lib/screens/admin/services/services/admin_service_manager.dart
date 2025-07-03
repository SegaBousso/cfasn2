import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../models/models.dart';
import '../../services/admin_firebase_manager.dart';
import '../../utils/admin_cache_manager.dart';

/// Gestionnaire des services pour l'administration
/// Utilise l'architecture unifiée avec cache et Firebase manager
class AdminServiceManager {
  static final AdminServiceManager _instance = AdminServiceManager._internal();
  factory AdminServiceManager() => _instance;
  AdminServiceManager._internal();

  final AdminFirebaseManager _firebase = AdminFirebaseManager();
  final AdminCacheManager _cache = AdminCacheManager();
  final String _collectionName = 'services';

  /// Récupère tous les services
  Future<List<ServiceModel>> get allServices async {
    const cacheKey = AdminCacheKeys.servicesAll;
    final cached = _cache.get<List<ServiceModel>>(cacheKey);
    if (cached != null) return cached;

    final docs = await _firebase.getDocuments(
      _collectionName,
      sorts: [QuerySort(field: 'createdAt', descending: true)],
      cacheKey: cacheKey,
    );

    final services = docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return ServiceModel.fromMap(data, doc.id);
    }).toList();

    return services;
  }

  /// Récupère les services actifs
  Future<List<ServiceModel>> get activeServices async {
    const cacheKey = AdminCacheKeys.servicesActive;

    // Bypass temporaire du cache pour éviter le problème de cast
    // final cached = _cache.get<List<ServiceModel>>(cacheKey);
    // if (cached != null) return cached;

    final docs = await _firebase.getDocuments(
      _collectionName,
      filters: [
        QueryFilter(
          field: 'isActive',
          operator: FilterOperator.isEqualTo,
          value: true,
        ),
      ],
      sorts: [QuerySort(field: 'createdAt', descending: true)],
      // Pas de cacheKey pour éviter le problème
    );

    final services = docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return ServiceModel.fromMap(data, doc.id);
    }).toList();

    // Mettre en cache manuellement avec le bon type
    _cache.set(cacheKey, services);

    return services;
  }

  /// Récupère les services inactifs
  Future<List<ServiceModel>> get inactiveServices async {
    const cacheKey = 'services_inactive';
    final cached = _cache.get<List<ServiceModel>>(cacheKey);
    if (cached != null) return cached;

    final docs = await _firebase.getDocuments(
      _collectionName,
      filters: [
        QueryFilter(
          field: 'isActive',
          operator: FilterOperator.isEqualTo,
          value: false,
        ),
      ],
      sorts: [QuerySort(field: 'createdAt', descending: true)],
      cacheKey: cacheKey,
    );

    final services = docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return ServiceModel.fromMap(data, doc.id);
    }).toList();

    return services;
  }

  /// Récupère les services disponibles
  Future<List<ServiceModel>> get availableServices async {
    const cacheKey = AdminCacheKeys.servicesAvailable;
    final cached = _cache.get<List<ServiceModel>>(cacheKey);
    if (cached != null) return cached;

    final docs = await _firebase.getDocuments(
      _collectionName,
      filters: [
        QueryFilter(
          field: 'isActive',
          operator: FilterOperator.isEqualTo,
          value: true,
        ),
        QueryFilter(
          field: 'isAvailable',
          operator: FilterOperator.isEqualTo,
          value: true,
        ),
      ],
      sorts: [QuerySort(field: 'createdAt', descending: true)],
      cacheKey: cacheKey,
    );

    final services = docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return ServiceModel.fromMap(data, doc.id);
    }).toList();

    return services;
  }

  /// Récupère un service par ID
  Future<ServiceModel?> getServiceById(String id) async {
    final cacheKey = AdminCacheKeys.serviceById(id);
    final cached = _cache.get<ServiceModel>(cacheKey);
    if (cached != null) return cached;

    try {
      final doc = await FirebaseFirestore.instance
          .collection(_collectionName)
          .doc(id)
          .get();

      if (!doc.exists) return null;

      final data = doc.data() as Map<String, dynamic>;
      final service = ServiceModel.fromMap(data, doc.id);

      _cache.set(cacheKey, service);
      return service;
    } catch (e) {
      print('❌ Erreur lors de la récupération du service: $e');
      return null;
    }
  }

  /// Récupère les services par catégorie
  Future<List<ServiceModel>> getServicesByCategory(String categoryId) async {
    final cacheKey = 'services_category_$categoryId';
    final cached = _cache.get<List<ServiceModel>>(cacheKey);
    if (cached != null) return cached;

    final docs = await _firebase.getDocuments(
      _collectionName,
      filters: [
        QueryFilter(
          field: 'categoryId',
          operator: FilterOperator.isEqualTo,
          value: categoryId,
        ),
      ],
      sorts: [QuerySort(field: 'createdAt', descending: true)],
      cacheKey: cacheKey,
    );

    final services = docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return ServiceModel.fromMap(data, doc.id);
    }).toList();

    return services;
  }

  /// Récupère les services par prestataire
  Future<List<ServiceModel>> getServicesByProvider(String providerId) async {
    final cacheKey = 'services_provider_$providerId';
    final cached = _cache.get<List<ServiceModel>>(cacheKey);
    if (cached != null) return cached;

    final docs = await _firebase.getDocuments(
      _collectionName,
      filters: [
        QueryFilter(
          field: 'providerId',
          operator: FilterOperator.isEqualTo,
          value: providerId,
        ),
      ],
      sorts: [QuerySort(field: 'createdAt', descending: true)],
      cacheKey: cacheKey,
    );

    final services = docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return ServiceModel.fromMap(data, doc.id);
    }).toList();

    return services;
  }

  /// Crée un nouveau service
  Future<void> createService(ServiceModel service) async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection(_collectionName)
          .doc(service.id.isEmpty ? null : service.id);

      final serviceData = service.toMap();
      serviceData['createdAt'] = FieldValue.serverTimestamp();
      serviceData['updatedAt'] = FieldValue.serverTimestamp();

      final operation = BatchOperation.create(docRef, serviceData);
      await _firebase.executeBatch([operation]);

      // Invalider le cache
      _cache.clearByPrefix('services_');

      print('✅ Service créé avec succès');
    } catch (e) {
      print('❌ Erreur lors de la création du service: $e');
      rethrow;
    }
  }

  /// Met à jour un service
  Future<void> updateService(ServiceModel service) async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection(_collectionName)
          .doc(service.id);

      final serviceData = service.toMap();
      serviceData['updatedAt'] = FieldValue.serverTimestamp();

      final operation = BatchOperation.update(docRef, serviceData);
      await _firebase.executeBatch([operation]);

      // Mettre à jour le cache
      _cache.clearByPrefix('services_');
      _cache.set(AdminCacheKeys.serviceById(service.id), service);

      print('✅ Service mis à jour avec succès');
    } catch (e) {
      print('❌ Erreur lors de la mise à jour du service: $e');
      rethrow;
    }
  }

  /// Supprime un service
  Future<void> deleteService(String id) async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection(_collectionName)
          .doc(id);

      final operation = BatchOperation.delete(docRef);
      await _firebase.executeBatch([operation]);

      // Invalider le cache
      _cache.clearByPrefix('services_');

      print('✅ Service supprimé avec succès');
    } catch (e) {
      print('❌ Erreur lors de la suppression du service: $e');
      rethrow;
    }
  }

  /// Supprime plusieurs services
  Future<void> deleteMultipleServices(List<String> serviceIds) async {
    try {
      final operations = serviceIds.map((id) {
        final docRef = FirebaseFirestore.instance
            .collection(_collectionName)
            .doc(id);
        return BatchOperation.delete(docRef);
      }).toList();

      await _firebase.executeBatch(operations);

      // Invalider le cache
      _cache.clearByPrefix('services_');

      print('✅ ${serviceIds.length} services supprimés avec succès');
    } catch (e) {
      print('❌ Erreur lors de la suppression des services: $e');
      rethrow;
    }
  }

  /// Met à jour le statut actif de plusieurs services
  Future<void> bulkUpdateActiveStatus(
    List<String> serviceIds,
    bool isActive,
  ) async {
    try {
      final operations = serviceIds.map((id) {
        final docRef = FirebaseFirestore.instance
            .collection(_collectionName)
            .doc(id);
        return BatchOperation.update(docRef, {
          'isActive': isActive,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }).toList();

      await _firebase.executeBatch(operations);

      // Invalider le cache
      _cache.clearByPrefix('services_');

      print('✅ ${serviceIds.length} services mis à jour avec succès');
    } catch (e) {
      print('❌ Erreur lors de la mise à jour des services: $e');
      rethrow;
    }
  }

  /// Recherche des services
  Future<List<ServiceModel>> searchServices(String query) async {
    if (query.isEmpty) return await allServices;

    // Pour une recherche simple, on récupère tous les services et on filtre
    final services = await allServices;
    final lowercaseQuery = query.toLowerCase();

    return services.where((service) {
      return service.name.toLowerCase().contains(lowercaseQuery) ||
          service.description.toLowerCase().contains(lowercaseQuery) ||
          service.categoryName.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  /// Filtre les services avec critères avancés
  Future<List<ServiceModel>> filterServices({
    String? categoryId,
    String? providerId,
    bool? isActive,
    bool? isAvailable,
    double? minPrice,
    double? maxPrice,
    double? minRating,
  }) async {
    // Construire les filtres Firestore
    final filters = <QueryFilter>[];

    if (categoryId != null) {
      filters.add(
        QueryFilter(
          field: 'categoryId',
          operator: FilterOperator.isEqualTo,
          value: categoryId,
        ),
      );
    }

    if (providerId != null) {
      filters.add(
        QueryFilter(
          field: 'providerId',
          operator: FilterOperator.isEqualTo,
          value: providerId,
        ),
      );
    }

    if (isActive != null) {
      filters.add(
        QueryFilter(
          field: 'isActive',
          operator: FilterOperator.isEqualTo,
          value: isActive,
        ),
      );
    }

    if (isAvailable != null) {
      filters.add(
        QueryFilter(
          field: 'isAvailable',
          operator: FilterOperator.isEqualTo,
          value: isAvailable,
        ),
      );
    }

    if (minPrice != null) {
      filters.add(
        QueryFilter(
          field: 'price',
          operator: FilterOperator.isGreaterThanOrEqualTo,
          value: minPrice,
        ),
      );
    }

    if (maxPrice != null) {
      filters.add(
        QueryFilter(
          field: 'price',
          operator: FilterOperator.isLessThanOrEqualTo,
          value: maxPrice,
        ),
      );
    }

    final docs = await _firebase.getDocuments(
      _collectionName,
      filters: filters,
      sorts: [QuerySort(field: 'createdAt', descending: true)],
    );

    var services = docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return ServiceModel.fromMap(data, doc.id);
    }).toList();

    // Filtres locaux pour les critères qui ne peuvent pas être appliqués dans Firestore
    if (minRating != null) {
      services = services
          .where((service) => service.rating >= minRating)
          .toList();
    }

    return services;
  }

  /// Obtient les statistiques des services
  Future<Map<String, dynamic>> getServiceStats() async {
    const cacheKey = 'services_stats';
    final cached = _cache.get<Map<String, dynamic>>(cacheKey);
    if (cached != null) return cached;

    try {
      // Utiliser le service de statistiques pour des calculs optimisés
      final results = await Future.wait([
        _firebase.countDocuments(
          _collectionName,
          cacheKey: 'services_count_total',
        ),
        _firebase.countDocuments(
          _collectionName,
          filters: [
            QueryFilter(
              field: 'isActive',
              operator: FilterOperator.isEqualTo,
              value: true,
            ),
          ],
          cacheKey: 'services_count_active',
        ),
        _firebase.countDocuments(
          _collectionName,
          filters: [
            QueryFilter(
              field: 'isAvailable',
              operator: FilterOperator.isEqualTo,
              value: true,
            ),
          ],
          cacheKey: 'services_count_available',
        ),
      ]);

      final stats = {
        'total': results[0],
        'active': results[1],
        'available': results[2],
        'inactive': results[0] - results[1],
        'last_updated': DateTime.now().toIso8601String(),
      };

      _cache.set(cacheKey, stats, timeout: const Duration(minutes: 5));
      return stats;
    } catch (e) {
      print('❌ Erreur lors du calcul des statistiques: $e');
      return {};
    }
  }

  /// Compte total des services
  Future<int> get totalServicesCount async {
    return await _firebase.countDocuments(
      _collectionName,
      cacheKey: 'services_count_total',
    );
  }

  /// Compte des services actifs
  Future<int> get activeServicesCount async {
    return await _firebase.countDocuments(
      _collectionName,
      filters: [
        QueryFilter(
          field: 'isActive',
          operator: FilterOperator.isEqualTo,
          value: true,
        ),
      ],
      cacheKey: 'services_count_active',
    );
  }

  /// Forcer le rechargement en vidant le cache
  Future<void> forceReload() async {
    _cache.clearByPrefix('services_');
  }

  /// Créer un stream temps réel pour les services
  Stream<List<ServiceModel>> getServicesStream({
    List<QueryFilter>? filters,
    int? limit,
  }) {
    return _firebase
        .createDocumentsStream(
          _collectionName,
          filters: filters,
          sorts: [QuerySort(field: 'createdAt', descending: true)],
          limit: limit,
          streamKey: 'services_stream',
        )
        .map((docs) {
          return docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return ServiceModel.fromMap(data, doc.id);
          }).toList();
        });
  }

  /// Nettoie les ressources (streams, etc.)
  void dispose() {
    _firebase.closeStream('services_stream');
  }

  /// Initialiser des données par défaut si nécessaire
  Future<void> initializeDefaultData() async {
    final count = await _firebase.countDocuments(_collectionName);
    if (count == 0) {
      await _createDefaultServices();
    }
  }

  /// Créer des services par défaut pour les tests
  Future<void> _createDefaultServices() async {
    final defaultServices = [
      ServiceModel(
        id: 'service_001',
        name: 'Nettoyage de vitres',
        description:
            'Service professionnel de nettoyage de vitres pour particuliers et entreprises',
        categoryId: 'category_001',
        categoryName: 'Nettoyage',
        price: 45.0,
        isActive: true,
        isAvailable: true,
        providerId: 'provider_001',
        providerName: 'Jean Dupont',
        rating: 4.5,
        totalReviews: 23,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
        createdBy: 'admin',
      ),
      ServiceModel(
        id: 'service_002',
        name: 'Réparation plomberie',
        description: 'Dépannage et réparation de plomberie d\'urgence',
        categoryId: 'category_002',
        categoryName: 'Plomberie',
        price: 80.0,
        isActive: true,
        isAvailable: true,
        providerId: 'provider_002',
        providerName: 'Marie Martin',
        rating: 4.8,
        totalReviews: 45,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        updatedAt: DateTime.now(),
        createdBy: 'admin',
      ),
      ServiceModel(
        id: 'service_003',
        name: 'Jardinage et entretien',
        description: 'Entretien de jardins, taille de haies, tonte de pelouse',
        categoryId: 'category_003',
        categoryName: 'Jardinage',
        price: 35.0,
        isActive: true,
        isAvailable: false,
        providerId: 'provider_003',
        providerName: 'Pierre Durand',
        rating: 4.2,
        totalReviews: 18,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now(),
        createdBy: 'admin',
      ),
    ];

    // Créer les opérations batch
    final operations = defaultServices.map((service) {
      final docRef = FirebaseFirestore.instance
          .collection(_collectionName)
          .doc(service.id);
      return BatchOperation.create(docRef, service.toMap());
    }).toList();

    await _firebase.executeBatch(operations);

    // Invalider le cache pour forcer le rechargement
    _cache.clearByPrefix('services_');

    print('✅ Services par défaut créés avec succès');
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../models/models.dart';
import '../../../../services/admin_category_manager.dart';

class AdminServiceManager {
  static final AdminServiceManager _instance = AdminServiceManager._internal();
  factory AdminServiceManager() => _instance;
  AdminServiceManager._internal();

  // Instance Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'services';

  // Gestionnaire de catégories
  final AdminCategoryManager _categoryManager = AdminCategoryManager();

  // Cache local pour les performances
  List<ServiceModel> _cachedServices = [];
  DateTime? _lastCacheUpdate;
  final Duration _cacheTimeout = const Duration(minutes: 5);

  // Getters avec récupération automatique des données
  Future<List<ServiceModel>> get allServices async {
    await _ensureDataLoaded();
    return List.unmodifiable(_cachedServices);
  }

  Future<List<ServiceModel>> get activeServices async {
    await _ensureDataLoaded();
    return _cachedServices.where((s) => s.isActive).toList();
  }

  Future<List<ServiceModel>> get inactiveServices async {
    await _ensureDataLoaded();
    return _cachedServices.where((s) => !s.isActive).toList();
  }

  Future<List<ServiceModel>> get availableServices async {
    await _ensureDataLoaded();
    return _cachedServices.where((s) => s.isAvailable).toList();
  }

  // Statistiques
  Future<int> get totalServicesCount async {
    await _ensureDataLoaded();
    return _cachedServices.length;
  }

  Future<int> get activeServicesCount async {
    final active = await activeServices;
    return active.length;
  }

  Future<int> get availableServicesCount async {
    final available = await availableServices;
    return available.length;
  }

  Future<double> get averageRating async {
    await _ensureDataLoaded();
    if (_cachedServices.isEmpty) return 0.0;
    final total = _cachedServices.fold<double>(
      0.0,
      (sum, service) => sum + service.rating,
    );
    return total / _cachedServices.length;
  }

  // Méthodes synchrones pour la compatibilité (utilisent le cache)
  List<ServiceModel> get allServicesSync => List.unmodifiable(_cachedServices);
  List<ServiceModel> get activeServicesSync =>
      _cachedServices.where((s) => s.isActive).toList();
  List<ServiceModel> get inactiveServicesSync =>
      _cachedServices.where((s) => !s.isActive).toList();
  List<ServiceModel> get availableServicesSync =>
      _cachedServices.where((s) => s.isAvailable).toList();
  int get totalServicesCountSync => _cachedServices.length;
  int get activeServicesCountSync => activeServicesSync.length;
  int get availableServicesCountSync => availableServicesSync.length;
  double get averageRatingSync {
    if (_cachedServices.isEmpty) return 0.0;
    final total = _cachedServices.fold<double>(
      0.0,
      (sum, service) => sum + service.rating,
    );
    return total / _cachedServices.length;
  }

  // Initialisation et gestion du cache
  Future<void> _ensureDataLoaded() async {
    if (_cachedServices.isEmpty || _isCacheExpired()) {
      await _loadServicesFromFirestore();
    }
  }

  bool _isCacheExpired() {
    if (_lastCacheUpdate == null) return true;
    return DateTime.now().difference(_lastCacheUpdate!) > _cacheTimeout;
  }

  Future<void> _loadServicesFromFirestore() async {
    try {
      final querySnapshot = await _firestore.collection(_collectionName).get();

      _cachedServices = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return ServiceModel.fromFirestore(data, doc.id);
      }).toList();

      _lastCacheUpdate = DateTime.now();

      // Si aucun service n'existe, créer des services par défaut
      if (_cachedServices.isEmpty) {
        await _createDefaultServices();
      }
    } catch (e) {
      print('Erreur lors du chargement des services: $e');
      // En cas d'erreur, garder une liste vide
      _cachedServices = [];
      _lastCacheUpdate = DateTime.now();
    }
  }

  // CRUD Operations avec Firestore

  /// Créer un nouveau service
  Future<ServiceModel> createService(ServiceModel service) async {
    try {
      // Générer un nouvel ID si nécessaire
      final newService = service.copyWith(
        id: service.id.isEmpty ? _generateId() : service.id,
        createdAt: service.createdAt,
        updatedAt: DateTime.now(),
      );

      // Sauvegarder dans Firestore
      await _firestore
          .collection(_collectionName)
          .doc(newService.id)
          .set(newService.toFirestore());

      // Mettre à jour le cache
      _cachedServices.add(newService);
      _lastCacheUpdate = DateTime.now();

      return newService;
    } catch (e) {
      throw Exception('Erreur lors de la création du service: $e');
    }
  }

  /// Mettre à jour un service existant
  Future<ServiceModel> updateService(ServiceModel service) async {
    try {
      final updatedService = service.copyWith(updatedAt: DateTime.now());

      // Mettre à jour dans Firestore
      await _firestore
          .collection(_collectionName)
          .doc(service.id)
          .update(updatedService.toFirestore());

      // Mettre à jour le cache
      final index = _cachedServices.indexWhere((s) => s.id == service.id);
      if (index != -1) {
        _cachedServices[index] = updatedService;
      }
      _lastCacheUpdate = DateTime.now();

      return updatedService;
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du service: $e');
    }
  }

  /// Supprimer un service
  Future<bool> deleteService(String serviceId) async {
    try {
      // Supprimer de Firestore
      await _firestore.collection(_collectionName).doc(serviceId).delete();

      // Mettre à jour le cache
      final initialLength = _cachedServices.length;
      _cachedServices.removeWhere((s) => s.id == serviceId);
      _lastCacheUpdate = DateTime.now();

      return _cachedServices.length < initialLength;
    } catch (e) {
      throw Exception('Erreur lors de la suppression du service: $e');
    }
  }

  /// Supprimer plusieurs services
  Future<int> deleteServices(List<String> serviceIds) async {
    try {
      int deletedCount = 0;
      final batch = _firestore.batch();

      // Préparer la suppression en batch
      for (final id in serviceIds) {
        batch.delete(_firestore.collection(_collectionName).doc(id));
      }

      // Exécuter le batch
      await batch.commit();

      // Mettre à jour le cache
      for (final id in serviceIds) {
        final initialLength = _cachedServices.length;
        _cachedServices.removeWhere((s) => s.id == id);
        if (_cachedServices.length < initialLength) {
          deletedCount++;
        }
      }
      _lastCacheUpdate = DateTime.now();

      return deletedCount;
    } catch (e) {
      throw Exception('Erreur lors de la suppression des services: $e');
    }
  }

  /// Changer le statut d'un service (actif/inactif)
  Future<ServiceModel> toggleServiceStatus(String serviceId) async {
    try {
      final service = await getServiceById(serviceId);
      if (service == null) {
        throw Exception('Service non trouvé');
      }

      final updatedService = service.copyWith(
        isActive: !service.isActive,
        updatedAt: DateTime.now(),
      );

      // Mettre à jour dans Firestore
      await _firestore.collection(_collectionName).doc(serviceId).update({
        'isActive': updatedService.isActive,
        'updatedAt': updatedService.updatedAt,
      });

      // Mettre à jour le cache
      final index = _cachedServices.indexWhere((s) => s.id == serviceId);
      if (index != -1) {
        _cachedServices[index] = updatedService;
      }
      _lastCacheUpdate = DateTime.now();

      return updatedService;
    } catch (e) {
      throw Exception('Erreur lors du changement de statut: $e');
    }
  }

  /// Changer la disponibilité d'un service
  Future<ServiceModel> toggleServiceAvailability(String serviceId) async {
    try {
      final service = await getServiceById(serviceId);
      if (service == null) {
        throw Exception('Service non trouvé');
      }

      final updatedService = service.copyWith(
        isAvailable: !service.isAvailable,
        updatedAt: DateTime.now(),
      );

      // Mettre à jour dans Firestore
      await _firestore.collection(_collectionName).doc(serviceId).update({
        'isAvailable': updatedService.isAvailable,
        'updatedAt': updatedService.updatedAt,
      });

      // Mettre à jour le cache
      final index = _cachedServices.indexWhere((s) => s.id == serviceId);
      if (index != -1) {
        _cachedServices[index] = updatedService;
      }
      _lastCacheUpdate = DateTime.now();

      return updatedService;
    } catch (e) {
      throw Exception('Erreur lors du changement de disponibilité: $e');
    }
  }

  /// Actions en lot
  Future<List<ServiceModel>> bulkActivateServices(
    List<String> serviceIds,
  ) async {
    try {
      final batch = _firestore.batch();
      final updatedServices = <ServiceModel>[];

      for (final id in serviceIds) {
        batch.update(_firestore.collection(_collectionName).doc(id), {
          'isActive': true,
          'updatedAt': DateTime.now(),
        });

        // Mettre à jour le cache
        final index = _cachedServices.indexWhere((s) => s.id == id);
        if (index != -1) {
          final updatedService = _cachedServices[index].copyWith(
            isActive: true,
            updatedAt: DateTime.now(),
          );
          _cachedServices[index] = updatedService;
          updatedServices.add(updatedService);
        }
      }

      await batch.commit();
      _lastCacheUpdate = DateTime.now();

      return updatedServices;
    } catch (e) {
      throw Exception('Erreur lors de l\'activation des services: $e');
    }
  }

  Future<List<ServiceModel>> bulkDeactivateServices(
    List<String> serviceIds,
  ) async {
    try {
      final batch = _firestore.batch();
      final updatedServices = <ServiceModel>[];

      for (final id in serviceIds) {
        batch.update(_firestore.collection(_collectionName).doc(id), {
          'isActive': false,
          'updatedAt': DateTime.now(),
        });

        // Mettre à jour le cache
        final index = _cachedServices.indexWhere((s) => s.id == id);
        if (index != -1) {
          final updatedService = _cachedServices[index].copyWith(
            isActive: false,
            updatedAt: DateTime.now(),
          );
          _cachedServices[index] = updatedService;
          updatedServices.add(updatedService);
        }
      }

      await batch.commit();
      _lastCacheUpdate = DateTime.now();

      return updatedServices;
    } catch (e) {
      throw Exception('Erreur lors de la désactivation des services: $e');
    }
  }

  // Recherche et filtrage
  Future<List<ServiceModel>> searchServices({
    String? query,
    String? categoryId,
    bool? isActive,
    bool? isAvailable,
  }) async {
    await _ensureDataLoaded();
    var filteredServices = _cachedServices.toList();

    // Filtrer par requête de recherche
    if (query != null && query.isNotEmpty) {
      final lowercaseQuery = query.toLowerCase();
      filteredServices = filteredServices.where((service) {
        return service.name.toLowerCase().contains(lowercaseQuery) ||
            service.description.toLowerCase().contains(lowercaseQuery) ||
            service.categoryName.toLowerCase().contains(lowercaseQuery) ||
            service.tags.any(
              (tag) => tag.toLowerCase().contains(lowercaseQuery),
            );
      }).toList();
    }

    // Filtrer par catégorie
    if (categoryId != null && categoryId.isNotEmpty && categoryId != 'all') {
      filteredServices = filteredServices.where((service) {
        return service.categoryId == categoryId;
      }).toList();
    }

    // Filtrer par statut actif
    if (isActive != null) {
      filteredServices = filteredServices.where((service) {
        return service.isActive == isActive;
      }).toList();
    }

    // Filtrer par disponibilité
    if (isAvailable != null) {
      filteredServices = filteredServices.where((service) {
        return service.isAvailable == isAvailable;
      }).toList();
    }

    return filteredServices;
  }

  /// Obtenir un service par son ID
  Future<ServiceModel?> getServiceById(String id) async {
    await _ensureDataLoaded();
    try {
      return _cachedServices.firstWhere((service) => service.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Obtenir les services par catégorie
  Future<List<ServiceModel>> getServicesByCategory(String categoryId) async {
    await _ensureDataLoaded();
    return _cachedServices
        .where((service) => service.categoryId == categoryId)
        .toList();
  }

  /// Obtenir les catégories avec le nombre de services
  Future<List<Map<String, dynamic>>> getCategoriesWithCount() async {
    await _ensureDataLoaded();

    try {
      final categories = await _categoryManager.getCategories();
      return categories.map((category) {
        final count = _cachedServices
            .where((service) => service.categoryId == category.id)
            .length;
        return {
          'id': category.id,
          'name': category.name,
          'count': count,
          'color': category.color.value,
          'icon': category.iconName,
        };
      }).toList();
    } catch (e) {
      print('Erreur lors de la récupération des catégories: $e');
      return [];
    }
  }

  /// Obtenir toutes les catégories
  Future<List<CategoryModel>> getCategories() async {
    return await _categoryManager.getCategories();
  }

  /// Obtenir les catégories actives
  Future<List<CategoryModel>> getActiveCategories() async {
    return await _categoryManager.getActiveCategories();
  }

  // Utilitaires
  String _generateId() {
    return _firestore.collection(_collectionName).doc().id;
  }

  /// Forcer le rechargement des données
  Future<void> refreshData() async {
    _lastCacheUpdate = null;
    _cachedServices.clear();
    await _loadServicesFromFirestore();
  }

  /// Exporter les services (format CSV)
  Future<String> exportServices() async {
    await _ensureDataLoaded();

    final buffer = StringBuffer();
    buffer.writeln(
      'ID,Nom,Description,Prix,Catégorie,Note,Avis,Actif,Disponible,Créé le,Modifié le',
    );

    for (final service in _cachedServices) {
      buffer.writeln(
        [
          service.id,
          '"${service.name}"',
          '"${service.description.replaceAll('"', '""')}"',
          service.price,
          service.categoryName,
          service.rating,
          service.totalReviews,
          service.isActive ? 'Oui' : 'Non',
          service.isAvailable ? 'Oui' : 'Non',
          _formatDate(service.createdAt),
          _formatDate(service.updatedAt),
        ].join(','),
      );
    }

    return buffer.toString();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  /// Créer des services par défaut si la base est vide
  Future<void> _createDefaultServices() async {
    // S'assurer que les catégories par défaut existent
    await _categoryManager.initializeDefaultCategories();

    final categories = await _categoryManager.getCategories();
    if (categories.isEmpty) {
      print('Aucune catégorie disponible pour créer les services par défaut');
      return;
    }

    final defaultServices = await _getDefaultServices(categories);

    final batch = _firestore.batch();
    for (final service in defaultServices) {
      batch.set(
        _firestore.collection(_collectionName).doc(service.id),
        service.toFirestore(),
      );
    }

    await batch.commit();
    _cachedServices = defaultServices;
    _lastCacheUpdate = DateTime.now();
  }

  Future<List<ServiceModel>> _getDefaultServices(
    List<CategoryModel> categories,
  ) async {
    // Créer une map pour accéder facilement aux catégories par nom
    final categoryMap = {for (var cat in categories) cat.name: cat};

    final services = <ServiceModel>[];

    // Nettoyage
    if (categoryMap.containsKey('Nettoyage')) {
      final cat = categoryMap['Nettoyage']!;
      services.add(
        ServiceModel(
          id: 'default_1',
          name: 'Nettoyage de bureaux',
          description:
              'Service de nettoyage professionnel pour bureaux et espaces commerciaux.',
          price: 80.0,
          categoryId: cat.id,
          categoryName: cat.name,
          rating: 4.5,
          totalReviews: 23,
          isAvailable: true,
          isActive: true,
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
          updatedAt: DateTime.now().subtract(const Duration(days: 1)),
          createdBy: 'admin',
          tags: ['bureau', 'professionnel', 'commercial'],
        ),
      );
    }

    // Réparation
    if (categoryMap.containsKey('Réparation')) {
      final cat = categoryMap['Réparation']!;
      services.add(
        ServiceModel(
          id: 'default_2',
          name: 'Réparation plomberie',
          description: 'Intervention rapide pour tous problèmes de plomberie.',
          price: 120.0,
          categoryId: cat.id,
          categoryName: cat.name,
          rating: 4.8,
          totalReviews: 45,
          isAvailable: false,
          isActive: true,
          createdAt: DateTime.now().subtract(const Duration(days: 15)),
          updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
          createdBy: 'admin',
          tags: ['plomberie', 'urgence', 'domicile'],
        ),
      );
    }

    // Éducation
    if (categoryMap.containsKey('Éducation')) {
      final cat = categoryMap['Éducation']!;
      services.add(
        ServiceModel(
          id: 'default_3',
          name: 'Cours de guitare',
          description: 'Cours particuliers de guitare pour tous niveaux.',
          price: 50.0,
          categoryId: cat.id,
          categoryName: cat.name,
          rating: 4.9,
          totalReviews: 67,
          isAvailable: true,
          isActive: false,
          createdAt: DateTime.now().subtract(const Duration(days: 60)),
          updatedAt: DateTime.now().subtract(const Duration(days: 5)),
          createdBy: 'admin',
          tags: ['musique', 'cours', 'particulier'],
        ),
      );
    }

    // Santé
    if (categoryMap.containsKey('Santé')) {
      final cat = categoryMap['Santé']!;
      services.add(
        ServiceModel(
          id: 'default_4',
          name: 'Massage relaxant',
          description:
              'Séance de massage relaxant à domicile par un professionnel certifié.',
          price: 75.0,
          categoryId: cat.id,
          categoryName: cat.name,
          rating: 4.7,
          totalReviews: 32,
          isAvailable: true,
          isActive: true,
          createdAt: DateTime.now().subtract(const Duration(days: 20)),
          updatedAt: DateTime.now().subtract(const Duration(days: 3)),
          createdBy: 'admin',
          tags: ['massage', 'relaxation', 'domicile', 'bien-être'],
        ),
      );
    }

    // Beauté
    if (categoryMap.containsKey('Beauté')) {
      final cat = categoryMap['Beauté']!;
      services.add(
        ServiceModel(
          id: 'default_5',
          name: 'Coiffure à domicile',
          description: 'Service de coiffure professionnel à votre domicile.',
          price: 45.0,
          categoryId: cat.id,
          categoryName: cat.name,
          rating: 4.6,
          totalReviews: 18,
          isAvailable: true,
          isActive: true,
          createdAt: DateTime.now().subtract(const Duration(days: 10)),
          updatedAt: DateTime.now().subtract(const Duration(hours: 12)),
          createdBy: 'admin',
          tags: ['coiffure', 'domicile', 'beauté'],
        ),
      );
    }

    return services;
  }

  /// Réinitialiser les données (pour les tests)
  Future<void> reset() async {
    try {
      // Supprimer tous les documents de la collection
      final querySnapshot = await _firestore.collection(_collectionName).get();
      final batch = _firestore.batch();

      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      // Vider le cache
      _cachedServices.clear();
      _lastCacheUpdate = null;
    } catch (e) {
      print('Erreur lors de la réinitialisation: $e');
    }
  }
}

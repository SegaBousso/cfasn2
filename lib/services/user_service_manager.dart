import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

class UserServiceManager {
  static final UserServiceManager _instance = UserServiceManager._internal();
  factory UserServiceManager() => _instance;
  UserServiceManager._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'services';

  // Cache local pour améliorer les performances
  List<ServiceModel> _cachedServices = [];
  DateTime? _lastCacheUpdate;
  final Duration _cacheTimeout = const Duration(minutes: 10);

  /// Récupère tous les services actifs et disponibles
  Future<List<ServiceModel>> getActiveServices() async {
    try {
      await _loadServicesIfNeeded();
      return _cachedServices
          .where((service) => service.isActive && service.isAvailable)
          .toList();
    } catch (e) {
      print('Erreur lors de la récupération des services: $e');
      return [];
    }
  }

  /// Récupère les services populaires (basés sur la note)
  Future<List<ServiceModel>> getPopularServices({int limit = 10}) async {
    try {
      final activeServices = await getActiveServices();
      activeServices.sort((a, b) => b.rating.compareTo(a.rating));
      return activeServices.take(limit).toList();
    } catch (e) {
      print('Erreur lors de la récupération des services populaires: $e');
      return [];
    }
  }

  /// Récupère les services récents
  Future<List<ServiceModel>> getRecentServices({int limit = 10}) async {
    try {
      final activeServices = await getActiveServices();
      activeServices.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return activeServices.take(limit).toList();
    } catch (e) {
      print('Erreur lors de la récupération des services récents: $e');
      return [];
    }
  }

  /// Récupère les services par catégorie
  Future<List<ServiceModel>> getServicesByCategory(String categoryId) async {
    try {
      final activeServices = await getActiveServices();
      return activeServices
          .where((service) => service.categoryId == categoryId)
          .toList();
    } catch (e) {
      print('Erreur lors de la récupération des services par catégorie: $e');
      return [];
    }
  }

  /// Recherche des services par nom ou description
  Future<List<ServiceModel>> searchServices(String query) async {
    try {
      final activeServices = await getActiveServices();
      final lowercaseQuery = query.toLowerCase();

      return activeServices.where((service) {
        return service.name.toLowerCase().contains(lowercaseQuery) ||
            service.description.toLowerCase().contains(lowercaseQuery) ||
            service.tags.any(
              (tag) => tag.toLowerCase().contains(lowercaseQuery),
            );
      }).toList();
    } catch (e) {
      print('Erreur lors de la recherche de services: $e');
      return [];
    }
  }

  /// Récupère un service par son ID
  Future<ServiceModel?> getServiceById(String serviceId) async {
    try {
      final doc = await _firestore
          .collection(_collectionName)
          .doc(serviceId)
          .get();

      if (doc.exists && doc.data() != null) {
        return ServiceModel.fromFirestore(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('Erreur lors de la récupération du service: $e');
      return null;
    }
  }

  /// Récupère tous les services (actifs et inactifs) pour les statistiques
  Future<List<ServiceModel>> getAllServices() async {
    try {
      await _loadServicesIfNeeded();
      return List.from(_cachedServices);
    } catch (e) {
      print('Erreur lors de la récupération de tous les services: $e');
      return [];
    }
  }

  /// Charge les services depuis Firestore si nécessaire
  Future<void> _loadServicesIfNeeded() async {
    final now = DateTime.now();

    // Vérifier si le cache est encore valide
    if (_lastCacheUpdate != null &&
        now.difference(_lastCacheUpdate!) < _cacheTimeout &&
        _cachedServices.isNotEmpty) {
      return; // Le cache est encore valide
    }

    await _loadServicesFromFirestore();
  }

  /// Charge tous les services depuis Firestore
  Future<void> _loadServicesFromFirestore() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .orderBy('createdAt', descending: true)
          .get();

      _cachedServices = querySnapshot.docs
          .map((doc) => ServiceModel.fromFirestore(doc.data(), doc.id))
          .toList();

      _lastCacheUpdate = DateTime.now();

      print('${_cachedServices.length} services chargés depuis Firestore');
    } catch (e) {
      print('Erreur lors du chargement des services depuis Firestore: $e');
      _cachedServices = [];
    }
  }

  /// Force le rechargement des données depuis Firestore
  Future<void> refreshServices() async {
    _lastCacheUpdate = null;
    await _loadServicesFromFirestore();
  }

  /// Vide le cache local
  void clearCache() {
    _cachedServices.clear();
    _lastCacheUpdate = null;
  }

  /// Écoute les changements en temps réel (optionnel)
  Stream<List<ServiceModel>> getServicesStream() {
    return _firestore
        .collection(_collectionName)
        .where('isActive', isEqualTo: true)
        .where('isAvailable', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ServiceModel.fromFirestore(doc.data(), doc.id))
              .toList();
        });
  }
}

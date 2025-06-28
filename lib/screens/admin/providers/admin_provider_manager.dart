import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../models/models.dart';

class AdminProviderManager {
  static final AdminProviderManager _instance =
      AdminProviderManager._internal();
  factory AdminProviderManager() => _instance;
  AdminProviderManager._internal();

  // Instance Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'providers';

  // Cache local pour les performances
  List<ProviderModel> _cachedProviders = [];
  DateTime? _lastCacheUpdate;
  final Duration _cacheTimeout = const Duration(minutes: 5);

  // Getters avec récupération automatique des données
  Future<List<ProviderModel>> get allProviders async {
    await _ensureDataLoaded();
    return List.unmodifiable(_cachedProviders);
  }

  Future<List<ProviderModel>> get activeProviders async {
    await _ensureDataLoaded();
    return _cachedProviders.where((p) => p.isActive).toList();
  }

  Future<List<ProviderModel>> get verifiedProviders async {
    await _ensureDataLoaded();
    return _cachedProviders.where((p) => p.isVerified).toList();
  }

  Future<List<ProviderModel>> get availableProviders async {
    await _ensureDataLoaded();
    return _cachedProviders.where((p) => p.isAvailable && p.isActive).toList();
  }

  // Getters synchrones pour le cache
  List<ProviderModel> get allProvidersSync =>
      List.unmodifiable(_cachedProviders);

  /// S'assurer que les données sont chargées et à jour
  Future<void> _ensureDataLoaded() async {
    if (_cachedProviders.isEmpty || _isCacheExpired()) {
      await _loadProvidersFromFirestore();
    }
  }

  bool _isCacheExpired() {
    if (_lastCacheUpdate == null) return true;
    return DateTime.now().difference(_lastCacheUpdate!) > _cacheTimeout;
  }

  /// Charger les prestataires depuis Firestore
  Future<void> _loadProvidersFromFirestore() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_collectionName)
          .orderBy('createdAt', descending: true)
          .get();

      _cachedProviders = snapshot.docs
          .map(
            (doc) => ProviderModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();

      _lastCacheUpdate = DateTime.now();
    } catch (e) {
      throw Exception('Erreur lors du chargement des prestataires: $e');
    }
  }

  /// Créer un nouveau prestataire
  Future<ProviderModel> createProvider(ProviderModel provider) async {
    try {
      final DocumentReference docRef = await _firestore
          .collection(_collectionName)
          .add(provider.toMap());

      final ProviderModel newProvider = provider.copyWith(id: docRef.id);

      // Mettre à jour le cache
      _cachedProviders.insert(0, newProvider);
      _lastCacheUpdate = DateTime.now();

      return newProvider;
    } catch (e) {
      throw Exception('Erreur lors de la création du prestataire: $e');
    }
  }

  /// Mettre à jour un prestataire
  Future<ProviderModel> updateProvider(ProviderModel provider) async {
    try {
      final updatedProvider = provider.copyWith(updatedAt: DateTime.now());

      await _firestore
          .collection(_collectionName)
          .doc(provider.id)
          .update(updatedProvider.toMap());

      // Mettre à jour le cache
      final index = _cachedProviders.indexWhere((p) => p.id == provider.id);
      if (index != -1) {
        _cachedProviders[index] = updatedProvider;
      }
      _lastCacheUpdate = DateTime.now();

      return updatedProvider;
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du prestataire: $e');
    }
  }

  /// Supprimer un prestataire
  Future<void> deleteProvider(String providerId) async {
    try {
      await _firestore.collection(_collectionName).doc(providerId).delete();

      // Mettre à jour le cache
      _cachedProviders.removeWhere((p) => p.id == providerId);
      _lastCacheUpdate = DateTime.now();
    } catch (e) {
      throw Exception('Erreur lors de la suppression du prestataire: $e');
    }
  }

  /// Obtenir un prestataire par son ID
  Future<ProviderModel?> getProviderById(String providerId) async {
    await _ensureDataLoaded();
    return _cachedProviders.firstWhere(
      (p) => p.id == providerId,
      orElse: () => throw Exception('Prestataire non trouvé'),
    );
  }

  /// Rechercher des prestataires
  Future<List<ProviderModel>> searchProviders(String query) async {
    await _ensureDataLoaded();

    if (query.isEmpty) return _cachedProviders;

    final lowerQuery = query.toLowerCase();
    return _cachedProviders.where((provider) {
      return provider.name.toLowerCase().contains(lowerQuery) ||
          provider.email.toLowerCase().contains(lowerQuery) ||
          provider.specialty.toLowerCase().contains(lowerQuery) ||
          provider.specialties.any((s) => s.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  /// Filtrer par spécialité
  Future<List<ProviderModel>> getProvidersBySpecialty(String specialty) async {
    await _ensureDataLoaded();
    return _cachedProviders
        .where(
          (p) => p.specialty == specialty || p.specialties.contains(specialty),
        )
        .toList();
  }

  /// Activer/désactiver un prestataire
  Future<ProviderModel> toggleProviderStatus(String providerId) async {
    try {
      final provider = await getProviderById(providerId);
      if (provider == null) {
        throw Exception('Prestataire non trouvé');
      }

      final updatedProvider = provider.copyWith(
        isActive: !provider.isActive,
        updatedAt: DateTime.now(),
      );

      await _firestore.collection(_collectionName).doc(providerId).update({
        'isActive': updatedProvider.isActive,
        'updatedAt': updatedProvider.updatedAt,
      });

      // Mettre à jour le cache
      final index = _cachedProviders.indexWhere((p) => p.id == providerId);
      if (index != -1) {
        _cachedProviders[index] = updatedProvider;
      }
      _lastCacheUpdate = DateTime.now();

      return updatedProvider;
    } catch (e) {
      throw Exception('Erreur lors du changement de statut: $e');
    }
  }

  /// Vérifier un prestataire
  Future<ProviderModel> verifyProvider(String providerId) async {
    try {
      final provider = await getProviderById(providerId);
      if (provider == null) {
        throw Exception('Prestataire non trouvé');
      }

      final updatedProvider = provider.copyWith(
        isVerified: true,
        updatedAt: DateTime.now(),
      );

      await _firestore.collection(_collectionName).doc(providerId).update({
        'isVerified': true,
        'updatedAt': updatedProvider.updatedAt,
      });

      // Mettre à jour le cache
      final index = _cachedProviders.indexWhere((p) => p.id == providerId);
      if (index != -1) {
        _cachedProviders[index] = updatedProvider;
      }
      _lastCacheUpdate = DateTime.now();

      return updatedProvider;
    } catch (e) {
      throw Exception('Erreur lors de la vérification: $e');
    }
  }

  /// Ajouter un service à un prestataire
  Future<void> addServiceToProvider(String providerId, String serviceId) async {
    try {
      final provider = await getProviderById(providerId);
      if (provider == null) {
        throw Exception('Prestataire non trouvé');
      }

      if (!provider.serviceIds.contains(serviceId)) {
        final updatedServiceIds = [...provider.serviceIds, serviceId];

        await _firestore.collection(_collectionName).doc(providerId).update({
          'serviceIds': updatedServiceIds,
          'updatedAt': DateTime.now(),
        });

        // Mettre à jour le cache
        final index = _cachedProviders.indexWhere((p) => p.id == providerId);
        if (index != -1) {
          _cachedProviders[index] = provider.copyWith(
            serviceIds: updatedServiceIds,
            updatedAt: DateTime.now(),
          );
        }
        _lastCacheUpdate = DateTime.now();
      }
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout du service: $e');
    }
  }

  /// Retirer un service d'un prestataire
  Future<void> removeServiceFromProvider(
    String providerId,
    String serviceId,
  ) async {
    try {
      final provider = await getProviderById(providerId);
      if (provider == null) {
        throw Exception('Prestataire non trouvé');
      }

      final updatedServiceIds = provider.serviceIds
          .where((id) => id != serviceId)
          .toList();

      await _firestore.collection(_collectionName).doc(providerId).update({
        'serviceIds': updatedServiceIds,
        'updatedAt': DateTime.now(),
      });

      // Mettre à jour le cache
      final index = _cachedProviders.indexWhere((p) => p.id == providerId);
      if (index != -1) {
        _cachedProviders[index] = provider.copyWith(
          serviceIds: updatedServiceIds,
          updatedAt: DateTime.now(),
        );
      }
      _lastCacheUpdate = DateTime.now();
    } catch (e) {
      throw Exception('Erreur lors du retrait du service: $e');
    }
  }

  /// Obtenir les statistiques des prestataires
  Future<Map<String, int>> getProviderStats() async {
    await _ensureDataLoaded();

    return {
      'total': _cachedProviders.length,
      'active': _cachedProviders.where((p) => p.isActive).length,
      'verified': _cachedProviders.where((p) => p.isVerified).length,
      'available': _cachedProviders.where((p) => p.isAvailable).length,
    };
  }

  /// Actions en lot - activer plusieurs prestataires
  Future<void> bulkActivateProviders(List<String> providerIds) async {
    try {
      final batch = _firestore.batch();

      for (final providerId in providerIds) {
        final docRef = _firestore.collection(_collectionName).doc(providerId);
        batch.update(docRef, {'isActive': true, 'updatedAt': DateTime.now()});
      }

      await batch.commit();

      // Mettre à jour le cache
      for (final providerId in providerIds) {
        final index = _cachedProviders.indexWhere((p) => p.id == providerId);
        if (index != -1) {
          _cachedProviders[index] = _cachedProviders[index].copyWith(
            isActive: true,
            updatedAt: DateTime.now(),
          );
        }
      }
      _lastCacheUpdate = DateTime.now();
    } catch (e) {
      throw Exception('Erreur lors de l\'activation en lot: $e');
    }
  }

  /// Actions en lot - désactiver plusieurs prestataires
  Future<void> bulkDeactivateProviders(List<String> providerIds) async {
    try {
      final batch = _firestore.batch();

      for (final providerId in providerIds) {
        final docRef = _firestore.collection(_collectionName).doc(providerId);
        batch.update(docRef, {'isActive': false, 'updatedAt': DateTime.now()});
      }

      await batch.commit();

      // Mettre à jour le cache
      for (final providerId in providerIds) {
        final index = _cachedProviders.indexWhere((p) => p.id == providerId);
        if (index != -1) {
          _cachedProviders[index] = _cachedProviders[index].copyWith(
            isActive: false,
            updatedAt: DateTime.now(),
          );
        }
      }
      _lastCacheUpdate = DateTime.now();
    } catch (e) {
      throw Exception('Erreur lors de la désactivation en lot: $e');
    }
  }

  /// Supprimer plusieurs prestataires
  Future<void> bulkDeleteProviders(List<String> providerIds) async {
    try {
      final batch = _firestore.batch();

      for (final providerId in providerIds) {
        final docRef = _firestore.collection(_collectionName).doc(providerId);
        batch.delete(docRef);
      }

      await batch.commit();

      // Mettre à jour le cache
      _cachedProviders.removeWhere((p) => providerIds.contains(p.id));
      _lastCacheUpdate = DateTime.now();
    } catch (e) {
      throw Exception('Erreur lors de la suppression en lot: $e');
    }
  }

  /// Initialiser des prestataires par défaut pour les tests
  Future<void> initializeDefaultProviders() async {
    final providers = await allProviders;
    if (providers.isNotEmpty)
      return; // Ne pas réinitialiser si des données existent

    final defaultProviders = [
      ProviderModel(
        id: '',
        name: 'Jean Nettoyeur',
        email: 'jean.nettoyeur@example.com',
        phoneNumber: '+33123456789',
        address: '123 Rue de la Propreté, 75001 Paris',
        specialty: 'Nettoyage',
        specialties: ['Nettoyage de bureaux', 'Nettoyage résidentiel'],
        yearsOfExperience: 5,
        rating: 4.5,
        ratingsCount: 23,
        completedJobs: 150,
        isVerified: true,
        isActive: true,
        isAvailable: true,
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
        updatedAt: DateTime.now(),
        workingAreas: ['Paris', 'Banlieue parisienne'],
        certifications: ['Certification Hygiène', 'Formation Sécurité'],
      ),
      ProviderModel(
        id: '',
        name: 'Marie Réparatrice',
        email: 'marie.reparatrice@example.com',
        phoneNumber: '+33123456790',
        address: '456 Avenue des Outils, 69000 Lyon',
        specialty: 'Réparation',
        specialties: ['Électricité', 'Plomberie', 'Serrurerie'],
        yearsOfExperience: 8,
        rating: 4.8,
        ratingsCount: 45,
        completedJobs: 320,
        isVerified: true,
        isActive: true,
        isAvailable: true,
        createdAt: DateTime.now().subtract(const Duration(days: 300)),
        updatedAt: DateTime.now(),
        workingAreas: ['Lyon', 'Villeurbanne', 'Caluire'],
        certifications: ['Électricien agréé', 'Plombier certifié'],
      ),
    ];

    for (final provider in defaultProviders) {
      await createProvider(provider);
    }
  }

  /// Réinitialiser les données (pour les tests)
  Future<void> reset() async {
    try {
      final batch = _firestore.batch();
      final snapshot = await _firestore.collection(_collectionName).get();

      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      _cachedProviders.clear();
      _lastCacheUpdate = null;
    } catch (e) {
      throw Exception('Erreur lors de la réinitialisation: $e');
    }
  }
}

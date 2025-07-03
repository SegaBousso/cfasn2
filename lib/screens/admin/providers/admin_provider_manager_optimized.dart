import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/models.dart';
import '../utils/admin_cache_manager.dart';
import '../services/admin_firebase_manager.dart';

/// Gestionnaire administrateur pour les prestataires avec optimisations Firebase et cache
class AdminProviderManager {
  static final AdminProviderManager _instance =
      AdminProviderManager._internal();
  factory AdminProviderManager() => _instance;
  AdminProviderManager._internal();

  // Services optimisés
  final AdminFirebaseManager _firebaseManager = AdminFirebaseManager();
  final AdminCacheManager _cache = AdminCacheManager();
  final String _collectionName = 'providers';

  // Getters avec récupération automatique des données et cache optimisé
  Future<List<ProviderModel>> get allProviders async {
    const cacheKey = AdminCacheKeys.providersAll;

    // Vérifier le cache d'abord
    final cached = _cache.get<List<ProviderModel>>(cacheKey);
    if (cached != null) return cached;

    // Charger depuis Firebase
    final docs = await _firebaseManager.getDocuments(
      _collectionName,
      sorts: [QuerySort(field: 'createdAt', descending: true)],
      cacheKey: cacheKey,
      cacheTimeout: const Duration(minutes: 10),
    );

    final providers = docs
        .map(
          (doc) =>
              ProviderModel.fromMap(doc.data() as Map<String, dynamic>, doc.id),
        )
        .toList();

    // Mettre en cache localement
    _cache.set(cacheKey, providers);
    return providers;
  }

  Future<List<ProviderModel>> get activeProviders async {
    const cacheKey = AdminCacheKeys.providersActive;

    final cached = _cache.get<List<ProviderModel>>(cacheKey);
    if (cached != null) return cached;

    final docs = await _firebaseManager.getDocuments(
      _collectionName,
      filters: [
        QueryFilter(
          field: 'isActive',
          operator: FilterOperator.isEqualTo,
          value: true,
        ),
      ],
      sorts: [QuerySort(field: 'createdAt', descending: true)],
      cacheKey: cacheKey,
      cacheTimeout: const Duration(minutes: 10),
    );

    final providers = docs
        .map(
          (doc) =>
              ProviderModel.fromMap(doc.data() as Map<String, dynamic>, doc.id),
        )
        .toList();

    _cache.set(cacheKey, providers);
    return providers;
  }

  Future<List<ProviderModel>> get verifiedProviders async {
    const cacheKey = AdminCacheKeys.providersVerified;

    final cached = _cache.get<List<ProviderModel>>(cacheKey);
    if (cached != null) return cached;

    final docs = await _firebaseManager.getDocuments(
      _collectionName,
      filters: [
        QueryFilter(
          field: 'isVerified',
          operator: FilterOperator.isEqualTo,
          value: true,
        ),
      ],
      sorts: [QuerySort(field: 'createdAt', descending: true)],
      cacheKey: cacheKey,
      cacheTimeout: const Duration(minutes: 10),
    );

    final providers = docs
        .map(
          (doc) =>
              ProviderModel.fromMap(doc.data() as Map<String, dynamic>, doc.id),
        )
        .toList();

    _cache.set(cacheKey, providers);
    return providers;
  }

  Future<List<ProviderModel>> get availableProviders async {
    final all = await allProviders;
    return all.where((p) => p.isAvailable && p.isActive).toList();
  }

  /// Créer un nouveau prestataire avec optimisations
  Future<ProviderModel> createProvider(ProviderModel provider) async {
    try {
      final providerData = provider
          .copyWith(createdAt: DateTime.now(), updatedAt: DateTime.now())
          .toMap();

      final docRef = FirebaseFirestore.instance
          .collection(_collectionName)
          .doc();

      await _firebaseManager.executeBatch([
        BatchOperation.create(docRef, providerData),
      ]);

      final newProvider = provider.copyWith(id: docRef.id);

      // Invalider le cache pour forcer le rechargement
      _cache.clearByPrefix('providers_');

      return newProvider;
    } catch (e) {
      throw Exception('Erreur lors de la création du prestataire: $e');
    }
  }

  /// Mettre à jour un prestataire avec optimisations
  Future<ProviderModel> updateProvider(ProviderModel provider) async {
    try {
      final updatedProvider = provider.copyWith(updatedAt: DateTime.now());
      final docRef = FirebaseFirestore.instance
          .collection(_collectionName)
          .doc(provider.id);

      await _firebaseManager.executeBatch([
        BatchOperation.update(docRef, updatedProvider.toMap()),
      ]);

      // Invalider le cache
      _cache.clearByPrefix('providers_');
      _cache.remove(AdminCacheKeys.providerById(provider.id));

      return updatedProvider;
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du prestataire: $e');
    }
  }

  /// Supprimer un prestataire avec optimisations
  Future<void> deleteProvider(String providerId) async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection(_collectionName)
          .doc(providerId);

      await _firebaseManager.executeBatch([BatchOperation.delete(docRef)]);

      // Invalider le cache
      _cache.clearByPrefix('providers_');
      _cache.remove(AdminCacheKeys.providerById(providerId));
    } catch (e) {
      throw Exception('Erreur lors de la suppression du prestataire: $e');
    }
  }

  /// Obtenir un prestataire par son ID avec cache optimisé
  Future<ProviderModel?> getProviderById(String providerId) async {
    final cacheKey = AdminCacheKeys.providerById(providerId);

    // Vérifier le cache d'abord
    final cached = _cache.get<ProviderModel>(cacheKey);
    if (cached != null) return cached;

    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection(_collectionName)
          .doc(providerId)
          .get();

      if (!docSnapshot.exists) return null;

      final provider = ProviderModel.fromMap(
        docSnapshot.data() as Map<String, dynamic>,
        docSnapshot.id,
      );

      // Mettre en cache
      _cache.set(cacheKey, provider);
      return provider;
    } catch (e) {
      print('Erreur lors de la récupération du prestataire $providerId: $e');
      return null;
    }
  }

  /// Rechercher des prestataires avec optimisations
  Future<List<ProviderModel>> searchProviders(String query) async {
    if (query.isEmpty) return await allProviders;

    // Pour la recherche, on charge tous les providers et on filtre localement
    // Une optimisation future pourrait utiliser Algolia ou similar
    final providers = await allProviders;

    final lowerQuery = query.toLowerCase();
    return providers.where((provider) {
      return provider.name.toLowerCase().contains(lowerQuery) ||
          provider.email.toLowerCase().contains(lowerQuery) ||
          provider.specialty.toLowerCase().contains(lowerQuery) ||
          provider.specialties.any((s) => s.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  /// Filtrer par spécialité avec optimisations
  Future<List<ProviderModel>> getProvidersBySpecialty(String specialty) async {
    final docs = await _firebaseManager.getDocuments(
      _collectionName,
      filters: [
        QueryFilter(
          field: 'specialty',
          operator: FilterOperator.isEqualTo,
          value: specialty,
        ),
      ],
      sorts: [QuerySort(field: 'createdAt', descending: true)],
    );

    return docs
        .map(
          (doc) =>
              ProviderModel.fromMap(doc.data() as Map<String, dynamic>, doc.id),
        )
        .toList();
  }

  /// Activer/désactiver un prestataire avec optimisations
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

      final docRef = FirebaseFirestore.instance
          .collection(_collectionName)
          .doc(providerId);
      await _firebaseManager.executeBatch([
        BatchOperation.update(docRef, {
          'isActive': updatedProvider.isActive,
          'updatedAt': updatedProvider.updatedAt,
        }),
      ]);

      // Invalider le cache
      _cache.clearByPrefix('providers_');
      _cache.remove(AdminCacheKeys.providerById(providerId));

      return updatedProvider;
    } catch (e) {
      throw Exception('Erreur lors du changement de statut: $e');
    }
  }

  /// Vérifier un prestataire avec optimisations
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

      final docRef = FirebaseFirestore.instance
          .collection(_collectionName)
          .doc(providerId);
      await _firebaseManager.executeBatch([
        BatchOperation.update(docRef, {
          'isVerified': true,
          'updatedAt': updatedProvider.updatedAt,
        }),
      ]);

      // Invalider le cache
      _cache.clearByPrefix('providers_');
      _cache.remove(AdminCacheKeys.providerById(providerId));

      return updatedProvider;
    } catch (e) {
      throw Exception('Erreur lors de la vérification: $e');
    }
  }

  /// Obtenir les statistiques des prestataires avec cache
  Future<Map<String, int>> getProviderStats() async {
    const cacheKey = 'provider_stats';

    final cached = _cache.get<Map<String, int>>(cacheKey);
    if (cached != null) return cached;

    final providers = await allProviders;

    final stats = {
      'total': providers.length,
      'active': providers.where((p) => p.isActive).length,
      'verified': providers.where((p) => p.isVerified).length,
      'available': providers.where((p) => p.isAvailable).length,
    };

    _cache.set(cacheKey, stats, timeout: const Duration(minutes: 5));
    return stats;
  }

  /// Actions en lot optimisées - activer plusieurs prestataires
  Future<void> bulkActivateProviders(List<String> providerIds) async {
    try {
      final operations = providerIds.map((id) {
        final docRef = FirebaseFirestore.instance
            .collection(_collectionName)
            .doc(id);
        return BatchOperation.update(docRef, {
          'isActive': true,
          'updatedAt': DateTime.now(),
        });
      }).toList();

      await _firebaseManager.executeBatch(operations);

      // Invalider le cache
      _cache.clearByPrefix('providers_');
      for (final id in providerIds) {
        _cache.remove(AdminCacheKeys.providerById(id));
      }
    } catch (e) {
      throw Exception('Erreur lors de l\'activation en lot: $e');
    }
  }

  /// Actions en lot optimisées - désactiver plusieurs prestataires
  Future<void> bulkDeactivateProviders(List<String> providerIds) async {
    try {
      final operations = providerIds.map((id) {
        final docRef = FirebaseFirestore.instance
            .collection(_collectionName)
            .doc(id);
        return BatchOperation.update(docRef, {
          'isActive': false,
          'updatedAt': DateTime.now(),
        });
      }).toList();

      await _firebaseManager.executeBatch(operations);

      // Invalider le cache
      _cache.clearByPrefix('providers_');
      for (final id in providerIds) {
        _cache.remove(AdminCacheKeys.providerById(id));
      }
    } catch (e) {
      throw Exception('Erreur lors de la désactivation en lot: $e');
    }
  }

  /// Supprimer plusieurs prestataires avec optimisations
  Future<void> bulkDeleteProviders(List<String> providerIds) async {
    try {
      final operations = providerIds.map((id) {
        final docRef = FirebaseFirestore.instance
            .collection(_collectionName)
            .doc(id);
        return BatchOperation.delete(docRef);
      }).toList();

      await _firebaseManager.executeBatch(operations);

      // Invalider le cache
      _cache.clearByPrefix('providers_');
      for (final id in providerIds) {
        _cache.remove(AdminCacheKeys.providerById(id));
      }
    } catch (e) {
      throw Exception('Erreur lors de la suppression en lot: $e');
    }
  }

  /// Stream pour les mises à jour en temps réel
  Stream<List<ProviderModel>> getProvidersStream() {
    return _firebaseManager
        .createDocumentsStream(
          _collectionName,
          sorts: [QuerySort(field: 'createdAt', descending: true)],
          streamKey: 'providers_stream',
        )
        .map(
          (docs) => docs
              .map(
                (doc) => ProviderModel.fromMap(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList(),
        );
  }

  /// Nettoyer les ressources
  void dispose() {
    _firebaseManager.closeStream('providers_stream');
  }
}

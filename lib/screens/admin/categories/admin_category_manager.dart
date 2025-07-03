import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../models/service_model.dart';
import '../utils/admin_cache_manager.dart';
import '../services/admin_firebase_manager.dart';

/// Gestionnaire administrateur pour les catégories avec optimisations Firebase et cache
class AdminCategoryManager {
  static final AdminCategoryManager _instance =
      AdminCategoryManager._internal();
  factory AdminCategoryManager() => _instance;
  AdminCategoryManager._internal();

  // Services optimisés
  final AdminFirebaseManager _firebaseManager = AdminFirebaseManager();
  final AdminCacheManager _cache = AdminCacheManager();
  final String _collectionName = 'categories';

  /// Récupère toutes les catégories avec cache optimisé
  Future<List<ServiceCategory>> getAllCategories() async {
    const cacheKey = AdminCacheKeys.categoriesAll;

    // Vérifier le cache d'abord
    final cached = _cache.get<List<ServiceCategory>>(cacheKey);
    if (cached != null) return cached;

    try {
      final docs = await _firebaseManager.getDocuments(
        _collectionName,
        sorts: [QuerySort(field: 'name', descending: false)],
        cacheKey: cacheKey,
        cacheTimeout: const Duration(minutes: 15),
      );

      final categories = docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return ServiceCategory(
          id: doc.id,
          name: data['name'] ?? 'Catégorie',
          icon: _getIconFromString(data['icon']),
          servicesCount: data['servicesCount'] ?? 0,
        );
      }).toList();

      // Ajouter la catégorie "Tous" en premier
      final allCategory = ServiceCategory(
        id: 'all',
        name: 'Tous',
        icon: Icons.apps,
        servicesCount: await _getTotalServicesCount(),
      );

      final result = [allCategory, ...categories];
      _cache.set(cacheKey, result);
      return result;
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

  /// Récupère une catégorie par son ID
  Future<ServiceCategory?> getCategoryById(String categoryId) async {
    final cacheKey = AdminCacheKeys.categoryById(categoryId);

    // Vérifier le cache d'abord
    final cached = _cache.get<ServiceCategory>(cacheKey);
    if (cached != null) return cached;

    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection(_collectionName)
          .doc(categoryId)
          .get();

      if (!docSnapshot.exists) return null;

      final data = docSnapshot.data() as Map<String, dynamic>;
      final category = ServiceCategory(
        id: docSnapshot.id,
        name: data['name'] ?? 'Catégorie',
        icon: _getIconFromString(data['icon']),
        servicesCount: await _getServicesCountForCategory(categoryId),
      );

      _cache.set(cacheKey, category);
      return category;
    } catch (e) {
      print('Erreur lors de la récupération de la catégorie $categoryId: $e');
      return null;
    }
  }

  /// Crée une nouvelle catégorie
  Future<ServiceCategory> createCategory({
    required String name,
    required String icon,
  }) async {
    try {
      final categoryData = {
        'name': name,
        'icon': icon,
        'servicesCount': 0,
        'createdAt': DateTime.now(),
        'updatedAt': DateTime.now(),
      };

      final docRef = FirebaseFirestore.instance
          .collection(_collectionName)
          .doc();

      await _firebaseManager.executeBatch([
        BatchOperation.create(docRef, categoryData),
      ]);

      final newCategory = ServiceCategory(
        id: docRef.id,
        name: name,
        icon: _getIconFromString(icon),
        servicesCount: 0,
      );

      // Invalider le cache
      _cache.clearByPrefix('categories_');

      return newCategory;
    } catch (e) {
      throw Exception('Erreur lors de la création de la catégorie: $e');
    }
  }

  /// Met à jour une catégorie
  Future<ServiceCategory> updateCategory({
    required String categoryId,
    required String name,
    required String icon,
  }) async {
    try {
      final updateData = {
        'name': name,
        'icon': icon,
        'updatedAt': DateTime.now(),
      };

      final docRef = FirebaseFirestore.instance
          .collection(_collectionName)
          .doc(categoryId);

      await _firebaseManager.executeBatch([
        BatchOperation.update(docRef, updateData),
      ]);

      final updatedCategory = ServiceCategory(
        id: categoryId,
        name: name,
        icon: _getIconFromString(icon),
        servicesCount: await _getServicesCountForCategory(categoryId),
      );

      // Invalider le cache
      _cache.clearByPrefix('categories_');
      _cache.remove(AdminCacheKeys.categoryById(categoryId));

      return updatedCategory;
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de la catégorie: $e');
    }
  }

  /// Supprime une catégorie
  Future<void> deleteCategory(String categoryId) async {
    try {
      // Vérifier qu'aucun service n'utilise cette catégorie
      final servicesCount = await _getServicesCountForCategory(categoryId);
      if (servicesCount > 0) {
        throw Exception(
          'Impossible de supprimer une catégorie contenant des services',
        );
      }

      final docRef = FirebaseFirestore.instance
          .collection(_collectionName)
          .doc(categoryId);

      await _firebaseManager.executeBatch([BatchOperation.delete(docRef)]);

      // Invalider le cache
      _cache.clearByPrefix('categories_');
      _cache.remove(AdminCacheKeys.categoryById(categoryId));
    } catch (e) {
      throw Exception('Erreur lors de la suppression de la catégorie: $e');
    }
  }

  /// Met à jour le compteur de services pour une catégorie
  Future<void> updateServicesCount(String categoryId) async {
    try {
      final servicesCount = await _getServicesCountForCategory(categoryId);

      final docRef = FirebaseFirestore.instance
          .collection(_collectionName)
          .doc(categoryId);

      await _firebaseManager.executeBatch([
        BatchOperation.update(docRef, {
          'servicesCount': servicesCount,
          'updatedAt': DateTime.now(),
        }),
      ]);

      // Invalider le cache
      _cache.clearByPrefix('categories_');
      _cache.remove(AdminCacheKeys.categoryById(categoryId));
    } catch (e) {
      print('Erreur lors de la mise à jour du compteur de services: $e');
    }
  }

  /// Met à jour tous les compteurs de services
  Future<void> updateAllServicesCount() async {
    try {
      final categories = await getAllCategories();
      final operations = <BatchOperation>[];

      for (final category in categories) {
        if (category.id == 'all') continue; // Ignorer la catégorie "Tous"

        final servicesCount = await _getServicesCountForCategory(category.id);
        final docRef = FirebaseFirestore.instance
            .collection(_collectionName)
            .doc(category.id);

        operations.add(
          BatchOperation.update(docRef, {
            'servicesCount': servicesCount,
            'updatedAt': DateTime.now(),
          }),
        );
      }

      if (operations.isNotEmpty) {
        await _firebaseManager.executeBatch(operations);
      }

      // Invalider le cache
      _cache.clearByPrefix('categories_');
    } catch (e) {
      print('Erreur lors de la mise à jour de tous les compteurs: $e');
    }
  }

  /// Crée les catégories par défaut
  Future<void> initializeDefaultCategories() async {
    try {
      final existingCategories = await getAllCategories();
      if (existingCategories.length > 1) return; // Plus que juste "Tous"

      final defaultCategories = [
        {'name': 'Nettoyage', 'icon': 'cleaning'},
        {'name': 'Réparation', 'icon': 'repair'},
        {'name': 'Streaming', 'icon': 'streaming'},
        {'name': 'Internet', 'icon': 'internet'},
        {'name': 'Fitness', 'icon': 'fitness'},
        {'name': 'Éducation', 'icon': 'education'},
        {'name': 'Jardinage', 'icon': 'gardening'},
        {'name': 'Cuisine', 'icon': 'cooking'},
        {'name': 'Transport', 'icon': 'transport'},
        {'name': 'Santé', 'icon': 'health'},
      ];

      final operations = defaultCategories.map((category) {
        final docRef = FirebaseFirestore.instance
            .collection(_collectionName)
            .doc();
        return BatchOperation.create(docRef, {
          ...category,
          'servicesCount': 0,
          'createdAt': DateTime.now(),
          'updatedAt': DateTime.now(),
        });
      }).toList();

      await _firebaseManager.executeBatch(operations);

      // Invalider le cache
      _cache.clearByPrefix('categories_');

      print('✅ Catégories par défaut créées avec succès');
    } catch (e) {
      print('❌ Erreur lors de la création des catégories par défaut: $e');
    }
  }

  /// Stream pour les mises à jour en temps réel
  Stream<List<ServiceCategory>> getCategoriesStream() {
    return _firebaseManager
        .createDocumentsStream(
          _collectionName,
          sorts: [QuerySort(field: 'name', descending: false)],
          streamKey: 'categories_stream',
        )
        .asyncMap((docs) async {
          final categories = docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return ServiceCategory(
              id: doc.id,
              name: data['name'] ?? 'Catégorie',
              icon: _getIconFromString(data['icon']),
              servicesCount: data['servicesCount'] ?? 0,
            );
          }).toList();

          // Ajouter la catégorie "Tous" en premier
          final allCategory = ServiceCategory(
            id: 'all',
            name: 'Tous',
            icon: Icons.apps,
            servicesCount: await _getTotalServicesCount(),
          );

          return [allCategory, ...categories];
        });
  }

  // Méthodes privées

  /// Compte le nombre de services pour une catégorie
  Future<int> _getServicesCountForCategory(String categoryId) async {
    return await _firebaseManager.countDocuments(
      'services',
      filters: [
        QueryFilter(
          field: 'categoryId',
          operator: FilterOperator.isEqualTo,
          value: categoryId,
        ),
        QueryFilter(
          field: 'isActive',
          operator: FilterOperator.isEqualTo,
          value: true,
        ),
      ],
      cacheKey: 'services_count_$categoryId',
      cacheTimeout: const Duration(minutes: 5),
    );
  }

  /// Compte le nombre total de services
  Future<int> _getTotalServicesCount() async {
    return await _firebaseManager.countDocuments(
      'services',
      filters: [
        QueryFilter(
          field: 'isActive',
          operator: FilterOperator.isEqualTo,
          value: true,
        ),
      ],
      cacheKey: 'total_services_count',
      cacheTimeout: const Duration(minutes: 5),
    );
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
        case 'gardening':
          return Icons.local_florist;
        case 'cooking':
          return Icons.restaurant;
        case 'transport':
          return Icons.directions_car;
        case 'health':
          return Icons.local_hospital;
        default:
          return Icons.category;
      }
    }
    return Icons.category;
  }

  /// Nettoyer les ressources
  void dispose() {
    _firebaseManager.closeStream('categories_stream');
  }
}

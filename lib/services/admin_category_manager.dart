import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../../models/category_model.dart';

class AdminCategoryManager {
  static final AdminCategoryManager _instance =
      AdminCategoryManager._internal();
  factory AdminCategoryManager() => _instance;
  AdminCategoryManager._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'categories';

  // Cache local pour améliorer les performances
  List<CategoryModel>? _categoriesCache;
  DateTime? _lastCacheUpdate;

  // Durée du cache (5 minutes)
  static const Duration _cacheDuration = Duration(minutes: 5);

  /// Récupérer toutes les catégories
  Future<List<CategoryModel>> getCategories({bool forceRefresh = false}) async {
    try {
      // Vérifier le cache
      if (!forceRefresh &&
          _categoriesCache != null &&
          _lastCacheUpdate != null) {
        if (DateTime.now().difference(_lastCacheUpdate!) < _cacheDuration) {
          return _categoriesCache!;
        }
      }

      final querySnapshot = await _firestore
          .collection(_collectionName)
          .orderBy('sortOrder')
          .orderBy('name')
          .get();

      final categories = querySnapshot.docs
          .map((doc) => CategoryModel.fromMap(doc.data(), doc.id))
          .toList();

      // Mettre à jour le cache
      _categoriesCache = categories;
      _lastCacheUpdate = DateTime.now();

      return categories;
    } catch (e) {
      debugPrint('Erreur lors de la récupération des catégories: $e');
      // Retourner le cache si disponible, sinon une liste vide
      return _categoriesCache ?? [];
    }
  }

  /// Récupérer les catégories actives
  Future<List<CategoryModel>> getActiveCategories({
    bool forceRefresh = false,
  }) async {
    final categories = await getCategories(forceRefresh: forceRefresh);
    return categories.where((category) => category.isActive).toList();
  }

  /// Récupérer une catégorie par ID
  Future<CategoryModel?> getCategoryById(String categoryId) async {
    try {
      final doc = await _firestore
          .collection(_collectionName)
          .doc(categoryId)
          .get();
      if (doc.exists) {
        return CategoryModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      debugPrint(
        'Erreur lors de la récupération de la catégorie $categoryId: $e',
      );
      return null;
    }
  }

  /// Créer une nouvelle catégorie
  Future<String?> createCategory(CategoryModel category) async {
    try {
      final docRef = await _firestore
          .collection(_collectionName)
          .add(category.toMap());

      // Invalider le cache
      _categoriesCache = null;

      debugPrint('Catégorie créée avec l\'ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('Erreur lors de la création de la catégorie: $e');
      return null;
    }
  }

  /// Mettre à jour une catégorie
  Future<bool> updateCategory(CategoryModel category) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(category.id)
          .update(category.copyWith(updatedAt: DateTime.now()).toMap());

      // Invalider le cache
      _categoriesCache = null;

      debugPrint('Catégorie mise à jour: ${category.id}');
      return true;
    } catch (e) {
      debugPrint(
        'Erreur lors de la mise à jour de la catégorie ${category.id}: $e',
      );
      return false;
    }
  }

  /// Supprimer une catégorie
  Future<bool> deleteCategory(String categoryId) async {
    try {
      // Vérifier s'il y a des services associés
      final servicesCount = await getServicesCountForCategory(categoryId);
      if (servicesCount > 0) {
        debugPrint(
          'Impossible de supprimer la catégorie $categoryId: $servicesCount services associés',
        );
        return false;
      }

      await _firestore.collection(_collectionName).doc(categoryId).delete();

      // Invalider le cache
      _categoriesCache = null;

      debugPrint('Catégorie supprimée: $categoryId');
      return true;
    } catch (e) {
      debugPrint(
        'Erreur lors de la suppression de la catégorie $categoryId: $e',
      );
      return false;
    }
  }

  /// Activer/Désactiver une catégorie
  Future<bool> toggleCategoryStatus(String categoryId) async {
    try {
      final category = await getCategoryById(categoryId);
      if (category != null) {
        return await updateCategory(
          category.copyWith(isActive: !category.isActive),
        );
      }
      return false;
    } catch (e) {
      debugPrint(
        'Erreur lors du changement de statut de la catégorie $categoryId: $e',
      );
      return false;
    }
  }

  /// Mettre à jour le nombre de services pour une catégorie
  Future<bool> updateServicesCount(String categoryId, int count) async {
    try {
      await _firestore.collection(_collectionName).doc(categoryId).update({
        'serviceCount': count,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      // Invalider le cache
      _categoriesCache = null;

      return true;
    } catch (e) {
      debugPrint(
        'Erreur lors de la mise à jour du compteur de services pour $categoryId: $e',
      );
      return false;
    }
  }

  /// Obtenir le nombre de services pour une catégorie
  Future<int> getServicesCountForCategory(String categoryId) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('services')
          .where('categoryId', isEqualTo: categoryId)
          .get();

      return querySnapshot.docs.length;
    } catch (e) {
      debugPrint(
        'Erreur lors du comptage des services pour la catégorie $categoryId: $e',
      );
      return 0;
    }
  }

  /// Mettre à jour l'ordre d'affichage des catégories
  Future<bool> updateCategoriesOrder(List<CategoryModel> categories) async {
    try {
      final batch = _firestore.batch();

      for (int i = 0; i < categories.length; i++) {
        final categoryRef = _firestore
            .collection(_collectionName)
            .doc(categories[i].id);
        batch.update(categoryRef, {
          'sortOrder': i,
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        });
      }

      await batch.commit();

      // Invalider le cache
      _categoriesCache = null;

      debugPrint('Ordre des catégories mis à jour');
      return true;
    } catch (e) {
      debugPrint(
        'Erreur lors de la mise à jour de l\'ordre des catégories: $e',
      );
      return false;
    }
  }

  /// Initialiser les catégories par défaut (à utiliser lors de la première installation)
  Future<void> initializeDefaultCategories() async {
    try {
      final existingCategories = await getCategories(forceRefresh: true);
      if (existingCategories.isNotEmpty) {
        debugPrint('Les catégories existent déjà, initialisation ignorée');
        return;
      }

      final defaultCategories = [
        CategoryModel(
          id: '', // Sera généré par Firestore
          name: 'Nettoyage',
          description: 'Services de nettoyage et entretien',
          iconName: 'cleaning',
          color: Colors.blue,
          sortOrder: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        CategoryModel(
          id: '',
          name: 'Réparation',
          description: 'Services de réparation et maintenance',
          iconName: 'repair',
          color: Colors.orange,
          sortOrder: 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        CategoryModel(
          id: '',
          name: 'Éducation',
          description: 'Cours et formation',
          iconName: 'education',
          color: Colors.green,
          sortOrder: 2,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        CategoryModel(
          id: '',
          name: 'Santé',
          description: 'Services de santé et bien-être',
          iconName: 'health',
          color: Colors.red,
          sortOrder: 3,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        CategoryModel(
          id: '',
          name: 'Beauté',
          description: 'Services de beauté et esthétique',
          iconName: 'beauty',
          color: Colors.pink,
          sortOrder: 4,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      for (final category in defaultCategories) {
        await createCategory(category);
      }

      debugPrint('Catégories par défaut initialisées');
    } catch (e) {
      debugPrint(
        'Erreur lors de l\'initialisation des catégories par défaut: $e',
      );
    }
  }

  /// Invalider le cache manuellement
  void invalidateCache() {
    _categoriesCache = null;
    _lastCacheUpdate = null;
  }

  /// Vérifier si le cache est valide
  bool get isCacheValid {
    return _categoriesCache != null &&
        _lastCacheUpdate != null &&
        DateTime.now().difference(_lastCacheUpdate!) < _cacheDuration;
  }
}

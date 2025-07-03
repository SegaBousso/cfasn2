import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/admin_cache_manager.dart';

/// Gestionnaire Firebase optimisé pour les opérations administrateur
/// Centralise les opérations Firestore avec mise en cache et optimisations
class AdminFirebaseManager {
  static final AdminFirebaseManager _instance =
      AdminFirebaseManager._internal();
  factory AdminFirebaseManager() => _instance;
  AdminFirebaseManager._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AdminCacheManager _cache = AdminCacheManager();

  // Streams actifs pour éviter les fuites mémoire
  final Map<String, StreamSubscription> _activeStreams = {};

  /// Exécute une opération batch optimisée
  Future<void> executeBatch(List<BatchOperation> operations) async {
    if (operations.isEmpty) return;

    try {
      // Grouper les opérations par batch (Firestore limite à 500 opérations par batch)
      const batchSize = 450; // Marge de sécurité
      final batches = <WriteBatch>[];

      for (int i = 0; i < operations.length; i += batchSize) {
        final batch = _firestore.batch();
        final endIndex = (i + batchSize < operations.length)
            ? i + batchSize
            : operations.length;

        for (int j = i; j < endIndex; j++) {
          final op = operations[j];
          _applyBatchOperation(batch, op);
        }

        batches.add(batch);
      }

      // Exécuter tous les batches en parallèle
      await Future.wait(batches.map((batch) => batch.commit()));

      // Invalider le cache concerné
      _invalidateCacheForOperations(operations);

      print('✅ ${operations.length} opérations batch exécutées avec succès');
    } catch (e) {
      print('❌ Erreur lors de l\'exécution du batch: $e');
      rethrow;
    }
  }

  /// Exécute une transaction optimisée
  Future<T> executeTransaction<T>(
    Future<T> Function(Transaction transaction) updateFunction,
  ) async {
    try {
      return await _firestore.runTransaction(updateFunction);
    } catch (e) {
      print('❌ Erreur lors de la transaction: $e');
      rethrow;
    }
  }

  /// Récupère des documents avec mise en cache intelligente
  Future<List<QueryDocumentSnapshot>> getDocuments(
    String collection, {
    List<QueryFilter>? filters,
    List<QuerySort>? sorts,
    int? limit,
    DocumentSnapshot? startAfter,
    String? cacheKey,
    Duration? cacheTimeout,
  }) async {
    // Vérifier le cache si une clé est fournie
    if (cacheKey != null) {
      final cached = _cache.get<List<QueryDocumentSnapshot>>(cacheKey);
      if (cached != null) return cached;
    }

    try {
      Query query = _firestore.collection(collection);

      // Appliquer les filtres
      if (filters != null) {
        for (final filter in filters) {
          query = _applyFilter(query, filter);
        }
      }

      // Appliquer les tris
      if (sorts != null) {
        for (final sort in sorts) {
          query = query.orderBy(sort.field, descending: sort.descending);
        }
      }

      // Appliquer la limite
      if (limit != null) {
        query = query.limit(limit);
      }

      // Appliquer la pagination
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final snapshot = await query.get();
      final docs = snapshot.docs;

      // Mettre en cache si demandé
      if (cacheKey != null) {
        _cache.set(cacheKey, docs, timeout: cacheTimeout);
      }

      return docs;
    } catch (e) {
      print('❌ Erreur lors de la récupération des documents: $e');
      return [];
    }
  }

  /// Crée un stream avec gestion des abonnements
  Stream<List<QueryDocumentSnapshot>> createDocumentsStream(
    String collection, {
    List<QueryFilter>? filters,
    List<QuerySort>? sorts,
    int? limit,
    String? streamKey,
  }) {
    // Fermer l'ancien stream si il existe
    if (streamKey != null) {
      _activeStreams[streamKey]?.cancel();
    }

    Query query = _firestore.collection(collection);

    // Appliquer les filtres
    if (filters != null) {
      for (final filter in filters) {
        query = _applyFilter(query, filter);
      }
    }

    // Appliquer les tris
    if (sorts != null) {
      for (final sort in sorts) {
        query = query.orderBy(sort.field, descending: sort.descending);
      }
    }

    // Appliquer la limite
    if (limit != null) {
      query = query.limit(limit);
    }

    final stream = query.snapshots().map((snapshot) => snapshot.docs);

    // Enregistrer le stream pour le nettoyage ultérieur
    if (streamKey != null) {
      stream.listen(null).onDone(() {
        _activeStreams.remove(streamKey);
      });
    }

    return stream;
  }

  /// Compte le nombre de documents avec mise en cache
  Future<int> countDocuments(
    String collection, {
    List<QueryFilter>? filters,
    String? cacheKey,
    Duration? cacheTimeout,
  }) async {
    // Vérifier le cache
    if (cacheKey != null) {
      final cached = _cache.get<int>(cacheKey);
      if (cached != null) return cached;
    }

    try {
      Query query = _firestore.collection(collection);

      // Appliquer les filtres
      if (filters != null) {
        for (final filter in filters) {
          query = _applyFilter(query, filter);
        }
      }

      final snapshot = await query.count().get();
      final count = snapshot.count ?? 0;

      // Mettre en cache
      if (cacheKey != null) {
        _cache.set(
          cacheKey,
          count,
          timeout: cacheTimeout ?? const Duration(minutes: 10),
        );
      }

      return count;
    } catch (e) {
      print('❌ Erreur lors du comptage des documents: $e');
      return 0;
    }
  }

  /// Ferme tous les streams actifs
  void closeAllStreams() {
    for (final subscription in _activeStreams.values) {
      subscription.cancel();
    }
    _activeStreams.clear();
  }

  /// Ferme un stream spécifique
  void closeStream(String streamKey) {
    _activeStreams[streamKey]?.cancel();
    _activeStreams.remove(streamKey);
  }

  // Méthodes privées

  void _applyBatchOperation(WriteBatch batch, BatchOperation operation) {
    switch (operation.type) {
      case BatchOperationType.create:
        batch.set(operation.docRef, operation.data!);
        break;
      case BatchOperationType.update:
        batch.update(operation.docRef, operation.data!);
        break;
      case BatchOperationType.delete:
        batch.delete(operation.docRef);
        break;
    }
  }

  Query _applyFilter(Query query, QueryFilter filter) {
    switch (filter.operator) {
      case FilterOperator.isEqualTo:
        return query.where(filter.field, isEqualTo: filter.value);
      case FilterOperator.isNotEqualTo:
        return query.where(filter.field, isNotEqualTo: filter.value);
      case FilterOperator.isLessThan:
        return query.where(filter.field, isLessThan: filter.value);
      case FilterOperator.isLessThanOrEqualTo:
        return query.where(filter.field, isLessThanOrEqualTo: filter.value);
      case FilterOperator.isGreaterThan:
        return query.where(filter.field, isGreaterThan: filter.value);
      case FilterOperator.isGreaterThanOrEqualTo:
        return query.where(filter.field, isGreaterThanOrEqualTo: filter.value);
      case FilterOperator.arrayContains:
        return query.where(filter.field, arrayContains: filter.value);
      case FilterOperator.arrayContainsAny:
        return query.where(filter.field, arrayContainsAny: filter.value);
      case FilterOperator.whereIn:
        return query.where(filter.field, whereIn: filter.value);
      case FilterOperator.whereNotIn:
        return query.where(filter.field, whereNotIn: filter.value);
    }
  }

  void _invalidateCacheForOperations(List<BatchOperation> operations) {
    final collectionsToInvalidate = <String>{};
    for (final op in operations) {
      collectionsToInvalidate.add(op.docRef.path.split('/')[0]);
    }

    for (final collection in collectionsToInvalidate) {
      _cache.clearByPrefix(collection);
    }
  }
}

/// Opération pour les batches
class BatchOperation {
  final BatchOperationType type;
  final DocumentReference docRef;
  final Map<String, dynamic>? data;

  BatchOperation({required this.type, required this.docRef, this.data});

  factory BatchOperation.create(
    DocumentReference docRef,
    Map<String, dynamic> data,
  ) {
    return BatchOperation(
      type: BatchOperationType.create,
      docRef: docRef,
      data: data,
    );
  }

  factory BatchOperation.update(
    DocumentReference docRef,
    Map<String, dynamic> data,
  ) {
    return BatchOperation(
      type: BatchOperationType.update,
      docRef: docRef,
      data: data,
    );
  }

  factory BatchOperation.delete(DocumentReference docRef) {
    return BatchOperation(type: BatchOperationType.delete, docRef: docRef);
  }
}

enum BatchOperationType { create, update, delete }

/// Filtre pour les requêtes
class QueryFilter {
  final String field;
  final FilterOperator operator;
  final dynamic value;

  QueryFilter({
    required this.field,
    required this.operator,
    required this.value,
  });
}

enum FilterOperator {
  isEqualTo,
  isNotEqualTo,
  isLessThan,
  isLessThanOrEqualTo,
  isGreaterThan,
  isGreaterThanOrEqualTo,
  arrayContains,
  arrayContainsAny,
  whereIn,
  whereNotIn,
}

/// Tri pour les requêtes
class QuerySort {
  final String field;
  final bool descending;

  QuerySort({required this.field, this.descending = false});
}

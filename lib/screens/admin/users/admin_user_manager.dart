import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/user_model.dart';
import '../services/admin_firebase_manager.dart';
import '../utils/admin_cache_manager.dart';

/// Gestionnaire des utilisateurs pour l'administration
/// Utilise l'architecture unifiée avec cache et Firebase manager
class AdminUserManager {
  static final AdminUserManager _instance = AdminUserManager._internal();
  factory AdminUserManager() => _instance;
  AdminUserManager._internal();

  final AdminFirebaseManager _firebase = AdminFirebaseManager();
  final AdminCacheManager _cache = AdminCacheManager();
  final String _collectionName = 'users';

  /// Récupère tous les utilisateurs
  Future<List<UserModel>> get allUsers async {
    const cacheKey = AdminCacheKeys.usersAll;
    final cached = _cache.get<List<UserModel>>(cacheKey);
    if (cached != null) return cached;

    final docs = await _firebase.getDocuments(
      _collectionName,
      sorts: [QuerySort(field: 'createdAt', descending: true)],
      cacheKey: cacheKey,
    );

    final users = docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['uid'] = doc.id;
      return UserModel.fromMap(data);
    }).toList();

    return users;
  }

  /// Récupère les utilisateurs actifs (vérifiés)
  Future<List<UserModel>> get activeUsers async {
    const cacheKey = AdminCacheKeys.usersActive;
    final cached = _cache.get<List<UserModel>>(cacheKey);
    if (cached != null) return cached;

    final docs = await _firebase.getDocuments(
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
    );

    final users = docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['uid'] = doc.id;
      return UserModel.fromMap(data);
    }).toList();

    return users;
  }

  /// Récupère les utilisateurs vérifiés
  Future<List<UserModel>> get verifiedUsers async {
    return activeUsers; // Même logique que activeUsers
  }

  /// Alias pour compatibilité
  Future<List<UserModel>> getAllUsers() async {
    return allUsers;
  }

  /// Supprime plusieurs utilisateurs avec opération batch
  Future<void> deleteMultipleUsers(List<String> userIds) async {
    try {
      final operations = userIds.map((userId) {
        final docRef = FirebaseFirestore.instance
            .collection(_collectionName)
            .doc(userId);
        return BatchOperation.delete(docRef);
      }).toList();

      await _firebase.executeBatch(operations);

      // Invalider le cache
      _cache.clearByPrefix('users_');

      print('✅ ${userIds.length} utilisateurs supprimés avec succès');
    } catch (e) {
      print('❌ Erreur lors de la suppression d\'utilisateurs: $e');
      rethrow;
    }
  }

  /// Récupère les utilisateurs par rôle
  Future<List<UserModel>> getUsersByRole(UserRole role) async {
    final cacheKey = 'users_role_${role.toString()}';
    final cached = _cache.get<List<UserModel>>(cacheKey);
    if (cached != null) return cached;

    final docs = await _firebase.getDocuments(
      _collectionName,
      filters: [
        QueryFilter(
          field: 'role',
          operator: FilterOperator.isEqualTo,
          value: role.toString(),
        ),
      ],
      sorts: [QuerySort(field: 'createdAt', descending: true)],
      cacheKey: cacheKey,
    );

    final users = docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['uid'] = doc.id;
      return UserModel.fromMap(data);
    }).toList();

    return users;
  }

  /// Obtenir un utilisateur par UID
  Future<UserModel?> getUserById(String uid) async {
    final cacheKey = AdminCacheKeys.userById(uid);
    final cached = _cache.get<UserModel>(cacheKey);
    if (cached != null) return cached;

    try {
      final doc = await FirebaseFirestore.instance
          .collection(_collectionName)
          .doc(uid)
          .get();

      if (!doc.exists) return null;

      final data = doc.data() as Map<String, dynamic>;
      data['uid'] = doc.id;
      final user = UserModel.fromMap(data);

      _cache.set(cacheKey, user);
      return user;
    } catch (e) {
      print('❌ Erreur lors de la récupération de l\'utilisateur: $e');
      return null;
    }
  }

  /// Ajouter un nouvel utilisateur
  Future<void> addUser(UserModel user) async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection(_collectionName)
          .doc(user.uid);

      final operation = BatchOperation.create(docRef, user.toMap());
      await _firebase.executeBatch([operation]);

      // Invalider le cache
      _cache.clearByPrefix('users_');
      _cache.set(AdminCacheKeys.userById(user.uid), user);

      print('✅ Utilisateur ajouté avec succès');
    } catch (e) {
      print('❌ Erreur lors de l\'ajout de l\'utilisateur: $e');
      rethrow;
    }
  }

  /// Mettre à jour un utilisateur
  Future<void> updateUser(UserModel user) async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection(_collectionName)
          .doc(user.uid);

      final operation = BatchOperation.update(docRef, user.toMap());
      await _firebase.executeBatch([operation]);

      // Mettre à jour le cache
      _cache.clearByPrefix('users_');
      _cache.set(AdminCacheKeys.userById(user.uid), user);

      print('✅ Utilisateur mis à jour avec succès');
    } catch (e) {
      print('❌ Erreur lors de la mise à jour de l\'utilisateur: $e');
      rethrow;
    }
  }

  /// Supprimer un utilisateur
  Future<void> deleteUser(String uid) async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection(_collectionName)
          .doc(uid);

      final operation = BatchOperation.delete(docRef);
      await _firebase.executeBatch([operation]);

      // Invalider le cache
      _cache.clearByPrefix('users_');

      print('✅ Utilisateur supprimé avec succès');
    } catch (e) {
      print('❌ Erreur lors de la suppression de l\'utilisateur: $e');
      rethrow;
    }
  }

  /// Rechercher des utilisateurs
  Future<List<UserModel>> searchUsers(String query) async {
    if (query.isEmpty) return await allUsers;

    // Pour une recherche simple, on récupère tous les utilisateurs et on filtre
    final users = await allUsers;
    final lowercaseQuery = query.toLowerCase();

    return users.where((user) {
      return user.email.toLowerCase().contains(lowercaseQuery) ||
          user.displayName.toLowerCase().contains(lowercaseQuery) ||
          user.firstName.toLowerCase().contains(lowercaseQuery) ||
          user.lastName.toLowerCase().contains(lowercaseQuery) ||
          (user.phoneNumber?.contains(query) ?? false);
    }).toList();
  }

  /// Filtrer les utilisateurs avec critères avancés
  Future<List<UserModel>> filterUsers({
    UserRole? role,
    bool? isVerified,
    bool? isAdmin,
    DateTime? createdAfter,
    DateTime? createdBefore,
  }) async {
    // Construire la clé de cache basée sur les filtres
    final cacheKey =
        'users_filtered_${role}_${isVerified}_${isAdmin}_${createdAfter}_${createdBefore}';
    final cached = _cache.get<List<UserModel>>(cacheKey);
    if (cached != null) return cached;

    // Construire les filtres Firestore
    final filters = <QueryFilter>[];

    if (role != null) {
      filters.add(
        QueryFilter(
          field: 'role',
          operator: FilterOperator.isEqualTo,
          value: role.toString(),
        ),
      );
    }

    if (isVerified != null) {
      filters.add(
        QueryFilter(
          field: 'isVerified',
          operator: FilterOperator.isEqualTo,
          value: isVerified,
        ),
      );
    }

    if (isAdmin != null) {
      filters.add(
        QueryFilter(
          field: 'isAdmin',
          operator: FilterOperator.isEqualTo,
          value: isAdmin,
        ),
      );
    }

    if (createdAfter != null) {
      filters.add(
        QueryFilter(
          field: 'createdAt',
          operator: FilterOperator.isGreaterThanOrEqualTo,
          value: Timestamp.fromDate(createdAfter),
        ),
      );
    }

    if (createdBefore != null) {
      filters.add(
        QueryFilter(
          field: 'createdAt',
          operator: FilterOperator.isLessThanOrEqualTo,
          value: Timestamp.fromDate(createdBefore),
        ),
      );
    }

    final docs = await _firebase.getDocuments(
      _collectionName,
      filters: filters,
      sorts: [QuerySort(field: 'createdAt', descending: true)],
      cacheKey: cacheKey,
    );

    final users = docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['uid'] = doc.id;
      return UserModel.fromMap(data);
    }).toList();

    return users;
  }

  /// Obtient les statistiques des utilisateurs
  Future<Map<String, dynamic>> getStats() async {
    const cacheKey = 'users_stats';
    final cached = _cache.get<Map<String, dynamic>>(cacheKey);
    if (cached != null) return cached;

    // Utiliser le service de statistiques pour des calculs optimisés
    final results = await Future.wait([
      _firebase.countDocuments(_collectionName, cacheKey: 'users_count_total'),
      _firebase.countDocuments(
        _collectionName,
        filters: [
          QueryFilter(
            field: 'isVerified',
            operator: FilterOperator.isEqualTo,
            value: true,
          ),
        ],
        cacheKey: 'users_count_verified',
      ),
      _firebase.countDocuments(
        _collectionName,
        filters: [
          QueryFilter(
            field: 'isAdmin',
            operator: FilterOperator.isEqualTo,
            value: true,
          ),
        ],
        cacheKey: 'users_count_admins',
      ),
      _firebase.countDocuments(
        _collectionName,
        filters: [
          QueryFilter(
            field: 'role',
            operator: FilterOperator.isEqualTo,
            value: UserRole.provider.toString(),
          ),
        ],
        cacheKey: 'users_count_providers',
      ),
      _firebase.countDocuments(
        _collectionName,
        filters: [
          QueryFilter(
            field: 'role',
            operator: FilterOperator.isEqualTo,
            value: UserRole.client.toString(),
          ),
        ],
        cacheKey: 'users_count_clients',
      ),
    ]);

    final stats = {
      'total': results[0],
      'verified': results[1],
      'admins': results[2],
      'providers': results[3],
      'clients': results[4],
      'unverified': results[0] - results[1],
      'last_updated': DateTime.now().toIso8601String(),
    };

    _cache.set(cacheKey, stats, timeout: const Duration(minutes: 5));
    return stats;
  }

  /// Forcer le rechargement en vidant le cache
  Future<void> forceReload() async {
    _cache.clearByPrefix('users_');
  }

  /// Créer un stream temps réel pour les utilisateurs
  Stream<List<UserModel>> getUsersStream({
    List<QueryFilter>? filters,
    int? limit,
  }) {
    return _firebase
        .createDocumentsStream(
          _collectionName,
          filters: filters,
          sorts: [QuerySort(field: 'createdAt', descending: true)],
          limit: limit,
          streamKey: 'users_stream',
        )
        .map((docs) {
          return docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['uid'] = doc.id;
            return UserModel.fromMap(data);
          }).toList();
        });
  }

  /// Initialiser des données par défaut si nécessaire
  Future<void> initializeDefaultData() async {
    final count = await _firebase.countDocuments(_collectionName);
    if (count == 0) {
      await _createDefaultUsers();
    }
  }

  /// Créer des utilisateurs par défaut pour les tests
  Future<void> _createDefaultUsers() async {
    final defaultUsers = [
      UserModel(
        uid: 'admin_001',
        email: 'admin@servicespace.com',
        displayName: 'Admin Principal',
        firstName: 'Admin',
        lastName: 'Principal',
        phoneNumber: '+33123456789',
        address: '123 Rue de l\'Admin, 75001 Paris',
        civility: 'M.',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        lastSignIn: DateTime.now(),
        isVerified: true,
        isAdmin: true,
        role: UserRole.admin,
      ),
      UserModel(
        uid: 'provider_001',
        email: 'provider@servicespace.com',
        displayName: 'Jean Dupont',
        firstName: 'Jean',
        lastName: 'Dupont',
        phoneNumber: '+33123456788',
        address: '456 Avenue du Prestataire, 75002 Paris',
        civility: 'M.',
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        lastSignIn: DateTime.now().subtract(const Duration(hours: 2)),
        isVerified: true,
        role: UserRole.provider,
      ),
      UserModel(
        uid: 'client_001',
        email: 'client@servicespace.com',
        displayName: 'Marie Martin',
        firstName: 'Marie',
        lastName: 'Martin',
        phoneNumber: '+33123456787',
        address: '789 Boulevard du Client, 75003 Paris',
        civility: 'Mme.',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        lastSignIn: DateTime.now().subtract(const Duration(minutes: 30)),
        isVerified: true,
        role: UserRole.client,
      ),
      UserModel(
        uid: 'client_002',
        email: 'pierre.durand@example.com',
        displayName: 'Pierre Durand',
        firstName: 'Pierre',
        lastName: 'Durand',
        phoneNumber: '+33123456786',
        civility: 'M.',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        lastSignIn: DateTime.now().subtract(const Duration(days: 1)),
        isVerified: false,
        role: UserRole.client,
      ),
    ];

    // Créer les opérations batch
    final operations = defaultUsers.map((user) {
      final docRef = FirebaseFirestore.instance
          .collection(_collectionName)
          .doc(user.uid);
      return BatchOperation.create(docRef, user.toMap());
    }).toList();

    await _firebase.executeBatch(operations);

    // Invalider le cache pour forcer le rechargement
    _cache.clearByPrefix('users_');

    print('✅ Utilisateurs par défaut créés avec succès');
  }
}

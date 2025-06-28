import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/user_model.dart';

class AdminUserManager {
  static final AdminUserManager _instance = AdminUserManager._internal();
  factory AdminUserManager() => _instance;
  AdminUserManager._internal();

  // Instance Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'users';

  // Cache local pour les performances
  List<UserModel> _cachedUsers = [];
  DateTime? _lastCacheUpdate;
  final Duration _cacheTimeout = const Duration(minutes: 5);

  // Getters avec récupération automatique des données
  Future<List<UserModel>> get allUsers async {
    await _ensureDataLoaded();
    return List.unmodifiable(_cachedUsers);
  }

  Future<List<UserModel>> get activeUsers async {
    await _ensureDataLoaded();
    return _cachedUsers.where((u) => u.isVerified).toList();
  }

  Future<List<UserModel>> get verifiedUsers async {
    await _ensureDataLoaded();
    return _cachedUsers.where((u) => u.isVerified).toList();
  }

  // Alias pour compatibilité
  Future<List<UserModel>> getAllUsers() async {
    return allUsers;
  }

  // Méthode pour supprimer plusieurs utilisateurs
  Future<void> deleteMultipleUsers(List<String> userIds) async {
    try {
      final batch = _firestore.batch();

      for (final userId in userIds) {
        final docRef = _firestore.collection(_collectionName).doc(userId);
        batch.delete(docRef);
      }

      await batch.commit();

      // Mise à jour du cache
      _cachedUsers.removeWhere((user) => userIds.contains(user.uid));
      _triggerCacheUpdate();
    } catch (e) {
      print('Erreur lors de la suppression d\'utilisateurs: $e');
      rethrow;
    }
  }

  Future<List<UserModel>> getUsersByRole(UserRole role) async {
    await _ensureDataLoaded();
    return _cachedUsers.where((u) => u.role == role).toList();
  }

  // Getters synchrones pour le cache
  List<UserModel> get allUsersSync => List.unmodifiable(_cachedUsers);

  /// S'assurer que les données sont chargées et à jour
  Future<void> _ensureDataLoaded() async {
    if (_cachedUsers.isEmpty || _isCacheExpired()) {
      await _loadUsersFromFirestore();
    }
  }

  bool _isCacheExpired() {
    if (_lastCacheUpdate == null) return true;
    return DateTime.now().difference(_lastCacheUpdate!) > _cacheTimeout;
  }

  /// Charger les utilisateurs depuis Firestore
  Future<void> _loadUsersFromFirestore() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_collectionName)
          .orderBy('createdAt', descending: true)
          .get();

      _cachedUsers = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['uid'] = doc.id; // Assurer que l'UID est défini
        return UserModel.fromMap(data);
      }).toList();

      _lastCacheUpdate = DateTime.now();

      // Si aucun utilisateur n'existe, créer des utilisateurs par défaut
      if (_cachedUsers.isEmpty) {
        await _createDefaultUsers();
      }
    } catch (e) {
      print('Erreur lors du chargement des utilisateurs: $e');
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

    // Sauvegarder les utilisateurs par défaut
    for (final user in defaultUsers) {
      await _firestore
          .collection(_collectionName)
          .doc(user.uid)
          .set(user.toMap());
    }

    _cachedUsers = defaultUsers;
    _triggerCacheUpdate();
  }

  /// Déclencher la mise à jour du cache
  void _triggerCacheUpdate() {
    _lastCacheUpdate = DateTime.now();
  }

  /// Forcer le rechargement du cache
  Future<void> forceReload() async {
    _lastCacheUpdate = null;
    await _loadUsersFromFirestore();
  }

  /// Obtenir un utilisateur par UID
  Future<UserModel?> getUserById(String uid) async {
    await _ensureDataLoaded();
    try {
      return _cachedUsers.firstWhere((u) => u.uid == uid);
    } catch (e) {
      return null;
    }
  }

  /// Ajouter un nouvel utilisateur
  Future<void> addUser(UserModel user) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(user.uid)
          .set(user.toMap());
      _cachedUsers.add(user);
      _triggerCacheUpdate();
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout de l\'utilisateur: $e');
    }
  }

  /// Mettre à jour un utilisateur
  Future<void> updateUser(UserModel user) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(user.uid)
          .update(user.toMap());

      final index = _cachedUsers.indexWhere((u) => u.uid == user.uid);
      if (index != -1) {
        _cachedUsers[index] = user;
        _triggerCacheUpdate();
      }
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de l\'utilisateur: $e');
    }
  }

  /// Supprimer un utilisateur
  Future<void> deleteUser(String uid) async {
    try {
      await _firestore.collection(_collectionName).doc(uid).delete();
      _cachedUsers.removeWhere((u) => u.uid == uid);
      _triggerCacheUpdate();
    } catch (e) {
      throw Exception('Erreur lors de la suppression de l\'utilisateur: $e');
    }
  }

  /// Rechercher des utilisateurs
  Future<List<UserModel>> searchUsers(String query) async {
    await _ensureDataLoaded();

    if (query.isEmpty) return _cachedUsers;

    final lowercaseQuery = query.toLowerCase();
    return _cachedUsers.where((user) {
      return user.email.toLowerCase().contains(lowercaseQuery) ||
          user.displayName.toLowerCase().contains(lowercaseQuery) ||
          user.firstName.toLowerCase().contains(lowercaseQuery) ||
          user.lastName.toLowerCase().contains(lowercaseQuery) ||
          (user.phoneNumber?.contains(query) ?? false);
    }).toList();
  }

  /// Filtrer les utilisateurs
  Future<List<UserModel>> filterUsers({
    UserRole? role,
    bool? isVerified,
    bool? isAdmin,
    DateTime? createdAfter,
    DateTime? createdBefore,
  }) async {
    await _ensureDataLoaded();

    var filtered = _cachedUsers.where((user) {
      if (role != null && user.role != role) return false;
      if (isVerified != null && user.isVerified != isVerified) return false;
      if (isAdmin != null && user.isAdmin != isAdmin) return false;
      if (createdAfter != null && user.createdAt.isBefore(createdAfter))
        return false;
      if (createdBefore != null && user.createdAt.isAfter(createdBefore))
        return false;
      return true;
    });

    return filtered.toList();
  }

  /// Obtenir les statistiques des utilisateurs
  Future<Map<String, dynamic>> getStats() async {
    await _ensureDataLoaded();

    final total = _cachedUsers.length;
    final verified = _cachedUsers.where((u) => u.isVerified).length;
    final admins = _cachedUsers.where((u) => u.isAdmin).length;
    final providers = _cachedUsers
        .where((u) => u.role == UserRole.provider)
        .length;
    final clients = _cachedUsers.where((u) => u.role == UserRole.client).length;

    return {
      'total': total,
      'verified': verified,
      'admins': admins,
      'providers': providers,
      'clients': clients,
      'unverified': total - verified,
    };
  }
}

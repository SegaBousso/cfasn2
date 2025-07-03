/// Gestionnaire de cache centralisé pour l'administration
/// Permet une gestion cohérente du cache entre tous les managers administrateur
class AdminCacheManager {
  static final AdminCacheManager _instance = AdminCacheManager._internal();
  factory AdminCacheManager() => _instance;
  AdminCacheManager._internal();

  // Cache principal avec clés typées
  final Map<String, CacheEntry> _cache = {};

  // Configuration du cache
  static const Duration defaultCacheTimeout = Duration(minutes: 10);
  static const int maxCacheSize = 1000;

  /// Récupère une valeur du cache
  T? get<T>(String key) {
    final entry = _cache[key];
    if (entry == null) return null;

    // Vérifier l'expiration
    if (entry.isExpired) {
      _cache.remove(key);
      return null;
    }

    return entry.value as T?;
  }

  /// Met une valeur en cache
  void set<T>(String key, T value, {Duration? timeout}) {
    // Nettoyer le cache si nécessaire
    _cleanupIfNeeded();

    final expiration = DateTime.now().add(timeout ?? defaultCacheTimeout);
    _cache[key] = CacheEntry(value, expiration);
  }

  /// Supprime une entrée du cache
  void remove(String key) {
    _cache.remove(key);
  }

  /// Vide tout le cache
  void clear() {
    _cache.clear();
  }

  /// Vide le cache pour un préfixe donné
  void clearByPrefix(String prefix) {
    _cache.removeWhere((key, value) => key.startsWith(prefix));
  }

  /// Vérifie si une clé existe et n'est pas expirée
  bool contains(String key) {
    final entry = _cache[key];
    if (entry == null) return false;

    if (entry.isExpired) {
      _cache.remove(key);
      return false;
    }

    return true;
  }

  /// Nettoie le cache des entrées expirées
  void _cleanupIfNeeded() {
    if (_cache.length < maxCacheSize) return;

    // Supprimer les entrées expirées
    _cache.removeWhere((key, entry) => entry.isExpired);

    // Si toujours trop d'entrées, supprimer les plus anciennes
    if (_cache.length >= maxCacheSize) {
      final sortedEntries = _cache.entries.toList()
        ..sort((a, b) => a.value.createdAt.compareTo(b.value.createdAt));

      final toRemove = sortedEntries.take(_cache.length - maxCacheSize ~/ 2);
      for (final entry in toRemove) {
        _cache.remove(entry.key);
      }
    }
  }

  /// Statistiques du cache
  Map<String, dynamic> getStats() {
    final now = DateTime.now();
    int expiredCount = 0;

    for (final entry in _cache.values) {
      if (entry.isExpired) expiredCount++;
    }

    return {
      'total_entries': _cache.length,
      'expired_entries': expiredCount,
      'valid_entries': _cache.length - expiredCount,
      'max_size': maxCacheSize,
      'last_cleanup': now.toIso8601String(),
    };
  }
}

/// Entrée de cache avec métadonnées
class CacheEntry {
  final dynamic value;
  final DateTime expiration;
  final DateTime createdAt;

  CacheEntry(this.value, this.expiration) : createdAt = DateTime.now();

  bool get isExpired => DateTime.now().isAfter(expiration);
}

/// Clés de cache standardisées pour éviter les conflits
class AdminCacheKeys {
  // Providers
  static const String providersAll = 'providers_all';
  static const String providersActive = 'providers_active';
  static const String providersVerified = 'providers_verified';
  static String providerById(String id) => 'provider_$id';

  // Services
  static const String servicesAll = 'services_all';
  static const String servicesActive = 'services_active';
  static const String servicesAvailable = 'services_available';
  static String serviceById(String id) => 'service_$id';

  // Users
  static const String usersAll = 'users_all';
  static const String usersActive = 'users_active';
  static const String usersVerified = 'users_verified';
  static String userById(String id) => 'user_$id';

  // Bookings
  static const String bookingsAll = 'bookings_all';
  static const String bookingsPending = 'bookings_pending';
  static const String bookingsCompleted = 'bookings_completed';
  static String bookingById(String id) => 'booking_$id';

  // Categories
  static const String categoriesAll = 'categories_all';
  static String categoryById(String id) => 'category_$id';

  // Statistics
  static const String statsOverview = 'stats_overview';
  static const String statsProviders = 'stats_providers';
  static const String statsServices = 'stats_services';
  static const String statsBookings = 'stats_bookings';
}

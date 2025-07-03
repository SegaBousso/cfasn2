import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/admin_cache_manager.dart';

/// Service centralisé pour les statistiques administrateur
/// Calcule et met en cache les statistiques en temps réel depuis Firestore
class AdminStatsService {
  static final AdminStatsService _instance = AdminStatsService._internal();
  factory AdminStatsService() => _instance;
  AdminStatsService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AdminCacheManager _cache = AdminCacheManager();

  /// Récupère les statistiques générales du dashboard
  Future<AdminStats> getDashboardStats({bool forceRefresh = false}) async {
    const cacheKey = AdminCacheKeys.statsOverview;

    if (!forceRefresh) {
      final cached = _cache.get<AdminStats>(cacheKey);
      if (cached != null) return cached;
    }

    try {
      // Exécuter toutes les requêtes en parallèle pour optimiser les performances
      final results = await Future.wait([
        _getTotalUsers(),
        _getTotalProviders(),
        _getTotalServices(),
        _getTotalBookings(),
        _getMonthlyRevenue(),
        _getActiveProvidersCount(),
        _getPendingBookingsCount(),
        _getCompletedBookingsCount(),
      ]);

      final stats = AdminStats(
        totalUsers: results[0] as int,
        totalProviders: results[1] as int,
        totalServices: results[2] as int,
        totalBookings: results[3] as int,
        monthlyRevenue: results[4] as double,
        activeProviders: results[5] as int,
        pendingBookings: results[6] as int,
        completedBookings: results[7] as int,
        lastUpdated: DateTime.now(),
      );

      // Mettre en cache pour 5 minutes
      _cache.set(cacheKey, stats, timeout: const Duration(minutes: 5));
      return stats;
    } catch (e) {
      print('Erreur lors du calcul des statistiques: $e');
      // Retourner des stats par défaut en cas d'erreur
      return AdminStats.empty();
    }
  }

  /// Récupère les statistiques détaillées des prestataires
  Future<ProviderStats> getProviderStats({bool forceRefresh = false}) async {
    const cacheKey = AdminCacheKeys.statsProviders;

    if (!forceRefresh) {
      final cached = _cache.get<ProviderStats>(cacheKey);
      if (cached != null) return cached;
    }

    try {
      final results = await Future.wait([
        _getVerifiedProvidersCount(),
        _getTopRatedProviders(),
        _getProvidersBySpecialty(),
        _getProvidersRegistrationTrend(),
      ]);

      final stats = ProviderStats(
        verifiedCount: results[0] as int,
        topRated: results[1] as List<Map<String, dynamic>>,
        bySpecialty: results[2] as Map<String, int>,
        registrationTrend: results[3] as List<Map<String, dynamic>>,
        lastUpdated: DateTime.now(),
      );

      _cache.set(cacheKey, stats, timeout: const Duration(minutes: 10));
      return stats;
    } catch (e) {
      print('Erreur lors du calcul des statistiques prestataires: $e');
      return ProviderStats.empty();
    }
  }

  /// Récupère les statistiques des réservations par période
  Future<BookingStats> getBookingStats({
    DateTime? startDate,
    DateTime? endDate,
    bool forceRefresh = false,
  }) async {
    final cacheKey =
        '${AdminCacheKeys.statsBookings}_${startDate?.millisecondsSinceEpoch}_${endDate?.millisecondsSinceEpoch}';

    if (!forceRefresh) {
      final cached = _cache.get<BookingStats>(cacheKey);
      if (cached != null) return cached;
    }

    try {
      final results = await Future.wait([
        _getBookingsByStatus(startDate, endDate),
        _getBookingsByService(startDate, endDate),
        _getBookingsTrend(startDate, endDate),
        _getAverageBookingValue(startDate, endDate),
      ]);

      final stats = BookingStats(
        byStatus: results[0] as Map<String, int>,
        byService: results[1] as Map<String, int>,
        trend: results[2] as List<Map<String, dynamic>>,
        averageValue: results[3] as double,
        lastUpdated: DateTime.now(),
      );

      _cache.set(cacheKey, stats, timeout: const Duration(minutes: 15));
      return stats;
    } catch (e) {
      print('Erreur lors du calcul des statistiques réservations: $e');
      return BookingStats.empty();
    }
  }

  // Méthodes privées pour les calculs Firebase

  Future<int> _getTotalUsers() async {
    final snapshot = await _firestore.collection('users').count().get();
    return snapshot.count ?? 0;
  }

  Future<int> _getTotalProviders() async {
    final snapshot = await _firestore.collection('providers').count().get();
    return snapshot.count ?? 0;
  }

  Future<int> _getTotalServices() async {
    final snapshot = await _firestore.collection('services').count().get();
    return snapshot.count ?? 0;
  }

  Future<int> _getTotalBookings() async {
    final snapshot = await _firestore.collection('bookings').count().get();
    return snapshot.count ?? 0;
  }

  Future<double> _getMonthlyRevenue() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);

    final snapshot = await _firestore
        .collection('bookings')
        .where('status', isEqualTo: 'completed')
        .where('serviceDate', isGreaterThanOrEqualTo: startOfMonth)
        .where('serviceDate', isLessThan: now)
        .get();

    double total = 0;
    for (final doc in snapshot.docs) {
      final data = doc.data();
      total += (data['totalPrice'] as num?)?.toDouble() ?? 0;
    }
    return total;
  }

  Future<int> _getActiveProvidersCount() async {
    final snapshot = await _firestore
        .collection('providers')
        .where('isActive', isEqualTo: true)
        .where('isAvailable', isEqualTo: true)
        .count()
        .get();
    return snapshot.count ?? 0;
  }

  Future<int> _getPendingBookingsCount() async {
    final snapshot = await _firestore
        .collection('bookings')
        .where('status', isEqualTo: 'pending')
        .count()
        .get();
    return snapshot.count ?? 0;
  }

  Future<int> _getCompletedBookingsCount() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);

    final snapshot = await _firestore
        .collection('bookings')
        .where('status', isEqualTo: 'completed')
        .where('serviceDate', isGreaterThanOrEqualTo: startOfMonth)
        .count()
        .get();
    return snapshot.count ?? 0;
  }

  Future<int> _getVerifiedProvidersCount() async {
    final snapshot = await _firestore
        .collection('providers')
        .where('isVerified', isEqualTo: true)
        .count()
        .get();
    return snapshot.count ?? 0;
  }

  Future<List<Map<String, dynamic>>> _getTopRatedProviders() async {
    final snapshot = await _firestore
        .collection('providers')
        .where('isActive', isEqualTo: true)
        .orderBy('rating', descending: true)
        .limit(5)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'name': data['name'] ?? '',
        'rating': data['rating'] ?? 0.0,
        'ratingsCount': data['ratingsCount'] ?? 0,
      };
    }).toList();
  }

  Future<Map<String, int>> _getProvidersBySpecialty() async {
    final snapshot = await _firestore
        .collection('providers')
        .where('isActive', isEqualTo: true)
        .get();

    final Map<String, int> specialties = {};
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final specialty = data['specialty'] as String? ?? 'Non spécifié';
      specialties[specialty] = (specialties[specialty] ?? 0) + 1;
    }

    return specialties;
  }

  Future<List<Map<String, dynamic>>> _getProvidersRegistrationTrend() async {
    final now = DateTime.now();
    final sixMonthsAgo = DateTime(now.year, now.month - 6, 1);

    final snapshot = await _firestore
        .collection('providers')
        .where('createdAt', isGreaterThanOrEqualTo: sixMonthsAgo)
        .orderBy('createdAt')
        .get();

    final Map<String, int> monthlyCount = {};
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final createdAt = (data['createdAt'] as Timestamp?)?.toDate() ?? now;
      final monthKey =
          '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}';
      monthlyCount[monthKey] = (monthlyCount[monthKey] ?? 0) + 1;
    }

    return monthlyCount.entries
        .map((e) => {'month': e.key, 'count': e.value})
        .toList();
  }

  Future<Map<String, int>> _getBookingsByStatus(
    DateTime? startDate,
    DateTime? endDate,
  ) async {
    Query query = _firestore.collection('bookings');

    if (startDate != null) {
      query = query.where('createdAt', isGreaterThanOrEqualTo: startDate);
    }
    if (endDate != null) {
      query = query.where('createdAt', isLessThanOrEqualTo: endDate);
    }

    final snapshot = await query.get();
    final Map<String, int> statusCount = {};

    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final status = data['status'] as String? ?? 'unknown';
      statusCount[status] = (statusCount[status] ?? 0) + 1;
    }

    return statusCount;
  }

  Future<Map<String, int>> _getBookingsByService(
    DateTime? startDate,
    DateTime? endDate,
  ) async {
    Query query = _firestore.collection('bookings');

    if (startDate != null) {
      query = query.where('createdAt', isGreaterThanOrEqualTo: startDate);
    }
    if (endDate != null) {
      query = query.where('createdAt', isLessThanOrEqualTo: endDate);
    }

    final snapshot = await query.get();
    final Map<String, int> serviceCount = {};

    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final serviceName = data['serviceName'] as String? ?? 'Non spécifié';
      serviceCount[serviceName] = (serviceCount[serviceName] ?? 0) + 1;
    }

    return serviceCount;
  }

  Future<List<Map<String, dynamic>>> _getBookingsTrend(
    DateTime? startDate,
    DateTime? endDate,
  ) async {
    Query query = _firestore.collection('bookings');

    if (startDate != null) {
      query = query.where('createdAt', isGreaterThanOrEqualTo: startDate);
    }
    if (endDate != null) {
      query = query.where('createdAt', isLessThanOrEqualTo: endDate);
    }

    final snapshot = await query.orderBy('createdAt').get();
    final Map<String, int> dailyCount = {};

    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final createdAt =
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
      final dayKey =
          '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')}';
      dailyCount[dayKey] = (dailyCount[dayKey] ?? 0) + 1;
    }

    return dailyCount.entries
        .map((e) => {'date': e.key, 'count': e.value})
        .toList();
  }

  Future<double> _getAverageBookingValue(
    DateTime? startDate,
    DateTime? endDate,
  ) async {
    Query query = _firestore.collection('bookings');

    if (startDate != null) {
      query = query.where('createdAt', isGreaterThanOrEqualTo: startDate);
    }
    if (endDate != null) {
      query = query.where('createdAt', isLessThanOrEqualTo: endDate);
    }

    final snapshot = await query.get();

    if (snapshot.docs.isEmpty) return 0.0;

    double total = 0;
    int count = 0;

    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final price = (data['totalPrice'] as num?)?.toDouble() ?? 0;
      if (price > 0) {
        total += price;
        count++;
      }
    }

    return count > 0 ? total / count : 0.0;
  }
}

/// Modèles de données pour les statistiques

class AdminStats {
  final int totalUsers;
  final int totalProviders;
  final int totalServices;
  final int totalBookings;
  final double monthlyRevenue;
  final int activeProviders;
  final int pendingBookings;
  final int completedBookings;
  final DateTime lastUpdated;

  AdminStats({
    required this.totalUsers,
    required this.totalProviders,
    required this.totalServices,
    required this.totalBookings,
    required this.monthlyRevenue,
    required this.activeProviders,
    required this.pendingBookings,
    required this.completedBookings,
    required this.lastUpdated,
  });

  factory AdminStats.empty() => AdminStats(
    totalUsers: 0,
    totalProviders: 0,
    totalServices: 0,
    totalBookings: 0,
    monthlyRevenue: 0.0,
    activeProviders: 0,
    pendingBookings: 0,
    completedBookings: 0,
    lastUpdated: DateTime.now(),
  );
}

class ProviderStats {
  final int verifiedCount;
  final List<Map<String, dynamic>> topRated;
  final Map<String, int> bySpecialty;
  final List<Map<String, dynamic>> registrationTrend;
  final DateTime lastUpdated;

  ProviderStats({
    required this.verifiedCount,
    required this.topRated,
    required this.bySpecialty,
    required this.registrationTrend,
    required this.lastUpdated,
  });

  factory ProviderStats.empty() => ProviderStats(
    verifiedCount: 0,
    topRated: [],
    bySpecialty: {},
    registrationTrend: [],
    lastUpdated: DateTime.now(),
  );
}

class BookingStats {
  final Map<String, int> byStatus;
  final Map<String, int> byService;
  final List<Map<String, dynamic>> trend;
  final double averageValue;
  final DateTime lastUpdated;

  BookingStats({
    required this.byStatus,
    required this.byService,
    required this.trend,
    required this.averageValue,
    required this.lastUpdated,
  });

  factory BookingStats.empty() => BookingStats(
    byStatus: {},
    byService: {},
    trend: [],
    averageValue: 0.0,
    lastUpdated: DateTime.now(),
  );
}

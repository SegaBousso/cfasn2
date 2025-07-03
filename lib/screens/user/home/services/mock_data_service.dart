import '../../../../models/models.dart';
import '../../../admin/services/services/admin_service_manager.dart';

class MockDataService {
  // Singleton pour l'accès aux services admin
  static final AdminServiceManager _adminServiceManager = AdminServiceManager();

  // Méthode pour obtenir tous les services (admin + mock)
  static Future<List<ServiceModel>> getAllServices() async {
    final adminServices = await _getAdminServices();
    final mockServices = _getMockServices();

    // Combiner les services admin et mock, en évitant les doublons
    final allServices = <ServiceModel>[];
    final seenIds = <String>{};

    // Ajouter d'abord les services admin (priorité)
    for (final service in adminServices) {
      if (!seenIds.contains(service.id)) {
        allServices.add(service);
        seenIds.add(service.id);
      }
    }

    // Ajouter ensuite les services mock qui ne sont pas déjà présents
    for (final service in mockServices) {
      if (!seenIds.contains(service.id)) {
        allServices.add(service);
        seenIds.add(service.id);
      }
    }

    return allServices;
  }

  // Services créés par l'administrateur
  static Future<List<ServiceModel>> _getAdminServices() async {
    final allServices = await _adminServiceManager.allServices;
    return allServices
        .where((service) => service.isActive && service.isAvailable)
        .map((service) => _enhanceServiceForUser(service))
        .toList();
  }

  // Améliorer les services admin avec des données pour l'interface utilisateur
  static ServiceModel _enhanceServiceForUser(ServiceModel adminService) {
    return adminService.copyWith(
      // Ajouter une image par défaut basée sur la catégorie
      imageUrl: _getDefaultImageForCategory(adminService.categoryName),
      // Ajouter des données estimées pour l'interface utilisateur
      currency: 'EUR',
      estimatedDuration: _getEstimatedDuration(adminService.categoryName),
      likesCount:
          adminService.totalReviews * 2, // Estimation basée sur les avis
      viewsCount:
          adminService.totalReviews * 5, // Estimation basée sur les avis
      // Ajouter des métadonnées pour l'interface utilisateur
      metadata: {
        'providerId': adminService.createdBy,
        'providerName': _getProviderNameForService(adminService.createdBy),
        'serviceType': 'domicile',
        'source': 'admin',
      },
    );
  }

  // Images par défaut selon la catégorie
  static String _getDefaultImageForCategory(String categoryName) {
    final categoryImages = {
      'Nettoyage': 'https://via.placeholder.com/300x200?text=Nettoyage',
      'Réparation': 'https://via.placeholder.com/300x200?text=Réparation',
      'Éducation': 'https://via.placeholder.com/300x200?text=Éducation',
      'Santé': 'https://via.placeholder.com/300x200?text=Santé',
      'Beauté': 'https://via.placeholder.com/300x200?text=Beauté',
      'Jardinage': 'https://via.placeholder.com/300x200?text=Jardinage',
      'Transport': 'https://via.placeholder.com/300x200?text=Transport',
      'Informatique': 'https://via.placeholder.com/300x200?text=Informatique',
    };
    return categoryImages[categoryName] ??
        'https://via.placeholder.com/300x200?text=Service';
  }

  // Durée estimée selon la catégorie
  static String _getEstimatedDuration(String categoryName) {
    final categoryDurations = {
      'Nettoyage': '2-4 heures',
      'Réparation': '1-3 heures',
      'Éducation': '1 heure',
      'Santé': '45 minutes',
      'Beauté': '1-2 heures',
      'Jardinage': '2-5 heures',
      'Transport': '30 minutes',
      'Informatique': '1-2 heures',
    };
    return categoryDurations[categoryName] ?? '1-2 heures';
  }

  // Nom du prestataire selon l'ID
  static String _getProviderNameForService(String providerId) {
    final providerNames = {
      'admin': 'Service Admin',
      'provider1': 'Marie Cleaning',
      'provider2': 'Jean Réparation',
      'provider3': 'Sophie Éducation',
      'provider4': 'Paul Santé',
      'provider5': 'Lisa Beauté',
    };
    return providerNames[providerId] ?? 'Prestataire Professionnel';
  }

  // Méthode pour la compatibilité (retourne tous les services)
  static Future<List<ServiceModel>> getMockServices() async {
    return await getAllServices();
  }

  // Services mock originaux (pour les tests et la compatibilité)
  static List<ServiceModel> _getMockServices() {
    return [
      ServiceModel(
        id: '1',
        name: 'Ménage complet maison',
        description:
            'Service de ménage complet pour votre maison avec produits écologiques',
        imageUrl: 'https://via.placeholder.com/300x200?text=Ménage',
        price: 45.0,
        currency: 'EUR',
        estimatedDuration: '3 heures',
        categoryId: 'menage',
        categoryName: 'Ménage',
        rating: 4.8,
        totalReviews: 127,
        isAvailable: true,
        isActive: true,
        likesCount: 89,
        viewsCount: 324,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
        createdBy: 'provider1',
        tags: ['ménage', 'nettoyage', 'maison', 'écologique'],
        metadata: {
          'providerId': 'provider1',
          'providerName': 'Marie Cleaning',
          'serviceType': 'domicile',
        },
      ),
      ServiceModel(
        id: '2',
        name: 'Dépannage plomberie',
        description:
            'Intervention rapide pour tous vos problèmes de plomberie, 24h/24',
        imageUrl: 'https://via.placeholder.com/300x200?text=Plomberie',
        price: 65.0,
        currency: 'EUR',
        estimatedDuration: '2 heures',
        categoryId: 'plomberie',
        categoryName: 'Plomberie',
        rating: 4.6,
        totalReviews: 89,
        isAvailable: true,
        isActive: true,
        likesCount: 67,
        viewsCount: 245,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now(),
        createdBy: 'provider2',
        tags: ['plomberie', 'urgence', 'dépannage', '24h'],
        metadata: {
          'providerId': 'provider2',
          'providerName': 'Jean Plombier',
          'serviceType': 'urgence',
        },
      ),
      ServiceModel(
        id: '3',
        name: 'Entretien jardin',
        description: 'Taille, tonte et entretien complet de vos espaces verts',
        imageUrl: 'https://via.placeholder.com/300x200?text=Jardinage',
        price: 35.0,
        currency: 'EUR',
        estimatedDuration: '4 heures',
        categoryId: 'jardinage',
        categoryName: 'Jardinage',
        rating: 4.9,
        totalReviews: 156,
        isAvailable: true,
        isActive: true,
        likesCount: 134,
        viewsCount: 567,
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        updatedAt: DateTime.now(),
        createdBy: 'provider3',
        tags: ['jardinage', 'tonte', 'taille', 'entretien'],
        metadata: {
          'providerId': 'provider3',
          'providerName': 'Pierre Jardins',
          'serviceType': 'extérieur',
        },
      ),
      ServiceModel(
        id: '4',
        name: 'Cours de guitare',
        description: 'Cours particuliers de guitare à domicile, tous niveaux',
        imageUrl: 'https://via.placeholder.com/300x200?text=Guitare',
        price: 30.0,
        currency: 'EUR',
        estimatedDuration: '1 heure',
        categoryId: 'cours',
        categoryName: 'Cours particuliers',
        rating: 4.7,
        totalReviews: 73,
        isAvailable: true,
        isActive: true,
        likesCount: 52,
        viewsCount: 189,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now(),
        createdBy: 'provider4',
        tags: ['guitare', 'musique', 'cours', 'débutant'],
        metadata: {
          'providerId': 'provider4',
          'providerName': 'Paul Musique',
          'serviceType': 'éducation',
        },
      ),
      ServiceModel(
        id: '5',
        name: 'Réparation ordinateur',
        description:
            'Dépannage et réparation d\'ordinateurs, installation logiciels',
        imageUrl: 'https://via.placeholder.com/300x200?text=Informatique',
        price: 55.0,
        currency: 'EUR',
        estimatedDuration: '2 heures',
        categoryId: 'informatique',
        categoryName: 'Informatique',
        rating: 4.5,
        totalReviews: 92,
        isAvailable: true,
        isActive: true,
        likesCount: 76,
        viewsCount: 301,
        createdAt: DateTime.now().subtract(const Duration(days: 12)),
        updatedAt: DateTime.now(),
        createdBy: 'provider5',
        tags: ['informatique', 'réparation', 'dépannage', 'logiciels'],
        metadata: {
          'providerId': 'provider5',
          'providerName': 'Tech Support',
          'serviceType': 'technique',
        },
      ),
    ];
  }

  static List<Map<String, dynamic>> getMockProviders() {
    return [
      {
        'id': 'provider1',
        'name': 'Marie Dupont',
        'specialty': 'Services ménagers',
        'rating': 4.8,
        'avatar': 'https://via.placeholder.com/100x100?text=MD',
        'reviewCount': 127,
        'verified': true,
      },
      {
        'id': 'provider2',
        'name': 'Jean Martin',
        'specialty': 'Plomberie',
        'rating': 4.6,
        'avatar': 'https://via.placeholder.com/100x100?text=JM',
        'reviewCount': 89,
        'verified': true,
      },
      {
        'id': 'provider3',
        'name': 'Pierre Dubois',
        'specialty': 'Jardinage',
        'rating': 4.9,
        'avatar': 'https://via.placeholder.com/100x100?text=PD',
        'reviewCount': 156,
        'verified': true,
      },
      {
        'id': 'provider4',
        'name': 'Sophie Laurent',
        'specialty': 'Cours particuliers',
        'rating': 4.7,
        'avatar': 'https://via.placeholder.com/100x100?text=SL',
        'reviewCount': 84,
        'verified': true,
      },
    ];
  }
}

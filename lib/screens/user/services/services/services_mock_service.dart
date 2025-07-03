import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../models/service_model.dart';
import '../../../../models/provider_model.dart';
import '../../../admin/providers/admin_provider_manager.dart';

/// Service dédié à la création de données d'exemple pour les tests et le développement
class ServicesMockService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _servicesCollection =>
      _firestore.collection('services');
  CollectionReference get _categoriesCollection =>
      _firestore.collection('categories');

  /// Crée toutes les données d'exemple nécessaires
  Future<void> createAllSampleData() async {
    print('🚀 Début de la création des données d\'exemple...');

    try {
      await createSampleCategories();
      await createSampleServices();
      print('✅ Toutes les données d\'exemple ont été créées avec succès');
    } catch (e) {
      print('❌ Erreur lors de la création des données d\'exemple: $e');
      rethrow;
    }
  }

  /// Crée les catégories d'exemple
  Future<void> createSampleCategories() async {
    try {
      print('🔧 Création des catégories d\'exemple...');

      final sampleCategories = [
        {'name': 'Nettoyage', 'icon': 'cleaning'},
        {'name': 'Réparation', 'icon': 'repair'},
        {'name': 'Streaming', 'icon': 'streaming'},
        {'name': 'Internet', 'icon': 'internet'},
        {'name': 'Fitness', 'icon': 'fitness'},
        {'name': 'Éducation', 'icon': 'education'},
      ];

      final batch = _firestore.batch();
      for (final category in sampleCategories) {
        final docRef = _categoriesCollection.doc();
        batch.set(docRef, category);
      }
      await batch.commit();

      print('✅ Catégories d\'exemple créées avec succès');
    } catch (e) {
      print('❌ Erreur lors de la création des catégories: $e');
      rethrow;
    }
  }

  /// Crée les services d'exemple
  Future<void> createSampleServices() async {
    try {
      print('🔧 Création des services d\'exemple...');

      // D'abord, créer les providers si ils n'existent pas déjà
      final adminProviderManager = AdminProviderManager();
      await _createSampleProvidersIfNeeded(adminProviderManager);

      // Récupérer les providers créés
      final providers = await adminProviderManager.allProviders;
      if (providers.isEmpty) {
        print('❌ Aucun provider disponible pour créer les services');
        return;
      }

      // Récupérer les catégories
      final categoriesSnapshot = await _categoriesCollection.get();
      if (categoriesSnapshot.docs.isEmpty) {
        print('❌ Aucune catégorie disponible pour créer les services');
        return;
      }

      final sampleServices = _generateSampleServices(
        providers,
        categoriesSnapshot.docs,
      );

      final batch = _firestore.batch();
      for (final service in sampleServices) {
        final docRef = _servicesCollection.doc();
        batch.set(docRef, service.toFirestore());
      }
      await batch.commit();

      print(
        '✅ Services d\'exemple créés avec succès (${sampleServices.length} services)',
      );
    } catch (e) {
      print('❌ Erreur lors de la création des services: $e');
      rethrow;
    }
  }

  /// Génère la liste des services d'exemple
  List<ServiceModel> _generateSampleServices(
    List<ProviderModel> providers,
    List<QueryDocumentSnapshot> categories,
  ) {
    final services = <ServiceModel>[];
    final now = DateTime.now();

    // Services de nettoyage
    final cleaningCategory = categories.firstWhere(
      (cat) => (cat.data() as Map<String, dynamic>)['name'] == 'Nettoyage',
      orElse: () => categories.first,
    );
    final cleaningProvider = providers.firstWhere(
      (p) => p.name.contains('CleanPro'),
      orElse: () => providers.first,
    );

    services.addAll([
      ServiceModel(
        id: '',
        name: 'Nettoyage de bureaux',
        description:
            'Service de nettoyage professionnel pour bureaux et espaces de travail. Équipe expérimentée avec produits écologiques.',
        imageUrl:
            'https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=400',
        rating: 4.8,
        totalReviews: 127,
        price: 45.0,
        currency: 'EUR',
        estimatedDuration: '2-3 heures',
        categoryId: cleaningCategory.id,
        categoryName: 'Nettoyage',
        providerId: cleaningProvider.id,
        providerName: cleaningProvider.name,
        isAvailable: true,
        isActive: true,
        likesCount: 89,
        viewsCount: 1234,
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now,
        createdBy: cleaningProvider.id,
        tags: ['nettoyage', 'bureaux', 'professionnel', 'écologique'],
        metadata: {'difficulty': 'easy', 'equipment_required': false},
      ),
      ServiceModel(
        id: '',
        name: 'Nettoyage domicile',
        description:
            'Nettoyage complet de votre domicile par des professionnels qualifiés. Service flexible et adapté à vos besoins.',
        imageUrl:
            'https://images.unsplash.com/photo-1527515637462-cff94eecc1ac?w=400',
        rating: 4.6,
        totalReviews: 203,
        price: 35.0,
        currency: 'EUR',
        estimatedDuration: '3-4 heures',
        categoryId: cleaningCategory.id,
        categoryName: 'Nettoyage',
        providerId: cleaningProvider.id,
        providerName: cleaningProvider.name,
        isAvailable: true,
        isActive: true,
        likesCount: 156,
        viewsCount: 2107,
        createdAt: now.subtract(const Duration(days: 45)),
        updatedAt: now,
        createdBy: cleaningProvider.id,
        tags: ['nettoyage', 'domicile', 'maison', 'ménage'],
        metadata: {'difficulty': 'easy', 'equipment_required': false},
      ),
    ]);

    // Services de réparation
    final repairCategory = categories.firstWhere(
      (cat) => (cat.data() as Map<String, dynamic>)['name'] == 'Réparation',
      orElse: () => categories.first,
    );
    final techProvider = providers.firstWhere(
      (p) => p.name.contains('TechFix'),
      orElse: () => providers.first,
    );

    services.addAll([
      ServiceModel(
        id: '',
        name: 'Réparation ordinateur',
        description:
            'Diagnostic et réparation de tous types d\'ordinateurs. Intervention rapide et garantie sur les réparations.',
        imageUrl:
            'https://images.unsplash.com/photo-1588702547919-26089e690ecc?w=400',
        rating: 4.9,
        totalReviews: 89,
        price: 65.0,
        currency: 'EUR',
        estimatedDuration: '1-2 heures',
        categoryId: repairCategory.id,
        categoryName: 'Réparation',
        providerId: techProvider.id,
        providerName: techProvider.name,
        isAvailable: true,
        isActive: true,
        likesCount: 67,
        viewsCount: 890,
        createdAt: now.subtract(const Duration(days: 20)),
        updatedAt: now,
        createdBy: techProvider.id,
        tags: ['réparation', 'ordinateur', 'informatique', 'diagnostic'],
        metadata: {'difficulty': 'medium', 'equipment_required': true},
      ),
      ServiceModel(
        id: '',
        name: 'Installation système',
        description:
            'Installation et configuration de systèmes d\'exploitation, logiciels et applications. Support technique inclus.',
        imageUrl:
            'https://images.unsplash.com/photo-1504639725590-34d0984388bd?w=400',
        rating: 4.7,
        totalReviews: 142,
        price: 55.0,
        currency: 'EUR',
        estimatedDuration: '2-3 heures',
        categoryId: repairCategory.id,
        categoryName: 'Réparation',
        providerId: techProvider.id,
        providerName: techProvider.name,
        isAvailable: true,
        isActive: true,
        likesCount: 98,
        viewsCount: 1456,
        createdAt: now.subtract(const Duration(days: 15)),
        updatedAt: now,
        createdBy: techProvider.id,
        tags: ['installation', 'système', 'logiciel', 'configuration'],
        metadata: {'difficulty': 'medium', 'equipment_required': true},
      ),
    ]);

    // Services de streaming
    final streamingCategory = categories.firstWhere(
      (cat) => (cat.data() as Map<String, dynamic>)['name'] == 'Streaming',
      orElse: () => categories.first,
    );
    final streamProvider = providers.firstWhere(
      (p) => p.name.contains('StreamPro'),
      orElse: () => providers.first,
    );

    services.addAll([
      ServiceModel(
        id: '',
        name: 'Configuration streaming',
        description:
            'Configuration complète de votre setup de streaming pour Twitch, YouTube ou autres plateformes.',
        imageUrl:
            'https://images.unsplash.com/photo-1614680376573-df3480f1b6b5?w=400',
        rating: 4.8,
        totalReviews: 76,
        price: 85.0,
        currency: 'EUR',
        estimatedDuration: '2-4 heures',
        categoryId: streamingCategory.id,
        categoryName: 'Streaming',
        providerId: streamProvider.id,
        providerName: streamProvider.name,
        isAvailable: true,
        isActive: true,
        likesCount: 124,
        viewsCount: 987,
        createdAt: now.subtract(const Duration(days: 10)),
        updatedAt: now,
        createdBy: streamProvider.id,
        tags: ['streaming', 'configuration', 'twitch', 'youtube'],
        metadata: {'difficulty': 'hard', 'equipment_required': true},
      ),
    ]);

    return services;
  }

  /// Crée les providers d'exemple si nécessaire
  Future<void> _createSampleProvidersIfNeeded(
    AdminProviderManager adminProviderManager,
  ) async {
    final existingProviders = await adminProviderManager.allProviders;
    if (existingProviders.isNotEmpty) {
      print('ℹ️ Des providers existent déjà, création ignorée');
      return;
    }

    print('🔧 Création des providers d\'exemple...');

    final sampleProviders = [
      ProviderModel(
        id: '',
        name: 'TechFix Solutions',
        email: 'contact@techfix.fr',
        phoneNumber: '+33123456789',
        address: '15 Rue de la Technologie, 75001 Paris',
        specialty: 'Réparation Informatique',
        specialties: [
          'Réparation PC',
          'Installation logiciels',
          'Dépannage réseau',
        ],
        yearsOfExperience: 12,
        rating: 4.8,
        ratingsCount: 256,
        completedJobs: 850,
        isVerified: true,
        isActive: true,
        isAvailable: true,
        createdAt: DateTime.now().subtract(const Duration(days: 1500)),
        updatedAt: DateTime.now(),
        workingAreas: ['Paris', 'Île-de-France'],
        certifications: ['Certification Microsoft', 'Certification Apple'],
        serviceIds: [],
      ),
      ProviderModel(
        id: '',
        name: 'StreamPro Media',
        email: 'hello@streampro.fr',
        phoneNumber: '+33198765432',
        address: '42 Boulevard du Streaming, 69000 Lyon',
        specialty: 'Services Audiovisuels',
        specialties: [
          'Configuration streaming',
          'Montage vidéo',
          'Production audio',
        ],
        yearsOfExperience: 6,
        rating: 4.9,
        ratingsCount: 189,
        completedJobs: 450,
        isVerified: true,
        isActive: true,
        isAvailable: true,
        createdAt: DateTime.now().subtract(const Duration(days: 1000)),
        updatedAt: DateTime.now(),
        workingAreas: ['France', 'Europe'],
        certifications: ['Certification audiovisuelle'],
        serviceIds: [],
      ),
      ProviderModel(
        id: '',
        name: 'CleanPro Services',
        email: 'contact@cleanpro.fr',
        phoneNumber: '+33140987654',
        address: '25 Avenue des Champs, 75008 Paris',
        specialty: 'Nettoyage Professionnel',
        specialties: ['Nettoyage bureaux', 'Nettoyage résidentiel', 'Vitres'],
        yearsOfExperience: 8,
        rating: 4.7,
        ratingsCount: 340,
        completedJobs: 1200,
        isVerified: true,
        isActive: true,
        isAvailable: true,
        createdAt: DateTime.now().subtract(const Duration(days: 500)),
        updatedAt: DateTime.now(),
        workingAreas: ['Paris', 'Île-de-France'],
        certifications: ['Certification ISO 9001', 'Formation Hygiène'],
        serviceIds: [],
      ),
    ];

    for (final provider in sampleProviders) {
      await adminProviderManager.createProvider(provider);
    }

    print('✅ Providers d\'exemple créés avec succès');
  }
}

import 'dart:async';
import 'providers_management_data.dart';
import 'providers_management_events.dart';
import '../admin_provider_manager.dart';
import '../../../../utils/event_bus.dart';
import '../../../../models/models.dart';

/// Handler pour le chargement et la gestion des données des prestataires
class ProvidersManagementDataHandler {
  final ProvidersManagementData _data;
  final AdminProviderManager _providerManager = AdminProviderManager();

  ProvidersManagementDataHandler(this._data);

  /// Charge les prestataires et les statistiques
  Future<void> loadProviders() async {
    print(
      '🚀 ProvidersManagementDataHandler: Début du chargement des prestataires...',
    );

    EventBus.instance.emit(LoadingStateChangedEvent(true));

    try {
      final providers = await _providerManager.allProviders;
      final stats = await _providerManager.getProviderStats();

      print(
        '📊 ProvidersManagementDataHandler: Prestataires reçus: ${providers.length}',
      );
      print('📊 ProvidersManagementDataHandler: Stats: $stats');

      _data.providers = providers;
      _data.totalProvidersCount = stats['total'] ?? 0;
      _data.activeProvidersCount = stats['active'] ?? 0;
      _data.verifiedProvidersCount = stats['verified'] ?? 0;
      _data.availableProvidersCount = stats['available'] ?? 0;
      _data.isLoading = false;
      _data.error = null;

      EventBus.instance.emit(
        ProvidersLoadedEvent(providers: providers, stats: stats),
      );

      print('✅ ProvidersManagementDataHandler: Données chargées avec succès');
    } catch (e) {
      print('❌ ProvidersManagementDataHandler: Erreur lors du chargement: $e');
      _data.isLoading = false;
      _data.error = 'Erreur lors du chargement des prestataires';

      EventBus.instance.emit(ErrorEvent('Erreur lors du chargement: $e'));
    }

    EventBus.instance.emit(LoadingStateChangedEvent(false));
  }

  /// Actualise les données
  Future<void> refreshProviders() async {
    await loadProviders();
  }

  /// Active un prestataire
  Future<void> activateProvider(ProviderModel provider) async {
    try {
      // Si le prestataire n'est pas actif, on utilise toggle pour l'activer
      if (!provider.isActive) {
        await _providerManager.toggleProviderStatus(provider.id);
      }

      EventBus.instance.emit(
        ProviderActionCompletedEvent(
          message: 'Prestataire activé avec succès',
          isSuccess: true,
        ),
      );

      await refreshProviders();
    } catch (e) {
      EventBus.instance.emit(
        ProviderActionCompletedEvent(
          message: 'Erreur lors de l\'activation: $e',
          isSuccess: false,
        ),
      );
    }
  }

  /// Désactive un prestataire
  Future<void> deactivateProvider(ProviderModel provider) async {
    try {
      // Si le prestataire est actif, on utilise toggle pour le désactiver
      if (provider.isActive) {
        await _providerManager.toggleProviderStatus(provider.id);
      }

      EventBus.instance.emit(
        ProviderActionCompletedEvent(
          message: 'Prestataire désactivé avec succès',
          isSuccess: true,
        ),
      );

      await refreshProviders();
    } catch (e) {
      EventBus.instance.emit(
        ProviderActionCompletedEvent(
          message: 'Erreur lors de la désactivation: $e',
          isSuccess: false,
        ),
      );
    }
  }

  /// Supprime un prestataire
  Future<void> deleteProvider(ProviderModel provider) async {
    try {
      await _providerManager.deleteProvider(provider.id);

      EventBus.instance.emit(
        ProviderActionCompletedEvent(
          message: 'Prestataire supprimé avec succès',
          isSuccess: true,
        ),
      );

      await refreshProviders();
    } catch (e) {
      EventBus.instance.emit(
        ProviderActionCompletedEvent(
          message: 'Erreur lors de la suppression: $e',
          isSuccess: false,
        ),
      );
    }
  }

  /// Vérifie un prestataire
  Future<void> verifyProvider(ProviderModel provider) async {
    try {
      await _providerManager.verifyProvider(provider.id);

      EventBus.instance.emit(
        ProviderActionCompletedEvent(
          message: 'Prestataire vérifié avec succès',
          isSuccess: true,
        ),
      );

      await refreshProviders();
    } catch (e) {
      EventBus.instance.emit(
        ProviderActionCompletedEvent(
          message: 'Erreur lors de la vérification: $e',
          isSuccess: false,
        ),
      );
    }
  }

  /// Actions bulk
  Future<void> bulkActivateProviders(List<ProviderModel> providers) async {
    try {
      final providerIds = providers.map((p) => p.id).toList();
      await _providerManager.bulkActivateProviders(providerIds);

      EventBus.instance.emit(
        ProviderActionCompletedEvent(
          message: '${providers.length} prestataire(s) activé(s) avec succès',
          isSuccess: true,
        ),
      );

      _data.clearSelection();
      await refreshProviders();
    } catch (e) {
      EventBus.instance.emit(
        ProviderActionCompletedEvent(
          message: 'Erreur lors de l\'activation en lot: $e',
          isSuccess: false,
        ),
      );
    }
  }

  Future<void> bulkDeactivateProviders(List<ProviderModel> providers) async {
    try {
      final providerIds = providers.map((p) => p.id).toList();
      await _providerManager.bulkDeactivateProviders(providerIds);

      EventBus.instance.emit(
        ProviderActionCompletedEvent(
          message:
              '${providers.length} prestataire(s) désactivé(s) avec succès',
          isSuccess: true,
        ),
      );

      _data.clearSelection();
      await refreshProviders();
    } catch (e) {
      EventBus.instance.emit(
        ProviderActionCompletedEvent(
          message: 'Erreur lors de la désactivation en lot: $e',
          isSuccess: false,
        ),
      );
    }
  }

  Future<void> bulkDeleteProviders(List<ProviderModel> providers) async {
    try {
      final providerIds = providers.map((p) => p.id).toList();
      await _providerManager.bulkDeleteProviders(providerIds);

      EventBus.instance.emit(
        ProviderActionCompletedEvent(
          message: '${providers.length} prestataire(s) supprimé(s) avec succès',
          isSuccess: true,
        ),
      );

      _data.clearSelection();
      await refreshProviders();
    } catch (e) {
      EventBus.instance.emit(
        ProviderActionCompletedEvent(
          message: 'Erreur lors de la suppression en lot: $e',
          isSuccess: false,
        ),
      );
    }
  }

  /// Bascule le statut d'un prestataire
  Future<void> toggleProviderStatus(ProviderModel provider) async {
    try {
      await _providerManager.toggleProviderStatus(provider.id);

      final newStatus = provider.isActive ? 'désactivé' : 'activé';
      EventBus.instance.emit(
        ProviderActionCompletedEvent(
          message: 'Prestataire $newStatus avec succès',
          isSuccess: true,
        ),
      );

      await refreshProviders();
    } catch (e) {
      EventBus.instance.emit(
        ProviderActionCompletedEvent(
          message: 'Erreur lors du changement de statut: $e',
          isSuccess: false,
        ),
      );
    }
  }
}

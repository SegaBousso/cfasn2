import 'package:flutter/material.dart';
import '../../../../models/models.dart';
import 'logic.dart';

class ProviderEventHandler {
  final ProviderFormData formData;
  final ProviderImageHandler imageHandler;
  final ProviderSaveHandler saveHandler;
  final VoidCallback onStateChanged;

  ProviderEventHandler({
    required this.formData,
    required this.imageHandler,
    required this.saveHandler,
    required this.onStateChanged,
  });

  Future<void> handlePickImage(BuildContext context) async {
    try {
      final image = await imageHandler.pickImage(context);
      if (image != null) {
        onStateChanged();
      }
    } catch (e) {
      if (context.mounted) {
        ProviderSnackBarManager.showError(context, e.toString());
      }
    }
  }

  void handleAddToList(List<String> list, String value) {
    final success = formData.addToList(list, value);
    if (success) {
      onStateChanged();
    }
  }

  void handleRemoveFromList(List<String> list, String item) {
    final success = formData.removeFromList(list, item);
    if (success) {
      onStateChanged();
    }
  }

  void handleAddService(ServiceModel service) {
    print('🎯 EventHandler: handleAddService appelé pour: ${service.name}');
    final success = formData.addService(service);
    if (success) {
      print(
        '✅ EventHandler: Service ajouté avec succès, mise à jour de l\'état...',
      );
      onStateChanged();
    } else {
      print('❌ EventHandler: Échec de l\'ajout du service');
    }
  }

  void handleRemoveService(ServiceModel service) {
    print('🎯 EventHandler: handleRemoveService appelé pour: ${service.name}');
    final success = formData.removeService(service);
    if (success) {
      print(
        '✅ EventHandler: Service supprimé avec succès, mise à jour de l\'état...',
      );
      onStateChanged();
    } else {
      print('❌ EventHandler: Échec de la suppression du service');
    }
  }

  Future<ProviderModel?> handleSave({
    required BuildContext context,
    required GlobalKey<FormState> formKey,
    required ProviderModel? existingProvider,
  }) async {
    try {
      final provider = await saveHandler.saveProvider(
        formData: formData,
        imageHandler: imageHandler,
        formKey: formKey,
        existingProvider: existingProvider,
      );

      if (context.mounted) {
        ProviderSnackBarManager.showSuccess(
          context,
          existingProvider != null
              ? 'Prestataire modifié avec succès'
              : 'Prestataire créé avec succès',
        );
      }

      return provider;
    } catch (e) {
      if (context.mounted) {
        ProviderSnackBarManager.showError(context, e.toString());
      }
      return null;
    } finally {
      onStateChanged();
    }
  }

  /// Initialiser le provider et charger les services
  Future<void> initializeProvider({
    required BuildContext context,
    ProviderModel? existingProvider,
    required ProviderServicesHandler servicesHandler,
  }) async {
    print('🚀 EventHandler: Initialisation du provider...');

    // Populer les données si on modifie un provider existant
    if (existingProvider != null) {
      print(
        '✏️ EventHandler: Population des données pour provider existant: ${existingProvider.name}',
      );
      formData.populateFrom(existingProvider);
    } else {
      print('➕ EventHandler: Création d\'un nouveau provider');
    }

    // Charger les services disponibles
    print('🔄 EventHandler: Chargement des services disponibles...');
    final errorMessage = await servicesHandler.initializeServices(
      formData: formData,
      existingProvider: existingProvider,
    );

    print(
      '📊 EventHandler: Services chargés. Disponibles: ${servicesHandler.availableServices.length}',
    );
    print(
      '🎯 EventHandler: Services sélectionnés: ${formData.selectedServices.length}',
    );

    // Notifier du changement d'état
    onStateChanged();

    // Afficher l'erreur si nécessaire
    if (errorMessage != null && context.mounted) {
      print('❌ EventHandler: Erreur lors de l\'initialisation: $errorMessage');
      ProviderSnackBarManager.showError(context, errorMessage);
    } else {
      print('✅ EventHandler: Initialisation terminée avec succès');
    }
  }

  /// Sauvegarder et fermer l'écran avec navigation
  Future<void> saveAndClose({
    required BuildContext context,
    required GlobalKey<FormState> formKey,
    required ProviderModel? existingProvider,
  }) async {
    final provider = await handleSave(
      context: context,
      formKey: formKey,
      existingProvider: existingProvider,
    );

    // Fermer l'écran et retourner le provider si sauvegarde réussie
    if (provider != null && context.mounted) {
      Navigator.pop(context, provider);
    }
  }
}

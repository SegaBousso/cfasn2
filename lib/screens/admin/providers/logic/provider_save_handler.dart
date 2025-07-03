import 'package:flutter/material.dart';
import '../../../../models/models.dart';
import '../admin_provider_manager.dart';
import 'provider_form_data.dart';
import 'provider_image_handler.dart';

/// Gestionnaire pour la sauvegarde des prestataires
class ProviderSaveHandler {
  final AdminProviderManager _providerManager = AdminProviderManager();

  bool isLoading = false;

  /// Sauvegarder un prestataire (création ou modification)
  Future<ProviderModel> saveProvider({
    required ProviderFormData formData,
    required ProviderImageHandler imageHandler,
    required GlobalKey<FormState> formKey,
    ProviderModel? existingProvider,
  }) async {
    // Validation du formulaire
    if (!formKey.currentState!.validate()) {
      throw FormValidationException('Le formulaire contient des erreurs');
    }

    if (!formData.isValid()) {
      throw FormValidationException(
        'Tous les champs requis doivent être remplis',
      );
    }

    isLoading = true;

    try {
      // Upload de l'image si nécessaire
      String? imageUrl = formData.currentImageUrl;
      if (imageHandler.hasSelectedImage) {
        final providerId =
            existingProvider?.id ??
            DateTime.now().millisecondsSinceEpoch.toString();
        imageUrl = await imageHandler.uploadImage(providerId);
      }

      // Création du modèle prestataire
      final provider = formData.createProviderModel(
        existingId: existingProvider?.id,
        imageUrl: imageUrl,
        existingProvider: existingProvider,
      );

      // Sauvegarde en base
      if (existingProvider != null) {
        await _providerManager.updateProvider(provider);
      } else {
        await _providerManager.createProvider(provider);
      }

      return provider;
    } catch (e) {
      if (e is FormValidationException ||
          e is ImageUploadException ||
          e is ImagePickerException) {
        rethrow;
      }
      throw ProviderSaveException('Erreur lors de la sauvegarde: $e');
    } finally {
      isLoading = false;
    }
  }

  /// Vérifier si une sauvegarde est en cours
  bool get isSaving => isLoading;
}

/// Exception pour les erreurs de validation de formulaire
class FormValidationException implements Exception {
  final String message;
  const FormValidationException(this.message);

  @override
  String toString() => 'FormValidationException: $message';
}

/// Exception pour les erreurs de sauvegarde de prestataire
class ProviderSaveException implements Exception {
  final String message;
  const ProviderSaveException(this.message);

  @override
  String toString() => 'ProviderSaveException: $message';
}

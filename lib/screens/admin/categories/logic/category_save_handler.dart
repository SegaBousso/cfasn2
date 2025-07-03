import 'package:flutter/material.dart';
import '../../../../models/category_model.dart';
import 'logic.dart';

/// Gestionnaire pour la sauvegarde des catégories
class CategorySaveHandler {
  bool isLoading = false;

  /// Sauvegarder une catégorie (création ou modification)
  Future<CategoryModel> saveCategory(
    GlobalKey<FormState> formKey,
    CategoryFormData formData,
    CategoryImageHandler imageHandler, {
    CategoryModel? existingCategory,
  }) async {
    // Validation du formulaire
    if (!formKey.currentState!.validate()) {
      throw Exception('Veuillez corriger les erreurs dans le formulaire');
    }

    try {
      isLoading = true;

      // Générer ou utiliser l'ID existant
      final categoryId =
          existingCategory?.id ??
          DateTime.now().millisecondsSinceEpoch.toString();

      // Upload de l'image si nécessaire
      String? imageUrl = formData.currentImageUrl;
      if (imageHandler.selectedImage != null) {
        imageUrl = await imageHandler.uploadImage(categoryId);
      }

      // Créer le modèle de catégorie
      final category = formData.createCategoryModel(
        id: categoryId,
        createdAt: existingCategory?.createdAt,
        serviceCount: existingCategory?.serviceCount,
        imageUrl: imageUrl,
      );

      // Simuler un délai de sauvegarde (remplacer par vraie logique)
      await Future.delayed(const Duration(milliseconds: 500));

      return category;
    } catch (e) {
      throw Exception('Erreur lors de la sauvegarde: $e');
    } finally {
      isLoading = false;
    }
  }

  /// Valider avant sauvegarde
  bool canSave(GlobalKey<FormState> formKey) {
    return formKey.currentState?.validate() ?? false;
  }
}

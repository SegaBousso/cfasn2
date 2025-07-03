import 'package:flutter/material.dart';
import '../../../../models/category_model.dart';
import 'logic.dart';

class CategoryEventHandler {
  final CategoryFormData formData;
  final CategoryImageHandler imageHandler;
  final CategorySaveHandler saveHandler;
  final VoidCallback onStateChanged;

  CategoryEventHandler({
    required this.formData,
    required this.imageHandler,
    required this.saveHandler,
    required this.onStateChanged,
  });

  /// Initialiser le gestionnaire avec une catégorie existante ou par défaut
  void initializeCategory(CategoryModel? existingCategory) {
    if (existingCategory != null) {
      formData.populateFrom(existingCategory);
    } else {
      formData.initializeDefaults();
    }
    onStateChanged();
  }

  /// Gérer la sélection d'image
  Future<void> handlePickImage() async {
    try {
      final image = await imageHandler.pickImage();
      if (image != null) {
        onStateChanged();
      }
    } catch (e) {
      // La gestion d'erreur sera faite ailleurs
      rethrow;
    }
  }

  /// Supprimer l'image
  void handleRemoveImage() {
    imageHandler.removeSelectedImage();
    formData.currentImageUrl = null;
    onStateChanged();
  }

  /// Changer l'icône sélectionnée
  void selectIcon(String iconName) {
    formData.selectedIcon = iconName;
    onStateChanged();
  }

  /// Sélectionner une couleur
  void selectColor(Color color) {
    formData.selectedColor = color;
    onStateChanged();
  }

  /// Changer le statut actif
  void toggleActive(bool isActive) {
    formData.isActive = isActive;
    onStateChanged();
  }

  /// Sélectionner une image
  Future<void> pickImage() async {
    await imageHandler.pickImage();
    onStateChanged();
  }

  /// Supprimer l'image
  void removeImage() {
    imageHandler.removeSelectedImage();
    formData.currentImageUrl = null;
    onStateChanged();
  }

  /// Sauvegarder la catégorie
  Future<void> saveCategory(GlobalKey<FormState> formKey) async {
    try {
      if (!formKey.currentState!.validate()) {
        return;
      }

      onStateChanged(); // Mettre à jour l'état de chargement

      await saveHandler.saveCategory(formKey, formData, imageHandler);

      // Navigation et message de succès seront gérés dans le widget principal
      onStateChanged();
    } catch (e) {
      onStateChanged();
      rethrow;
    }
  }

  /// Changer l'icône sélectionnée
  void handleIconChanged(String iconName) {
    formData.selectedIcon = iconName;
    onStateChanged();
  }

  /// Changer la couleur sélectionnée
  void handleColorChanged(Color color) {
    formData.selectedColor = color;
    onStateChanged();
  }

  /// Changer le statut actif
  void handleActiveChanged(bool isActive) {
    formData.isActive = isActive;
    onStateChanged();
  }
}

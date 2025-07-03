import 'package:flutter/material.dart';
import '../../../../models/category_model.dart';

/// Gestionnaire centralisé des données du formulaire catégorie
class CategoryFormData {
  // Controllers
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final sortOrderController = TextEditingController();

  // État du formulaire
  String? selectedIcon;
  Color selectedColor = Colors.blue;
  bool isActive = true;

  // Image actuelle (pour l'édition)
  String? currentImageUrl;

  // Icônes disponibles
  final List<Map<String, dynamic>> availableIcons = [
    {'name': 'cleaning', 'icon': Icons.cleaning_services, 'label': 'Nettoyage'},
    {'name': 'repair', 'icon': Icons.build, 'label': 'Réparation'},
    {'name': 'education', 'icon': Icons.school, 'label': 'Éducation'},
    {'name': 'health', 'icon': Icons.health_and_safety, 'label': 'Santé'},
    {'name': 'beauty', 'icon': Icons.face, 'label': 'Beauté'},
    {'name': 'home', 'icon': Icons.home, 'label': 'Maison'},
    {'name': 'garden', 'icon': Icons.yard, 'label': 'Jardin'},
    {'name': 'transport', 'icon': Icons.directions_car, 'label': 'Transport'},
    {'name': 'technology', 'icon': Icons.computer, 'label': 'Technologie'},
    {'name': 'food', 'icon': Icons.restaurant, 'label': 'Alimentation'},
    {'name': 'sports', 'icon': Icons.sports, 'label': 'Sports'},
    {'name': 'music', 'icon': Icons.music_note, 'label': 'Musique'},
    {'name': 'art', 'icon': Icons.palette, 'label': 'Art'},
    {'name': 'pets', 'icon': Icons.pets, 'label': 'Animaux'},
    {'name': 'business', 'icon': Icons.business, 'label': 'Business'},
  ];

  // Couleurs disponibles
  final List<Color> availableColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.pink,
    Colors.teal,
    Colors.indigo,
    Colors.amber,
    Colors.brown,
    Colors.cyan,
    Colors.deepOrange,
    Colors.deepPurple,
    Colors.lime,
    Colors.blueGrey,
  ];

  /// Initialiser avec une catégorie existante
  void populateFrom(CategoryModel category) {
    nameController.text = category.name;
    descriptionController.text = category.description;
    sortOrderController.text = category.sortOrder.toString();
    selectedIcon = category.iconName;
    selectedColor = category.color;
    isActive = category.isActive;
    currentImageUrl = category.imageUrl;
  }

  /// Initialiser les valeurs par défaut pour une nouvelle catégorie
  void initializeDefaults() {
    selectedIcon = availableIcons.first['name'];
    sortOrderController.text = '0';
  }

  /// Créer un modèle CategoryModel à partir des données actuelles
  CategoryModel createCategoryModel({
    String? id,
    DateTime? createdAt,
    int? serviceCount,
    String? imageUrl,
  }) {
    final now = DateTime.now();

    return CategoryModel(
      id: id ?? now.millisecondsSinceEpoch.toString(),
      name: nameController.text.trim(),
      description: descriptionController.text.trim(),
      iconName: selectedIcon,
      color: selectedColor,
      isActive: isActive,
      sortOrder: int.tryParse(sortOrderController.text) ?? 0,
      serviceCount: serviceCount ?? 0,
      createdAt: createdAt ?? now,
      updatedAt: now,
      imageUrl: imageUrl ?? currentImageUrl,
    );
  }

  /// Valider les données du formulaire
  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Le nom est obligatoire';
    }
    if (value.trim().length < 2) {
      return 'Le nom doit contenir au moins 2 caractères';
    }
    return null;
  }

  String? validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'La description est obligatoire';
    }
    if (value.trim().length < 10) {
      return 'La description doit contenir au moins 10 caractères';
    }
    return null;
  }

  String? validateSortOrder(String? value) {
    if (value != null && value.isNotEmpty) {
      final order = int.tryParse(value);
      if (order == null || order < 0) {
        return 'L\'ordre doit être un nombre positif';
      }
    }
    return null;
  }

  /// Nettoyer les ressources
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    sortOrderController.dispose();
  }
}

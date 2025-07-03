import '../../../../models/models.dart';
import '../../../../services/admin_category_manager.dart';

/// Gestionnaire pour la gestion des catégories dans les services
class ServiceCategoryHandler {
  final AdminCategoryManager _categoryManager = AdminCategoryManager();

  List<CategoryModel> availableCategories = [];
  bool isLoading = true;

  /// Charger toutes les catégories
  Future<List<CategoryModel>> loadCategories() async {
    try {
      isLoading = true;
      final categories = await _categoryManager.getCategories();
      availableCategories = categories.where((cat) => cat.isActive).toList();
      return availableCategories;
    } catch (e) {
      throw Exception('Erreur lors du chargement des catégories: $e');
    } finally {
      isLoading = false;
    }
  }

  /// Obtenir une catégorie par son ID
  CategoryModel? getCategoryById(String categoryId) {
    try {
      return availableCategories.firstWhere((cat) => cat.id == categoryId);
    } catch (e) {
      return null;
    }
  }

  /// Vérifier si une catégorie existe
  bool categoryExists(String categoryId) {
    return availableCategories.any((cat) => cat.id == categoryId);
  }

  /// Obtenir la première catégorie (défaut)
  CategoryModel? getDefaultCategory() {
    return availableCategories.isNotEmpty ? availableCategories.first : null;
  }
}

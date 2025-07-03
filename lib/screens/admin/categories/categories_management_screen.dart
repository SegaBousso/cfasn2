import 'package:flutter/material.dart';
import '../../../models/models.dart';
import '../../../services/admin_category_manager.dart';
import 'widgets/category_filters.dart';
import 'widgets/category_card.dart';
import 'add_edit_category_screen.dart';

class CategoriesManagementScreen extends StatefulWidget {
  const CategoriesManagementScreen({super.key});

  @override
  State<CategoriesManagementScreen> createState() =>
      _CategoriesManagementScreenState();
}

class _CategoriesManagementScreenState
    extends State<CategoriesManagementScreen> {
  final AdminCategoryManager _categoryManager = AdminCategoryManager();

  List<CategoryModel> _categories = [];
  List<CategoryModel> _filteredCategories = [];
  bool _isLoading = false;
  String _searchQuery = '';
  bool _showActiveOnly = false;
  String _sortBy = 'name';

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final categories = await _categoryManager.getCategories();
      setState(() {
        _categories = categories;
        _applyFilters();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: ${e.toString()}')));
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    _filteredCategories = _categories.where((category) {
      bool matchesSearch =
          _searchQuery.isEmpty ||
          category.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          category.description.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );

      bool matchesActiveFilter = !_showActiveOnly || category.isActive;

      return matchesSearch && matchesActiveFilter;
    }).toList();

    // Appliquer le tri
    switch (_sortBy) {
      case 'name':
        _filteredCategories.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'date':
        _filteredCategories.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'active':
        _filteredCategories.sort(
          (a, b) => b.isActive.toString().compareTo(a.isActive.toString()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des catégories'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Filtres
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CategoryFilters(
              searchQuery: _searchQuery,
              showActiveOnly: _showActiveOnly,
              sortBy: _sortBy,
              onSearchChanged: (query) {
                setState(() {
                  _searchQuery = query;
                  _applyFilters();
                });
              },
              onActiveFilterChanged: (value) {
                setState(() {
                  _showActiveOnly = value;
                  _applyFilters();
                });
              },
              onSortChanged: (value) {
                setState(() {
                  _sortBy = value;
                  _applyFilters();
                });
              },
            ),
          ),

          // Statistiques
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Total',
                  _categories.length.toString(),
                  Icons.category,
                  Colors.blue,
                ),
                _buildStatItem(
                  'Actives',
                  _categories.where((c) => c.isActive).length.toString(),
                  Icons.check_circle,
                  Colors.green,
                ),
                _buildStatItem(
                  'Inactives',
                  _categories.where((c) => !c.isActive).length.toString(),
                  Icons.pause_circle,
                  Colors.orange,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Liste des catégories
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredCategories.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.category_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _categories.isEmpty
                              ? 'Aucune catégorie trouvée'
                              : 'Aucune catégorie ne correspond aux filtres',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (_categories.isEmpty)
                          ElevatedButton.icon(
                            onPressed: _initializeDefaultCategories,
                            icon: const Icon(Icons.restore),
                            label: const Text(
                              'Initialiser les catégories par défaut',
                            ),
                          ),
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1.2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                      itemCount: _filteredCategories.length,
                      itemBuilder: (context, index) {
                        final category = _filteredCategories[index];
                        return CategoryCard(
                          category: category,
                          onEdit: () => _navigateToEditCategory(category),
                          onDelete: () => _deleteCategory(category),
                          onToggleStatus: () => _toggleCategoryStatus(category),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: "categories_management_fab",
        onPressed: () => _navigateToCreateCategory(),
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle catégorie'),
      ),
    );
  }

  Widget _buildStatItem(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(title, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Future<void> _navigateToCreateCategory() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AddEditCategoryScreen()),
    );

    if (result != null && result is CategoryModel) {
      await _categoryManager.createCategory(result);
      _loadCategories();
    }
  }

  Future<void> _navigateToEditCategory(CategoryModel category) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditCategoryScreen(category: category),
      ),
    );

    if (result != null && result is CategoryModel) {
      await _categoryManager.updateCategory(result);
      _loadCategories();
    }
  }

  Future<void> _deleteCategory(CategoryModel category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la catégorie'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer "${category.name}" ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _categoryManager.deleteCategory(category.id);
        _loadCategories();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Catégorie supprimée avec succès')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Erreur: ${e.toString()}')));
        }
      }
    }
  }

  Future<void> _toggleCategoryStatus(CategoryModel category) async {
    try {
      final updatedCategory = category.copyWith(isActive: !category.isActive);
      await _categoryManager.updateCategory(updatedCategory);
      _loadCategories();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              updatedCategory.isActive
                  ? 'Catégorie activée'
                  : 'Catégorie désactivée',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: ${e.toString()}')));
      }
    }
  }

  Future<void> _initializeDefaultCategories() async {
    try {
      await _categoryManager.initializeDefaultCategories();
      _loadCategories();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Catégories par défaut initialisées')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: ${e.toString()}')));
      }
    }
  }
}

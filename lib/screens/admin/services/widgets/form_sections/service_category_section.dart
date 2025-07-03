import 'package:flutter/material.dart';
import '../../../../../models/service_model.dart';
import '../../../../../utils/event_bus.dart';
import '../../logic/logic.dart';

class ServiceCategorySection extends StatefulWidget {
  const ServiceCategorySection({super.key});

  @override
  State<ServiceCategorySection> createState() => _ServiceCategorySectionState();
}

class _ServiceCategorySectionState extends State<ServiceCategorySection> {
  String _selectedCategoryId = '';
  List<ServiceCategory> _categories = [];
  bool _categoriesLoading = true;
  late final ServiceCategoryHandler _categoryHandler;

  @override
  void initState() {
    super.initState();
    _categoryHandler = ServiceCategoryHandler();
    _setupEventListeners();
    _initializeData();
  }

  void _setupEventListeners() {
    EventBus.instance.on<ServiceFormDataUpdated>().listen((event) {
      if (mounted) {
        setState(() {
          _selectedCategoryId = event.formData.categoryId;
        });
      }
    });
  }

  void _initializeData() {
    _categoryHandler.loadCategories();
    final formData = ServiceFormData.instance;
    _selectedCategoryId = formData.categoryId;
  }

  void _onCategoryChanged(String? categoryId) {
    if (categoryId != null) {
      final selectedCategory = _categories.firstWhere(
        (cat) => cat.id == categoryId,
      );
      ServiceFormData.instance.updateCategory(
        categoryId,
        selectedCategory.name,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Catégorie',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (_categoriesLoading)
              const LinearProgressIndicator()
            else if (_categories.isEmpty)
              _buildNoCategoriesWarning()
            else
              _buildCategoryDropdown(),
          ],
        ),
      ),
    );
  }

  Widget _buildNoCategoriesWarning() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning, color: Colors.orange.shade700),
              const SizedBox(width: 8),
              Text(
                'Aucune catégorie disponible',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Vous devez d\'abord créer des catégories avant de pouvoir créer un service.',
            style: TextStyle(color: Colors.orange.shade700),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigation vers l'écran de gestion des catégories
            },
            icon: const Icon(Icons.category),
            label: const Text('Gérer les catégories'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      value: _selectedCategoryId.isEmpty ? null : _selectedCategoryId,
      decoration: const InputDecoration(
        labelText: 'Catégorie *',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.category),
      ),
      items: _categories.map((category) {
        return DropdownMenuItem<String>(
          value: category.id,
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(category.icon, size: 16, color: Colors.deepPurple),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(category.name, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: _onCategoryChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Veuillez sélectionner une catégorie';
        }
        return null;
      },
    );
  }
}

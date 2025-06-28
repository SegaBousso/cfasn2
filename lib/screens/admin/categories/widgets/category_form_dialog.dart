import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../models/category_model.dart';
import '../../../../services/image_upload_service.dart';

class CategoryFormDialog extends StatefulWidget {
  final CategoryModel? category;

  const CategoryFormDialog({super.key, this.category});

  @override
  State<CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends State<CategoryFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _sortOrderController;
  final ImageUploadService _imageUploadService = ImageUploadService();

  String? _selectedIcon;
  Color _selectedColor = Colors.blue;
  bool _isActive = true;

  // Gestion des images
  XFile? _selectedImage;
  String? _currentImageUrl;
  bool _imageUploading = false;

  final List<Map<String, dynamic>> _availableIcons = [
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
  ];

  final List<Color> _availableColors = [
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
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _descriptionController = TextEditingController(
      text: widget.category?.description ?? '',
    );
    _sortOrderController = TextEditingController(
      text: widget.category?.sortOrder.toString() ?? '0',
    );

    if (widget.category != null) {
      _selectedIcon = widget.category!.iconName;
      _selectedColor = widget.category!.color;
      _isActive = widget.category!.isActive;
      _currentImageUrl = widget.category!.imageUrl;
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 600,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la sélection de l\'image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _sortOrderController.dispose();
    super.dispose();
  }

  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _imageUploading = true);

    try {
      final now = DateTime.now();

      // Créer un ID temporaire pour les nouvelles catégories
      final categoryId =
          widget.category?.id ??
          DateTime.now().millisecondsSinceEpoch.toString();

      // Upload de l'image si nécessaire
      String? imageUrl = _currentImageUrl;
      if (_selectedImage != null) {
        imageUrl = await _imageUploadService.uploadCategoryImage(
          categoryId,
          _selectedImage!,
        );
      }

      final category = CategoryModel(
        id: categoryId,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        iconName: _selectedIcon,
        color: _selectedColor,
        isActive: _isActive,
        sortOrder: int.tryParse(_sortOrderController.text) ?? 0,
        serviceCount: widget.category?.serviceCount ?? 0,
        createdAt: widget.category?.createdAt ?? now,
        updatedAt: now,
        imageUrl: imageUrl,
      );

      if (mounted) {
        Navigator.of(context).pop(category);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'upload de l\'image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _imageUploading = false);
      }
    }
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Image de la catégorie',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            // Aperçu de l'image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _selectedImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: kIsWeb
                          ? Image.network(
                              _selectedImage!.path,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[300],
                                  child: const Icon(
                                    Icons.image,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                            )
                          : Image.network(
                              _selectedImage!.path,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[300],
                                  child: const Icon(
                                    Icons.image,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                            ),
                    )
                  : _currentImageUrl != null && _currentImageUrl!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        _currentImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.image, color: Colors.grey),
                          );
                        },
                      ),
                    )
                  : Container(
                      color: Colors.grey[100],
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image, size: 30, color: Colors.grey),
                          SizedBox(height: 4),
                          Text(
                            'Aucune image',
                            style: TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            // Boutons d'action
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _imageUploading ? null : _pickImage,
                      icon: _imageUploading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.upload, size: 16),
                      label: Text(_imageUploading ? 'Upload...' : 'Choisir'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  if (_selectedImage != null ||
                      (_currentImageUrl?.isNotEmpty ?? false)) ...[
                    const SizedBox(height: 4),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _selectedImage = null;
                            _currentImageUrl = null;
                          });
                        },
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                          size: 16,
                        ),
                        label: const Text('Supprimer'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 4),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'JPG, PNG max 5MB (optionnel)',
          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.category != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width,
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            //mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titre
              Row(
                children: [
                  Icon(
                    isEditing ? Icons.edit : Icons.add,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isEditing ? 'Modifier la catégorie' : 'Nouvelle catégorie',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Nom
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom de la catégorie *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.label),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Le nom est obligatoire';
                  }
                  if (value.trim().length < 2) {
                    return 'Le nom doit contenir au moins 2 caractères';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'La description est obligatoire';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Section image
              _buildImageSection(),

              const SizedBox(height: 16),

              // Icône
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Icône',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 100,
                    child: GridView.builder(
                      scrollDirection: Axis.horizontal,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                      itemCount: _availableIcons.length,
                      itemBuilder: (context, index) {
                        final iconData = _availableIcons[index];
                        final isSelected = _selectedIcon == iconData['name'];

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedIcon = iconData['name'];
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? _selectedColor.withOpacity(0.2)
                                  : Colors.grey[100],
                              border: Border.all(
                                color: isSelected
                                    ? _selectedColor
                                    : Colors.grey[300]!,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  iconData['icon'],
                                  color: isSelected
                                      ? _selectedColor
                                      : Colors.grey[600],
                                  size: 20,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  iconData['label'],
                                  style: TextStyle(
                                    fontSize: 8,
                                    color: isSelected
                                        ? _selectedColor
                                        : Colors.grey[600],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Couleur
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Couleur',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _availableColors.map((color) {
                      final isSelected = _selectedColor == color;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedColor = color;
                          });
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? Colors.black
                                  : Colors.grey[300]!,
                              width: isSelected ? 3 : 1,
                            ),
                          ),
                          child: isSelected
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 20,
                                )
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  // Ordre d'affichage
                  Expanded(
                    child: TextFormField(
                      controller: _sortOrderController,
                      decoration: const InputDecoration(
                        labelText: 'Ordre d\'affichage',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.reorder),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final order = int.tryParse(value);
                          if (order == null || order < 0) {
                            return 'Ordre invalide';
                          }
                        }
                        return null;
                      },
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Statut actif
                  Column(
                    children: [
                      const Text('Active'),
                      Switch(
                        value: _isActive,
                        onChanged: (value) {
                          setState(() {
                            _isActive = value;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Boutons d'action
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Annuler'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _saveCategory,
                    child: Text(isEditing ? 'Modifier' : 'Créer'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

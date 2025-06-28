import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../../../models/category_model.dart';
import '../../../services/image_upload_service.dart';
import '../../../utils/responsive_helper.dart';
import '../../../widgets/overflow_safe_widgets.dart';

class AddEditCategoryScreen extends StatefulWidget {
  final CategoryModel? category;

  const AddEditCategoryScreen({super.key, this.category});

  @override
  State<AddEditCategoryScreen> createState() => _AddEditCategoryScreenState();
}

class _AddEditCategoryScreenState extends State<AddEditCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _sortOrderController;
  final ImageUploadService _imageUploadService = ImageUploadService();

  String? _selectedIcon;
  Color _selectedColor = Colors.blue;
  bool _isActive = true;
  bool _isLoading = false;

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
    {'name': 'sports', 'icon': Icons.sports, 'label': 'Sports'},
    {'name': 'music', 'icon': Icons.music_note, 'label': 'Musique'},
    {'name': 'art', 'icon': Icons.palette, 'label': 'Art'},
    {'name': 'pets', 'icon': Icons.pets, 'label': 'Animaux'},
    {'name': 'business', 'icon': Icons.business, 'label': 'Business'},
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
    Colors.cyan,
    Colors.deepOrange,
    Colors.deepPurple,
    Colors.lime,
    Colors.blueGrey,
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
    } else {
      // Sélectionner le premier icône par défaut pour les nouvelles catégories
      _selectedIcon = _availableIcons.first['name'];
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

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.category != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Modifier la catégorie' : 'Nouvelle catégorie'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            )
          else
            TextButton.icon(
              onPressed: _saveCategory,
              icon: const Icon(Icons.save, color: Colors.white),
              label: Text(
                isEditing ? 'Modifier' : 'Créer',
                style: const TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: OverflowSafeArea(
        child: ResponsiveHelper.getDeviceType(context) == DeviceType.mobile
            ? _buildMobileLayout()
            : _buildDesktopLayout(),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildBasicInfoSection(),
            const SizedBox(height: 24),
            _buildImageSection(),
            const SizedBox(height: 24),
            _buildIconSection(),
            const SizedBox(height: 24),
            _buildColorSection(),
            const SizedBox(height: 24),
            _buildSettingsSection(),
            const SizedBox(height: 32),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          _buildBasicInfoSection(),
                          const SizedBox(height: 24),
                          _buildIconSection(),
                          const SizedBox(height: 24),
                          _buildColorSection(),
                        ],
                      ),
                    ),
                    const SizedBox(width: 32),
                    Expanded(
                      child: Column(
                        children: [
                          _buildImageSection(),
                          const SizedBox(height: 24),
                          _buildSettingsSection(),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informations de base',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nom de la catégorie *',
                hintText: 'Ex: Nettoyage',
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
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description *',
                hintText: 'Décrivez cette catégorie...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'La description est obligatoire';
                }
                if (value.trim().length < 10) {
                  return 'La description doit contenir au moins 10 caractères';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Image de la catégorie',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Image optionnelle pour illustrer la catégorie',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            // Aperçu de l'image
            Container(
              width: double.infinity,
              height: 200,
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
                                    size: 50,
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
                                    size: 50,
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
                            child: const Icon(
                              Icons.image,
                              color: Colors.grey,
                              size: 50,
                            ),
                          );
                        },
                      ),
                    )
                  : Container(
                      color: Colors.grey[100],
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image, size: 50, color: Colors.grey[400]),
                          const SizedBox(height: 8),
                          Text(
                            'Aucune image sélectionnée',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            // Boutons d'action pour l'image
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _imageUploading ? null : _pickImage,
                    icon: _imageUploading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.upload),
                    label: Text(
                      _imageUploading ? 'Upload...' : 'Choisir une image',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                if (_selectedImage != null ||
                    (_currentImageUrl?.isNotEmpty ?? false)) ...[
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _selectedImage = null;
                        _currentImageUrl = null;
                      });
                    },
                    icon: const Icon(Icons.delete),
                    label: const Text('Supprimer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Formats acceptés: JPG, PNG. Taille maximale: 5MB',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Icône de la catégorie',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Sélectionnez une icône représentative',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
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
                        color: isSelected ? _selectedColor : Colors.grey[300]!,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          iconData['icon'],
                          color: isSelected ? _selectedColor : Colors.grey[600],
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          iconData['label'],
                          style: TextStyle(
                            fontSize: 10,
                            color: isSelected
                                ? _selectedColor
                                : Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Couleur de la catégorie',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Choisissez une couleur pour identifier la catégorie',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _availableColors.map((color) {
                final isSelected = _selectedColor == color;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColor = color;
                    });
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.black : Colors.grey[300]!,
                        width: isSelected ? 3 : 1,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 24)
                        : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Paramètres',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _sortOrderController,
              decoration: const InputDecoration(
                labelText: 'Ordre d\'affichage',
                hintText: '0',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.reorder),
                helperText:
                    'Plus le nombre est petit, plus la catégorie apparaît en premier',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final order = int.tryParse(value);
                  if (order == null || order < 0) {
                    return 'L\'ordre doit être un nombre positif';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Catégorie active'),
              subtitle: const Text(
                'La catégorie est visible et utilisable dans l\'application',
              ),
              value: _isActive,
              onChanged: (value) {
                setState(() {
                  _isActive = value;
                });
              },
              activeColor: Colors.deepOrange,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
            icon: const Icon(Icons.cancel),
            label: const Text('Annuler'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _saveCategory,
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Icon(widget.category != null ? Icons.save : Icons.add),
            label: Text(widget.category != null ? 'Modifier' : 'Créer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final now = DateTime.now();

      // Créer un ID temporaire pour les nouvelles catégories
      final categoryId =
          widget.category?.id ??
          DateTime.now().millisecondsSinceEpoch.toString();

      // Upload de l'image si nécessaire
      String? imageUrl = _currentImageUrl;
      if (_selectedImage != null) {
        setState(() => _imageUploading = true);
        imageUrl = await _imageUploadService.uploadCategoryImage(
          categoryId,
          _selectedImage!,
        );
        setState(() => _imageUploading = false);
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

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.category != null
                  ? 'Catégorie modifiée avec succès'
                  : 'Catégorie créée avec succès',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la sauvegarde: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

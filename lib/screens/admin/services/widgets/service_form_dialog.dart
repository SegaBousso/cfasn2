import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../models/models.dart';
import '../../../../models/category_model.dart';
import '../../../../services/admin_category_manager.dart';
import '../../../../services/image_upload_service.dart';

class ServiceFormDialog extends StatefulWidget {
  final ServiceModel? service;
  final VoidCallback? onSaved;

  const ServiceFormDialog({super.key, this.service, this.onSaved});

  @override
  State<ServiceFormDialog> createState() => _ServiceFormDialogState();
}

class _ServiceFormDialogState extends State<ServiceFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _tagsController = TextEditingController();
  final AdminCategoryManager _categoryManager = AdminCategoryManager();
  final ImageUploadService _imageUploadService = ImageUploadService();

  String _selectedCategoryId = '';
  String _selectedCategoryName = '';
  bool _isAvailable = true;
  bool _isActive = true;
  bool _isLoading = false;

  List<CategoryModel> _categories = [];
  bool _categoriesLoading = true;

  // Gestion des images
  XFile? _selectedImage;
  String? _currentImageUrl;
  bool _imageUploading = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    if (widget.service != null) {
      _initializeFormWithService();
    }
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _categoryManager.getActiveCategories();
      setState(() {
        _categories = categories;
        _categoriesLoading = false;

        // Si pas de service en édition et qu'on a des catégories, sélectionner la première
        if (widget.service == null && categories.isNotEmpty) {
          _selectedCategoryId = categories.first.id;
          _selectedCategoryName = categories.first.name;
        }
      });
    } catch (e) {
      setState(() {
        _categoriesLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement des catégories: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _initializeFormWithService() {
    final service = widget.service!;
    _nameController.text = service.name;
    _descriptionController.text = service.description;
    _priceController.text = service.price.toString();
    _tagsController.text = service.tags.join(', ');
    _selectedCategoryId = service.categoryId;
    _selectedCategoryName = service.categoryName;
    _isAvailable = service.isAvailable;
    _isActive = service.isActive;
    _currentImageUrl = service.imageUrl;
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
    _priceController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.service != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.all(16),
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.9,
        child: Column(
          children: [
            // En-tête
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.deepPurple,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(isEditing ? Icons.edit : Icons.add, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isEditing ? 'Modifier le service' : 'Créer un service',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Formulaire
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildBasicInfoSection(),
                      const SizedBox(height: 24),
                      _buildImageSection(),
                      const SizedBox(height: 24),
                      _buildCategorySection(),
                      const SizedBox(height: 24),
                      _buildPriceSection(),
                      const SizedBox(height: 24),
                      _buildTagsSection(),
                      const SizedBox(height: 24),
                      _buildStatusSection(),
                    ],
                  ),
                ),
              ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isLoading
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: const Text('Annuler'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _saveService,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(isEditing ? 'Modifier' : 'Créer'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Column(
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
            labelText: 'Nom du service *',
            hintText: 'Ex: Nettoyage de bureaux',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.business_center),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Le nom du service est requis';
            }
            if (value.trim().length < 3) {
              return 'Le nom doit contenir au moins 3 caractères';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            labelText: 'Description *',
            hintText: 'Décrivez votre service en détail...',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.description),
          ),
          maxLines: 3,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'La description est requise';
            }
            if (value.trim().length < 10) {
              return 'La description doit contenir au moins 10 caractères';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildImagePickerSection(),
      ],
    );
  }

  Widget _buildImagePickerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Images du service (optionnel)',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Ajoutez des images pour illustrer votre service',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.upload),
                label: const Text('Télécharger une image'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 12),
            if (widget.service?.imageUrl != null)
              GestureDetector(
                onTap: () {
                  // TODO: Voir l'image en grand
                },
                child: Hero(
                  tag: 'service_image_${widget.service!.id}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      widget.service!.imageUrl ?? '',
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image, color: Colors.grey),
                        );
                      },
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Image du service',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            // Aperçu de l'image
            Container(
              width: 120,
              height: 120,
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
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image, size: 40, color: Colors.grey[400]),
                          const SizedBox(height: 8),
                          Text(
                            'Aucune image',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
            ),
            const SizedBox(width: 16),
            // Boutons d'action
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ElevatedButton.icon(
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
                  ),
                  if (_selectedImage != null ||
                      (_currentImageUrl?.isNotEmpty ?? false)) ...[
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _selectedImage = null;
                          _currentImageUrl = null;
                        });
                      },
                      icon: const Icon(Icons.delete, color: Colors.red),
                      label: const Text('Supprimer l\'image'),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Formats acceptés: JPG, PNG. Taille maximale: 5MB',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildCategorySection() {
    return Column(
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
          Container(
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
                    // Note: Idéalement, on naviguerait vers l'écran de gestion des catégories
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
          )
        else
          DropdownButtonFormField<String>(
            value: _selectedCategoryId.isEmpty ? null : _selectedCategoryId,
            decoration: const InputDecoration(
              labelText: 'Catégorie *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.category),
            ),
            items: _categories.map((category) {
              return DropdownMenuItem<String>(
                value: category.id,
                child: SizedBox(
                  width: double.infinity,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: category.color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Icon(
                          category.icon,
                          size: 16,
                          color: category.color,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          category.name,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (category.serviceCount > 0) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${category.serviceCount}',
                            style: const TextStyle(fontSize: 10),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                final selectedCategory = _categories.firstWhere(
                  (cat) => cat.id == value,
                );
                setState(() {
                  _selectedCategoryId = value;
                  _selectedCategoryName = selectedCategory.name;
                });
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez sélectionner une catégorie';
              }
              return null;
            },
          ),
      ],
    );
  }

  Widget _buildPriceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tarification',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _priceController,
          decoration: const InputDecoration(
            labelText: 'Prix (€) *',
            hintText: '0.00',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.euro),
            suffixText: '€',
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Le prix est requis';
            }
            final price = double.tryParse(value);
            if (price == null) {
              return 'Veuillez entrer un prix valide';
            }
            if (price <= 0) {
              return 'Le prix doit être supérieur à 0';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tags (optionnel)',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Séparez les tags par des virgules (ex: bureau, professionnel, rapide)',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _tagsController,
          decoration: const InputDecoration(
            labelText: 'Tags',
            hintText: 'bureau, professionnel, rapide',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.tag),
          ),
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildStatusSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statut',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('Service disponible'),
          subtitle: const Text('Les utilisateurs peuvent réserver ce service'),
          value: _isAvailable,
          onChanged: (value) {
            setState(() {
              _isAvailable = value;
            });
          },
          activeColor: Colors.green,
        ),
        SwitchListTile(
          title: const Text('Service actif'),
          subtitle: const Text('Le service est visible dans l\'application'),
          value: _isActive,
          onChanged: (value) {
            setState(() {
              _isActive = value;
            });
          },
          activeColor: Colors.deepPurple,
        ),
      ],
    );
  }

  Future<void> _saveService() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final tags = _tagsController.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();

      // Créer un ID temporaire pour les nouveaux services
      final serviceId =
          widget.service?.id ??
          DateTime.now().millisecondsSinceEpoch.toString();

      // Upload de l'image si nécessaire
      String? imageUrl = _currentImageUrl;
      if (_selectedImage != null) {
        setState(() => _imageUploading = true);
        imageUrl = await _imageUploadService.uploadServiceImage(
          serviceId,
          _selectedImage!,
        );
        setState(() => _imageUploading = false);
      }

      final service = ServiceModel(
        id: serviceId,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.parse(_priceController.text),
        categoryId: _selectedCategoryId,
        categoryName: _selectedCategoryName,
        rating: widget.service?.rating ?? 0.0,
        totalReviews: widget.service?.totalReviews ?? 0,
        isAvailable: _isAvailable,
        isActive: _isActive,
        createdAt: widget.service?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: widget.service?.createdBy ?? 'admin',
        tags: tags,
        imageUrl: imageUrl,
      );

      if (mounted) {
        Navigator.of(context).pop(service);
        widget.onSaved?.call();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.service != null
                  ? 'Service modifié avec succès'
                  : 'Service créé avec succès',
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

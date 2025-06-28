import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../models/models.dart';
import '../../../../services/image_upload_service.dart';

class ProviderFormDialog extends StatefulWidget {
  final ProviderModel? provider;
  final Function(ProviderModel) onSave;

  const ProviderFormDialog({super.key, this.provider, required this.onSave});

  @override
  State<ProviderFormDialog> createState() => _ProviderFormDialogState();
}

class _ProviderFormDialogState extends State<ProviderFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _bioController = TextEditingController();
  final _specialtyController = TextEditingController();
  final _experienceController = TextEditingController();
  final ImageUploadService _imageUploadService = ImageUploadService();

  List<String> _specialties = [];
  List<String> _workingAreas = [];
  List<String> _certifications = [];

  bool _isActive = true;
  bool _isAvailable = true;
  bool _isVerified = false;

  // Gestion des images
  XFile? _selectedImage;
  String? _currentImageUrl;
  bool _imageUploading = false;

  final _specialtyInputController = TextEditingController();
  final _areaInputController = TextEditingController();
  final _certificationInputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.provider != null) {
      _populateForm(widget.provider!);
    }
  }

  void _populateForm(ProviderModel provider) {
    _nameController.text = provider.name;
    _emailController.text = provider.email;
    _phoneController.text = provider.phoneNumber;
    _addressController.text = provider.address;
    _bioController.text = provider.bio;
    _specialtyController.text = provider.specialty;
    _experienceController.text = provider.yearsOfExperience.toString();

    _specialties = List.from(provider.specialties);
    _workingAreas = List.from(provider.workingAreas);
    _certifications = List.from(provider.certifications);

    _isActive = provider.isActive;
    _isAvailable = provider.isAvailable;
    _isVerified = provider.isVerified;
    _currentImageUrl = provider.profileImageUrl;
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
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _bioController.dispose();
    _specialtyController.dispose();
    _experienceController.dispose();
    _specialtyInputController.dispose();
    _areaInputController.dispose();
    _certificationInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.provider != null;

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          children: [
            // En-tête
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.purple,
                borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person_add, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    isEditing
                        ? 'Modifier le prestataire'
                        : 'Nouveau prestataire',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Contenu
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Informations de base
                      _buildSectionTitle('Informations générales'),
                      const SizedBox(height: 8),

                      // Section image
                      _buildImageSection(),
                      const SizedBox(height: 24),

                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nom complet *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Le nom est requis';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'L\'email est requis';
                          }
                          if (!value.contains('@')) {
                            return 'Email invalide';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Téléphone *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Le téléphone est requis';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          labelText: 'Adresse *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_on),
                        ),
                        maxLines: 2,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'L\'adresse est requise';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      // Informations professionnelles
                      _buildSectionTitle('Informations professionnelles'),
                      const SizedBox(height: 8),

                      TextFormField(
                        controller: _specialtyController,
                        decoration: const InputDecoration(
                          labelText: 'Spécialité principale *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.work),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'La spécialité est requise';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _experienceController,
                        decoration: const InputDecoration(
                          labelText: 'Années d\'expérience',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.schedule),
                          suffixText: 'années',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            final exp = int.tryParse(value);
                            if (exp == null || exp < 0) {
                              return 'Nombre d\'années invalide';
                            }
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _bioController,
                        decoration: const InputDecoration(
                          labelText: 'Description / Bio',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.description),
                          hintText: 'Décrivez brièvement vos services...',
                        ),
                        maxLines: 3,
                      ),

                      const SizedBox(height: 24),

                      // Spécialités multiples
                      _buildListSection(
                        'Spécialités additionnelles',
                        _specialties,
                        _specialtyInputController,
                        'Ajouter une spécialité',
                        Icons.add_business,
                      ),

                      const SizedBox(height: 16),

                      // Zones de travail
                      _buildListSection(
                        'Zones de travail',
                        _workingAreas,
                        _areaInputController,
                        'Ajouter une zone',
                        Icons.location_city,
                      ),

                      const SizedBox(height: 16),

                      // Certifications
                      _buildListSection(
                        'Certifications',
                        _certifications,
                        _certificationInputController,
                        'Ajouter une certification',
                        Icons.verified,
                      ),

                      const SizedBox(height: 24),

                      // Statuts
                      _buildSectionTitle('Statuts'),
                      const SizedBox(height: 8),

                      SwitchListTile(
                        title: const Text('Actif'),
                        subtitle: const Text(
                          'Le prestataire peut recevoir des demandes',
                        ),
                        value: _isActive,
                        onChanged: (value) {
                          setState(() {
                            _isActive = value;
                          });
                        },
                      ),

                      SwitchListTile(
                        title: const Text('Disponible'),
                        subtitle: const Text(
                          'Le prestataire est disponible pour de nouveaux projets',
                        ),
                        value: _isAvailable,
                        onChanged: (value) {
                          setState(() {
                            _isAvailable = value;
                          });
                        },
                      ),

                      SwitchListTile(
                        title: const Text('Vérifié'),
                        subtitle: const Text(
                          'Le prestataire a été vérifié par l\'administration',
                        ),
                        value: _isVerified,
                        onChanged: (value) {
                          setState(() {
                            _isVerified = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(4),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Annuler'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _saveProvider,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(isEditing ? 'Modifier' : 'Créer'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.purple,
      ),
    );
  }

  Widget _buildListSection(
    String title,
    List<String> items,
    TextEditingController controller,
    String hintText,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),

        // Input pour ajouter un item
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: hintText,
                  border: const OutlineInputBorder(),
                  prefixIcon: Icon(icon),
                  isDense: true,
                ),
                onFieldSubmitted: (_) => _addItem(items, controller),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => _addItem(items, controller),
              icon: const Icon(Icons.add, color: Colors.purple),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Liste des items
        if (items.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: items.map((item) {
              return Chip(
                label: Text(item),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () {
                  setState(() {
                    items.remove(item);
                  });
                },
              );
            }).toList(),
          ),
      ],
    );
  }

  void _addItem(List<String> items, TextEditingController controller) {
    final text = controller.text.trim();
    if (text.isNotEmpty && !items.contains(text)) {
      setState(() {
        items.add(text);
        controller.clear();
      });
    }
  }

  Future<void> _saveProvider() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _imageUploading = true);

    try {
      // Créer un ID temporaire pour les nouveaux prestataires
      final providerId =
          widget.provider?.id ??
          DateTime.now().millisecondsSinceEpoch.toString();

      // Upload de l'image si nécessaire
      String? imageUrl = _currentImageUrl;
      if (_selectedImage != null) {
        imageUrl = await _imageUploadService.uploadProviderImage(
          providerId,
          _selectedImage!,
        );
      }

      final provider = ProviderModel(
        id: providerId,
        name: _nameController.text,
        email: _emailController.text,
        phoneNumber: _phoneController.text,
        address: _addressController.text,
        bio: _bioController.text,
        specialty: _specialtyController.text,
        yearsOfExperience: int.tryParse(_experienceController.text) ?? 0,
        specialties: _specialties,
        workingAreas: _workingAreas,
        certifications: _certifications,
        isActive: _isActive,
        isAvailable: _isAvailable,
        isVerified: _isVerified,
        rating: widget.provider?.rating ?? 0.0,
        ratingsCount: widget.provider?.ratingsCount ?? 0,
        completedJobs: widget.provider?.completedJobs ?? 0,
        serviceIds: widget.provider?.serviceIds ?? [],
        createdAt: widget.provider?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        lastActiveAt: widget.provider?.lastActiveAt,
        businessHours: widget.provider?.businessHours ?? {},
        pricing: widget.provider?.pricing ?? {},
        metadata: widget.provider?.metadata ?? {},
        profileImageUrl: imageUrl,
      );

      widget.onSave(provider);
      if (mounted) {
        Navigator.pop(context);
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
        Text(
          'Photo de profil',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.purple[700],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // Aperçu de l'image
            Container(
              width: 100,
              height: 100,
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
                                    Icons.person,
                                    color: Colors.grey,
                                    size: 40,
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
                                    Icons.person,
                                    color: Colors.grey,
                                    size: 40,
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
                              Icons.person,
                              color: Colors.grey,
                              size: 40,
                            ),
                          );
                        },
                      ),
                    )
                  : Container(
                      color: Colors.grey[100],
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person, size: 40, color: Colors.grey),
                          SizedBox(height: 4),
                          Text(
                            'Aucune photo',
                            style: TextStyle(fontSize: 10, color: Colors.grey),
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
                      _imageUploading ? 'Upload...' : 'Choisir une photo',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple[100],
                      foregroundColor: Colors.purple[700],
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
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                        size: 16,
                      ),
                      label: const Text('Supprimer'),
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
          'Formats acceptés: JPG, PNG. Taille max: 5MB',
          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
        ),
      ],
    );
  }
}

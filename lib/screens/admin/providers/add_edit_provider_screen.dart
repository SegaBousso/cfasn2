import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../models/models.dart';
import '../../../services/image_upload_service.dart';
import '../../../utils/responsive_helper.dart';
import 'admin_provider_manager.dart';

class AddEditProviderScreen extends StatefulWidget {
  final ProviderModel? provider;

  const AddEditProviderScreen({super.key, this.provider});

  @override
  State<AddEditProviderScreen> createState() => _AddEditProviderScreenState();
}

class _AddEditProviderScreenState extends State<AddEditProviderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _bioController = TextEditingController();
  final _specialtyController = TextEditingController();
  final _experienceController = TextEditingController();

  final AdminProviderManager _providerManager = AdminProviderManager();
  final ImageUploadService _imageUploadService = ImageUploadService();

  List<String> _specialties = [];
  List<String> _workingAreas = [];
  List<String> _certifications = [];
  List<String> _serviceIds = [];

  bool _isActive = true;
  bool _isAvailable = true;
  bool _isVerified = false;
  bool _isLoading = false;

  // Gestion des images
  XFile? _selectedImage;
  String? _currentImageUrl;
  bool _imageUploading = false;

  // Controllers pour les listes
  final _specialtyInputController = TextEditingController();
  final _areaInputController = TextEditingController();
  final _certificationInputController = TextEditingController();
  final _serviceInputController = TextEditingController();

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
    _serviceIds = List.from(provider.serviceIds);

    _isActive = provider.isActive;
    _isAvailable = provider.isAvailable;
    _isVerified = provider.isVerified;
    _currentImageUrl = provider.profileImageUrl;
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
    _serviceInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.provider != null;
    final deviceType = ResponsiveHelper.getDeviceType(context);
    final isTabletOrDesktop = deviceType != DeviceType.mobile;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'Modifier le prestataire' : 'Nouveau prestataire',
        ),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: isTabletOrDesktop
            ? _buildTabletDesktopLayout()
            : _buildMobileLayout(),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildTabletDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Colonne gauche
        Expanded(
          flex: 1,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildImageSection(),
                const SizedBox(height: 24),
                _buildBasicInfoSection(),
                const SizedBox(height: 24),
                _buildStatusSection(),
              ],
            ),
          ),
        ),
        // Colonne droite
        Expanded(
          flex: 1,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildProfessionalInfoSection(),
                const SizedBox(height: 24),
                _buildListsSection(),
                const SizedBox(height: 100), // Espace pour le bottom bar
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildImageSection(),
          const SizedBox(height: 24),
          _buildBasicInfoSection(),
          const SizedBox(height: 24),
          _buildProfessionalInfoSection(),
          const SizedBox(height: 24),
          _buildListsSection(),
          const SizedBox(height: 24),
          _buildStatusSection(),
          const SizedBox(height: 100), // Espace pour le bottom bar
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Photo de profil',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: _getImageProvider(),
                    child: _getImageProvider() == null
                        ? const Icon(Icons.person, size: 60, color: Colors.grey)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.purple,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, color: Colors.white),
                        onPressed: _imageUploading ? null : _pickImage,
                      ),
                    ),
                  ),
                  if (_imageUploading)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (_selectedImage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Image sélectionnée: ${_selectedImage!.name}',
                  style: const TextStyle(fontSize: 12, color: Colors.green),
                ),
              ),
          ],
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
              'Informations générales',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
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
                if (!RegExp(
                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                ).hasMatch(value)) {
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
          ],
        ),
      ),
    );
  }

  Widget _buildProfessionalInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informations professionnelles',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
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
                    return 'Nombre invalide';
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
          ],
        ),
      ),
    );
  }

  Widget _buildListsSection() {
    return Column(
      children: [
        _buildListCard(
          'Spécialités additionnelles',
          _specialties,
          _specialtyInputController,
          'Ajouter une spécialité',
          Icons.add_business,
        ),
        const SizedBox(height: 16),
        _buildListCard(
          'Zones de travail',
          _workingAreas,
          _areaInputController,
          'Ajouter une zone',
          Icons.location_city,
        ),
        const SizedBox(height: 16),
        _buildListCard(
          'Services (IDs)',
          _serviceIds,
          _serviceInputController,
          'Ajouter un ID de service',
          Icons.build,
        ),
        const SizedBox(height: 16),
        _buildListCard(
          'Certifications',
          _certifications,
          _certificationInputController,
          'Ajouter une certification',
          Icons.verified,
        ),
      ],
    );
  }

  Widget _buildListCard(
    String title,
    List<String> items,
    TextEditingController controller,
    String hintText,
    IconData icon,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: hintText,
                      border: const OutlineInputBorder(),
                      prefixIcon: Icon(icon),
                    ),
                    onFieldSubmitted: (value) => _addToList(items, controller),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _addToList(items, controller),
                  icon: const Icon(Icons.add),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            if (items.isNotEmpty) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: items.map((item) {
                  return Chip(
                    label: Text(item),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () => _removeFromList(items, item),
                    backgroundColor: Colors.purple.shade50,
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statuts',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('Actif'),
              subtitle: const Text('Le prestataire peut recevoir des demandes'),
              value: _isActive,
              onChanged: (value) => setState(() => _isActive = value),
            ),
            SwitchListTile(
              title: const Text('Disponible'),
              subtitle: const Text(
                'Actuellement disponible pour de nouveaux projets',
              ),
              value: _isAvailable,
              onChanged: (value) => setState(() => _isAvailable = value),
            ),
            SwitchListTile(
              title: const Text('Vérifié'),
              subtitle: const Text('Profil vérifié par l\'administration'),
              value: _isVerified,
              onChanged: (value) => setState(() => _isVerified = value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _isLoading ? null : () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _saveProvider,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text('Sauvegarde...'),
                      ],
                    )
                  : Text(widget.provider != null ? 'Modifier' : 'Créer'),
            ),
          ),
        ],
      ),
    );
  }

  ImageProvider? _getImageProvider() {
    if (_selectedImage != null) {
      return FileImage(_selectedImage as dynamic);
    } else if (_currentImageUrl != null && _currentImageUrl!.isNotEmpty) {
      return NetworkImage(_currentImageUrl!);
    }
    return null;
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

  void _addToList(List<String> list, TextEditingController controller) {
    final value = controller.text.trim();
    if (value.isNotEmpty && !list.contains(value)) {
      setState(() {
        list.add(value);
        controller.clear();
      });
    }
  }

  void _removeFromList(List<String> list, String item) {
    setState(() {
      list.remove(item);
    });
  }

  Future<void> _saveProvider() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String? imageUrl = _currentImageUrl;

      // Upload de l'image si nécessaire
      if (_selectedImage != null) {
        setState(() {
          _imageUploading = true;
        });

        imageUrl = await _imageUploadService.uploadProviderImage(
          widget.provider?.id ??
              DateTime.now().millisecondsSinceEpoch.toString(),
          _selectedImage!,
        );

        setState(() {
          _imageUploading = false;
        });
      }

      final provider = ProviderModel(
        id:
            widget.provider?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        bio: _bioController.text.trim(),
        specialty: _specialtyController.text.trim(),
        specialties: _specialties,
        workingAreas: _workingAreas,
        certifications: _certifications,
        serviceIds: _serviceIds,
        yearsOfExperience: int.tryParse(_experienceController.text) ?? 0,
        profileImageUrl: imageUrl,
        isActive: _isActive,
        isAvailable: _isAvailable,
        isVerified: _isVerified,
        rating: widget.provider?.rating ?? 0.0,
        ratingsCount: widget.provider?.ratingsCount ?? 0,
        completedJobs: widget.provider?.completedJobs ?? 0,
        createdAt: widget.provider?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        lastActiveAt: widget.provider?.lastActiveAt,
        businessHours: widget.provider?.businessHours ?? {},
        pricing: widget.provider?.pricing ?? {},
        metadata: widget.provider?.metadata ?? {},
      );

      if (widget.provider != null) {
        await _providerManager.updateProvider(provider);
      } else {
        await _providerManager.createProvider(provider);
      }

      if (mounted) {
        Navigator.pop(context, provider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.provider != null
                  ? 'Prestataire modifié avec succès'
                  : 'Prestataire créé avec succès',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _imageUploading = false;
        });
      }
    }
  }
}

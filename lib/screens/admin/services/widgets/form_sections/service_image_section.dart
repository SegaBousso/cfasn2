import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../../logic/logic.dart';

class ServiceImageSection extends StatefulWidget {
  const ServiceImageSection({super.key});

  @override
  State<ServiceImageSection> createState() => _ServiceImageSectionState();
}

class _ServiceImageSectionState extends State<ServiceImageSection> {
  XFile? _selectedImage;
  String? _currentImageUrl;
  bool _imageUploading = false;
  late final ServiceImageHandler _imageHandler;

  @override
  void initState() {
    super.initState();
    _imageHandler = ServiceImageHandler();
    _setupEventListeners();
    _initializeData();
  }

  void _setupEventListeners() {
    // For now, we'll manage image state locally
    // Can be enhanced later with proper image events
  }

  void _initializeData() {
    final formData = ServiceFormData.instance;
    _currentImageUrl = formData.imageUrl;
  }

  Future<void> _pickImage() async {
    try {
      final image = await _imageHandler.pickImage();
      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      // Handle error (could show snackbar here)
      print('Error picking image: $e');
    }
  }

  void _removeImage() {
    _imageHandler.removeSelectedImage();
    setState(() {
      _selectedImage = null;
      _currentImageUrl = null;
    });
    // Update the form data as well
    ServiceFormData.instance.updateImageUrl(null);
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
              'Image du service',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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
              child: _buildImagePreview(),
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
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                if (_selectedImage != null ||
                    (_currentImageUrl?.isNotEmpty ?? false)) ...[
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _removeImage,
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

  Widget _buildImagePreview() {
    if (_selectedImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: kIsWeb
            ? Image.network(
                _selectedImage!.path,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildErrorImage(),
              )
            : Image.network(
                _selectedImage!.path,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildErrorImage(),
              ),
      );
    }

    if (_currentImageUrl != null && _currentImageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          _currentImageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildErrorImage(),
        ),
      );
    }

    return _buildPlaceholder();
  }

  Widget _buildErrorImage() {
    return Container(
      color: Colors.grey[300],
      child: const Icon(Icons.image, color: Colors.grey, size: 50),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
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
    );
  }
}

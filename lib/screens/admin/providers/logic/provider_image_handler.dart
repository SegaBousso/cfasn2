import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../services/image_upload_service.dart';
import '../../../../utils/responsive_helper.dart';

/// Gestionnaire pour la sélection et l'upload d'images de prestataires
class ProviderImageHandler {
  final ImageUploadService _imageUploadService = ImageUploadService();
  final ImagePicker _imagePicker = ImagePicker();

  XFile? selectedImage;
  bool isUploading = false;

  /// Sélectionner une image depuis la galerie
  Future<XFile?> pickImage(BuildContext context) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: ResponsiveHelper.getValue<double>(
          context,
          mobile: 800,
          tablet: 1000,
          desktop: 1200,
        ),
        maxHeight: ResponsiveHelper.getValue<double>(
          context,
          mobile: 600,
          tablet: 800,
          desktop: 1000,
        ),
        imageQuality: 80,
      );

      if (image != null) {
        selectedImage = image;
        return image;
      }
    } catch (e) {
      throw ImagePickerException('Erreur lors de la sélection de l\'image: $e');
    }
    return null;
  }

  /// Uploader l'image sélectionnée
  Future<String?> uploadImage(String providerId) async {
    if (selectedImage == null) return null;

    try {
      isUploading = true;
      final imageUrl = await _imageUploadService.uploadProviderImage(
        providerId,
        selectedImage!,
      );
      return imageUrl;
    } catch (e) {
      throw ImageUploadException('Erreur lors de l\'upload de l\'image: $e');
    } finally {
      isUploading = false;
    }
  }

  /// Obtenir le provider d'image approprié
  ImageProvider? getImageProvider(String? currentImageUrl) {
    if (selectedImage != null) {
      return FileImage(selectedImage as dynamic);
    } else if (currentImageUrl != null && currentImageUrl.isNotEmpty) {
      return NetworkImage(currentImageUrl);
    }
    return null;
  }

  /// Réinitialiser l'état
  void reset() {
    selectedImage = null;
    isUploading = false;
  }

  /// Vérifier si une image est sélectionnée
  bool get hasSelectedImage => selectedImage != null;

  /// Obtenir le nom du fichier sélectionné
  String? get selectedImageName => selectedImage?.name;
}

/// Exception pour les erreurs de sélection d'image
class ImagePickerException implements Exception {
  final String message;
  const ImagePickerException(this.message);

  @override
  String toString() => 'ImagePickerException: $message';
}

/// Exception pour les erreurs d'upload d'image
class ImageUploadException implements Exception {
  final String message;
  const ImageUploadException(this.message);

  @override
  String toString() => 'ImageUploadException: $message';
}

import 'package:image_picker/image_picker.dart';
import '../../../../services/image_upload_service.dart';

/// Gestionnaire pour la sélection et l'upload d'images de services
class ServiceImageHandler {
  final ImageUploadService _imageUploadService = ImageUploadService();

  XFile? selectedImage;
  String? currentImageUrl;
  bool isUploading = false;

  /// Sélectionner une image depuis la galerie
  Future<XFile?> pickImage() async {
    try {
      final XFile? image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 600,
        imageQuality: 80,
      );

      if (image != null) {
        selectedImage = image;
        return image;
      }
      return null;
    } catch (e) {
      throw Exception('Erreur lors de la sélection de l\'image: $e');
    }
  }

  /// Uploader l'image sélectionnée
  Future<String?> uploadImage(String serviceId) async {
    if (selectedImage == null) return null;

    try {
      isUploading = true;
      final imageUrl = await _imageUploadService.uploadServiceImage(
        serviceId,
        selectedImage!,
      );
      return imageUrl;
    } catch (e) {
      throw Exception('Erreur lors de l\'upload de l\'image: $e');
    } finally {
      isUploading = false;
    }
  }

  /// Supprimer l'image sélectionnée
  void removeSelectedImage() {
    selectedImage = null;
    currentImageUrl = null;
  }

  /// Vérifier s'il y a une image (sélectionnée ou actuelle)
  bool hasImage(String? currentImageUrl) {
    return selectedImage != null || (currentImageUrl?.isNotEmpty ?? false);
  }

  /// Obtenir l'URL d'affichage de l'image
  String? getDisplayImageUrl(String? currentImageUrl) {
    if (selectedImage != null) {
      return selectedImage!.path;
    }
    return currentImageUrl;
  }
}

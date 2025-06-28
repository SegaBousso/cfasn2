import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';

class ImageUploadService {
  static final ImageUploadService _instance = ImageUploadService._internal();
  factory ImageUploadService() => _instance;
  ImageUploadService._internal();

  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  /// Upload une image et retourne l'URL de téléchargement
  Future<String> uploadServiceImage(String serviceId, XFile imageFile) async {
    try {
      final String fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${imageFile.name}';
      final Reference ref = _storage.ref().child(
        'services/$serviceId/$fileName',
      );

      final UploadTask uploadTask;
      if (kIsWeb) {
        // Pour le web
        final bytes = await imageFile.readAsBytes();
        uploadTask = ref.putData(bytes);
      } else {
        // Pour mobile
        final File file = File(imageFile.path);
        uploadTask = ref.putFile(file);
      }

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Erreur lors de l\'upload de l\'image: $e');
    }
  }

  /// Upload une image de catégorie
  Future<String> uploadCategoryImage(String categoryId, XFile imageFile) async {
    try {
      final String fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${imageFile.name}';
      final Reference ref = _storage.ref().child(
        'categories/$categoryId/$fileName',
      );

      final UploadTask uploadTask;
      if (kIsWeb) {
        final bytes = await imageFile.readAsBytes();
        uploadTask = ref.putData(bytes);
      } else {
        final File file = File(imageFile.path);
        uploadTask = ref.putFile(file);
      }

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Erreur lors de l\'upload de l\'image: $e');
    }
  }

  /// Upload une image de profil prestataire
  Future<String> uploadProviderImage(String providerId, XFile imageFile) async {
    try {
      final String fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${imageFile.name}';
      final Reference ref = _storage.ref().child(
        'providers/$providerId/$fileName',
      );

      final UploadTask uploadTask;
      if (kIsWeb) {
        final bytes = await imageFile.readAsBytes();
        uploadTask = ref.putData(bytes);
      } else {
        final File file = File(imageFile.path);
        uploadTask = ref.putFile(file);
      }

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Erreur lors de l\'upload de l\'image: $e');
    }
  }

  /// Choisir une image depuis la galerie
  Future<XFile?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      throw Exception('Erreur lors de la sélection de l\'image: $e');
    }
  }

  /// Prendre une photo avec la caméra
  Future<XFile?> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      throw Exception('Erreur lors de la prise de photo: $e');
    }
  }

  /// Supprimer une image du storage
  Future<void> deleteImage(String imageUrl) async {
    try {
      final Reference ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      // Ignorer les erreurs de suppression (fichier peut déjà être supprimé)
      print('Erreur lors de la suppression de l\'image: $e');
    }
  }
}

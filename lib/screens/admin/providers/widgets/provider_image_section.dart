import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../utils/responsive_helper.dart';

class ProviderImageSection extends StatelessWidget {
  final XFile? selectedImage;
  final String? currentImageUrl;
  final bool isUploading;
  final VoidCallback onPickImage;

  const ProviderImageSection({
    super.key,
    this.selectedImage,
    this.currentImageUrl,
    required this.isUploading,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
    final avatarRadius = ResponsiveHelper.getValue<double>(
      context,
      mobile: 50.0,
      tablet: 60.0,
      desktop: 70.0,
    );

    return Card(
      child: Padding(
        padding: ResponsiveHelper.getScreenPadding(context),
        child: Column(
          children: [
            Text(
              'Photo de profil',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: ResponsiveHelper.getFontSize(
                  context,
                  mobile: 16,
                  tablet: 18,
                  desktop: 20,
                ),
              ),
            ),
            SizedBox(height: ResponsiveHelper.getSpacing(context)),
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: avatarRadius,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: _getImageProvider(),
                    child: _getImageProvider() == null
                        ? Icon(
                            Icons.person,
                            size: avatarRadius,
                            color: Colors.grey,
                          )
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
                        icon: Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: ResponsiveHelper.getValue<double>(
                            context,
                            mobile: 20,
                            tablet: 22,
                            desktop: 24,
                          ),
                        ),
                        onPressed: isUploading ? null : onPickImage,
                      ),
                    ),
                  ),
                  if (isUploading)
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
            if (selectedImage != null)
              Padding(
                padding: EdgeInsets.only(
                  top: ResponsiveHelper.getSpacing(context) / 2,
                ),
                child: Text(
                  'Image sélectionnée: ${selectedImage!.name}',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getFontSize(
                      context,
                      mobile: 11,
                      tablet: 12,
                      desktop: 13,
                    ),
                    color: Colors.green,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  ImageProvider? _getImageProvider() {
    if (selectedImage != null) {
      return FileImage(File(selectedImage!.path));
    } else if (currentImageUrl != null && currentImageUrl!.isNotEmpty) {
      return NetworkImage(currentImageUrl!);
    }
    return null;
  }
}

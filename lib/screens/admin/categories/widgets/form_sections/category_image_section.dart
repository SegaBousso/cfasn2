import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../../../../utils/event_bus.dart';
import '../../logic/logic.dart';

/// Section de gestion des images du formulaire catégorie
class CategoryImageSection extends StatelessWidget {
  const CategoryImageSection({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<CategoryImageHandler>(
      stream: EventBus.instance.on<CategoryImageHandler>(),
      builder: (context, imageSnapshot) {
        return StreamBuilder<CategoryEventHandler>(
          stream: EventBus.instance.on<CategoryEventHandler>(),
          builder: (context, eventSnapshot) {
            if (!imageSnapshot.hasData || !eventSnapshot.hasData) {
              return const SizedBox.shrink();
            }

            final imageHandler = imageSnapshot.data!;
            final eventHandler = eventSnapshot.data!;

            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Image de la catégorie',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
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
                      child: imageHandler.selectedImage != null
                          ? _buildSelectedImagePreview(imageHandler)
                          : imageHandler.currentImageUrl != null &&
                                imageHandler.currentImageUrl!.isNotEmpty
                          ? _buildCurrentImagePreview(imageHandler)
                          : _buildPlaceholder(),
                    ),
                    const SizedBox(height: 16),
                    // Boutons d'action pour l'image
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: imageHandler.isUploading
                                ? null
                                : () => eventHandler.pickImage(),
                            icon: imageHandler.isUploading
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.upload),
                            label: Text(
                              imageHandler.isUploading
                                  ? 'Upload...'
                                  : 'Choisir une image',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepOrange,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        if (imageHandler.selectedImage != null ||
                            (imageHandler.currentImageUrl?.isNotEmpty ??
                                false)) ...[
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: () => eventHandler.removeImage(),
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
          },
        );
      },
    );
  }

  Widget _buildSelectedImagePreview(CategoryImageHandler imageHandler) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: kIsWeb
          ? Image.network(
              imageHandler.selectedImage!.path,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
            )
          : Image.network(
              imageHandler.selectedImage!.path,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
            ),
    );
  }

  Widget _buildCurrentImagePreview(CategoryImageHandler imageHandler) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        imageHandler.currentImageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
      ),
    );
  }

  Widget _buildErrorWidget() {
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

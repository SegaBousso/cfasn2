import 'package:flutter/material.dart';
import '../../../../../utils/event_bus.dart';
import '../../logic/logic.dart';

/// Section des informations de base du formulaire catégorie
class CategoryBasicInfoSection extends StatelessWidget {
  const CategoryBasicInfoSection({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<CategoryFormData>(
      stream: EventBus.instance.on<CategoryFormData>(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();

        final formData = snapshot.data!;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Informations de base',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: formData.nameController,
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
                  controller: formData.descriptionController,
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
      },
    );
  }
}

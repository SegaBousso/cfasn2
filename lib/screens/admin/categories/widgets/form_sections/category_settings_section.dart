import 'package:flutter/material.dart';
import '../../../../../utils/event_bus.dart';
import '../../logic/logic.dart';

/// Section des paramètres du formulaire catégorie
class CategorySettingsSection extends StatelessWidget {
  const CategorySettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<CategoryFormData>(
      stream: EventBus.instance.on<CategoryFormData>(),
      builder: (context, formSnapshot) {
        return StreamBuilder<CategoryEventHandler>(
          stream: EventBus.instance.on<CategoryEventHandler>(),
          builder: (context, eventSnapshot) {
            if (!formSnapshot.hasData || !eventSnapshot.hasData) {
              return const SizedBox.shrink();
            }

            final formData = formSnapshot.data!;
            final eventHandler = eventSnapshot.data!;

            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Paramètres',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: formData.sortOrderController,
                      decoration: const InputDecoration(
                        labelText: 'Ordre d\'affichage',
                        hintText: '0',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.reorder),
                        helperText:
                            'Plus le nombre est petit, plus la catégorie apparaît en premier',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final order = int.tryParse(value);
                          if (order == null || order < 0) {
                            return 'L\'ordre doit être un nombre positif';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Catégorie active'),
                      subtitle: const Text(
                        'La catégorie est visible et utilisable dans l\'application',
                      ),
                      value: formData.isActive,
                      onChanged: (value) => eventHandler.toggleActive(value),
                      activeColor: Colors.deepOrange,
                      contentPadding: EdgeInsets.zero,
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
}

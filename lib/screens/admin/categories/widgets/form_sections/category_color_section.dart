import 'package:flutter/material.dart';
import '../../../../../utils/event_bus.dart';
import '../../logic/logic.dart';

/// Section de sélection de couleur du formulaire catégorie
class CategoryColorSection extends StatelessWidget {
  const CategoryColorSection({super.key});

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
                      'Couleur de la catégorie',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Choisissez une couleur pour identifier la catégorie',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: formData.availableColors.map((color) {
                        final isSelected = formData.selectedColor == color;

                        return GestureDetector(
                          onTap: () => eventHandler.selectColor(color),
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? Colors.black
                                    : Colors.grey[300]!,
                                width: isSelected ? 3 : 1,
                              ),
                            ),
                            child: isSelected
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 24,
                                  )
                                : null,
                          ),
                        );
                      }).toList(),
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

import 'package:flutter/material.dart';
import '../../../../../utils/event_bus.dart';
import '../../logic/logic.dart';

/// Section de sélection d'icône du formulaire catégorie
class CategoryIconSection extends StatelessWidget {
  const CategoryIconSection({super.key});

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
                      'Icône de la catégorie',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sélectionnez une icône représentative',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 16),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5,
                            childAspectRatio: 1,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                      itemCount: formData.availableIcons.length,
                      itemBuilder: (context, index) {
                        final iconData = formData.availableIcons[index];
                        final isSelected =
                            formData.selectedIcon == iconData['name'];

                        return GestureDetector(
                          onTap: () =>
                              eventHandler.selectIcon(iconData['name']),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? formData.selectedColor.withOpacity(0.2)
                                  : Colors.grey[100],
                              border: Border.all(
                                color: isSelected
                                    ? formData.selectedColor
                                    : Colors.grey[300]!,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  iconData['icon'],
                                  color: isSelected
                                      ? formData.selectedColor
                                      : Colors.grey[600],
                                  size: 24,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  iconData['label'],
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isSelected
                                        ? formData.selectedColor
                                        : Colors.grey[600],
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
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

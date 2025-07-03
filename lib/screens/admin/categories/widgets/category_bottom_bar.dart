import 'package:flutter/material.dart';
import '../../../../models/category_model.dart';
import '../../../../utils/event_bus.dart';
import '../logic/logic.dart';

/// Barre de navigation inférieure avec boutons d'action pour AddEditCategoryScreen
class CategoryBottomBar extends StatelessWidget {
  final CategoryModel? category;
  final GlobalKey<FormState> formKey;

  const CategoryBottomBar({super.key, this.category, required this.formKey});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<CategorySaveHandler>(
      stream: EventBus.instance.on<CategorySaveHandler>(),
      builder: (context, saveSnapshot) {
        return StreamBuilder<CategoryEventHandler>(
          stream: EventBus.instance.on<CategoryEventHandler>(),
          builder: (context, eventSnapshot) {
            if (!saveSnapshot.hasData || !eventSnapshot.hasData) {
              return const SizedBox.shrink();
            }

            final saveHandler = saveSnapshot.data!;
            final eventHandler = eventSnapshot.data!;

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: saveHandler.isLoading
                            ? null
                            : () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.cancel),
                        label: const Text('Annuler'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: saveHandler.isLoading
                            ? null
                            : () => _handleSave(context, eventHandler),
                        icon: saveHandler.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Icon(category != null ? Icons.save : Icons.add),
                        label: Text(category != null ? 'Modifier' : 'Créer'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
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

  /// Gérer la sauvegarde avec navigation et gestion d'erreurs
  Future<void> _handleSave(
    BuildContext context,
    CategoryEventHandler eventHandler,
  ) async {
    try {
      await eventHandler.saveCategory(formKey);

      if (context.mounted) {
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              category != null
                  ? 'Catégorie modifiée avec succès'
                  : 'Catégorie créée avec succès',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la sauvegarde: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

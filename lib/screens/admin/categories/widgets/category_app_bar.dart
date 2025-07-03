import 'package:flutter/material.dart';
import '../../../../models/category_model.dart';

/// AppBar modulaire pour AddEditCategoryScreen
class CategoryAppBar extends StatelessWidget implements PreferredSizeWidget {
  final CategoryModel? category;

  const CategoryAppBar({super.key, this.category});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        category == null ? 'Ajouter une catégorie' : 'Modifier la catégorie',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 1,
      iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

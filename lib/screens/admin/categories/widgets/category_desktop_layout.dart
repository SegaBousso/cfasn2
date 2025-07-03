import 'package:flutter/material.dart';
import 'form_sections/category_basic_info_section.dart';
import 'form_sections/category_image_section.dart';
import 'form_sections/category_icon_section.dart';
import 'form_sections/category_color_section.dart';
import 'form_sections/category_settings_section.dart';

/// Layout desktop pour AddEditCategoryScreen
class CategoryDesktopLayout extends StatelessWidget {
  final GlobalKey<FormState> formKey;

  const CategoryDesktopLayout({super.key, required this.formKey});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: formKey,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Colonne gauche
            Expanded(
              flex: 2,
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CategoryBasicInfoSection(),
                  SizedBox(height: 24),
                  CategoryImageSection(),
                ],
              ),
            ),
            const SizedBox(width: 32),
            // Colonne droite
            Expanded(
              flex: 1,
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CategoryIconSection(),
                  SizedBox(height: 24),
                  CategoryColorSection(),
                  SizedBox(height: 24),
                  CategorySettingsSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

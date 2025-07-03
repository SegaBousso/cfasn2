import 'package:flutter/material.dart';
import 'form_sections/category_basic_info_section.dart';
import 'form_sections/category_image_section.dart';
import 'form_sections/category_icon_section.dart';
import 'form_sections/category_color_section.dart';
import 'form_sections/category_settings_section.dart';

/// Layout mobile pour AddEditCategoryScreen
class CategoryMobileLayout extends StatelessWidget {
  final GlobalKey<FormState> formKey;

  const CategoryMobileLayout({super.key, required this.formKey});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: formKey,
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CategoryBasicInfoSection(),
            SizedBox(height: 24),
            CategoryImageSection(),
            SizedBox(height: 24),
            CategoryIconSection(),
            SizedBox(height: 24),
            CategoryColorSection(),
            SizedBox(height: 24),
            CategorySettingsSection(),
            SizedBox(height: 100), // Espace pour le bottom bar
          ],
        ),
      ),
    );
  }
}

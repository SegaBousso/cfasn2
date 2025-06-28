import 'package:flutter/material.dart';
import '../../../../widgets/overflow_safe_widgets.dart';
import '../../../../utils/responsive_helper.dart';

class CategoriesSection extends StatelessWidget {
  const CategoriesSection({super.key});

  // Catégories populaires
  static const List<Map<String, dynamic>> _categories = [
    {'icon': Icons.cleaning_services, 'name': 'Ménage', 'color': Colors.blue},
    {'icon': Icons.build, 'name': 'Bricolage', 'color': Colors.orange},
    {'icon': Icons.local_florist, 'name': 'Jardinage', 'color': Colors.green},
    {'icon': Icons.local_shipping, 'name': 'Déménagement', 'color': Colors.red},
    {'icon': Icons.computer, 'name': 'Informatique', 'color': Colors.purple},
    {'icon': Icons.school, 'name': 'Cours', 'color': Colors.teal},
  ];

  @override
  Widget build(BuildContext context) {
    final categoryHeight = ResponsiveHelper.getValue<double>(
      context,
      mobile: 110.0,
      tablet: 120.0,
      desktop: 130.0,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveHelper.getSpacing(context),
          ),
          child: AdaptiveText(
            'Catégories populaires',
            style: TextStyle(
              fontSize: ResponsiveHelper.getFontSize(
                context,
                mobile: 18.0,
                tablet: 20.0,
                desktop: 22.0,
              ),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: ResponsiveHelper.getSpacing(context)),
        SizedBox(
          height: categoryHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveHelper.getSpacing(context),
            ),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              return _CategoryItem(category: category);
            },
          ),
        ),
      ],
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final Map<String, dynamic> category;

  const _CategoryItem({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 16),
      child: InkWell(
        onTap: () {
          // TODO: Navigation vers la catégorie
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: category['color'].withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: category['color'].withOpacity(0.3)),
              ),
              child: Icon(category['icon'], color: category['color'], size: 30),
            ),
            const SizedBox(height: 8),
            Text(
              category['name'],
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../widgets/overflow_safe_widgets.dart';
import '../../../../utils/responsive_helper.dart';

class QuickSearchBar extends StatelessWidget {
  final VoidCallback onTap;

  const QuickSearchBar({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OverflowSafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.getSpacing(context),
        ),
        child: AdaptiveContainer(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: ListTile(
            leading: const Icon(Icons.search, color: Colors.grey),
            title: AdaptiveText(
              'Que recherchez-vous ?',
              style: TextStyle(
                color: Colors.grey,
                fontSize: ResponsiveHelper.getFontSize(
                  context,
                  mobile: 14.0,
                  tablet: 16.0,
                  desktop: 16.0,
                ),
              ),
            ),
            onTap: onTap,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../utils/responsive_helper.dart';
import 'category_mobile_layout.dart';
import 'category_desktop_layout.dart';

/// Body modulaire pour AddEditCategoryScreen avec responsive design
class CategoryBody extends StatelessWidget {
  final GlobalKey<FormState> formKey;

  const CategoryBody({super.key, required this.formKey});

  @override
  Widget build(BuildContext context) {
    return ResponsiveHelper.getDeviceType(context) == DeviceType.mobile
        ? CategoryMobileLayout(formKey: formKey)
        : CategoryDesktopLayout(formKey: formKey);
  }
}

import 'package:flutter/material.dart';
import '../../../../utils/responsive_helper.dart';

class ProviderAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isEditing;
  final bool isSaving;
  final bool isUploading;

  const ProviderAppBar({
    super.key,
    required this.isEditing,
    required this.isSaving,
    required this.isUploading,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        isEditing ? 'Modifier le prestataire' : 'Nouveau prestataire',
        style: TextStyle(
          fontSize: ResponsiveHelper.getFontSize(
            context,
            mobile: 18,
            tablet: 20,
            desktop: 22,
          ),
        ),
      ),
      backgroundColor: Colors.purple,
      foregroundColor: Colors.white,
      elevation: ResponsiveHelper.getValue<double>(
        context,
        mobile: 4,
        tablet: 6,
        desktop: 8,
      ),
      actions: [
        if (isSaving || isUploading)
          Padding(
            padding: ResponsiveHelper.getScreenPadding(context),
            child: SizedBox(
              width: ResponsiveHelper.getValue<double>(
                context,
                mobile: 20,
                tablet: 22,
                desktop: 24,
              ),
              height: ResponsiveHelper.getValue<double>(
                context,
                mobile: 20,
                tablet: 22,
                desktop: 24,
              ),
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

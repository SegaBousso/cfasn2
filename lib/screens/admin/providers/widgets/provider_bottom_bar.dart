import 'package:flutter/material.dart';
import '../../../../utils/responsive_helper.dart';

class ProviderBottomBar extends StatelessWidget {
  final bool isEditing;
  final bool isSaving;
  final bool isUploading;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  const ProviderBottomBar({
    super.key,
    required this.isEditing,
    required this.isSaving,
    required this.isUploading,
    required this.onSave,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final dimensions = ResponsiveHelper.getDimensions(context);
    final padding = ResponsiveHelper.getScreenPadding(context);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: dimensions.deviceType == DeviceType.mobile
          ? _buildMobileBottomBar(context)
          : _buildDesktopBottomBar(context),
    );
  }

  Widget _buildMobileBottomBar(BuildContext context) {
    final spacing = ResponsiveHelper.getSpacing(context);
    final isLoading = isSaving || isUploading;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isLoading ? null : onSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: spacing),
            ),
            child: isLoading
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(width: spacing / 2),
                      const Text('Sauvegarde...'),
                    ],
                  )
                : Text(isEditing ? 'Modifier' : 'Créer'),
          ),
        ),
        SizedBox(height: spacing / 2),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: isLoading ? null : onCancel,
            child: const Text('Annuler'),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopBottomBar(BuildContext context) {
    final spacing = ResponsiveHelper.getSpacing(context);
    final isLoading = isSaving || isUploading;

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: isLoading ? null : onCancel,
            child: const Text('Annuler'),
          ),
        ),
        SizedBox(width: spacing),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: isLoading ? null : onSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: spacing),
            ),
            child: isLoading
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(width: spacing / 2),
                      const Text('Sauvegarde...'),
                    ],
                  )
                : Text(isEditing ? 'Modifier' : 'Créer'),
          ),
        ),
      ],
    );
  }
}

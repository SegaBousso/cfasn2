import 'package:flutter/material.dart';
import '../../../../utils/responsive_helper.dart';

class ProviderProfessionalInfoSection extends StatelessWidget {
  final TextEditingController specialtyController;
  final TextEditingController experienceController;
  final TextEditingController bioController;

  const ProviderProfessionalInfoSection({
    super.key,
    required this.specialtyController,
    required this.experienceController,
    required this.bioController,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = ResponsiveHelper.getSpacing(context);

    return Card(
      child: Padding(
        padding: ResponsiveHelper.getScreenPadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informations professionnelles',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: ResponsiveHelper.getFontSize(
                  context,
                  mobile: 16,
                  tablet: 18,
                  desktop: 20,
                ),
              ),
            ),
            SizedBox(height: spacing),
            _buildTextField(
              context: context,
              controller: specialtyController,
              label: 'Spécialité principale *',
              icon: Icons.work,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'La spécialité est requise';
                }
                return null;
              },
            ),
            SizedBox(height: spacing),
            _buildTextField(
              context: context,
              controller: experienceController,
              label: 'Années d\'expérience',
              icon: Icons.schedule,
              keyboardType: TextInputType.number,
              suffixText: 'années',
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final exp = int.tryParse(value);
                  if (exp == null || exp < 0) {
                    return 'Nombre invalide';
                  }
                }
                return null;
              },
            ),
            SizedBox(height: spacing),
            _buildTextField(
              context: context,
              controller: bioController,
              label: 'Description / Bio',
              icon: Icons.description,
              hintText: 'Décrivez brièvement vos services...',
              maxLines: ResponsiveHelper.getValue<int>(
                context,
                mobile: 3,
                tablet: 4,
                desktop: 5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? suffixText,
    String? hintText,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
        suffixText: suffixText,
        hintText: hintText,
        labelStyle: TextStyle(
          fontSize: ResponsiveHelper.getFontSize(
            context,
            mobile: 14,
            tablet: 15,
            desktop: 16,
          ),
        ),
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: TextStyle(
        fontSize: ResponsiveHelper.getFontSize(
          context,
          mobile: 14,
          tablet: 15,
          desktop: 16,
        ),
      ),
    );
  }
}

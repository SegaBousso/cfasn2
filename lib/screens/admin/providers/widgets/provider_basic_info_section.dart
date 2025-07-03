import 'package:flutter/material.dart';
import '../../../../utils/responsive_helper.dart';

class ProviderBasicInfoSection extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController addressController;

  const ProviderBasicInfoSection({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.addressController,
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
              'Informations générales',
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
              controller: nameController,
              label: 'Nom complet *',
              icon: Icons.person,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Le nom est requis';
                }
                return null;
              },
            ),
            SizedBox(height: spacing),
            _buildTextField(
              context: context,
              controller: emailController,
              label: 'Email *',
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'L\'email est requis';
                }
                if (!RegExp(
                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                ).hasMatch(value)) {
                  return 'Email invalide';
                }
                return null;
              },
            ),
            SizedBox(height: spacing),
            _buildTextField(
              context: context,
              controller: phoneController,
              label: 'Téléphone *',
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Le téléphone est requis';
                }
                return null;
              },
            ),
            SizedBox(height: spacing),
            _buildTextField(
              context: context,
              controller: addressController,
              label: 'Adresse *',
              icon: Icons.location_on,
              maxLines: ResponsiveHelper.getValue<int>(
                context,
                mobile: 2,
                tablet: 2,
                desktop: 3,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'L\'adresse est requise';
                }
                return null;
              },
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
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
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

import 'package:flutter/material.dart';
import '../../../widgets/overflow_safe_widgets.dart';
import '../logic/profile_validation_handler.dart';

/// Personal information form section
class PersonalInfoSection extends StatelessWidget {
  final String? selectedCivility;
  final List<String> civilities;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController phoneController;
  final TextEditingController addressController;
  final ValueChanged<String?> onCivilityChanged;

  const PersonalInfoSection({
    super.key,
    required this.selectedCivility,
    required this.civilities,
    required this.firstNameController,
    required this.lastNameController,
    required this.phoneController,
    required this.addressController,
    required this.onCivilityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Civilité
        AdaptiveText(
          'Civilité',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedCivility,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Sélectionnez votre civilité',
          ),
          items: civilities
              .map(
                (civility) =>
                    DropdownMenuItem(value: civility, child: Text(civility)),
              )
              .toList(),
          onChanged: onCivilityChanged,
          validator: ProfileValidationHandler.validateCivility,
        ),

        const SizedBox(height: 16),

        // Prénom
        AdaptiveText('Prénom', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        TextFormField(
          controller: firstNameController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Votre prénom',
          ),
          validator: ProfileValidationHandler.validateFirstName,
        ),

        const SizedBox(height: 16),

        // Nom
        AdaptiveText('Nom', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        TextFormField(
          controller: lastNameController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Votre nom',
          ),
          validator: ProfileValidationHandler.validateLastName,
        ),

        const SizedBox(height: 16),

        // Téléphone
        AdaptiveText(
          'Téléphone',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: phoneController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Votre numéro de téléphone',
            prefixIcon: Icon(Icons.phone),
          ),
          keyboardType: TextInputType.phone,
          validator: ProfileValidationHandler.validatePhone,
        ),

        const SizedBox(height: 16),

        // Adresse
        AdaptiveText('Adresse', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        TextFormField(
          controller: addressController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Votre adresse complète',
            prefixIcon: Icon(Icons.location_on),
          ),
          maxLines: 2,
          validator: ProfileValidationHandler.validateAddress,
        ),
      ],
    );
  }
}

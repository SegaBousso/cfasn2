import 'package:flutter/material.dart';
import '../../../../models/models.dart';
import '../../../../utils/responsive_helper.dart';
import '../logic/logic.dart';
import 'widgets.dart';

class ProviderTabletLayout extends StatelessWidget {
  final ProviderFormData formData;
  final ProviderImageHandler imageHandler;
  final ProviderServicesHandler servicesHandler;
  final VoidCallback onPickImage;
  final Function(bool) onActiveChanged;
  final Function(bool) onAvailableChanged;
  final Function(bool) onVerifiedChanged;
  final Function(List<String>, String) onAddToList;
  final Function(List<String>, String) onRemoveFromList;
  final Function(ServiceModel) onAddService;
  final Function(ServiceModel) onRemoveService;

  const ProviderTabletLayout({
    super.key,
    required this.formData,
    required this.imageHandler,
    required this.servicesHandler,
    required this.onPickImage,
    required this.onActiveChanged,
    required this.onAvailableChanged,
    required this.onVerifiedChanged,
    required this.onAddToList,
    required this.onRemoveFromList,
    required this.onAddService,
    required this.onRemoveService,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: ResponsiveHelper.getScreenPadding(context),
      child: Column(
        children: [
          // Top section with image and basic info
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: ProviderImageSection(
                  selectedImage: imageHandler.selectedImage,
                  currentImageUrl: formData.currentImageUrl,
                  isUploading: imageHandler.isUploading,
                  onPickImage: onPickImage,
                ),
              ),
              SizedBox(width: ResponsiveHelper.getSpacing(context)),
              Expanded(
                flex: 2,
                child: ProviderBasicInfoSection(
                  nameController: formData.nameController,
                  emailController: formData.emailController,
                  phoneController: formData.phoneController,
                  addressController: formData.addressController,
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveHelper.getSpacing(context)),

          // Professional info and status
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ProviderProfessionalInfoSection(
                  specialtyController: formData.specialtyController,
                  experienceController: formData.experienceController,
                  bioController: formData.bioController,
                ),
              ),
              SizedBox(width: ResponsiveHelper.getSpacing(context)),
              Expanded(
                child: ProviderStatusSection(
                  isActive: formData.isActive,
                  isAvailable: formData.isAvailable,
                  isVerified: formData.isVerified,
                  onActiveChanged: onActiveChanged,
                  onAvailableChanged: onAvailableChanged,
                  onVerifiedChanged: onVerifiedChanged,
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveHelper.getSpacing(context)),

          _buildListsSections(context),
          SizedBox(height: ResponsiveHelper.getSpacing(context) * 4),
        ],
      ),
    );
  }

  Widget _buildListsSections(BuildContext context) {
    final spacing = ResponsiveHelper.getSpacing(context);

    return Column(
      children: [
        ProviderListSection(
          title: 'Spécialités additionnelles',
          icon: Icons.add_business,
          items: formData.specialties,
          controller: formData.specialtyInputController,
          hintText: 'Ajouter une spécialité',
          onAdd: (value) => onAddToList(formData.specialties, value),
          onRemove: (value) => onRemoveFromList(formData.specialties, value),
        ),
        SizedBox(height: spacing),
        ProviderListSection(
          title: 'Zones de travail',
          icon: Icons.location_city,
          items: formData.workingAreas,
          controller: formData.areaInputController,
          hintText: 'Ajouter une zone',
          onAdd: (value) => onAddToList(formData.workingAreas, value),
          onRemove: (value) => onRemoveFromList(formData.workingAreas, value),
        ),
        SizedBox(height: spacing),
        ProviderServicesSelection(
          availableServices: servicesHandler.availableServices,
          selectedServices: formData.selectedServices,
          isLoading: servicesHandler.isLoading,
          onAddService: onAddService,
          onRemoveService: onRemoveService,
        ),
        SizedBox(height: spacing),
        ProviderListSection(
          title: 'Certifications',
          icon: Icons.verified,
          items: formData.certifications,
          controller: formData.certificationInputController,
          hintText: 'Ajouter une certification',
          onAdd: (value) => onAddToList(formData.certifications, value),
          onRemove: (value) => onRemoveFromList(formData.certifications, value),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../models/models.dart';

/// Gestionnaire des données de formulaire pour les prestataires
class ProviderFormData {
  // Controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final bioController = TextEditingController();
  final specialtyController = TextEditingController();
  final experienceController = TextEditingController();
  final specialtyInputController = TextEditingController();
  final areaInputController = TextEditingController();
  final certificationInputController = TextEditingController();

  // Lists data
  List<String> specialties = [];
  List<String> workingAreas = [];
  List<String> certifications = [];
  List<String> serviceIds = [];
  List<ServiceModel> selectedServices = [];

  // Status data
  bool isActive = true;
  bool isAvailable = true;
  bool isVerified = false;

  // Image data
  String? currentImageUrl;

  /// Populate form with existing provider data
  void populateFrom(ProviderModel provider) {
    nameController.text = provider.name;
    emailController.text = provider.email;
    phoneController.text = provider.phoneNumber;
    addressController.text = provider.address;
    bioController.text = provider.bio;
    specialtyController.text = provider.specialty;
    experienceController.text = provider.yearsOfExperience.toString();

    specialties = List.from(provider.specialties);
    workingAreas = List.from(provider.workingAreas);
    certifications = List.from(provider.certifications);
    serviceIds = List.from(provider.serviceIds);

    isActive = provider.isActive;
    isAvailable = provider.isAvailable;
    isVerified = provider.isVerified;
    currentImageUrl = provider.profileImageUrl;
  }

  /// Create provider model from form data
  ProviderModel createProviderModel({
    String? existingId,
    String? imageUrl,
    ProviderModel? existingProvider,
  }) {
    return ProviderModel(
      id: existingId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      phoneNumber: phoneController.text.trim(),
      address: addressController.text.trim(),
      bio: bioController.text.trim(),
      specialty: specialtyController.text.trim(),
      specialties: specialties,
      workingAreas: workingAreas,
      certifications: certifications,
      serviceIds: serviceIds,
      yearsOfExperience: int.tryParse(experienceController.text) ?? 0,
      profileImageUrl: imageUrl ?? currentImageUrl,
      isActive: isActive,
      isAvailable: isAvailable,
      isVerified: isVerified,
      rating: existingProvider?.rating ?? 0.0,
      ratingsCount: existingProvider?.ratingsCount ?? 0,
      completedJobs: existingProvider?.completedJobs ?? 0,
      createdAt: existingProvider?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      lastActiveAt: existingProvider?.lastActiveAt,
      businessHours: existingProvider?.businessHours ?? {},
      pricing: existingProvider?.pricing ?? {},
      metadata: existingProvider?.metadata ?? {},
    );
  }

  /// Check if form data is valid
  bool isValid() {
    return nameController.text.trim().isNotEmpty &&
        emailController.text.trim().isNotEmpty &&
        phoneController.text.trim().isNotEmpty &&
        addressController.text.trim().isNotEmpty &&
        specialtyController.text.trim().isNotEmpty;
  }

  /// Add item to a list if not already present
  bool addToList(List<String> list, String value) {
    if (value.trim().isNotEmpty && !list.contains(value.trim())) {
      list.add(value.trim());
      return true;
    }
    return false;
  }

  /// Remove item from a list
  bool removeFromList(List<String> list, String item) {
    return list.remove(item);
  }

  /// Add service to selected services
  bool addService(ServiceModel service) {
    print('🔄 FormData: Tentative d\'ajout du service: ${service.name}');
    if (!selectedServices.contains(service)) {
      selectedServices.add(service);
      serviceIds.add(service.id);
      print(
        '✅ FormData: Service ajouté. Total sélectionnés: ${selectedServices.length}',
      );
      return true;
    }
    print('⚠️ FormData: Service déjà sélectionné: ${service.name}');
    return false;
  }

  /// Remove service from selected services
  bool removeService(ServiceModel service) {
    print('🔄 FormData: Tentative de suppression du service: ${service.name}');
    final removed = selectedServices.remove(service);
    if (removed) {
      serviceIds.remove(service.id);
      print(
        '✅ FormData: Service supprimé. Total sélectionnés: ${selectedServices.length}',
      );
    } else {
      print(
        '⚠️ FormData: Service non trouvé pour suppression: ${service.name}',
      );
    }
    return removed;
  }

  /// Sync selected services with available services (for editing)
  void syncSelectedServices(List<ServiceModel> availableServices) {
    selectedServices = availableServices
        .where((service) => serviceIds.contains(service.id))
        .toList();
  }

  /// Clear all form data
  void clear() {
    nameController.clear();
    emailController.clear();
    phoneController.clear();
    addressController.clear();
    bioController.clear();
    specialtyController.clear();
    experienceController.clear();
    specialtyInputController.clear();
    areaInputController.clear();
    certificationInputController.clear();

    specialties.clear();
    workingAreas.clear();
    certifications.clear();
    serviceIds.clear();
    selectedServices.clear();

    isActive = true;
    isAvailable = true;
    isVerified = false;
    currentImageUrl = null;
  }

  /// Dispose all controllers
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    bioController.dispose();
    specialtyController.dispose();
    experienceController.dispose();
    specialtyInputController.dispose();
    areaInputController.dispose();
    certificationInputController.dispose();
  }
}

import 'package:flutter/material.dart';
import '../../../models/models.dart';

/// Manages form data and controllers for the complete profile screen
class ProfileFormData {
  late final TextEditingController firstNameController;
  late final TextEditingController lastNameController;
  late final TextEditingController phoneController;
  late final TextEditingController addressController;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String? _selectedCivility;
  UserRole _selectedRole = UserRole.client;
  bool _isLoading = false;

  // Available civilities
  final List<String> civilities = ['M.', 'Mme', 'Mlle'];

  ProfileFormData() {
    firstNameController = TextEditingController();
    lastNameController = TextEditingController();
    phoneController = TextEditingController();
    addressController = TextEditingController();
  }

  // Getters
  String? get selectedCivility => _selectedCivility;
  UserRole get selectedRole => _selectedRole;
  bool get isLoading => _isLoading;

  // Setters
  set selectedCivility(String? value) => _selectedCivility = value;
  set selectedRole(UserRole value) => _selectedRole = value;
  set isLoading(bool value) => _isLoading = value;

  /// Initialize form with existing user data
  void initializeWithUserData(UserModel? user) {
    if (user != null) {
      firstNameController.text = user.firstName;
      lastNameController.text = user.lastName;
      phoneController.text = user.phoneNumber ?? '';
      addressController.text = user.address ?? '';
      _selectedRole = user.role;
      _selectedCivility = user.civility;
    }
  }

  /// Validate all form fields
  bool validateForm() {
    return formKey.currentState?.validate() ?? false;
  }

  /// Get form data as a map
  Map<String, dynamic> getFormData() {
    return {
      'firstName': firstNameController.text.trim(),
      'lastName': lastNameController.text.trim(),
      'phoneNumber': phoneController.text.trim(),
      'address': addressController.text.trim(),
      'civility': _selectedCivility,
      'role': _selectedRole,
    };
  }

  /// Clear all form data
  void clear() {
    firstNameController.clear();
    lastNameController.clear();
    phoneController.clear();
    addressController.clear();
    _selectedCivility = null;
    _selectedRole = UserRole.client;
    _isLoading = false;
  }

  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    addressController.dispose();
  }
}

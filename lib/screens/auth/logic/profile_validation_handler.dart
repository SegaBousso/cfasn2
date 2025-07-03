/// Handles form validation for the complete profile screen
class ProfileValidationHandler {
  /// Validate civility field
  static String? validateCivility(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez sélectionner votre civilité';
    }
    return null;
  }

  /// Validate first name field
  static String? validateFirstName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Le prénom est obligatoire';
    }
    return null;
  }

  /// Validate last name field
  static String? validateLastName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Le nom est obligatoire';
    }
    return null;
  }

  /// Validate phone number field
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Le numéro de téléphone est obligatoire';
    }
    if (value.length < 10) {
      return 'Numéro de téléphone invalide';
    }
    return null;
  }

  /// Validate address field
  static String? validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'L\'adresse est obligatoire';
    }
    return null;
  }
}

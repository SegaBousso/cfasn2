import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';
import '../../utils/responsive_helper.dart';
import '../../widgets/overflow_safe_widgets.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  UserRole _selectedRole = UserRole.client;
  String? _selectedCivility;
  bool _isLoading = false;

  final List<String> _civilities = ['M.', 'Mme', 'Mlle'];

  @override
  void initState() {
    super.initState();
    _initializeFormWithUserData();
  }

  void _initializeFormWithUserData() {
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      _firstNameController.text = user.firstName;
      _lastNameController.text = user.lastName;
      _phoneController.text = user.phoneNumber ?? '';
      _addressController.text = user.address ?? '';
      _selectedRole = user.role;
      _selectedCivility = user.civility;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complétez votre profil'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: ResponsiveBuilder(
        builder: (context, dimensions) {
          return OverflowSafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context)),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // En-tête explicatif
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(
                          ResponsiveHelper.getSpacing(context),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 48,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(height: 16),
                            const AdaptiveText(
                              'Bienvenue !',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const AdaptiveText(
                              'Pour finaliser votre inscription, veuillez compléter les informations suivantes :',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Civilité
                    AdaptiveText(
                      'Civilité',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedCivility,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Sélectionnez votre civilité',
                      ),
                      items: _civilities
                          .map(
                            (civility) => DropdownMenuItem(
                              value: civility,
                              child: Text(civility),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCivility = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez sélectionner votre civilité';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Prénom
                    AdaptiveText(
                      'Prénom',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Votre prénom',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Le prénom est obligatoire';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Nom
                    AdaptiveText(
                      'Nom',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Votre nom',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Le nom est obligatoire';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Téléphone
                    AdaptiveText(
                      'Téléphone',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Votre numéro de téléphone',
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Le numéro de téléphone est obligatoire';
                        }
                        if (value.length < 10) {
                          return 'Numéro de téléphone invalide';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Adresse
                    AdaptiveText(
                      'Adresse',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Votre adresse complète',
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      maxLines: 2,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'L\'adresse est obligatoire';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    // Sélection du rôle
                    AdaptiveText(
                      'Je suis :',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Card(
                      child: Column(
                        children: UserRole.values
                            .where((role) => role != UserRole.admin)
                            .map((role) {
                              return RadioListTile<UserRole>(
                                title: Text(role.label),
                                subtitle: Text(_getRoleDescription(role)),
                                value: role,
                                groupValue: _selectedRole,
                                onChanged: (UserRole? value) {
                                  setState(() {
                                    _selectedRole = value ?? UserRole.client;
                                  });
                                },
                              );
                            })
                            .toList(),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Bouton de validation
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _completeProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'Finaliser mon profil',
                                style: TextStyle(fontSize: 16),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _getRoleDescription(UserRole role) {
    switch (role) {
      case UserRole.client:
        return 'Je souhaite réserver des services';
      case UserRole.provider:
        return 'Je veux proposer mes services';
      case UserRole.admin:
        return 'Administrateur';
    }
  }

  Future<void> _completeProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final currentUser = authProvider.user;

      if (currentUser == null) {
        throw Exception('Aucun utilisateur connecté');
      }

      // Créer l'utilisateur mis à jour
      final updatedUser = currentUser.copyWith(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        civility: _selectedCivility,
        role: _selectedRole,
        displayName:
            '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}',
      );

      // Sauvegarder dans Firestore
      await AuthService().updateUserProfile(updatedUser);

      // Recharger l'utilisateur dans le provider
      await authProvider.reloadUser();

      // Navigation vers l'écran approprié selon le rôle
      if (mounted) {
        _navigateBasedOnRole(_selectedRole);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateBasedOnRole(UserRole role) {
    switch (role) {
      case UserRole.client:
        Navigator.pushReplacementNamed(context, '/user/home');
        break;
      case UserRole.provider:
        Navigator.pushReplacementNamed(context, '/provider/dashboard');
        break;
      case UserRole.admin:
        Navigator.pushReplacementNamed(context, '/admin/dashboard');
        break;
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}

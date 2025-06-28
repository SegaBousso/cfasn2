import 'package:flutter/material.dart';
import '../../../../../models/user_model.dart';

class UserFormDialog extends StatefulWidget {
  final UserModel? user;
  final Function(UserModel) onUserSaved;

  const UserFormDialog({super.key, this.user, required this.onUserSaved});

  @override
  State<UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<UserFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  UserRole _selectedRole = UserRole.client;
  bool _isVerified = false;
  bool _isAdmin = false;
  String? _selectedCivility;

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      _populateFields();
    }
  }

  void _populateFields() {
    final user = widget.user!;
    _emailController.text = user.email;
    _displayNameController.text = user.displayName;
    _firstNameController.text = user.firstName;
    _lastNameController.text = user.lastName;
    _phoneController.text = user.phoneNumber ?? '';
    _addressController.text = user.address ?? '';
    _selectedRole = user.role;
    _isVerified = user.isVerified;
    _isAdmin = user.isAdmin;
    _selectedCivility = user.civility;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _displayNameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.user == null
                  ? 'Ajouter un utilisateur'
                  : 'Modifier l\'utilisateur',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email *',
                        border: OutlineInputBorder(),
                      ),
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
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _displayNameController,
                      decoration: const InputDecoration(
                        labelText: 'Nom d\'affichage *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Le nom d\'affichage est requis';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _firstNameController,
                            decoration: const InputDecoration(
                              labelText: 'Prénom *',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Le prénom est requis';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _lastNameController,
                            decoration: const InputDecoration(
                              labelText: 'Nom *',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Le nom est requis';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedCivility,
                      decoration: const InputDecoration(
                        labelText: 'Civilité',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Mr', child: Text('Monsieur')),
                        DropdownMenuItem(value: 'Mme', child: Text('Madame')),
                        DropdownMenuItem(
                          value: 'Mlle',
                          child: Text('Mademoiselle'),
                        ),
                      ],
                      onChanged: (value) =>
                          setState(() => _selectedCivility = value),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Téléphone',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'Adresse',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<UserRole>(
                      value: _selectedRole,
                      decoration: const InputDecoration(
                        labelText: 'Rôle *',
                        border: OutlineInputBorder(),
                      ),
                      items: UserRole.values.map((role) {
                        return DropdownMenuItem(
                          value: role,
                          child: Text(role.label),
                        );
                      }).toList(),
                      onChanged: (value) =>
                          setState(() => _selectedRole = value!),
                    ),
                    const SizedBox(height: 16),
                    CheckboxListTile(
                      title: const Text('Compte vérifié'),
                      value: _isVerified,
                      onChanged: (value) =>
                          setState(() => _isVerified = value ?? false),
                    ),
                    CheckboxListTile(
                      title: const Text('Administrateur'),
                      value: _isAdmin,
                      onChanged: (value) =>
                          setState(() => _isAdmin = value ?? false),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Annuler'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _saveUser,
                  child: Text(widget.user == null ? 'Créer' : 'Modifier'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _saveUser() {
    if (!_formKey.currentState!.validate()) return;

    final now = DateTime.now();
    final user = UserModel(
      uid: widget.user?.uid ?? '',
      email: _emailController.text.trim(),
      displayName: _displayNameController.text.trim(),
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      phoneNumber: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      address: _addressController.text.trim().isEmpty
          ? null
          : _addressController.text.trim(),
      civility: _selectedCivility,
      role: _selectedRole,
      isVerified: _isVerified,
      isAdmin: _isAdmin,
      createdAt: widget.user?.createdAt ?? now,
      lastSignIn: widget.user?.lastSignIn ?? now,
      photoURL: widget.user?.photoURL,
      fcmToken: widget.user?.fcmToken,
      preferences: widget.user?.preferences ?? {},
    );

    widget.onUserSaved(user);
    Navigator.of(context).pop();
  }
}

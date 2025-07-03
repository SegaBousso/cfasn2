import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/responsive_helper.dart';
import '../../widgets/overflow_safe_widgets.dart';
import 'logic/profile_form_data.dart';
import 'logic/profile_event_handler.dart';
import 'widgets/profile_header_card.dart';
import 'widgets/personal_info_section.dart';
import 'widgets/role_selection_section.dart';
import 'widgets/profile_action_button.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  late final ProfileFormData _formData;
  late final ProfileEventHandler _eventHandler;

  @override
  void initState() {
    super.initState();
    _formData = ProfileFormData();
    _eventHandler = ProfileEventHandler(
      context: context,
      formData: _formData,
      onStateChanged: () {
        if (mounted) setState(() {});
      },
    );
    _initializeFormWithUserData();
  }

  void _initializeFormWithUserData() {
    final user = context.read<AuthProvider>().user;
    _formData.initializeWithUserData(user);
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
                key: _formData.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header card
                    const ProfileHeaderCard(),

                    const SizedBox(height: 24),

                    // Personal information section
                    PersonalInfoSection(
                      selectedCivility: _formData.selectedCivility,
                      civilities: _formData.civilities,
                      firstNameController: _formData.firstNameController,
                      lastNameController: _formData.lastNameController,
                      phoneController: _formData.phoneController,
                      addressController: _formData.addressController,
                      onCivilityChanged: _eventHandler.handleCivilityChanged,
                    ),

                    const SizedBox(height: 24),

                    // Role selection section
                    RoleSelectionSection(
                      selectedRole: _formData.selectedRole,
                      onRoleChanged: _eventHandler.handleRoleChanged,
                    ),

                    const SizedBox(height: 32),

                    // Action button
                    ProfileActionButton(
                      isLoading: _formData.isLoading,
                      onPressed: _eventHandler.handleCompleteProfile,
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

  @override
  void dispose() {
    _formData.dispose();
    _eventHandler.dispose();
    super.dispose();
  }
}

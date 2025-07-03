import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/models.dart';
import '../../../providers/auth_provider.dart';
import '../../../utils/event_bus.dart';
import 'profile_events.dart';
import 'profile_form_data.dart';
import 'profile_save_handler.dart';

/// Main event handler for the complete profile screen
class ProfileEventHandler {
  final BuildContext context;
  final ProfileFormData formData;
  final VoidCallback? onStateChanged;
  late final ProfileSaveHandler saveHandler;
  late final StreamSubscription _eventSubscription;

  ProfileEventHandler({
    required this.context,
    required this.formData,
    this.onStateChanged,
  }) {
    saveHandler = ProfileSaveHandler(
      context: context,
      authProvider: context.read<AuthProvider>(),
    );
    _setupEventListeners();
  }

  void _setupEventListeners() {
    _eventSubscription = EventBus.instance.on<ProfileEvent>().listen((event) {
      _handleEvent(event);
    });
  }

  void _handleEvent(ProfileEvent event) {
    switch (event.runtimeType) {
      case ProfileCivilityChangedEvent:
        final e = event as ProfileCivilityChangedEvent;
        formData.selectedCivility = e.civility;
        onStateChanged?.call();
        break;

      case ProfileRoleChangedEvent:
        final e = event as ProfileRoleChangedEvent;
        final role = UserRole.values.firstWhere((r) => r.name == e.role);
        formData.selectedRole = role;
        onStateChanged?.call();
        break;

      case ProfileSaveStartedEvent:
        formData.isLoading = true;
        onStateChanged?.call();
        break;

      case ProfileSaveSuccessEvent:
        final e = event as ProfileSaveSuccessEvent;
        formData.isLoading = false;
        final role = UserRole.values.firstWhere((r) => r.name == e.role);
        saveHandler.navigateBasedOnRole(role);
        onStateChanged?.call();
        break;

      case ProfileSaveFailedEvent:
        final e = event as ProfileSaveFailedEvent;
        formData.isLoading = false;
        _showErrorSnackbar(e.error);
        onStateChanged?.call();
        break;

      case ProfileShowSnackbarEvent:
        final e = event as ProfileShowSnackbarEvent;
        _showSnackbar(e.message, e.isError);
        break;
    }
  }

  /// Handle complete profile action
  Future<void> handleCompleteProfile() async {
    if (!formData.validateForm()) {
      return;
    }

    final data = formData.getFormData();
    await saveHandler.saveProfile(data);
  }

  /// Handle civility change
  void handleCivilityChanged(String? civility) {
    EventBus.instance.emit(ProfileCivilityChangedEvent(civility));
  }

  /// Handle role change
  void handleRoleChanged(UserRole role) {
    EventBus.instance.emit(ProfileRoleChangedEvent(role.name));
  }

  void _showSnackbar(String message, bool isError) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : null,
      ),
    );
  }

  void _showErrorSnackbar(String error) {
    _showSnackbar('Erreur: $error', true);
  }

  void dispose() {
    _eventSubscription.cancel();
  }
}

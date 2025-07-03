import 'package:flutter/material.dart';
import '../../../models/models.dart';
import 'widgets/widgets.dart';
import 'logic/logic.dart';

class AddEditProviderScreen extends StatefulWidget {
  final ProviderModel? provider;

  const AddEditProviderScreen({super.key, this.provider});

  @override
  State<AddEditProviderScreen> createState() => _AddEditProviderScreenState();
}

class _AddEditProviderScreenState extends State<AddEditProviderScreen> {
  final _formKey = GlobalKey<FormState>();

  // Logic handlers
  final _formData = ProviderFormData();
  final _imageHandler = ProviderImageHandler();
  final _saveHandler = ProviderSaveHandler();
  final _servicesHandler = ProviderServicesHandler();

  // Event handler
  late final ProviderEventHandler _eventHandler;

  @override
  void initState() {
    super.initState();

    // Initialize event handler
    _eventHandler = ProviderEventHandler(
      formData: _formData,
      imageHandler: _imageHandler,
      saveHandler: _saveHandler,
      onStateChanged: () {
        if (mounted) setState(() {});
      },
    );

    // Initialize provider and load services
    _eventHandler.initializeProvider(
      context: context,
      existingProvider: widget.provider,
      servicesHandler: _servicesHandler,
    );
  }

  @override
  void dispose() {
    _formData.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.provider != null;

    return Scaffold(
      appBar: ProviderAppBar(
        isEditing: isEditing,
        isSaving: _saveHandler.isSaving,
        isUploading: _imageHandler.isUploading,
      ),
      body: Form(
        key: _formKey,
        child: ProviderBody(
          formData: _formData,
          imageHandler: _imageHandler,
          servicesHandler: _servicesHandler,
          onPickImage: () => _eventHandler.handlePickImage(context),
          onActiveChanged: (value) =>
              setState(() => _formData.isActive = value),
          onAvailableChanged: (value) =>
              setState(() => _formData.isAvailable = value),
          onVerifiedChanged: (value) =>
              setState(() => _formData.isVerified = value),
          onAddToList: _eventHandler.handleAddToList,
          onRemoveFromList: _eventHandler.handleRemoveFromList,
          onAddService: _eventHandler.handleAddService,
          onRemoveService: _eventHandler.handleRemoveService,
        ),
      ),
      bottomNavigationBar: ProviderBottomBar(
        isEditing: isEditing,
        isSaving: _saveHandler.isSaving,
        isUploading: _imageHandler.isUploading,
        onSave: () => _eventHandler.saveAndClose(
          context: context,
          formKey: _formKey,
          existingProvider: widget.provider,
        ),
        onCancel: () => Navigator.pop(context),
      ),
    );
  }
}

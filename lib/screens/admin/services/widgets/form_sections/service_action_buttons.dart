import 'package:flutter/material.dart';
import '../../../../../utils/event_bus.dart';
import '../../logic/logic.dart';

class ServiceActionButtons extends StatefulWidget {
  const ServiceActionButtons({super.key});

  @override
  State<ServiceActionButtons> createState() => _ServiceActionButtonsState();
}

class _ServiceActionButtonsState extends State<ServiceActionButtons> {
  bool _isLoading = false;
  bool _isEditing = false;
  late final ServiceSaveHandler _saveHandler;

  @override
  void initState() {
    super.initState();
    _saveHandler = ServiceSaveHandler();
    _setupEventListeners();
    _initializeData();
  }

  void _setupEventListeners() {
    EventBus.instance.on<ServiceSaveStateChanged>().listen((event) {
      if (mounted) {
        setState(() {
          _isLoading = event.isLoading;
        });
      }
    });

    EventBus.instance.on<ServiceFormDataUpdated>().listen((event) {
      if (mounted) {
        setState(() {
          _isEditing = event.formData.isEditing;
        });
      }
    });
  }

  void _initializeData() {
    final formData = ServiceFormData.instance;
    _isEditing = formData.isEditing;
  }

  Future<void> _onSave() async {
    await _saveHandler.saveService();
  }

  void _onCancel() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _isLoading ? null : _onCancel,
            icon: const Icon(Icons.cancel),
            label: const Text('Annuler'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _onSave,
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Icon(_isEditing ? Icons.save : Icons.add),
            label: Text(_isEditing ? 'Modifier' : 'Créer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}

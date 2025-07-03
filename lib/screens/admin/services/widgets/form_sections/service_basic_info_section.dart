import 'package:flutter/material.dart';
import '../../../../../utils/event_bus.dart';
import '../../logic/logic.dart';

class ServiceBasicInfoSection extends StatefulWidget {
  const ServiceBasicInfoSection({super.key});

  @override
  State<ServiceBasicInfoSection> createState() =>
      _ServiceBasicInfoSectionState();
}

class _ServiceBasicInfoSectionState extends State<ServiceBasicInfoSection> {
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _setupEventListeners();
    _initializeData();
  }

  void _setupEventListeners() {
    EventBus.instance.on<ServiceFormDataUpdated>().listen((event) {
      if (mounted) {
        nameController.text = event.formData.name;
        descriptionController.text = event.formData.description;
      }
    });
  }

  void _initializeData() {
    final formData = ServiceFormData.instance;
    nameController.text = formData.name;
    descriptionController.text = formData.description;
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informations de base',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nom du service *',
                hintText: 'Ex: Nettoyage de bureaux',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.business_center),
              ),
              onChanged: (value) {
                ServiceFormData.instance.updateName(value);
              },
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Le nom du service est requis';
                }
                if (value.trim().length < 3) {
                  return 'Le nom doit contenir au moins 3 caractères';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description *',
                hintText: 'Décrivez votre service en détail...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 4,
              onChanged: (value) {
                ServiceFormData.instance.updateDescription(value);
              },
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'La description est requise';
                }
                if (value.trim().length < 10) {
                  return 'La description doit contenir au moins 10 caractères';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}

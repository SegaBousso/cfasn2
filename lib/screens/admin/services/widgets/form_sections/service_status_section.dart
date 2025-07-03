import 'package:flutter/material.dart';
import '../../../../../utils/event_bus.dart';
import '../../logic/logic.dart';

class ServiceStatusSection extends StatefulWidget {
  const ServiceStatusSection({super.key});

  @override
  State<ServiceStatusSection> createState() => _ServiceStatusSectionState();
}

class _ServiceStatusSectionState extends State<ServiceStatusSection> {
  bool _isAvailable = true;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _setupEventListeners();
    _initializeData();
  }

  void _setupEventListeners() {
    EventBus.instance.on<ServiceFormDataUpdated>().listen((event) {
      if (mounted) {
        setState(() {
          _isAvailable = event.formData.isAvailable;
          _isActive = event.formData.isActive;
        });
      }
    });
  }

  void _initializeData() {
    final formData = ServiceFormData.instance;
    _isAvailable = formData.isAvailable;
    _isActive = formData.isActive;
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
              'Statut',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Service disponible'),
              subtitle: const Text(
                'Les utilisateurs peuvent réserver ce service',
              ),
              value: _isAvailable,
              onChanged: (value) {
                setState(() {
                  _isAvailable = value;
                });
                ServiceFormData.instance.updateAvailability(value);
              },
              activeColor: Colors.green,
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              title: const Text('Service actif'),
              subtitle: const Text(
                'Le service est visible dans l\'application',
              ),
              value: _isActive,
              onChanged: (value) {
                setState(() {
                  _isActive = value;
                });
                ServiceFormData.instance.updateActive(value);
              },
              activeColor: Colors.deepPurple,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }
}

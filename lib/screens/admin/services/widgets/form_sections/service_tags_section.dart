import 'package:flutter/material.dart';
import '../../../../../utils/event_bus.dart';
import '../../logic/logic.dart';

class ServiceTagsSection extends StatefulWidget {
  const ServiceTagsSection({super.key});

  @override
  State<ServiceTagsSection> createState() => _ServiceTagsSectionState();
}

class _ServiceTagsSectionState extends State<ServiceTagsSection> {
  final tagsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _setupEventListeners();
    _initializeData();
  }

  void _setupEventListeners() {
    EventBus.instance.on<ServiceFormDataUpdated>().listen((event) {
      if (mounted) {
        tagsController.text = event.formData.tags.join(', ');
      }
    });
  }

  void _initializeData() {
    final formData = ServiceFormData.instance;
    tagsController.text = formData.tags.join(', ');
  }

  @override
  void dispose() {
    tagsController.dispose();
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
              'Tags (optionnel)',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Séparez les tags par des virgules (ex: bureau, professionnel, rapide)',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: tagsController,
              decoration: const InputDecoration(
                labelText: 'Tags',
                hintText: 'bureau, professionnel, rapide',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.tag),
              ),
              maxLines: 2,
              onChanged: (value) {
                final tags = value
                    .split(',')
                    .map((tag) => tag.trim())
                    .where((tag) => tag.isNotEmpty)
                    .toList();
                ServiceFormData.instance.updateTags(tags);
              },
            ),
          ],
        ),
      ),
    );
  }
}

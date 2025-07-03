import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../utils/event_bus.dart';
import '../../logic/logic.dart';

class ServicePriceSection extends StatefulWidget {
  const ServicePriceSection({super.key});

  @override
  State<ServicePriceSection> createState() => _ServicePriceSectionState();
}

class _ServicePriceSectionState extends State<ServicePriceSection> {
  final priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _setupEventListeners();
    _initializeData();
  }

  void _setupEventListeners() {
    EventBus.instance.on<ServiceFormDataUpdated>().listen((event) {
      if (mounted) {
        priceController.text = event.formData.price.toString();
      }
    });
  }

  void _initializeData() {
    final formData = ServiceFormData.instance;
    priceController.text = formData.price.toString();
  }

  @override
  void dispose() {
    priceController.dispose();
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
              'Tarification',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: priceController,
              decoration: const InputDecoration(
                labelText: 'Prix (€) *',
                hintText: '0.00',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.euro),
                suffixText: '€',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              onChanged: (value) {
                final price = double.tryParse(value) ?? 0.0;
                ServiceFormData.instance.updatePrice(price);
              },
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Le prix est requis';
                }
                final price = double.tryParse(value);
                if (price == null) {
                  return 'Veuillez entrer un prix valide';
                }
                if (price <= 0) {
                  return 'Le prix doit être supérieur à 0';
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

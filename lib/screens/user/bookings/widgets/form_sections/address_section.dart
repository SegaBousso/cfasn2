import 'package:flutter/material.dart';
import '../../../../../utils/event_bus.dart';
import '../../logic/booking_address_handler.dart';
import '../../logic/booking_events.dart';

/// Section modulaire pour la saisie de l'adresse d'intervention
class AddressSection extends StatefulWidget {
  final BookingAddressHandler handler;

  const AddressSection({super.key, required this.handler});

  @override
  State<AddressSection> createState() => _AddressSectionState();
}

class _AddressSectionState extends State<AddressSection> {
  final TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeEventListeners();
    _addressController.text = widget.handler.selectedAddress;
  }

  @override
  void dispose() {
    _cleanupEventListeners();
    _addressController.dispose();
    super.dispose();
  }

  void _initializeEventListeners() {
    EventBus.instance.on<AddressUpdatedEvent>().listen((event) {
      if (mounted && _addressController.text != event.address) {
        _addressController.text = event.address;
      }
    });

    EventBus.instance.on<AddressResetEvent>().listen((_) {
      if (mounted) {
        _addressController.clear();
      }
    });
  }

  void _cleanupEventListeners() {
    // Les subscriptions se nettoient automatiquement avec le dispose du widget
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Adresse d\'intervention',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _addressController,
          decoration: const InputDecoration(
            hintText: 'Entrez l\'adresse complète',
            prefixIcon: Icon(Icons.location_on),
            border: OutlineInputBorder(),
          ),
          validator: widget.handler.validateAddress,
          onChanged: widget.handler.updateAddress,
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.streetAddress,
        ),
      ],
    );
  }
}

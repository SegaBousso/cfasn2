import 'package:flutter/material.dart';
import '../../../../../utils/event_bus.dart';
import '../../logic/booking_datetime_handler.dart';
import '../../logic/booking_events.dart' as events;
import '../../logic/booking_form_data.dart';

/// Section modulaire pour la sélection de date et heure
class DateTimeSection extends StatefulWidget {
  final BookingDateTimeHandler handler;

  const DateTimeSection({super.key, required this.handler});

  @override
  State<DateTimeSection> createState() => _DateTimeSectionState();
}

class _DateTimeSectionState extends State<DateTimeSection> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    _initializeEventListeners();
    _selectedDate = widget.handler.selectedDate;
    _selectedTime = widget.handler.selectedTime;
  }

  @override
  void dispose() {
    _cleanupEventListeners();
    super.dispose();
  }

  void _initializeEventListeners() {
    EventBus.instance.on<BookingFormDataUpdated>().listen((event) {
      if (mounted) {
        setState(() {
          _selectedDate = event.formData.selectedDate;
          _selectedTime = event.formData.selectedTime;
        });
      }
    });

    EventBus.instance.on<events.BookingDateSelected>().listen((event) {
      if (mounted) {
        setState(() {
          _selectedDate = event.date;
        });
      }
    });

    EventBus.instance.on<events.BookingTimeSelected>().listen((event) {
      if (mounted) {
        setState(() {
          _selectedTime = event.time;
        });
      }
    });

    EventBus.instance.on<events.DateTimeResetEvent>().listen((_) {
      if (mounted) {
        setState(() {
          _selectedDate = null;
          _selectedTime = null;
        });
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
          'Date et Heure',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildDateField()),
            const SizedBox(width: 16),
            Expanded(child: _buildTimeField()),
          ],
        ),
      ],
    );
  }

  /// Construit le champ de sélection de date
  Widget _buildDateField() {
    return InkWell(
      onTap: () => widget.handler.selectDate(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: Colors.grey),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _selectedDate != null
                    ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                    : 'Sélectionner une date',
                style: TextStyle(
                  color: _selectedDate != null ? Colors.black : Colors.grey,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construit le champ de sélection d'heure
  Widget _buildTimeField() {
    return InkWell(
      onTap: () => widget.handler.selectTime(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time, color: Colors.grey),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _selectedTime != null
                    ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
                    : 'Heure',
                style: TextStyle(
                  color: _selectedTime != null ? Colors.black : Colors.grey,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

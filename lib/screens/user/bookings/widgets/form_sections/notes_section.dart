import 'package:flutter/material.dart';
import '../../../../../utils/event_bus.dart';
import '../../logic/booking_notes_handler.dart';
import '../../logic/booking_events.dart';

/// Section modulaire pour la saisie des notes et instructions
class NotesSection extends StatefulWidget {
  final BookingNotesHandler handler;

  const NotesSection({super.key, required this.handler});

  @override
  State<NotesSection> createState() => _NotesSectionState();
}

class _NotesSectionState extends State<NotesSection> {
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeEventListeners();
    _notesController.text = widget.handler.notes;
  }

  @override
  void dispose() {
    _cleanupEventListeners();
    _notesController.dispose();
    super.dispose();
  }

  void _initializeEventListeners() {
    EventBus.instance.on<NotesUpdatedEvent>().listen((event) {
      if (mounted && _notesController.text != event.notes) {
        _notesController.text = event.notes;
      }
    });

    EventBus.instance.on<NotesResetEvent>().listen((_) {
      if (mounted) {
        _notesController.clear();
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
          'Notes et instructions (optionnel)',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _notesController,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Ajoutez des détails ou instructions spéciales...',
            border: OutlineInputBorder(),
          ),
          validator: widget.handler.validateNotes,
          onChanged: widget.handler.updateNotes,
          textInputAction: TextInputAction.done,
          keyboardType: TextInputType.multiline,
        ),
      ],
    );
  }
}

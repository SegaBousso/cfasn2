import '../../../../utils/event_bus.dart';
import 'dart:async';

/// Gestionnaire principal des événements pour les écrans de services
class ServiceEventHandler {
  late StreamSubscription _subscription;

  ServiceEventHandler() {
    _setupEventListeners();
  }

  void _setupEventListeners() {
    // Handle service save completion events
    _subscription = EventBus.instance.on<ServiceSaveCompleted>().listen((
      event,
    ) {
      // Handle completion if needed
    });
  }

  void dispose() {
    _subscription.cancel();
  }
}

/// Event classes
class ServiceSaveCompleted {
  final bool success;
  final String? error;

  ServiceSaveCompleted({required this.success, this.error});
}

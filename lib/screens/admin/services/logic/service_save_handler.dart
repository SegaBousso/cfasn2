import '../../../../utils/event_bus.dart';
import 'service_form_data.dart';
import 'service_image_handler.dart';
import 'service_event_handler.dart';

/// Gestionnaire pour la sauvegarde des services
class ServiceSaveHandler {
  /// Sauvegarder un service (création ou modification)
  Future<void> saveService() async {
    try {
      // Notify loading started
      EventBus.instance.emit(ServiceSaveStateChanged(isLoading: true));

      final formData = ServiceFormData.instance;
      final imageHandler = ServiceImageHandler();

      // Generate service ID
      final serviceId = formData.isEditing
          ? formData
                .name // Use existing ID logic here
          : DateTime.now().millisecondsSinceEpoch.toString();

      // Upload image if needed (placeholder for now)
      if (imageHandler.selectedImage != null) {
        // imageUrl = await imageHandler.uploadImage(serviceId);
        // For now, just set a placeholder
      }

      // Create service model to validate data
      final service = formData.createServiceModel(id: serviceId);

      // Simulate save operation (replace with actual Firebase/API call)
      await Future.delayed(const Duration(milliseconds: 500));

      // Success - no snackbar needed here, will be handled in UI
      print('Service saved successfully: ${service.name}');

      // Notify completion
      EventBus.instance.emit(ServiceSaveCompleted(success: true));
      EventBus.instance.emit(ServiceSaveStateChanged(isLoading: false));
    } catch (e) {
      // Error - no snackbar needed here, will be handled in UI
      print('Error saving service: $e');

      // Notify completion with error
      EventBus.instance.emit(
        ServiceSaveCompleted(success: false, error: e.toString()),
      );
      EventBus.instance.emit(ServiceSaveStateChanged(isLoading: false));

      rethrow;
    }
  }
}

/// Event for save state changes
class ServiceSaveStateChanged {
  final bool isLoading;
  ServiceSaveStateChanged({required this.isLoading});
}

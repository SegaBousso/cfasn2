import 'package:flutter/material.dart';
import '../../../../models/models.dart';
import '../../../../utils/responsive_helper.dart';
import '../logic/logic.dart';
import 'widgets.dart';

class ProviderBody extends StatelessWidget {
  final ProviderFormData formData;
  final ProviderImageHandler imageHandler;
  final ProviderServicesHandler servicesHandler;
  final VoidCallback onPickImage;
  final Function(bool) onActiveChanged;
  final Function(bool) onAvailableChanged;
  final Function(bool) onVerifiedChanged;
  final Function(List<String>, String) onAddToList;
  final Function(List<String>, String) onRemoveFromList;
  final Function(ServiceModel) onAddService;
  final Function(ServiceModel) onRemoveService;

  const ProviderBody({
    super.key,
    required this.formData,
    required this.imageHandler,
    required this.servicesHandler,
    required this.onPickImage,
    required this.onActiveChanged,
    required this.onAvailableChanged,
    required this.onVerifiedChanged,
    required this.onAddToList,
    required this.onRemoveFromList,
    required this.onAddService,
    required this.onRemoveService,
  });

  @override
  Widget build(BuildContext context) {
    final dimensions = ResponsiveHelper.getDimensions(context);

    switch (dimensions.deviceType) {
      case DeviceType.mobile:
        return ProviderMobileLayout(
          formData: formData,
          imageHandler: imageHandler,
          servicesHandler: servicesHandler,
          onPickImage: onPickImage,
          onActiveChanged: onActiveChanged,
          onAvailableChanged: onAvailableChanged,
          onVerifiedChanged: onVerifiedChanged,
          onAddToList: onAddToList,
          onRemoveFromList: onRemoveFromList,
          onAddService: onAddService,
          onRemoveService: onRemoveService,
        );
      case DeviceType.tablet:
        return ProviderTabletLayout(
          formData: formData,
          imageHandler: imageHandler,
          servicesHandler: servicesHandler,
          onPickImage: onPickImage,
          onActiveChanged: onActiveChanged,
          onAvailableChanged: onAvailableChanged,
          onVerifiedChanged: onVerifiedChanged,
          onAddToList: onAddToList,
          onRemoveFromList: onRemoveFromList,
          onAddService: onAddService,
          onRemoveService: onRemoveService,
        );
      case DeviceType.desktop:
        return ProviderDesktopLayout(
          formData: formData,
          imageHandler: imageHandler,
          servicesHandler: servicesHandler,
          onPickImage: onPickImage,
          onActiveChanged: onActiveChanged,
          onAvailableChanged: onAvailableChanged,
          onVerifiedChanged: onVerifiedChanged,
          onAddToList: onAddToList,
          onRemoveFromList: onRemoveFromList,
          onAddService: onAddService,
          onRemoveService: onRemoveService,
        );
    }
  }
}

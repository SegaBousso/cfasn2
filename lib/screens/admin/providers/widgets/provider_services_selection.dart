import 'package:flutter/material.dart';
import '../../../../models/models.dart';
import '../../../../utils/responsive_helper.dart';

class ProviderServicesSelection extends StatelessWidget {
  final List<ServiceModel> availableServices;
  final List<ServiceModel> selectedServices;
  final bool isLoading;
  final Function(ServiceModel) onAddService;
  final Function(ServiceModel) onRemoveService;

  const ProviderServicesSelection({
    super.key,
    required this.availableServices,
    required this.selectedServices,
    required this.isLoading,
    required this.onAddService,
    required this.onRemoveService,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = ResponsiveHelper.getSpacing(context);
    final dimensions = ResponsiveHelper.getDimensions(context);

    return Card(
      child: Padding(
        padding: ResponsiveHelper.getScreenPadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, spacing),
            SizedBox(height: spacing),
            if (isLoading)
              _buildLoadingState()
            else if (availableServices.isEmpty)
              _buildEmptyState(context)
            else
              _buildServicesList(context, spacing, dimensions),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double spacing) {
    return Row(
      children: [
        Icon(Icons.business, color: Colors.purple),
        SizedBox(width: spacing / 2),
        Text(
          'Services associés',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: ResponsiveHelper.getFontSize(
              context,
              mobile: 16,
              tablet: 18,
              desktop: 20,
            ),
          ),
        ),
        const Spacer(),
        if (isLoading)
          SizedBox(
            width: ResponsiveHelper.getValue<double>(
              context,
              mobile: 16,
              tablet: 18,
              desktop: 20,
            ),
            height: ResponsiveHelper.getValue<double>(
              context,
              mobile: 16,
              tablet: 18,
              desktop: 20,
            ),
            child: const CircularProgressIndicator(strokeWidth: 2),
          ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: ResponsiveHelper.getScreenPadding(context),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(Icons.info_outline, color: Colors.grey.shade600),
          SizedBox(height: ResponsiveHelper.getSpacing(context) / 2),
          Text(
            'Aucun service disponible',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: ResponsiveHelper.getFontSize(context),
            ),
          ),
          SizedBox(height: ResponsiveHelper.getSpacing(context) / 4),
          Text(
            'Créez d\'abord des services dans la section Services',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: ResponsiveHelper.getFontSize(
                context,
                mobile: 11,
                tablet: 12,
                desktop: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesList(
    BuildContext context,
    double spacing,
    ResponsiveDimensions dimensions,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Services sélectionnés
        if (selectedServices.isNotEmpty) ...[
          _buildSelectedServices(context, spacing),
          SizedBox(height: spacing),
        ],

        // Services disponibles
        _buildAvailableServices(context, spacing, dimensions),
      ],
    );
  }

  Widget _buildSelectedServices(BuildContext context, double spacing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Services sélectionnés (${selectedServices.length})',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.green,
            fontSize: ResponsiveHelper.getFontSize(context),
          ),
        ),
        SizedBox(height: spacing / 2),
        ResponsiveHelper.getDeviceType(context) == DeviceType.mobile
            ? _buildSelectedServicesMobile(context)
            : _buildSelectedServicesDesktop(context),
      ],
    );
  }

  Widget _buildSelectedServicesMobile(BuildContext context) {
    return Column(
      children: selectedServices
          .map((service) => _buildSelectedServiceTile(context, service))
          .toList(),
    );
  }

  Widget _buildSelectedServicesDesktop(BuildContext context) {
    return Wrap(
      spacing: ResponsiveHelper.getSpacing(context),
      runSpacing: ResponsiveHelper.getSpacing(context) / 2,
      children: selectedServices
          .map((service) => _buildSelectedServiceChip(context, service))
          .toList(),
    );
  }

  Widget _buildSelectedServiceTile(BuildContext context, ServiceModel service) {
    return Card(
      margin: EdgeInsets.only(bottom: ResponsiveHelper.getSpacing(context) / 2),
      color: Colors.green.shade50,
      child: ListTile(
        dense: true,
        leading: Icon(Icons.check_circle, color: Colors.green.shade600),
        title: Text(
          service.name,
          style: TextStyle(
            color: Colors.green.shade700,
            fontWeight: FontWeight.w500,
            fontSize: ResponsiveHelper.getFontSize(context),
          ),
        ),
        subtitle: Text(
          '${service.categoryName} • ${service.price.toStringAsFixed(2)} €',
          style: TextStyle(
            fontSize: ResponsiveHelper.getFontSize(
              context,
              mobile: 12,
              tablet: 13,
              desktop: 14,
            ),
          ),
        ),
        trailing: IconButton(
          icon: Icon(Icons.close, color: Colors.green.shade600),
          onPressed: () => onRemoveService(service),
        ),
      ),
    );
  }

  Widget _buildSelectedServiceChip(BuildContext context, ServiceModel service) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.getSpacing(context),
        vertical: ResponsiveHelper.getSpacing(context) / 2,
      ),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle,
            size: ResponsiveHelper.getValue<double>(
              context,
              mobile: 16,
              tablet: 18,
              desktop: 20,
            ),
            color: Colors.green.shade600,
          ),
          SizedBox(width: ResponsiveHelper.getSpacing(context) / 2),
          Text(
            service.name,
            style: TextStyle(
              color: Colors.green.shade700,
              fontWeight: FontWeight.w500,
              fontSize: ResponsiveHelper.getFontSize(context),
            ),
          ),
          SizedBox(width: ResponsiveHelper.getSpacing(context) / 2),
          GestureDetector(
            onTap: () => onRemoveService(service),
            child: Icon(
              Icons.close,
              size: ResponsiveHelper.getValue<double>(
                context,
                mobile: 16,
                tablet: 18,
                desktop: 20,
              ),
              color: Colors.green.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableServices(
    BuildContext context,
    double spacing,
    ResponsiveDimensions dimensions,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Services disponibles',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.purple,
            fontSize: ResponsiveHelper.getFontSize(context),
          ),
        ),
        SizedBox(height: spacing / 2),
        Container(
          constraints: BoxConstraints(
            maxHeight: ResponsiveHelper.getValue<double>(
              context,
              mobile: 200,
              tablet: 250,
              desktop: 300,
            ),
          ),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: availableServices.length,
            itemBuilder: (context, index) {
              final service = availableServices[index];
              final isSelected = selectedServices.contains(service);

              return ListTile(
                dense: dimensions.deviceType == DeviceType.mobile,
                leading: Icon(
                  isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                  color: isSelected ? Colors.green : Colors.grey,
                ),
                title: Text(
                  service.name,
                  style: TextStyle(
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                    color: isSelected ? Colors.green : Colors.black87,
                    fontSize: ResponsiveHelper.getFontSize(context),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.categoryName,
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getFontSize(
                          context,
                          mobile: 11,
                          tablet: 12,
                          desktop: 13,
                        ),
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${service.price.toStringAsFixed(2)} €',
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getFontSize(
                          context,
                          mobile: 12,
                          tablet: 13,
                          desktop: 14,
                        ),
                        fontWeight: FontWeight.w500,
                        color: Colors.purple.shade600,
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  final isSelected = selectedServices.any(
                    (s) => s.id == service.id,
                  );
                  if (isSelected) {
                    onRemoveService(service);
                  } else {
                    onAddService(service);
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

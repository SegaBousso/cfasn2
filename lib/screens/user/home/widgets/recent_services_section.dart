import 'package:flutter/material.dart';
import '../../../../models/models.dart';
import '../../services/service_detail_screen.dart';
import '../../../../widgets/overflow_safe_widgets.dart';
import '../../../../utils/responsive_helper.dart';

class RecentServicesSection extends StatelessWidget {
  final List<ServiceModel> services;
  final VoidCallback? onSeeAll;

  const RecentServicesSection({
    super.key,
    required this.services,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return OverflowSafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: AdaptiveText(
                    'Récemment ajoutés',
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getFontSize(
                        context,
                        mobile: 18.0,
                        tablet: 20.0,
                        desktop: 22.0,
                      ),
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                  ),
                ),
                AdaptiveContainer(
                  child: TextButton(
                    onPressed: onSeeAll,
                    child: AdaptiveText(
                      'Voir tout',
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getFontSize(
                          context,
                          mobile: 12.0,
                          tablet: 14.0,
                          desktop: 16.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: services.length.clamp(
              0,
              3,
            ), // Limiter à 3 services récents
            itemBuilder: (context, index) {
              final service = services[index];
              return ServiceListTile(service: service);
            },
          ),
        ],
      ),
    );
  }
}

class ServiceListTile extends StatelessWidget {
  final ServiceModel service;

  const ServiceListTile({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return AdaptiveContainer(
      margin: const EdgeInsets.only(bottom: 8),
      child: Card(
        child: ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              service.displayImage,
              width:
                  ResponsiveHelper.getDeviceType(context) == DeviceType.mobile
                  ? 45
                  : 50,
              height:
                  ResponsiveHelper.getDeviceType(context) == DeviceType.mobile
                  ? 45
                  : 50,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width:
                      ResponsiveHelper.getDeviceType(context) ==
                          DeviceType.mobile
                      ? 45
                      : 50,
                  height:
                      ResponsiveHelper.getDeviceType(context) ==
                          DeviceType.mobile
                      ? 45
                      : 50,
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.image_not_supported),
                );
              },
            ),
          ),
          title: AdaptiveText(
            service.name,
            style: TextStyle(
              fontSize: ResponsiveHelper.getFontSize(
                context,
                mobile: 14.0,
                tablet: 16.0,
                desktop: 16.0,
              ),
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
          ),
          subtitle: AdaptiveText(
            service.formattedPrice,
            style: TextStyle(
              fontSize: ResponsiveHelper.getFontSize(
                context,
                mobile: 12.0,
                tablet: 14.0,
                desktop: 14.0,
              ),
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.star,
                color: Colors.amber,
                size:
                    ResponsiveHelper.getDeviceType(context) == DeviceType.mobile
                    ? 14
                    : 16,
              ),
              const SizedBox(width: 2),
              AdaptiveText(
                service.rating.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: ResponsiveHelper.getFontSize(
                    context,
                    mobile: 10.0,
                    tablet: 12.0,
                    desktop: 12.0,
                  ),
                ),
              ),
            ],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ServiceDetailScreen(service: service),
              ),
            );
          },
        ),
      ),
    );
  }
}

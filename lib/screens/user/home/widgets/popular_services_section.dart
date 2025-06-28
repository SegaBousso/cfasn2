import 'package:flutter/material.dart';
import '../../../../models/models.dart';
import '../../services/service_detail_screen.dart';
import '../../../../widgets/overflow_safe_widgets.dart';
import '../../../../utils/responsive_helper.dart';

class PopularServicesSection extends StatelessWidget {
  final List<ServiceModel> services;
  final VoidCallback? onSeeAll;

  const PopularServicesSection({
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
                    'Services populaires',
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
          SizedBox(
            height: ResponsiveHelper.getDeviceType(context) == DeviceType.mobile
                ? 260.0
                : 280.0,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: services.length,
              itemBuilder: (context, index) {
                final service = services[index];
                return ServiceCard(service: service);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ServiceCard extends StatelessWidget {
  final ServiceModel service;

  const ServiceCard({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return AdaptiveContainer(
      width: ResponsiveHelper.getDeviceType(context) == DeviceType.mobile
          ? 180.0
          : 200.0,
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ServiceDetailScreen(service: service),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Image du service
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Image.network(
                  service.displayImage,
                  height:
                      ResponsiveHelper.getDeviceType(context) ==
                          DeviceType.mobile
                      ? 100
                      : 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height:
                          ResponsiveHelper.getDeviceType(context) ==
                              DeviceType.mobile
                          ? 100
                          : 120,
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.image_not_supported, size: 40),
                    );
                  },
                ),
              ),
              Expanded(
                child: Padding(
                  padding:
                      ResponsiveHelper.getDeviceType(context) ==
                          DeviceType.mobile
                      ? const EdgeInsets.all(8)
                      : const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AdaptiveText(
                        service.name,
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getFontSize(
                            context,
                            mobile: 12.0,
                            tablet: 14.0,
                            desktop: 14.0,
                          ),
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                      ),
                      SizedBox(
                        height: ResponsiveHelper.getSpacing(
                          context,
                          mobile: 2.0,
                          tablet: 4.0,
                        ),
                      ),
                      AdaptiveText(
                        service.formattedPrice,
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getFontSize(
                            context,
                            mobile: 14.0,
                            tablet: 16.0,
                            desktop: 16.0,
                          ),
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      SizedBox(
                        height: ResponsiveHelper.getSpacing(
                          context,
                          mobile: 2.0,
                          tablet: 4.0,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star,
                            color: Colors.amber,
                            size:
                                ResponsiveHelper.getDeviceType(context) ==
                                    DeviceType.mobile
                                ? 14
                                : 16,
                          ),
                          const SizedBox(width: 4),
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
                          const Spacer(),
                          Icon(
                            Icons.favorite_border,
                            size:
                                ResponsiveHelper.getDeviceType(context) ==
                                    DeviceType.mobile
                                ? 14
                                : 16,
                            color: Colors.grey.shade600,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

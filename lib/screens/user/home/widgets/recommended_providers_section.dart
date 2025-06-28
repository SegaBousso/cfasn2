import 'package:flutter/material.dart';
import '../../../../widgets/overflow_safe_widgets.dart';
import '../../../../utils/responsive_helper.dart';

class RecommendedProvidersSection extends StatelessWidget {
  final List<Map<String, dynamic>> providers;
  final VoidCallback? onSeeAll;

  const RecommendedProvidersSection({
    super.key,
    required this.providers,
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
                    'Prestataires recommandés',
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
                ? 180.0
                : 200.0,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: providers.length,
              itemBuilder: (context, index) {
                final provider = providers[index];
                return ProviderCard(provider: provider);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ProviderCard extends StatelessWidget {
  final Map<String, dynamic> provider;

  const ProviderCard({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return AdaptiveContainer(
      width: ResponsiveHelper.getDeviceType(context) == DeviceType.mobile
          ? 140.0
          : 160.0,
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: () {
            // TODO: Navigation vers le profil du prestataire
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding:
                ResponsiveHelper.getDeviceType(context) == DeviceType.mobile
                ? const EdgeInsets.all(12)
                : const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius:
                      ResponsiveHelper.getDeviceType(context) ==
                          DeviceType.mobile
                      ? 25
                      : 30,
                  backgroundImage: NetworkImage(provider['avatar']),
                  onBackgroundImageError: (exception, stackTrace) {},
                  child: provider['avatar'] == null
                      ? AdaptiveText(
                          provider['name'][0],
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getFontSize(
                              context,
                              mobile: 16.0,
                              tablet: 20.0,
                              desktop: 20.0,
                            ),
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                SizedBox(
                  height: ResponsiveHelper.getSpacing(
                    context,
                    mobile: 8.0,
                    tablet: 12.0,
                  ),
                ),
                AdaptiveText(
                  provider['name'],
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getFontSize(
                      context,
                      mobile: 12.0,
                      tablet: 14.0,
                      desktop: 14.0,
                    ),
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
                const SizedBox(height: 4),
                AdaptiveText(
                  provider['specialty'],
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getFontSize(
                      context,
                      mobile: 10.0,
                      tablet: 12.0,
                      desktop: 12.0,
                    ),
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                ),
                SizedBox(
                  height: ResponsiveHelper.getSpacing(
                    context,
                    mobile: 6.0,
                    tablet: 8.0,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star,
                      color: Colors.amber,
                      size:
                          ResponsiveHelper.getDeviceType(context) ==
                              DeviceType.mobile
                          ? 12
                          : 14,
                    ),
                    const SizedBox(width: 4),
                    AdaptiveText(
                      provider['rating'].toString(),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

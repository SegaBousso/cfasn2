import 'package:flutter/material.dart';
import '../../../../widgets/overflow_safe_widgets.dart';
import '../../../../utils/responsive_helper.dart';
import '../../../../models/models.dart';

class HeroSection extends StatefulWidget {
  final List<ServiceModel> featuredServices;
  final int totalServices;
  final int totalCategories;

  const HeroSection({
    super.key,
    this.featuredServices = const [],
    this.totalServices = 0,
    this.totalCategories = 0,
  });

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection> {
  final PageController _pageController = PageController();
  int _currentBannerIndex = 0;

  // Générer les données de bannière basées sur les services
  List<Map<String, dynamic>> get _bannerData {
    if (widget.featuredServices.isEmpty) {
      // Bannières par défaut si aucun service
      return [
        {
          'title': 'Bienvenue sur notre plateforme',
          'subtitle': 'Découvrez nos services de qualité',
          'color': Colors.deepPurple,
          'action': 'Explorer',
        },
        {
          'title': 'Services professionnels',
          'subtitle': 'Des prestataires qualifiés',
          'color': Colors.blue,
          'action': 'Découvrir',
        },
        {
          'title': 'Réservation facile',
          'subtitle': 'En quelques clics seulement',
          'color': Colors.green,
          'action': 'Commencer',
        },
      ];
    }

    List<Map<String, dynamic>> banners = [];

    // Première bannière : statistiques
    banners.add({
      'title': '${widget.totalServices}+ Services disponibles',
      'subtitle': '${widget.totalCategories} catégories à explorer',
      'color': Colors.deepPurple,
      'action': 'Explorer',
      'type': 'stats',
    });

    // Bannières pour les services populaires (max 3)
    final topServices = widget.featuredServices.take(3).toList();
    for (var service in topServices) {
      banners.add({
        'title': service.name,
        'subtitle': '${service.formattedPrice} - ${service.categoryName}',
        'color': _getColorForCategory(service.categoryName),
        'action': 'Réserver',
        'type': 'service',
        'service': service,
      });
    }

    return banners;
  }

  Color _getColorForCategory(String categoryName) {
    final colors = {
      'Ménage': Colors.green,
      'Plomberie': Colors.blue,
      'Électricité': Colors.amber,
      'Jardinage': Colors.green.shade700,
      'Peinture': Colors.orange,
      'Réparation': Colors.red,
      'Transport': Colors.cyan,
      'Informatique': Colors.indigo,
    };
    return colors[categoryName] ?? Colors.deepPurple;
  }

  @override
  void initState() {
    super.initState();
    // Auto-scroll pour la hero section
    Future.delayed(const Duration(seconds: 3), _autoScrollBanner);
  }

  void _autoScrollBanner() {
    if (mounted && _pageController.hasClients) {
      final nextPage = (_currentBannerIndex + 1) % _bannerData.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      Future.delayed(const Duration(seconds: 3), _autoScrollBanner);
    }
  }

  @override
  Widget build(BuildContext context) {
    final heroHeight =
        ResponsiveHelper.getDeviceType(context) == DeviceType.mobile
        ? 180.0
        : 200.0;

    return OverflowSafeArea(
      child: AdaptiveContainer(
        height: heroHeight,
        margin: EdgeInsets.all(ResponsiveHelper.getSpacing(context)),
        child: PageView.builder(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentBannerIndex = index;
            });
          },
          itemCount: _bannerData.length,
          itemBuilder: (context, index) {
            final banner = _bannerData[index];
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [banner['color'], banner['color'].withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: banner['color'].withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Image de fond pour les services
                  if (banner['type'] == 'service' && banner['service'] != null)
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          banner['service'].imageUrl ??
                              banner['service'].displayImage,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    banner['color'],
                                    banner['color'].withOpacity(0.7),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                  // Overlay sombre pour la lisibilité du texte sur les images
                  if (banner['type'] == 'service')
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withOpacity(0.6),
                              Colors.black.withOpacity(0.3),
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                      ),
                    ),

                  // Background pattern (seulement pour les bannières non-service)
                  if (banner['type'] != 'service')
                    Positioned(
                      right: -20,
                      top: -20,
                      child: Container(
                        width:
                            ResponsiveHelper.getDeviceType(context) ==
                                DeviceType.mobile
                            ? 100
                            : 120,
                        height:
                            ResponsiveHelper.getDeviceType(context) ==
                                DeviceType.mobile
                            ? 100
                            : 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                  // Content
                  Padding(
                    padding: EdgeInsets.all(
                      ResponsiveHelper.getSpacing(
                        context,
                        mobile: 12.0,
                        tablet: 16.0,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Badge de note pour les services
                        if (banner['type'] == 'service' &&
                            banner['service'] != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.white,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  banner['service'].rating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        SizedBox(height: banner['type'] == 'service' ? 8 : 0),

                        AdaptiveText(
                          banner['title'],
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: ResponsiveHelper.getFontSize(
                              context,
                              mobile: 20.0,
                              tablet: 24.0,
                              desktop: 26.0,
                            ),
                            fontWeight: FontWeight.bold,
                            shadows: banner['type'] == 'service'
                                ? [
                                    const Shadow(
                                      color: Colors.black,
                                      blurRadius: 2,
                                    ),
                                  ]
                                : null,
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: ResponsiveHelper.getSpacing(
                            context,
                            mobile: 2.0,
                            tablet: 4.0,
                          ),
                        ),
                        AdaptiveText(
                          banner['subtitle'],
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: ResponsiveHelper.getFontSize(
                              context,
                              mobile: 12.0,
                              tablet: 14.0,
                              desktop: 14.0,
                            ),
                            shadows: banner['type'] == 'service'
                                ? [
                                    const Shadow(
                                      color: Colors.black,
                                      blurRadius: 1,
                                    ),
                                  ]
                                : null,
                          ),
                          maxLines: 1,
                        ),
                        SizedBox(
                          height: ResponsiveHelper.getSpacing(
                            context,
                            mobile: 8.0,
                            tablet: 12.0,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            final banner = _bannerData[index];
                            if (banner['type'] == 'service' &&
                                banner['service'] != null) {
                              // TODO: Navigation vers le détail du service
                              print(
                                'Navigation vers service: ${banner['service'].name}',
                              );
                            } else {
                              // TODO: Navigation vers la liste des services
                              print('Navigation vers tous les services');
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: banner['color'],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: AdaptiveText(
                            banner['action'] ?? 'Voir plus',
                            style: TextStyle(
                              fontSize: ResponsiveHelper.getFontSize(
                                context,
                                mobile: 12.0,
                                tablet: 14.0,
                                desktop: 14.0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

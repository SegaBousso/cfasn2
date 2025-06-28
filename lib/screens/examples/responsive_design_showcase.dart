import 'package:flutter/material.dart';
import '../../utils/responsive_helper.dart';
import '../../widgets/overflow_safe_widgets.dart';

/// Écran de démonstration du système responsive et anti-overflow
class ResponsiveDesignShowcase extends StatelessWidget {
  const ResponsiveDesignShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Design Responsive - Démonstration'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: ResponsiveBuilder(
        builder: (context, dimensions) {
          return OverflowSafeArea(
            padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête avec information sur l'appareil
                _buildDeviceInfo(context, dimensions),

                SizedBox(height: ResponsiveHelper.getSpacing(context)),

                // Grille responsive
                _buildResponsiveGrid(context, dimensions),

                SizedBox(height: ResponsiveHelper.getSpacing(context)),

                // Containers adaptatifs
                _buildAdaptiveContainers(context, dimensions),

                SizedBox(height: ResponsiveHelper.getSpacing(context)),

                // Text responsive
                _buildResponsiveText(context, dimensions),

                SizedBox(height: ResponsiveHelper.getSpacing(context)),

                // Layout selon l'orientation
                _buildOrientationAwareLayout(context, dimensions),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDeviceInfo(
    BuildContext context,
    ResponsiveDimensions dimensions,
  ) {
    return AdaptiveContainer(
      padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context)),
      decoration: BoxDecoration(
        color: Colors.teal.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.teal),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informations de l\'appareil',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.teal,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text('Type: ${dimensions.deviceType.name}'),
          Text(
            'Écran: ${dimensions.screenWidth.round()} x ${dimensions.screenHeight.round()}',
          ),
          Text(
            'Orientation: ${dimensions.isLandscape ? 'Paysage' : 'Portrait'}',
          ),
          Text('Safe Area Top: ${dimensions.safeAreaTop}'),
          Text('Safe Area Bottom: ${dimensions.safeAreaBottom}'),
        ],
      ),
    );
  }

  Widget _buildResponsiveGrid(
    BuildContext context,
    ResponsiveDimensions dimensions,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Grille Responsive',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ResponsiveGrid(
          children: List.generate(
            6,
            (index) => Container(
              height: 80,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  'Item ${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdaptiveContainers(
    BuildContext context,
    ResponsiveDimensions dimensions,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Containers Adaptatifs',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: AdaptiveContainer(
                height: ResponsiveHelper.getValue(
                  context,
                  mobile: 100,
                  tablet: 120,
                  desktop: 140,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    'Container 1',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: ResponsiveHelper.getSpacing(context)),
            Expanded(
              child: AdaptiveContainer(
                height: ResponsiveHelper.getValue(
                  context,
                  mobile: 100,
                  tablet: 120,
                  desktop: 140,
                ),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    'Container 2',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildResponsiveText(
    BuildContext context,
    ResponsiveDimensions dimensions,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Texte Adaptatif',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        AdaptiveText(
          'Ce texte s\'adapte automatiquement à la taille de l\'écran. '
          'Sur mobile il sera plus petit, sur tablette moyen, et sur desktop plus grand.',
          style: TextStyle(
            fontSize: ResponsiveHelper.getValue(
              context,
              mobile: 14,
              tablet: 16,
              desktop: 18,
            ),
            color: Colors.grey[700],
          ),
          maxLines: dimensions.deviceType == DeviceType.mobile ? 3 : 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildOrientationAwareLayout(
    BuildContext context,
    ResponsiveDimensions dimensions,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Layout selon l\'orientation',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (dimensions.isLandscape)
          // Layout paysage : côte à côte
          Row(
            children: [
              Expanded(child: _buildColoredCard('Gauche', Colors.red)),
              SizedBox(width: ResponsiveHelper.getSpacing(context)),
              Expanded(child: _buildColoredCard('Droite', Colors.green)),
            ],
          )
        else
          // Layout portrait : empilé
          Column(
            children: [
              _buildColoredCard('Haut', Colors.red),
              SizedBox(height: ResponsiveHelper.getSpacing(context) / 2),
              _buildColoredCard('Bas', Colors.green),
            ],
          ),
      ],
    );
  }

  Widget _buildColoredCard(String text, Color color) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: color.withOpacity(0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

/// Extension pour ajouter des utilitaires responsive
extension ResponsiveExtensions on BuildContext {
  /// Obtenir la largeur de l'écran
  double get screenWidth => MediaQuery.of(this).size.width;

  /// Obtenir la hauteur de l'écran
  double get screenHeight => MediaQuery.of(this).size.height;

  /// Vérifier si c'est un mobile
  bool get isMobile =>
      ResponsiveHelper.getDeviceType(this) == DeviceType.mobile;

  /// Vérifier si c'est une tablette
  bool get isTablet =>
      ResponsiveHelper.getDeviceType(this) == DeviceType.tablet;

  /// Vérifier si c'est un desktop
  bool get isDesktop =>
      ResponsiveHelper.getDeviceType(this) == DeviceType.desktop;

  /// Obtenir l'orientation
  bool get isLandscape =>
      MediaQuery.of(this).orientation == Orientation.landscape;

  /// Obtenir un espacement responsive rapide
  double get spacing => ResponsiveHelper.getSpacing(this);

  /// Obtenir une valeur responsive rapide
  T getResponsiveValue<T>({
    required T mobile,
    required T tablet,
    required T desktop,
  }) {
    return ResponsiveHelper.getValue(
      this,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }
}

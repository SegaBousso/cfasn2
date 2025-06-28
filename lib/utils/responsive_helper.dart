import 'package:flutter/material.dart';

/// Utilitaires pour le design responsive
class ResponsiveHelper {
  static const double mobileMaxWidth = 600;
  static const double tabletMaxWidth = 1024;
  static const double desktopMaxWidth = 1440;

  /// Déterminer le type d'appareil
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileMaxWidth) return DeviceType.mobile;
    if (width < tabletMaxWidth) return DeviceType.tablet;
    return DeviceType.desktop;
  }

  /// Obtenir les dimensions adaptées selon l'appareil
  static ResponsiveDimensions getDimensions(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final deviceType = getDeviceType(context);
    final size = mediaQuery.size;
    final orientation = mediaQuery.orientation;

    return ResponsiveDimensions(
      screenWidth: size.width,
      screenHeight: size.height,
      deviceType: deviceType,
      orientation: orientation,
      isLandscape: orientation == Orientation.landscape,
      safeAreaTop: mediaQuery.padding.top,
      safeAreaBottom: mediaQuery.padding.bottom,
    );
  }

  /// Espacement responsive
  static double getSpacing(
    BuildContext context, {
    double mobile = 8.0,
    double tablet = 12.0,
    double desktop = 16.0,
  }) {
    switch (getDeviceType(context)) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet;
      case DeviceType.desktop:
        return desktop;
    }
  }

  /// Taille de police responsive
  static double getFontSize(
    BuildContext context, {
    double mobile = 14.0,
    double tablet = 16.0,
    double desktop = 18.0,
  }) {
    switch (getDeviceType(context)) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet;
      case DeviceType.desktop:
        return desktop;
    }
  }

  /// Nombre de colonnes pour grille responsive
  static int getGridColumns(
    BuildContext context, {
    int mobile = 1,
    int tablet = 2,
    int desktop = 3,
  }) {
    switch (getDeviceType(context)) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet;
      case DeviceType.desktop:
        return desktop;
    }
  }

  /// Largeur de dialog responsive
  static double getDialogWidth(BuildContext context) {
    final dimensions = getDimensions(context);
    switch (dimensions.deviceType) {
      case DeviceType.mobile:
        return dimensions.screenWidth * 0.95;
      case DeviceType.tablet:
        return dimensions.screenWidth * 0.8;
      case DeviceType.desktop:
        return 600;
    }
  }

  /// Hauteur de dialog responsive
  static double getDialogMaxHeight(BuildContext context) {
    final dimensions = getDimensions(context);
    return dimensions.screenHeight * 0.8;
  }

  /// Padding responsive
  static EdgeInsets getScreenPadding(BuildContext context) {
    final spacing = getSpacing(context, mobile: 16, tablet: 24, desktop: 32);
    return EdgeInsets.all(spacing);
  }

  /// Padding horizontal responsive
  static EdgeInsets getHorizontalPadding(BuildContext context) {
    final spacing = getSpacing(context, mobile: 16, tablet: 24, desktop: 32);
    return EdgeInsets.symmetric(horizontal: spacing);
  }

  /// Aspect ratio responsive pour cartes
  static double getCardAspectRatio(BuildContext context) {
    switch (getDeviceType(context)) {
      case DeviceType.mobile:
        return 1.2;
      case DeviceType.tablet:
        return 1.4;
      case DeviceType.desktop:
        return 1.6;
    }
  }

  /// Obtenir une valeur responsive générique
  static T getValue<T>(
    BuildContext context, {
    required T mobile,
    required T tablet,
    required T desktop,
  }) {
    switch (getDeviceType(context)) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet;
      case DeviceType.desktop:
        return desktop;
    }
  }
}

/// Types d'appareils
enum DeviceType { mobile, tablet, desktop }

/// Dimensions responsive
class ResponsiveDimensions {
  final double screenWidth;
  final double screenHeight;
  final DeviceType deviceType;
  final Orientation orientation;
  final bool isLandscape;
  final double safeAreaTop;
  final double safeAreaBottom;

  const ResponsiveDimensions({
    required this.screenWidth,
    required this.screenHeight,
    required this.deviceType,
    required this.orientation,
    required this.isLandscape,
    required this.safeAreaTop,
    required this.safeAreaBottom,
  });

  bool get isMobile => deviceType == DeviceType.mobile;
  bool get isTablet => deviceType == DeviceType.tablet;
  bool get isDesktop => deviceType == DeviceType.desktop;
}

/// Widget pour construction responsive
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, ResponsiveDimensions dimensions)
  builder;

  const ResponsiveBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final dimensions = ResponsiveHelper.getDimensions(context);
        return builder(context, dimensions);
      },
    );
  }
}

/// Widget pour grille responsive
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int? mobileColumns;
  final int? tabletColumns;
  final int? desktopColumns;
  final double spacing;
  final double runSpacing;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 3,
    this.spacing = 16.0,
    this.runSpacing = 16.0,
    this.shrinkWrap = false,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, dimensions) {
        int columns;
        switch (dimensions.deviceType) {
          case DeviceType.mobile:
            columns = mobileColumns ?? 1;
            break;
          case DeviceType.tablet:
            columns = tabletColumns ?? 2;
            break;
          case DeviceType.desktop:
            columns = desktopColumns ?? 3;
            break;
        }

        return GridView.count(
          crossAxisCount: columns,
          crossAxisSpacing: spacing,
          mainAxisSpacing: runSpacing,
          shrinkWrap: shrinkWrap,
          physics: physics,
          children: children,
        );
      },
    );
  }
}

/// Widget pour colonnes responsives
class ResponsiveRow extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final bool wrapOnMobile;

  const ResponsiveRow({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.wrapOnMobile = true,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, dimensions) {
        if (dimensions.isMobile && wrapOnMobile) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children
                .map(
                  (child) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: child,
                  ),
                )
                .toList(),
          );
        }

        return Row(
          mainAxisAlignment: mainAxisAlignment,
          crossAxisAlignment: crossAxisAlignment,
          children: children,
        );
      },
    );
  }
}

/// Container responsive avec constraints automatiques
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? color;
  final Decoration? decoration;
  final double? maxWidth;
  final double? maxHeight;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.decoration,
    this.maxWidth,
    this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, dimensions) {
        final responsivePadding =
            padding ?? ResponsiveHelper.getScreenPadding(context);

        return Container(
          constraints: BoxConstraints(
            maxWidth:
                maxWidth ?? (dimensions.isDesktop ? 1200 : double.infinity),
            maxHeight: maxHeight ?? double.infinity,
          ),
          margin: margin,
          padding: responsivePadding,
          color: color,
          decoration: decoration,
          child: child,
        );
      },
    );
  }
}

/// Dialog responsive
class ResponsiveDialog extends StatelessWidget {
  final Widget child;
  final String? title;
  final List<Widget>? actions;
  final bool scrollable;

  const ResponsiveDialog({
    super.key,
    required this.child,
    this.title,
    this.actions,
    this.scrollable = true,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, dimensions) {
        final dialogWidth = ResponsiveHelper.getDialogWidth(context);
        final dialogMaxHeight = ResponsiveHelper.getDialogMaxHeight(context);

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: dialogWidth,
            constraints: BoxConstraints(
              maxHeight: dialogMaxHeight,
              maxWidth: dimensions.isDesktop ? 600 : double.infinity,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null) ...[
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      title!,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                ],
                Flexible(
                  child: scrollable
                      ? SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: child,
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: child,
                        ),
                ),
                if (actions != null) ...[
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: ResponsiveRow(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: actions!,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Extension pour MediaQuery facile
extension ResponsiveContext on BuildContext {
  ResponsiveDimensions get dimensions => ResponsiveHelper.getDimensions(this);
  DeviceType get deviceType => ResponsiveHelper.getDeviceType(this);
  bool get isMobile => deviceType == DeviceType.mobile;
  bool get isTablet => deviceType == DeviceType.tablet;
  bool get isDesktop => deviceType == DeviceType.desktop;

  double responsiveSpacing({
    double mobile = 8,
    double tablet = 12,
    double desktop = 16,
  }) {
    return ResponsiveHelper.getSpacing(
      this,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }

  double responsiveFontSize({
    double mobile = 14,
    double tablet = 16,
    double desktop = 18,
  }) {
    return ResponsiveHelper.getFontSize(
      this,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }

  int responsiveGridColumns({int mobile = 1, int tablet = 2, int desktop = 3}) {
    return ResponsiveHelper.getGridColumns(
      this,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }
}

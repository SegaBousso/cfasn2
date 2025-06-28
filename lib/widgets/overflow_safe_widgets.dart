import 'package:flutter/material.dart';
import '../utils/responsive_helper.dart';

/// Widget wrapper pour éviter les RenderOverflow avec défilement automatique
class OverflowSafeArea extends StatelessWidget {
  final Widget child;
  final Axis scrollDirection;
  final bool primary;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool enableScrolling;

  const OverflowSafeArea({
    super.key,
    required this.child,
    this.scrollDirection = Axis.vertical,
    this.primary = false,
    this.physics,
    this.padding,
    this.margin,
    this.enableScrolling = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = child;

    // Ajouter padding si spécifié
    if (padding != null) {
      content = Padding(padding: padding!, child: content);
    }

    // Wrapper avec défilement si activé
    if (enableScrolling) {
      content = SingleChildScrollView(
        scrollDirection: scrollDirection,
        primary: primary,
        physics: physics ?? const ClampingScrollPhysics(),
        child: content,
      );
    }

    // Ajouter margin si spécifié
    if (margin != null) {
      content = Container(margin: margin, child: content);
    }

    return content;
  }
}

/// Container adaptatif qui limite sa largeur selon l'appareil
class AdaptiveContainer extends StatelessWidget {
  final Widget? child;
  final double? width;
  final double? height;
  final double? maxWidth;
  final double? maxHeight;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BoxDecoration? decoration;
  final AlignmentGeometry? alignment;
  final BoxConstraints? constraints;

  const AdaptiveContainer({
    super.key,
    this.child,
    this.width,
    this.height,
    this.maxWidth,
    this.maxHeight,
    this.padding,
    this.margin,
    this.decoration,
    this.alignment,
    this.constraints,
  });

  @override
  Widget build(BuildContext context) {
    final deviceType = ResponsiveHelper.getDeviceType(context);

    // Largeur maximale adaptée à l'appareil
    double? adaptiveMaxWidth = maxWidth;
    if (maxWidth != null) {
      switch (deviceType) {
        case DeviceType.mobile:
          adaptiveMaxWidth = maxWidth! > 400 ? 400 : maxWidth;
          break;
        case DeviceType.tablet:
          adaptiveMaxWidth = maxWidth! > 600 ? 600 : maxWidth;
          break;
        case DeviceType.desktop:
          break; // Garde la valeur originale
      }
    }

    return Container(
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      decoration: decoration,
      alignment: alignment,
      constraints:
          constraints ??
          BoxConstraints(
            maxWidth: adaptiveMaxWidth ?? double.infinity,
            maxHeight: maxHeight ?? double.infinity,
          ),
      child: child,
    );
  }
}

/// Texte adaptatif avec gestion automatique du débordement
class AdaptiveText extends StatelessWidget {
  final String data;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;
  final bool softWrap;
  final TextScaler? textScaler;

  const AdaptiveText(
    this.data, {
    super.key,
    this.style,
    this.maxLines,
    this.overflow = TextOverflow.ellipsis,
    this.textAlign,
    this.softWrap = true,
    this.textScaler,
  });

  @override
  Widget build(BuildContext context) {
    final deviceType = ResponsiveHelper.getDeviceType(context);

    // Ajuster les lignes maximales selon l'appareil
    int? adaptiveMaxLines = maxLines;
    if (maxLines == null) {
      switch (deviceType) {
        case DeviceType.mobile:
          adaptiveMaxLines = 3;
          break;
        case DeviceType.tablet:
          adaptiveMaxLines = 4;
          break;
        case DeviceType.desktop:
          adaptiveMaxLines = 5;
          break;
      }
    }

    return Text(
      data,
      style: style,
      maxLines: adaptiveMaxLines,
      overflow: overflow,
      textAlign: textAlign,
      softWrap: softWrap,
      textScaler: textScaler,
    );
  }
}

/// Grid adaptatif qui évite les débordements
class AdaptiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double maxItemWidth;
  final double spacing;
  final double runSpacing;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const AdaptiveGrid({
    super.key,
    required this.children,
    this.maxItemWidth = 300,
    this.spacing = 16,
    this.runSpacing = 16,
    this.shrinkWrap = true,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final itemsPerRow = (availableWidth / (maxItemWidth + spacing))
            .floor()
            .clamp(1, children.length);
        final itemWidth =
            (availableWidth - (spacing * (itemsPerRow - 1))) / itemsPerRow;

        return Wrap(
          spacing: spacing,
          runSpacing: runSpacing,
          children: children.map((child) {
            return SizedBox(width: itemWidth, child: child);
          }).toList(),
        );
      },
    );
  }
}

/// Mixin pour les widgets responsives
mixin ResponsiveMixin {
  bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 600 && width < 1024;
  }

  bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1024;
  }

  double getResponsiveWidth(
    BuildContext context, {
    double mobile = 1.0,
    double tablet = 0.8,
    double desktop = 0.6,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (isMobile(context)) {
      return screenWidth * mobile;
    } else if (isTablet(context)) {
      return screenWidth * tablet;
    } else {
      return screenWidth * desktop;
    }
  }

  EdgeInsets getResponsivePadding(
    BuildContext context, {
    EdgeInsets mobile = const EdgeInsets.all(16),
    EdgeInsets tablet = const EdgeInsets.all(24),
    EdgeInsets desktop = const EdgeInsets.all(32),
  }) {
    if (isMobile(context)) {
      return mobile;
    } else if (isTablet(context)) {
      return tablet;
    } else {
      return desktop;
    }
  }

  double getResponsiveFontSize(
    BuildContext context, {
    double mobile = 14,
    double tablet = 16,
    double desktop = 18,
  }) {
    if (isMobile(context)) {
      return mobile;
    } else if (isTablet(context)) {
      return tablet;
    } else {
      return desktop;
    }
  }

  int getResponsiveColumns(
    BuildContext context, {
    int mobile = 1,
    int tablet = 2,
    int desktop = 3,
  }) {
    if (isMobile(context)) {
      return mobile;
    } else if (isTablet(context)) {
      return tablet;
    } else {
      return desktop;
    }
  }
}

/// Widget pour débordement horizontal avec scroll
class HorizontalOverflowHandler extends StatelessWidget {
  final Widget child;
  final bool showScrollbar;

  const HorizontalOverflowHandler({
    super.key,
    required this.child,
    this.showScrollbar = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: child,
          ),
        );
      },
    );
  }
}

/// Widget pour débordement vertical avec scroll
class VerticalOverflowHandler extends StatelessWidget {
  final Widget child;
  final bool showScrollbar;

  const VerticalOverflowHandler({
    super.key,
    required this.child,
    this.showScrollbar = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: child,
          ),
        );
      },
    );
  }
}

/// Extension pour faciliter l'utilisation des widgets anti-overflow
extension OverflowSafeExtensions on Widget {
  /// Rend le widget sûr contre les débordements
  Widget overflowSafe({
    EdgeInsetsGeometry? padding,
    bool enableScrolling = true,
    Axis scrollDirection = Axis.vertical,
  }) {
    return OverflowSafeArea(
      padding: padding,
      enableScrolling: enableScrolling,
      scrollDirection: scrollDirection,
      child: this,
    );
  }

  /// Adapte le widget aux différentes tailles d'écran
  Widget adaptive({double? maxWidth, EdgeInsetsGeometry? padding}) {
    return AdaptiveContainer(maxWidth: maxWidth, padding: padding, child: this);
  }
}

/// Row adaptatif qui devient une Column sur mobile
class AdaptiveRow extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;
  final double spacing;
  final bool forceColumn;

  const AdaptiveRow({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
    this.spacing = 8.0,
    this.forceColumn = false,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile =
        ResponsiveHelper.getDeviceType(context) == DeviceType.mobile;
    final shouldUseColumn = forceColumn || isMobile;

    if (shouldUseColumn) {
      return Column(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        mainAxisSize: mainAxisSize,
        children: _addSpacing(children, vertical: true),
      );
    }

    return Row(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: _addSpacing(children, vertical: false),
    );
  }

  List<Widget> _addSpacing(List<Widget> widgets, {required bool vertical}) {
    if (widgets.isEmpty || spacing <= 0) return widgets;

    final List<Widget> spacedWidgets = [];
    for (int i = 0; i < widgets.length; i++) {
      spacedWidgets.add(widgets[i]);
      if (i < widgets.length - 1) {
        spacedWidgets.add(
          vertical ? SizedBox(height: spacing) : SizedBox(width: spacing),
        );
      }
    }
    return spacedWidgets;
  }
}

/// Widget wrapper pour les CustomScrollView et widgets avec slivers
/// N'ajoute pas de scroll supplémentaire pour éviter les conflits
class OverflowSafeSliverArea extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const OverflowSafeSliverArea({
    super.key,
    required this.child,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = child;

    // Ajouter padding et margin sans créer de scroll conflictuel
    if (padding != null || margin != null) {
      content = Container(padding: padding, margin: margin, child: content);
    }

    return content;
  }
}

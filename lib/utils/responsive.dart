import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Screen size categorization for responsive layouts.
enum ScreenType { mobile, tablet, desktop }

/// Helper utility for adapting layouts across mobile portrait, mobile landscape,
/// tablet, and desktop/web views.
class Responsive {
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 1024.0;

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < mobileBreakpoint;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= mobileBreakpoint && width <= tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width > tabletBreakpoint;

  static bool isLandscape(BuildContext context) =>
      MediaQuery.orientationOf(context) == Orientation.landscape;

  static bool isPortrait(BuildContext context) =>
      MediaQuery.orientationOf(context) == Orientation.portrait;

  /// Determines if physical keyboard hints should be displayed.
  static bool get showKeyboardHints {
    if (kIsWeb) return true;
    return defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS;
  }

  static ScreenType getScreenType(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < mobileBreakpoint) return ScreenType.mobile;
    if (width <= tabletBreakpoint) return ScreenType.tablet;
    return ScreenType.desktop;
  }

  /// Calculates dynamic grid columns based on screen width.
  static int getGridColumns(
    BuildContext context, {
    int mobile = 2,
    int tablet = 3,
    int desktop = 4,
  }) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < mobileBreakpoint) return mobile;
    if (width <= tabletBreakpoint) return tablet;
    return desktop;
  }

  /// Scales content proportionally within a safe bound.
  static double scale(BuildContext context, double baseSize, {double min = 0.8, double max = 1.3}) {
    final width = MediaQuery.sizeOf(context).width;
    final factor = (width / 400.0).clamp(min, max);
    return baseSize * factor;
  }
}

/// A widget builder that rebuilds when screen constraints or orientation change.
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, ScreenType screenType, BoxConstraints constraints) builder;

  const ResponsiveBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenType = constraints.maxWidth < Responsive.mobileBreakpoint
            ? ScreenType.mobile
            : (constraints.maxWidth <= Responsive.tabletBreakpoint
                ? ScreenType.tablet
                : ScreenType.desktop);
        return builder(context, screenType, constraints);
      },
    );
  }
}

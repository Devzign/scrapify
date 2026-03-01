import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1100;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1100;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1100 && desktop != null) {
          return desktop!;
        } else if (constraints.maxWidth >= 600 && tablet != null) {
          return tablet!;
        } else {
          return mobile;
        }
      },
    );
  }
}

// Extension to help scaling UI easily depending on device aspect ratio
extension ResponsiveExtensions on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;

  // A scaling helper: scale proportionately compared to basic mobile design width (e.g. 375.0)
  double scaleWidth(double val) {
    double baseWidth = 375.0; // standard mobile width
    if (ResponsiveLayout.isTablet(this)) {
      baseWidth = 768.0; // standard tablet width
    }
    if (ResponsiveLayout.isDesktop(this)) {
      return val; // No scaling on desktop usually, use max constraints
    }

    return (screenWidth / baseWidth) * val;
  }
}

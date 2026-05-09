import 'package:flutter/material.dart';

import '../theme/app_color.dart';
import '../theme/app_theme.dart';

/// A scaffold preset for the new design system.
///
/// Use this instead of building a Scaffold + container background manually.
/// It handles:
///  - Cream background by default
///  - Subtle top-of-screen sage tint that fades into the background (the
///    "eco glow" used across all the redesigned hero pages)
///  - Optional bottom action bar with safe-area padding
class AppScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? bottomBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final bool showEcoGlow;
  final Color? backgroundColor;
  final bool resizeToAvoidBottomInset;

  const AppScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.bottomBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.showEcoGlow = true,
    this.backgroundColor,
    this.resizeToAvoidBottomInset = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? AppColor.backgroundLight,
      appBar: appBar,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: showEcoGlow
          ? Stack(
              children: [
                _EcoGlow(),
                body,
              ],
            )
          : body,
      bottomNavigationBar: bottomBar == null
          ? null
          : SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: bottomBar,
              ),
            ),
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }
}

class _EcoGlow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          height: 260,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColor.primary.withValues(alpha: 0.10),
                AppColor.primary.withValues(alpha: 0.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A compact pill-shaped status badge.
class AppStatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const AppStatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.icon,
  });

  factory AppStatusBadge.success(String label, {IconData? icon}) =>
      AppStatusBadge(
        label: label,
        color: AppColor.success,
        icon: icon ?? Icons.check_circle_rounded,
      );

  factory AppStatusBadge.warning(String label, {IconData? icon}) =>
      AppStatusBadge(
        label: label,
        color: AppColor.warning,
        icon: icon ?? Icons.error_rounded,
      );

  factory AppStatusBadge.info(String label, {IconData? icon}) =>
      AppStatusBadge(
        label: label,
        color: AppColor.info,
        icon: icon ?? Icons.info_rounded,
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

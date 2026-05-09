import 'package:flutter/material.dart';

import '../theme/app_color.dart';
import '../theme/app_theme.dart';

/// A consistent white card with the new design system's shadow + radius.
/// Use this instead of building ad-hoc Containers in screens.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final BorderRadius? borderRadius;
  final Border? border;
  final List<BoxShadow>? boxShadow;
  final VoidCallback? onTap;
  final bool tinted;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppTheme.space20),
    this.margin,
    this.color,
    this.borderRadius,
    this.border,
    this.boxShadow,
    this.onTap,
    this.tinted = false,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? AppTheme.cardBorderRadius;
    final decoration = BoxDecoration(
      color: color ??
          (tinted ? AppColor.primarySurface : AppColor.surface),
      borderRadius: radius,
      border: border ??
          Border.all(
            color: tinted
                ? AppColor.primaryLight
                : AppColor.cardBorder,
            width: 1,
          ),
      boxShadow: boxShadow ?? (tinted ? null : AppTheme.e1),
    );

    final content = Container(
      padding: padding,
      decoration: decoration,
      child: child,
    );

    final wrapped = Padding(
      padding: margin ?? EdgeInsets.zero,
      child: onTap != null
          ? Material(
              color: Colors.transparent,
              borderRadius: radius,
              child: InkWell(
                onTap: onTap,
                borderRadius: radius,
                child: content,
              ),
            )
          : content,
    );

    return wrapped;
  }
}

import 'package:flutter/material.dart';

import '../theme/app_color.dart';
import '../theme/app_theme.dart';

/// Primary button variants used across the app.
enum AppButtonVariant {
  /// Solid sage primary — main CTA.
  primary,

  /// Solid navy — used for trust/finance contexts (review, payouts).
  navy,

  /// Outlined sage — secondary action.
  outline,

  /// Tinted sage fill — tertiary action, sits on white cards.
  soft,

  /// Flat text button — least emphasis.
  ghost,

  /// Solid red — destructive (cancel pickup, delete item).
  danger,
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;

  /// Preferred way to pick a style. If left null, the legacy [isOutlined]
  /// flag is honoured for back-compat.
  final AppButtonVariant? variant;

  /// Legacy flag — kept so existing screens compile unchanged.
  final bool isOutlined;

  /// Optional override colors. Prefer using [variant] instead.
  final Color? backgroundColor;
  final Color? textColor;
  final Widget? leading;
  final Widget? trailing;
  final double minHeight;
  final double borderRadius;
  final double fontSize;
  final FontWeight fontWeight;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.variant,
    this.backgroundColor,
    this.textColor,
    this.leading,
    this.trailing,
    this.minHeight = 54,
    this.borderRadius = AppTheme.radiusLg,
    this.fontSize = 15,
    this.fontWeight = FontWeight.w600,
  });

  AppButtonVariant get _resolvedVariant {
    if (variant != null) return variant!;
    if (isOutlined) return AppButtonVariant.outline;
    return AppButtonVariant.primary;
  }

  @override
  Widget build(BuildContext context) {
    final v = _resolvedVariant;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadius),
    );
    final size = Size(double.infinity, minHeight);
    final padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 14);

    switch (v) {
      case AppButtonVariant.primary:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? AppColor.primary,
            foregroundColor: textColor ?? Colors.white,
            disabledBackgroundColor: AppColor.primary.withValues(alpha: 0.4),
            disabledForegroundColor: Colors.white.withValues(alpha: 0.85),
            elevation: 0,
            minimumSize: size,
            padding: padding,
            shape: shape,
            textStyle: TextStyle(fontSize: fontSize, fontWeight: fontWeight),
          ),
          child: _buildChild(Colors.white),
        );

      case AppButtonVariant.navy:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? AppColor.brandNavy,
            foregroundColor: textColor ?? Colors.white,
            disabledBackgroundColor:
                AppColor.brandNavy.withValues(alpha: 0.4),
            elevation: 0,
            minimumSize: size,
            padding: padding,
            shape: shape,
            textStyle: TextStyle(fontSize: fontSize, fontWeight: fontWeight),
          ),
          child: _buildChild(Colors.white),
        );

      case AppButtonVariant.outline:
        return OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: textColor ?? AppColor.primary,
            backgroundColor: AppColor.surface,
            side: BorderSide(
              color: backgroundColor ?? AppColor.primary,
              width: 1.4,
            ),
            minimumSize: size,
            padding: padding,
            shape: shape,
            textStyle: TextStyle(fontSize: fontSize, fontWeight: fontWeight),
          ),
          child: _buildChild(textColor ?? AppColor.primary),
        );

      case AppButtonVariant.soft:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? AppColor.primarySurface,
            foregroundColor: textColor ?? AppColor.primaryDark,
            disabledBackgroundColor:
                AppColor.primarySurface.withValues(alpha: 0.5),
            elevation: 0,
            minimumSize: size,
            padding: padding,
            shape: shape,
            textStyle: TextStyle(fontSize: fontSize, fontWeight: fontWeight),
          ),
          child: _buildChild(textColor ?? AppColor.primaryDark),
        );

      case AppButtonVariant.ghost:
        return TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: textColor ?? AppColor.primary,
            minimumSize: Size(0, minHeight),
            padding: padding,
            shape: shape,
            textStyle: TextStyle(fontSize: fontSize, fontWeight: fontWeight),
          ),
          child: _buildChild(textColor ?? AppColor.primary),
        );

      case AppButtonVariant.danger:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? AppColor.error,
            foregroundColor: textColor ?? Colors.white,
            disabledBackgroundColor: AppColor.error.withValues(alpha: 0.4),
            elevation: 0,
            minimumSize: size,
            padding: padding,
            shape: shape,
            textStyle: TextStyle(fontSize: fontSize, fontWeight: fontWeight),
          ),
          child: _buildChild(Colors.white),
        );
    }
  }

  Widget _buildChild(Color spinnerColor) {
    if (isLoading) {
      return SizedBox(
        height: 22,
        width: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.4,
          color: spinnerColor,
        ),
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (leading != null) ...[leading!, const SizedBox(width: 10)],
        Flexible(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 10), trailing!],
      ],
    );
  }
}

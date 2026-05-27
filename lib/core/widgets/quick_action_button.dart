import 'package:flutter/material.dart';
import '../theme/app_color.dart';
import '../theme/app_theme.dart';

/// Quick action button for dashboard CTAs.
/// Supports primary, secondary, and outline variants.
enum QuickActionVariant { primary, secondary, outline }

class QuickActionButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onPressed;
  final QuickActionVariant variant;
  final bool isLoading;
  final double? width;
  final double? height;

  const QuickActionButton({
    Key? key,
    required this.label,
    this.icon,
    required this.onPressed,
    this.variant = QuickActionVariant.primary,
    this.isLoading = false,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    Color borderColor;

    switch (variant) {
      case QuickActionVariant.primary:
        bgColor = AppColor.primary;
        textColor = AppColor.textOnPrimary;
        borderColor = AppColor.primary;
        break;
      case QuickActionVariant.secondary:
        bgColor = AppColor.primaryLight;
        textColor = AppColor.primary;
        borderColor = AppColor.primaryLight;
        break;
      case QuickActionVariant.outline:
        bgColor = Colors.transparent;
        textColor = AppColor.primary;
        borderColor = AppColor.outline;
        break;
    }

    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Container(
        width: width,
        height: height ?? 40,
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.space12,
          vertical: AppTheme.space8,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: borderColor, width: 1),
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        child: isLoading
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(textColor),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: textColor, size: 16),
                    const SizedBox(width: AppTheme.space8),
                  ],
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

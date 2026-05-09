import 'package:flutter/material.dart';

import '../theme/app_color.dart';
import '../theme/app_theme.dart';

/// A consistent section header with optional eyebrow label and trailing action.
class AppSectionHeader extends StatelessWidget {
  /// Small uppercase label above the title (e.g. "UPLOAD ITEM PHOTOS").
  final String? eyebrow;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;

  const AppSectionHeader({
    super.key,
    this.eyebrow,
    required this.title,
    this.subtitle,
    this.trailing,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (eyebrow != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      eyebrow!.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColor.primary,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColor.textPrimary,
                    height: 1.25,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: AppTheme.space4),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: AppColor.textSecondary,
                      height: 1.45,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

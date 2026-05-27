import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/app_color.dart';

/// Modern dashboard stat card with icon, label, and value.
/// Used for displaying key metrics in dashboards.
class DashboardStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? valueColor;
  final VoidCallback? onTap;
  final String? trend;
  final Color? trendColor;
  final Widget? trailing;

  const DashboardStatCard({
    Key? key,
    required this.label,
    required this.value,
    required this.icon,
    this.backgroundColor,
    this.iconColor,
    this.valueColor,
    this.onTap,
    this.trend,
    this.trendColor,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.space16),
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColor.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(color: AppColor.cardBorder, width: 1),
          boxShadow: AppTheme.e1,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: (iconColor ?? AppColor.primary).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor ?? AppColor.primary,
                    size: 20,
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: AppTheme.space12),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: valueColor ?? AppColor.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: AppTheme.space4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColor.textSecondary,
                letterSpacing: 0.3,
              ),
            ),
            if (trend != null) ...[
              const SizedBox(height: AppTheme.space8),
              Text(
                trend!,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: trendColor ?? AppColor.success,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

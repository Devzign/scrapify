import 'package:flutter/material.dart';

import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_theme.dart';

class LanguageOptionCard extends StatelessWidget {
  final String iconLabel;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const LanguageOptionCard({
    super.key,
    required this.iconLabel,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppTheme.radiusXl);
    return Material(
      color: Colors.transparent,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColor.primary
                : AppColor.surface,
            borderRadius: radius,
            border: Border.all(
              color: isSelected
                  ? AppColor.primary
                  : AppColor.cardBorder,
              width: isSelected ? 1.5 : 1,
            ),
            boxShadow: isSelected ? AppTheme.e2 : AppTheme.e1,
          ),
          child: Row(
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.18)
                      : AppColor.primarySurface,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  iconLabel,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? Colors.white : AppColor.primary,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.white : AppColor.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.85)
                            : AppColor.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                isSelected
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color:
                    isSelected ? Colors.white : AppColor.outline,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

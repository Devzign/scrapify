import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_theme.dart';

class RoleOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const RoleOptionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
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
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isSelected ? AppColor.primary : AppColor.surface,
            borderRadius: radius,
            border: Border.all(
              color: isSelected ? AppColor.primary : AppColor.cardBorder,
              width: isSelected ? 1.5 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColor.primary.withValues(alpha: 0.22),
                      blurRadius: 22,
                      offset: const Offset(0, 10),
                    ),
                  ]
                : AppTheme.e1,
          ),
          child: Row(
            children: [
              Container(
                height: 52,
                width: 52,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.18)
                      : AppColor.primarySurface,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: FaIcon(
                    icon,
                    color: isSelected ? Colors.white : AppColor.primary,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: isSelected ? Colors.white : AppColor.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13.5,
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.85)
                            : AppColor.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const FaIcon(
                  FontAwesomeIcons.solidCircleCheck,
                  color: Colors.white,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

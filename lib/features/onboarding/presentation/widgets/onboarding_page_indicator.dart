import 'package:flutter/material.dart';

import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_theme.dart';

class OnboardingPageIndicator extends StatelessWidget {
  final bool isSelected;

  const OnboardingPageIndicator({super.key, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isSelected ? 32 : 8,
      decoration: BoxDecoration(
        color: isSelected
            ? AppColor.emeraldMoss
            : AppTheme.textSecondary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppColor.emeraldMoss.withValues(alpha: 0.32),
                  blurRadius: 10,
                ),
              ]
            : null,
      ),
    );
  }
}

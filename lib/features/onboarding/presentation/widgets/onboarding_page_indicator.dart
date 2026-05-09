import 'package:flutter/material.dart';

import '../../../../core/theme/app_color.dart';

class OnboardingPageIndicator extends StatelessWidget {
  final bool isSelected;

  const OnboardingPageIndicator({super.key, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isSelected ? 28 : 8,
      decoration: BoxDecoration(
        color: isSelected
            ? AppColor.primary
            : AppColor.outline,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

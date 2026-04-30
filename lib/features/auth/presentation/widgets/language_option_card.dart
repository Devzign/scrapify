import 'package:flutter/material.dart';

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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor
              : AppTheme.primaryColor.withValues(alpha: 0.05),
          borderRadius: AppTheme.cardBorderRadius,
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryColor
                : AppTheme.cardBorderColor,
            width: AppTheme.cardBorderWidth,
          ),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.18)
                    : AppTheme.primaryColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                iconLabel,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : AppTheme.primaryColor,
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
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.82)
                          : AppTheme.primaryColor.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isSelected ? Colors.white : Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}

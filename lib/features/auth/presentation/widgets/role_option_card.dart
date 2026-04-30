import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.white,
          borderRadius: AppTheme.cardBorderRadius,
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryColor
                : AppTheme.cardBorderColor,
            width: AppTheme.cardBorderWidth,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppTheme.primaryColor.withValues(alpha: 0.22)
                  : Colors.grey.withValues(alpha: 0.1),
              blurRadius: isSelected ? 18 : 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.18)
                    : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: FaIcon(
                  icon,
                  color: isSelected ? Colors.white : AppTheme.textSecondary,
                  size: 24,
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
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.82)
                          : AppTheme.textSecondary,
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
    );
  }
}

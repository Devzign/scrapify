import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class ReferralEmptyState extends StatelessWidget {
  const ReferralEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.cardBorderRadius,
        border: AppTheme.cardBorder,
        boxShadow: AppTheme.cardShadow,
      ),
      child: const Column(
        children: [
          Icon(Icons.card_giftcard, size: 40, color: AppTheme.primaryColor),
          SizedBox(height: 12),
          Text(
            'No rewards yet. Invite your friends to start earning.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

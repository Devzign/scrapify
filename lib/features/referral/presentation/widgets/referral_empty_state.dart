import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_card.dart';

class ReferralEmptyState extends StatelessWidget {
  const ReferralEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(Icons.card_giftcard, size: 40, color: AppTheme.primaryColor),
          const SizedBox(height: 12),
          Text(
            'No rewards yet. Invite your friends to start earning.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_card.dart';

class HowItWorksCard extends StatelessWidget {
  const HowItWorksCard({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How It Works',
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          const _StepText('1. Share your referral code with your friend.'),
          const SizedBox(height: 8),
          const _StepText('2. Your friend signs up using your referral code.'),
          const SizedBox(height: 8),
          const _StepText('3. You get a reward coupon after successful referral.'),
        ],
      ),
    );
  }
}

class _StepText extends StatelessWidget {
  final String text;
  const _StepText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        color: AppTheme.textSecondary,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

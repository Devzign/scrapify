import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_card.dart';
import '../../data/models/referral_reward_model.dart';

class RewardCouponCard extends StatelessWidget {
  final ReferralRewardModel reward;

  const RewardCouponCard({super.key, required this.reward});

  @override
  Widget build(BuildContext context) {
    final status = reward.status.toLowerCase();
    final isActive = status == 'active';
    final statusColor = isActive
        ? AppTheme.primaryColor
        : (status == 'used' ? Colors.orange : Colors.redAccent);

    final textTheme = Theme.of(context).textTheme;
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  reward.couponCode,
                  style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  reward.status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Reward: ${_rewardLabel()}',
            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text(
            'Expiry: ${_formatDate(reward.expiryDate)}',
            style: textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Use this coupon during scrap booking to get extra value.',
            style: textTheme.labelMedium?.copyWith(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _rewardLabel() {
    if (reward.couponType == 'percentage') {
      return '${reward.couponValue.toStringAsFixed(0)}%';
    }
    return '₹${reward.couponValue.toStringAsFixed(0)}';
  }

  String _formatDate(String value) {
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return value;
    return DateFormat('dd MMM yyyy').format(parsed);
  }
}

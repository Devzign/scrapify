import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/models/pickup_request_model.dart';

class PickupPriceSummary extends StatelessWidget {
  final PickupRequestModel pickup;
  final EdgeInsets padding;

  const PickupPriceSummary({
    super.key,
    required this.pickup,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    final estimated = pickup.estimatedAmount ?? 0;
    final hasFinal = pickup.finalAmount != null && pickup.finalAmount! > 0;
    final finalAmt = pickup.finalAmount ?? estimated;
    final differs = hasFinal && (estimated - finalAmt).abs() > 0.01;
    final hasCoupon = pickup.hasCoupon;
    final discount = pickup.couponDiscountValue ?? 0;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppTheme.backgroundCream,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Pricing',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textSecondary,
                  letterSpacing: 1.1,
                ),
              ),
              if (pickup.isPriceLocked) _LockedBadge(at: pickup.priceLockedAt!),
            ],
          ),
          const SizedBox(height: 12),

          // Estimated row
          _row(
            label: 'Estimated',
            value: '₹${estimated.toStringAsFixed(0)}',
            valueStyle: TextStyle(
              fontSize: 14,
              color: differs ? AppTheme.textMuted : AppTheme.textPrimary,
              decoration: differs ? TextDecoration.lineThrough : null,
              fontWeight: FontWeight.w600,
            ),
          ),

          // Coupon row
          if (hasCoupon) ...[
            const SizedBox(height: 6),
            _row(
              label: 'Coupon ${pickup.couponCode ?? ''}',
              labelStyle: const TextStyle(
                fontSize: 13,
                color: AppTheme.successColor,
                fontWeight: FontWeight.w600,
              ),
              value: '+₹${discount.toStringAsFixed(0)}',
              valueStyle: const TextStyle(
                fontSize: 14,
                color: AppTheme.successColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],

          if (hasFinal) ...[
            const Divider(height: 20),
            _row(
              label: 'Final Payout',
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
              value: '₹${finalAmt.toStringAsFixed(0)}',
              valueStyle: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppTheme.successColor,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _row({
    required String label,
    required String value,
    TextStyle? labelStyle,
    TextStyle? valueStyle,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: labelStyle ??
              const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
        ),
        Text(value, style: valueStyle),
      ],
    );
  }
}

class _LockedBadge extends StatelessWidget {
  final DateTime at;
  const _LockedBadge({required this.at});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.hairline,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.lock_outline, size: 12, color: AppTheme.textSecondary),
          const SizedBox(width: 4),
          Text(
            'Locked',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

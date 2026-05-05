import 'package:flutter/material.dart';
import '../../domain/models/pickup_request_model.dart';

/// Reusable pricing summary card for an order detail / history screen.
/// Renders:
///   - Estimated amount (struck through if final differs)
///   - Coupon line (if applied)
///   - Final amount (highlighted)
///   - 🔒 Price-locked badge (after pickup verified)
///
/// Drop into customer / pickup-boy / warehouse order detail screens.
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
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
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
                  color: Color(0xFF64748B),
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
              color: differs ? const Color(0xFF94A3B8) : const Color(0xFF1E293B),
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
                color: Color(0xFF16A34A),
                fontWeight: FontWeight.w600,
              ),
              value: '+₹${discount.toStringAsFixed(0)}',
              valueStyle: const TextStyle(
                fontSize: 14,
                color: Color(0xFF16A34A),
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
                color: Color(0xFF0F172A),
              ),
              value: '₹${finalAmt.toStringAsFixed(0)}',
              valueStyle: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Color(0xFF059669),
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
                color: Color(0xFF64748B),
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
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.lock_outline, size: 12, color: Color(0xFF475569)),
          const SizedBox(width: 4),
          Text(
            'Locked',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }
}

/// Maps backend error keys (`message` field) to user-facing strings.
class ApiErrorMessages {
  const ApiErrorMessages._();

  static const Map<String, String> _map = {
    // Referral
    'referral.campaign_inactive': 'Referral campaign not active right now.',
    'referral.invalid_code': 'Invalid referral code.',
    'referral.self_not_allowed': "You can't use your own code.",
    'referral.already_used': 'Referral already applied to this account.',
    'referral.cap_reached': "Referrer's quota is full.",
    'referral.customer_only': 'Only customers can use referrals.',
    'referral.valid': 'Referral code applied.',

    // Coupon
    'coupon.invalid': 'Coupon not found.',
    'coupon.not_owned': 'This coupon is not yours.',
    'coupon.already_used': 'Coupon already used.',
    'coupon.inactive': 'Coupon not active.',
    'coupon.expired': 'Coupon has expired.',
    'coupon.min_value_not_met':
        'Order amount below minimum required for this coupon.',
    'coupon.valid': 'Coupon applied.',
    'coupon.not_found': 'Coupon not found.',

    // Pickup
    'pickup.price_locked': 'Price is locked. Contact admin to edit.',
    'pickup.cannot_assign': 'Cannot assign — pickup already closed.',
    'pickup.minimum_value_not_met': 'Pickup value is below minimum threshold.',
    'pickup.not_found': 'Pickup not found.',

    // Warehouse / pickup-boy mapping
    'pickup_boy.not_mapped_to_warehouse':
        'Pickup boy not mapped to this warehouse.',
    'pickup_boy.invalid': 'Invalid pickup boy.',
    'warehouse.unauthorized': "You don't have access to this warehouse.",
    'warehouse.not_found': 'Warehouse not found.',

    // Order / Help-Support
    'order.not_found': 'Order not found.',
    'help_support.submitted': 'Ticket submitted.',

    // Auth
    'auth.invalid_otp': 'Invalid OTP. Please try again.',
    'auth.unauthorized': 'You are not authorized for this action.',
    'auth.unauthorized_role': "You don't have access for this role.",

    // Generic
    'validation.failed': 'Some fields are invalid.',
    'server.error': 'Something went wrong. Try again.',
  };

  /// Returns user-friendly message for a backend `message` key.
  /// Falls back to [fallback] if provided, else the raw key.
  static String resolve(String? key, {String? fallback}) {
    if (key == null || key.isEmpty) {
      return fallback ?? 'Something went wrong.';
    }
    return _map[key] ?? fallback ?? key;
  }

  /// Convenience for a Map response (`{message, data, status}`).
  static String fromResponse(Map<String, dynamic>? body, {String? fallback}) {
    return resolve(body?['message'] as String?, fallback: fallback);
  }
}

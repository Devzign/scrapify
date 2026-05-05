class ValidateCouponResponseModel {
  final String couponCode;
  final String couponType;
  final double couponValue;
  final double finalExtraValue;

  const ValidateCouponResponseModel({
    required this.couponCode,
    required this.couponType,
    required this.couponValue,
    required this.finalExtraValue,
  });

  factory ValidateCouponResponseModel.fromJson(Map<String, dynamic> json) {
    final coupon = (json['coupon'] as Map<String, dynamic>?) ?? json;
    final discount = _parseDouble(json['discount']);
    final extraValue = _parseDouble(json['final_extra_value']);
    return ValidateCouponResponseModel(
      couponCode: coupon['coupon_code']?.toString() ?? '',
      couponType: coupon['coupon_type']?.toString() ?? '',
      couponValue: _parseDouble(coupon['coupon_value']),
      finalExtraValue: extraValue > 0 ? extraValue : discount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'coupon_code': couponCode,
      'coupon_type': couponType,
      'coupon_value': couponValue,
      'final_extra_value': finalExtraValue,
    };
  }
}

double _parseDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

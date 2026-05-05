class ReferralRewardModel {
  final String couponCode;
  final String couponType;
  final double couponValue;
  final String expiryDate;
  final String status;

  const ReferralRewardModel({
    required this.couponCode,
    required this.couponType,
    required this.couponValue,
    required this.expiryDate,
    required this.status,
  });

  factory ReferralRewardModel.fromJson(Map<String, dynamic> json) {
    return ReferralRewardModel(
      couponCode: json['coupon_code']?.toString() ?? '',
      couponType: json['coupon_type']?.toString() ?? '',
      couponValue: _parseDouble(json['coupon_value']),
      expiryDate: json['expiry_date']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'coupon_code': couponCode,
      'coupon_type': couponType,
      'coupon_value': couponValue,
      'expiry_date': expiryDate,
      'status': status,
    };
  }
}

double _parseDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

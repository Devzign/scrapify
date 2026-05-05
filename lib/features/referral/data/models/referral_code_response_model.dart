class ReferralCodeResponseModel {
  final bool status;
  final String message;
  final ReferralCodeData data;

  const ReferralCodeResponseModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory ReferralCodeResponseModel.fromJson(Map<String, dynamic> json) {
    return ReferralCodeResponseModel(
      status: json['status'] == true || json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: ReferralCodeData.fromJson(
        (json['data'] as Map<String, dynamic>?) ?? const {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'message': message, 'data': data.toJson()};
  }
}

class ReferralCodeData {
  final String referralCode;

  const ReferralCodeData({required this.referralCode});

  factory ReferralCodeData.fromJson(Map<String, dynamic> json) {
    return ReferralCodeData(
      referralCode: json['referral_code']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'referral_code': referralCode};
  }
}

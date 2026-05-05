import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/dio_client.dart';
import '../../../auth/providers/auth_provider.dart';
import '../models/referral_code_response_model.dart';
import '../models/referral_reward_model.dart';
import '../models/validate_coupon_response_model.dart';

final referralRepositoryProvider = Provider<ReferralRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ReferralRepository(dioClient);
});

class ReferralRepository {
  final DioClient _dioClient;

  ReferralRepository(this._dioClient);

  Future<ApiResponse<String>> validateReferralCode({
    required String referralCode,
  }) {
    return _dioClient.post<String>(
      ApiEndpoints.referralValidateCode,
      data: {'referral_code': referralCode},
      parser: (json) {
        final map = json as Map<String, dynamic>;
        final data = (map['data'] as Map<String, dynamic>?) ?? const {};
        return data['referrer_name']?.toString() ?? '';
      },
    );
  }

  Future<ApiResponse<ReferralCodeResponseModel>> getMyReferralCode() {
    return _dioClient.get<ReferralCodeResponseModel>(
      ApiEndpoints.referralMyCode,
      parser: (json) =>
          ReferralCodeResponseModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<List<ReferralRewardModel>>> getMyRewards() {
    return _dioClient.get<List<ReferralRewardModel>>(
      ApiEndpoints.referralMyRewards,
      parser: (json) {
        final map = json as Map<String, dynamic>;
        final rawData = map['data'];
        final list = rawData is List<dynamic>
            ? rawData
            : (rawData is Map<String, dynamic>
                  ? rawData['data'] as List<dynamic>? ?? const []
                  : const []);
        return list
            .whereType<Map>()
            .map(
              (item) =>
                  ReferralRewardModel.fromJson(Map<String, dynamic>.from(item)),
            )
            .toList();
      },
    );
  }

  Future<ApiResponse<ValidateCouponResponseModel>> validateCoupon({
    required String couponCode,
    required double bookingAmount,
  }) {
    return _dioClient.post<ValidateCouponResponseModel>(
      ApiEndpoints.referralValidateCoupon,
      data: {'coupon_code': couponCode, 'booking_amount': bookingAmount},
      parser: (json) {
        final map = json as Map<String, dynamic>;
        return ValidateCouponResponseModel.fromJson(
          (map['data'] as Map<String, dynamic>?) ?? const {},
        );
      },
    );
  }
}

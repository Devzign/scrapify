import 'package:flutter_riverpod/legacy.dart';

import '../data/models/validate_coupon_response_model.dart';
import '../data/repositories/referral_repository.dart';
import 'referral_state.dart';

class ReferralNotifier extends StateNotifier<ReferralState> {
  final ReferralRepository _repository;

  ReferralNotifier(this._repository) : super(const ReferralState());

  Future<void> loadReferralData() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final codeRes = await _repository.getMyReferralCode();
    final rewardsRes = await _repository.getMyRewards();

    if (!codeRes.isSuccess) {
      state = state.copyWith(
        isLoading: false,
        error: codeRes.errorMessage ?? 'Failed to fetch referral code',
      );
      return;
    }

    if (!rewardsRes.isSuccess) {
      state = state.copyWith(
        isLoading: false,
        referralCode: codeRes.data?.data.referralCode ?? '',
        error: rewardsRes.errorMessage ?? 'Failed to fetch rewards',
      );
      return;
    }

    state = state.copyWith(
      isLoading: false,
      referralCode: codeRes.data?.data.referralCode ?? '',
      rewards: rewardsRes.data ?? const [],
      clearError: true,
    );
  }

  Future<ValidateCouponResponseModel?> validateCoupon({
    required String couponCode,
    required double bookingAmount,
  }) async {
    state = state.copyWith(isCouponValidating: true, clearError: true);
    final result = await _repository.validateCoupon(
      couponCode: couponCode,
      bookingAmount: bookingAmount,
    );
    state = state.copyWith(isCouponValidating: false);

    if (!result.isSuccess) {
      state = state.copyWith(
        error: result.errorMessage ?? 'Unable to validate coupon',
      );
      return null;
    }

    return result.data;
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

final referralProvider = StateNotifierProvider<ReferralNotifier, ReferralState>(
  (ref) {
    final repo = ref.watch(referralRepositoryProvider);
    return ReferralNotifier(repo);
  },
);

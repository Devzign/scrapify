import '../data/models/referral_reward_model.dart';

class ReferralState {
  final bool isLoading;
  final bool isCouponValidating;
  final String referralCode;
  final List<ReferralRewardModel> rewards;
  final String? error;

  const ReferralState({
    this.isLoading = false,
    this.isCouponValidating = false,
    this.referralCode = '',
    this.rewards = const [],
    this.error,
  });

  ReferralState copyWith({
    bool? isLoading,
    bool? isCouponValidating,
    String? referralCode,
    List<ReferralRewardModel>? rewards,
    String? error,
    bool clearError = false,
  }) {
    return ReferralState(
      isLoading: isLoading ?? this.isLoading,
      isCouponValidating: isCouponValidating ?? this.isCouponValidating,
      referralCode: referralCode ?? this.referralCode,
      rewards: rewards ?? this.rewards,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/user_role_helper.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../providers/referral_provider.dart';
import '../widgets/how_it_works_card.dart';
import '../widgets/referral_code_card.dart';
import '../widgets/referral_empty_state.dart';
import '../widgets/reward_coupon_card.dart';

class ReferAndEarnScreen extends ConsumerStatefulWidget {
  const ReferAndEarnScreen({super.key});

  @override
  ConsumerState<ReferAndEarnScreen> createState() => _ReferAndEarnScreenState();
}

class _ReferAndEarnScreenState extends ConsumerState<ReferAndEarnScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(referralProvider.notifier).loadReferralData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final referralState = ref.watch(referralProvider);
    final user = ref.watch(authProvider);
    final isCustomer = isCustomerUser(user);

    if (!isCustomer) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Refer & Earn'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(
          child: Text('This feature is only available for customers.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Refer & Earn',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(referralProvider.notifier).loadReferralData(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            const Text(
              'Invite your friends and earn rewards',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            if (referralState.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: CircularProgressIndicator(
                    color: AppTheme.primaryColor,
                  ),
                ),
              )
            else ...[
              ReferralCodeCard(
                referralCode: referralState.referralCode,
                onCopy: _copyCode,
                onShare: _shareCode,
              ),
              const SizedBox(height: 16),
              const HowItWorksCard(),
              const SizedBox(height: 16),
              const Text(
                'My Rewards / Coupons',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              if (referralState.rewards.isEmpty)
                const ReferralEmptyState()
              else
                ...referralState.rewards.map(
                  (reward) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: RewardCouponCard(reward: reward),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  void _copyCode() {
    final code = ref.read(referralProvider).referralCode.trim();
    if (code.isEmpty) return;
    Clipboard.setData(ClipboardData(text: code));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Referral code copied')));
  }

  void _shareCode() {
    final code = ref.read(referralProvider).referralCode.trim();
    if (code.isEmpty) return;
    SharePlus.instance.share(
      ShareParams(
        text:
            'Join our app using my referral code $code and earn rewards on scrap booking.',
      ),
    );
  }
}

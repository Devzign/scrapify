import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/user_role_helper.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/app_section_header.dart';
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
      return AppScaffold(
        appBar: AppBar(
          title: Text('refer.title'.tr()),
          leading: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColor.primarySurface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColor.primary.withValues(alpha: 0.20)),
              ),
              child: const Icon(Icons.arrow_back_rounded, color: AppColor.primary, size: 18),
            ),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
          child: Text('refer.customer_only'.tr()),
        ),
      );
    }

    return AppScaffold(
      backgroundColor: AppColor.backgroundLight,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A5C35),
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1A5C35), AppColor.primary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.30)),
            ),
            child: const Icon(Icons.arrow_back_rounded,
                color: Colors.white, size: 18),
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'refer.title',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 18,
            letterSpacing: -0.2,
          ),
        ).tr(),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(referralProvider.notifier).loadReferralData(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            AppSectionHeader(
              title: 'refer.title'.tr(),
              subtitle: 'refer.subtitle'.tr(),
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
              Text(
                'refer.my_rewards'.tr(),
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
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
    ).showSnackBar(SnackBar(content: Text('refer.code_copied'.tr())));
  }

  void _shareCode() {
    final code = ref.read(referralProvider).referralCode.trim();
    if (code.isEmpty) return;
    SharePlus.instance.share(
      ShareParams(
        text:
            '${'refer.share_text'.tr()} $code',
      ),
    );
  }
}

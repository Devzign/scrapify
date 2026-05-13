import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_config.dart';
import '../../../core/theme/app_color.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/utils/app_routes.dart';
import '../../../core/utils/user_role_helper.dart';
import '../../auth/providers/auth_provider.dart';

class UserProfileScreen extends ConsumerStatefulWidget {
  final bool showAppBar;

  const UserProfileScreen({super.key, this.showAppBar = true});

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(authProvider.notifier).fetchProfile());
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.locale;
    final user = ref.watch(authProvider);
    final isCustomer = isCustomerUser(user);
    final profilePhoto = user?.profilePhoto?.trim();
    final hasRemotePhoto = profilePhoto != null && profilePhoto.isNotEmpty;
    final remotePhotoUrl = hasRemotePhoto
        ? (profilePhoto.startsWith('http')
              ? profilePhoto
              : '${AppConfig.instance.baseUrl.replaceAll('/api', '')}/$profilePhoto')
        : null;

    return AppScaffold(
      key: ValueKey('profile_${locale.languageCode}'),
      backgroundColor: AppColor.backgroundLight,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: AppBar(
          backgroundColor: const Color(0xFF1A5C35),
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // ── Green gradient header ──────────────────────────────────
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1A5C35), AppColor.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                  child: Column(
                    children: [
                      // Back button row
                      if (widget.showAppBar)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: GestureDetector(
                            onTap: () => context.pop(),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.16),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.30),
                                ),
                              ),
                              child: const Icon(
                                Icons.arrow_back_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 12),
                      // Avatar with Edit Button
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.20),
                              border: Border.all(color: Colors.white, width: 3),
                              image: DecorationImage(
                                image: remotePhotoUrl != null
                                    ? NetworkImage(remotePhotoUrl)
                                    : const AssetImage(
                                        'assets/images/user-profile.png',
                                      ) as ImageProvider,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.push(AppRoutes.editProfile),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 2, right: 2),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.15),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.edit,
                                color: AppColor.primary,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        user?.name ?? 'Loading...',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.phone ?? '+91 ...',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.80),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.30),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.verified,
                              color: Colors.white,
                              size: 15,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'profile.verified_user'.tr(),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Settings List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('profile.account_settings'.tr()),
                  _buildSettingsTile(
                    icon: Icons.location_on,
                    title: 'profile.addresses'.tr(),
                    subtitle: 'profile.addresses_desc'.tr(),
                    onTap: () => context.push(AppRoutes.savedAddresses),
                  ),
                  const SizedBox(height: 12),
                  _buildSettingsTile(
                    icon: Icons.account_balance,
                    title: 'profile.bank_details'.tr(),
                    subtitle: 'profile.bank_details_desc'.tr(),
                    onTap: () => context.push(AppRoutes.paymentMethods),
                  ),
                  const SizedBox(height: 12),
                  _buildSettingsTile(
                    icon: Icons.translate,
                    title: 'profile.language'.tr(),
                    subtitle: 'profile.language_desc'.tr(),
                    onTap: () => context.push(AppRoutes.settings),
                  ),
                  if (isCustomer) ...[
                    const SizedBox(height: 12),
                    _buildSettingsTile(
                      icon: Icons.card_giftcard,
                      title: 'profile.refer_earn'.tr(),
                      subtitle: 'profile.refer_earn_desc'.tr(),
                      onTap: () => context.push(AppRoutes.referAndEarn),
                    ),
                  ],

                  const SizedBox(height: 24),
                  _buildSectionHeader('profile.support_other'.tr()),
                  _buildSettingsTile(
                    icon: Icons.support_agent,
                    title: 'profile.help_support'.tr(),
                    subtitle: 'profile.faq_desc'.tr(),
                    onTap: () => context.push(AppRoutes.faq),
                  ),
                  const SizedBox(height: 12),
                  _buildSettingsTile(
                    icon: Icons.contact_support_outlined,
                    title: 'profile.need_help'.tr(),
                    subtitle: 'profile.need_help_desc'.tr(),
                    onTap: () => context.push(AppRoutes.helpSupport),
                  ),
                  const SizedBox(height: 24),

                  // Logout Button
                  InkWell(
                    onTap: () async {
                      await ref.read(authProvider.notifier).logout();
                      if (context.mounted) context.go(AppRoutes.login);
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.red.shade100),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.logout,
                              color: Colors.red,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'profile.logout'.tr(),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      '${'profile.app_version'.tr()} 1.0.2',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.5,
          color: AppTheme.textSecondary,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColor.cardBorder, width: 1.2),
            boxShadow: AppTheme.e1,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: AppColor.primarySurface,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: AppColor.primary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: AppColor.deepNavy,
                        letterSpacing: -0.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColor.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColor.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

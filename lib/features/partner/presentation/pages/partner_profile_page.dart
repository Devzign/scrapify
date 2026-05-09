import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_routes.dart';
import '../../../../features/auth/providers/auth_provider.dart';
import '../../../../features/channel_partner/providers/channel_partner_provider.dart';
import '../partner_locale.dart';
import 'partner_approvals_page.dart';

class PartnerProfilePage extends ConsumerStatefulWidget {
  const PartnerProfilePage({super.key});

  @override
  ConsumerState<PartnerProfilePage> createState() => _PartnerProfilePageState();
}

class _PartnerProfilePageState extends ConsumerState<PartnerProfilePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final notifier = ref.read(channelPartnerProvider.notifier);
      notifier.loadDashboard();
      notifier.loadApprovalRequests(status: 'pending');
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    final partnerState = ref.watch(channelPartnerProvider);
    final dashboard = partnerState.dashboard;
    final pendingApprovals = partnerState.approvalRequests
        .whereType<Map<String, dynamic>>()
        .where(
          (request) =>
              (request['status']?.toString() ?? '').toLowerCase() == 'pending',
        )
        .length;
    final initials = (user?.name.trim().isNotEmpty ?? false)
        ? user!.name
              .trim()
              .split(' ')
              .map((part) => part[0])
              .take(2)
              .join()
              .toUpperCase()
        : 'CP';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await ref.read(channelPartnerProvider.notifier).loadDashboard();
            await ref
                .read(channelPartnerProvider.notifier)
                .loadApprovalRequests(status: 'pending');
            await ref.read(authProvider.notifier).fetchProfile();
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: AppTheme.primaryColor.withValues(
                      alpha: 0.15,
                    ),
                    child: Text(
                      initials,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.partnerText(
                            'Partner Profile',
                            'पार्टनर प्रोफ़ाइल',
                          ),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          user?.name ??
                              context.partnerText(
                                'Channel Partner',
                                'चैनल पार्टनर',
                              ),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppTheme.cardBorderRadius,
                  border: AppTheme.cardBorder,
                  boxShadow: AppTheme.cardShadow,
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 42,
                      backgroundColor: AppTheme.primaryColor.withValues(
                        alpha: 0.12,
                      ),
                      child: Text(
                        initials,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user?.name ??
                          context.partnerText(
                            'Channel Partner',
                            'चैनल पार्टनर',
                          ),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      user?.phone ?? '',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    if ((user?.email ?? '').isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        user!.email!,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primarySurface,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        context.partnerText(
                          'Verified Partner',
                          'सत्यापित पार्टनर',
                        ),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: AppTheme.primaryDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      context.partnerText('Orders', 'ऑर्डर्स'),
                      '${dashboard?.totalOrders ?? 0}',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      context.partnerText('Warehouses', 'गोदाम'),
                      '${dashboard?.activeWarehouses ?? 0}',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      context.partnerText('Pickup Boys', 'पिकअप बॉय'),
                      '${dashboard?.totalPickupBoys ?? 0}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildActionTile(
                icon: Icons.fact_check_rounded,
                title: context.partnerText(
                  'Approval Requests',
                  'अनुमोदन अनुरोध',
                ),
                subtitle: context.partnerText(
                  '$pendingApprovals pending requests need review',
                  '$pendingApprovals लंबित अनुरोध समीक्षा के लिए हैं',
                ),
                trailingText: pendingApprovals.toString(),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const PartnerApprovalsPage(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildActionTile(
                icon: Icons.language_rounded,
                title: context.partnerText('Language', 'भाषा'),
                subtitle: context.partnerText(
                  context.isHindi ? 'Hindi selected' : 'English selected',
                  context.isHindi
                      ? 'हिन्दी चुनी गई है'
                      : 'अंग्रेज़ी चुनी गई है',
                ),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        context.partnerText(
                          'Change language from the main app language settings.',
                          'भाषा बदलने के लिए मुख्य ऐप भाषा सेटिंग्स का उपयोग करें।',
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildActionTile(
                icon: Icons.support_agent_rounded,
                title: context.partnerText('Help & Support', 'मदद और सहायता'),
                subtitle: context.partnerText(
                  'Reach Scrapify support for partner issues',
                  'पार्टनर सहायता के लिए स्क्रैपिफाई टीम से संपर्क करें',
                ),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        context.partnerText(
                          'Support flow will be connected here.',
                          'सपोर्ट फ़्लो यहां जोड़ा जाएगा।',
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildActionTile(
                icon: Icons.logout_rounded,
                title: context.partnerText('Logout', 'लॉगआउट'),
                subtitle: context.partnerText(
                  'Sign out of the channel partner account',
                  'चैनल पार्टनर खाते से बाहर निकलें',
                ),
                destructive: true,
                onTap: () async {
                  final router = GoRouter.of(context);
                  await ref.read(authProvider.notifier).logout();
                  if (!mounted) return;
                  router.go(AppRoutes.role);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.cardBorderRadius,
        border: AppTheme.cardBorder,
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    String? trailingText,
    bool destructive = false,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppTheme.cardBorderRadius,
          border: AppTheme.cardBorder,
          boxShadow: AppTheme.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: (destructive ? Colors.red : AppTheme.primaryColor)
                    .withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: destructive ? Colors.red : AppTheme.primaryColor,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: destructive ? Colors.red : AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            if (trailingText != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  trailingText,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryColor,
                  ),
                ),
              )
            else
              Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}

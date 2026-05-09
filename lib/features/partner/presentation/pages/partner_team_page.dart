import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../features/auth/providers/auth_provider.dart';
import '../../../../features/channel_partner/providers/channel_partner_provider.dart';
import '../partner_locale.dart';

class PartnerTeamPage extends ConsumerStatefulWidget {
  const PartnerTeamPage({super.key});

  @override
  ConsumerState<PartnerTeamPage> createState() => _PartnerTeamPageState();
}

class _PartnerTeamPageState extends ConsumerState<PartnerTeamPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(channelPartnerProvider.notifier).loadPickupBoys(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(channelPartnerProvider);
    final user = ref.watch(authProvider);
    final boys = state.pickupBoys.whereType<Map<String, dynamic>>().toList();
    final d = state.dashboard;
    final onlineCount = boys.where((b) => b['is_online'] == true).length;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(user?.name),
            Expanded(
              child: state.isLoading && boys.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: () => ref
                          .read(channelPartnerProvider.notifier)
                          .loadPickupBoys(),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 80),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (state.error != null)
                              Container(
                                margin: const EdgeInsets.all(16),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColor.hintPeach,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppColor.warning.withValues(alpha: 0.30),
                                  ),
                                ),
                                child: Text(
                                  state.error!,
                                  style: TextStyle(
                                    color: AppColor.warning,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            _buildHeader(
                              boys.length,
                              onlineCount,
                              d?.totalPickupBoys,
                            ),
                            _buildAgentCards(boys),
                            _buildTeamEfficiency(d),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(String? name) {
    final initial = (name?.trim().isNotEmpty ?? false)
        ? name!.trim()[0].toUpperCase()
        : 'P';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColor.hairline)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.12),
                child: Text(
                  initial,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                name ?? 'Partner',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColor.backgroundCream,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_none_rounded,
              color: AppColor.textSecondary,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(int listCount, int onlineCount, int? totalFromDashboard) {
    final total = totalFromDashboard ?? listCount;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        context.partnerText('Team Management', 'टीम प्रबंधन'),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  context.partnerText(
                    'Monitoring $total field agents across your network.',
                    'आपके नेटवर्क के $total फील्ड एजेंट्स की निगरानी।',
                  ),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColor.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(12),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppTheme.cardBorderRadius,
              border: Border.all(color: AppColor.hairline),
              boxShadow: AppTheme.cardShadow,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.partnerText('ONLINE NOW', 'अभी ऑनलाइन'),
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: AppColor.textMuted,
                        letterSpacing: 1,
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(),
                        children: [
                          TextSpan(
                            text: '$onlineCount ',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          TextSpan(
                            text: '/ $total',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColor.outline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgentCards(List<Map<String, dynamic>> boys) {
    if (boys.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
        child: Center(
          child: Text(
            context.partnerText(
              'No team members found',
              'कोई टीम सदस्य नहीं मिला',
            ),
            style: TextStyle(color: AppColor.textMuted, fontSize: 15),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(children: boys.map((b) => _buildAgentCard(b)).toList()),
    );
  }

  Widget _buildAgentCard(Map<String, dynamic> b) {
    final name = b['name']?.toString() ?? 'Agent';
    final phone = b['phone']?.toString() ?? '';
    final isOnline = b['is_online'] == true;
    final isAvailable = b['is_available'] == true;
    final isInactive = b['is_active'] == false;
    final warehouseName =
        b['warehouse_name']?.toString() ??
        (b['warehouse'] as Map?)?['name']?.toString() ??
        '—';
    final currentCount = b['current_assignment_count'] ?? 0;
    final completedCount = b['completed_count'] ?? 0;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    final statusLabel = isInactive
        ? 'Inactive'
        : !isOnline
        ? 'Offline'
        : isAvailable
        ? 'Online'
        : 'Busy';
    final statusBg = isInactive
        ? AppColor.errorTint
        : !isOnline
        ? AppTheme.hairline
        : isAvailable
        ? AppTheme.primarySurface
        : AppColor.hintPeach;
    final statusFg = isInactive
        ? AppColor.error
        : !isOnline
        ? AppTheme.textSecondary
        : isAvailable
        ? AppTheme.primaryColor
        : AppColor.warning;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.cardBorderRadius,
        border: AppTheme.cardBorder,
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: isOnline
                          ? AppTheme.primaryLight.withValues(alpha: 0.3)
                          : AppColor.hairline,
                      child: Text(
                        initial,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: isOnline
                              ? AppTheme.primaryDark
                              : AppColor.textSecondary,
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusBg,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            localizedPartnerStatus(context, statusLabel),
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: statusFg,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          localizedPartnerStatus(context, statusLabel),
                          style: TextStyle(
                            fontSize: 9,
                            color: AppColor.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: isInactive
                        ? AppColor.textMuted
                        : AppTheme.textPrimary,
                  ),
                ),
                Text(
                  'ID: ${b['id']}',
                  style: TextStyle(fontSize: 12, color: AppColor.textSecondary),
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  icon: Icons.warehouse_rounded,
                  iconColor: AppColor.textMuted,
                  label: context.partnerText('Warehouse', 'गोदाम'),
                  value: warehouseName,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoRow(
                        icon: Icons.local_shipping_rounded,
                        iconColor: AppColor.textMuted,
                        label: context.partnerText('Active', 'सक्रिय'),
                        value: '$currentCount',
                      ),
                    ),
                    Expanded(
                      child: _buildInfoRow(
                        icon: Icons.task_alt_rounded,
                        iconColor: AppColor.textMuted,
                        label: context.partnerText('Completed', 'पूरा हुआ'),
                        value: '$completedCount',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: AppColor.backgroundCream,
              border: Border(top: BorderSide(color: AppColor.backgroundCream)),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: phone.isNotEmpty
                  ? MainAxisAlignment.spaceBetween
                  : MainAxisAlignment.end,
              children: [
                if (phone.isNotEmpty)
                  GestureDetector(
                    onTap: () async {
                      final uri = Uri.parse('tel:$phone');
                      if (await canLaunchUrl(uri)) launchUrl(uri);
                    },
                    child: Row(
                      children: [
                        Icon(Icons.call, size: 14, color: AppColor.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          context.partnerText('Call', 'कॉल'),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColor.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                Row(
                  children: [
                    Text(
                      context.partnerText('View History', 'इतिहास देखें'),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right,
                      size: 14,
                      color: AppTheme.primaryColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.backgroundCream,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 18),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: AppColor.textMuted,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: valueColor ?? AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTeamEfficiency(channelDashboard) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppTheme.cardBorderRadius,
              boxShadow: AppTheme.cardShadow,
              border: Border.all(color: AppColor.hairline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.partnerText('Team Overview', 'टीम अवलोकन'),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.partnerText(
                    'Live field agent status across your network.',
                    'आपके नेटवर्क के फील्ड एजेंट्स की लाइव स्थिति।',
                  ),
                  style: TextStyle(fontSize: 13, color: AppColor.textSecondary),
                ),
                const SizedBox(height: 20),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.6,
                  children: [
                    _buildEfficiencyChip(
                      context.partnerText('Total Boys', 'कुल बॉय'),
                      '${channelDashboard?.totalPickupBoys ?? 0}',
                    ),
                    _buildEfficiencyChip(
                      context.partnerText('Active', 'सक्रिय'),
                      '${channelDashboard?.activePickupBoys ?? 0}',
                    ),
                    _buildEfficiencyChip(
                      context.partnerText('Available', 'उपलब्ध'),
                      '${channelDashboard?.availablePickupBoys ?? 0}',
                    ),
                    _buildEfficiencyChip(
                      context.partnerText('Pending KYC', 'लंबित केवाईसी'),
                      '${channelDashboard?.pendingPickupBoyApprovals ?? 0}',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -16,
                  top: -16,
                  child: Opacity(
                    opacity: 0.2,
                    child: Transform.rotate(
                      angle: 0.2,
                      child: const Icon(
                        Icons.group_add_rounded,
                        color: Colors.white,
                        size: 80,
                      ),
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.partnerText(
                        'Scale Your Force',
                        'अपनी टीम बढ़ाएं',
                      ),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.partnerText(
                        'Onboard new agents for your network instantly.',
                        'अपने नेटवर्क के लिए नए एजेंट तुरंत जोड़ें।',
                      ),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.backgroundLight,
                          foregroundColor: AppTheme.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 4,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              context.partnerText(
                                'Start Recruitment',
                                'भर्ती शुरू करें',
                              ),
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(Icons.arrow_forward, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildEfficiencyChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.backgroundCream,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: AppColor.textMuted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

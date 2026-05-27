import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/utils/app_routes.dart';
import '../../../../core/widgets/dashboard_stat_card.dart';
import '../../../../core/widgets/metric_grid.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../features/auth/providers/auth_provider.dart';
import '../../../../features/channel_partner/domain/models/channel_partner_dashboard.dart';
import '../../../../features/channel_partner/providers/channel_partner_provider.dart';

class PartnerDashboardPage extends ConsumerStatefulWidget {
  const PartnerDashboardPage({super.key});

  @override
  ConsumerState<PartnerDashboardPage> createState() =>
      _PartnerDashboardPageState();
}

class _PartnerDashboardPageState extends ConsumerState<PartnerDashboardPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(channelPartnerProvider.notifier).loadDashboard(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(channelPartnerProvider);
    final user = ref.watch(authProvider);
    final d = state.dashboard;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildModernAppBar(user?.name, user?.id),
            Expanded(
              child: state.isLoading && d == null
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: () => ref
                          .read(channelPartnerProvider.notifier)
                          .loadDashboard(),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (state.error != null)
                              _buildErrorBanner(state.error!),
                            _buildModernHeader(user?.name),
                            _buildModernMetrics(d),
                            _buildQuickActionsSection(context),
                            if (d != null) _buildPerformanceSection(d),
                            if (d != null && (d.recentOrders.isNotEmpty))
                              _buildRecentActivitySection(d),
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

  /// Modern gradient app bar
  Widget _buildModernAppBar(String? name, dynamic id) {
    final initial = (name?.trim().isNotEmpty ?? false)
        ? name!.trim()[0].toUpperCase()
        : 'P';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColor.primary, AppColor.primaryDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppTheme.space16,
            AppTheme.space12,
            AppTheme.space16,
            AppTheme.space16,
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.35),
                  ),
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name ?? 'Partner',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'partner_dashboard.business_overview'.tr(),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => context.push(AppRoutes.notifications),
                child: Container(
                  padding: const EdgeInsets.all(AppTheme.space8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Icon(
                    Icons.notifications_none_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.space8),
              GestureDetector(
                onTap: () => context.push(AppRoutes.partnerProfile),
                child: Container(
                  padding: const EdgeInsets.all(AppTheme.space8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Icon(
                    Icons.person_outline_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Error banner
  Widget _buildErrorBanner(String error) {
    return Container(
      margin: const EdgeInsets.all(AppTheme.space16),
      padding: const EdgeInsets.all(AppTheme.space12),
      decoration: BoxDecoration(
        color: AppColor.hintPeach,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
          color: AppColor.warning.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_rounded,
            color: AppColor.warning,
            size: 18,
          ),
          const SizedBox(width: AppTheme.space12),
          Expanded(
            child: Text(
              error,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColor.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Header section
  Widget _buildModernHeader(String? name) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.space16,
        AppTheme.space20,
        AppTheme.space16,
        AppTheme.space12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'partner_dashboard.title'.tr(),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: AppColor.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'partner_dashboard.business_overview'.tr(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColor.primary,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  /// Modern metrics grid
  Widget _buildModernMetrics(ChannelPartnerDashboard? d) {
    final metrics = [
      DashboardStatCard(
        label: 'partner_dashboard.total_pickups'.tr(),
        value: '${d?.totalPickups ?? 0}',
        icon: Icons.local_shipping_rounded,
        iconColor: AppColor.primary,
        backgroundColor: AppColor.surface,
      ),
      DashboardStatCard(
        label: 'partner_dashboard.pending_requests'.tr(),
        value: '${d?.pendingPickups ?? 0}',
        icon: Icons.schedule_rounded,
        iconColor: AppColor.warning,
        valueColor: AppColor.warning,
        backgroundColor: AppColor.surface,
      ),
      DashboardStatCard(
        label: 'partner_dashboard.completed_jobs'.tr(),
        value: '${d?.completedPickups ?? 0}',
        icon: Icons.check_circle_rounded,
        iconColor: AppColor.success,
        valueColor: AppColor.success,
        backgroundColor: AppColor.surface,
      ),
      DashboardStatCard(
        label: 'partner_dashboard.total_earnings'.tr(),
        value: '₹${_formatCurrency(0)}',
        icon: Icons.trending_up_rounded,
        iconColor: AppColor.info,
        valueColor: AppColor.info,
        backgroundColor: AppColor.surface,
      ),
    ];

    return MetricGrid(
      metrics: metrics,
      columns: 2,
      spacing: AppTheme.space12,
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.space12,
        vertical: AppTheme.space12,
      ),
    );
  }

  /// Quick actions section
  Widget _buildQuickActionsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.space16,
        vertical: AppTheme.space16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'partner_dashboard.quick_actions'.tr(),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColor.textPrimary,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: AppTheme.space12),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.assignment_rounded,
                  label: 'View Pickups',
                  color: AppColor.primary,
                  onTap: () => context.push(AppRoutes.partnerOperations),
                ),
              ),
              const SizedBox(width: AppTheme.space12),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.group_rounded,
                  label: 'Customers',
                  color: AppColor.info,
                  onTap: () => context.push(AppRoutes.partnerCustomers),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Action button
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.space12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: AppTheme.space8),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
                letterSpacing: 0.2,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  /// Performance section
  Widget _buildPerformanceSection(ChannelPartnerDashboard d) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.space16,
        vertical: AppTheme.space16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'partner_dashboard.performance'.tr(),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColor.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: AppTheme.space12),
          Container(
            padding: const EdgeInsets.all(AppTheme.space16),
            decoration: BoxDecoration(
              color: AppColor.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              border: Border.all(color: AppColor.cardBorder),
              boxShadow: AppTheme.e1,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Completion Rate',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColor.textPrimary,
                      ),
                    ),
                    Text(
                      '${_calculateCompletionRate(d)}%',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColor.success,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.space12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  child: LinearProgressIndicator(
                    value: _calculateCompletionRate(d) / 100,
                    minHeight: 8,
                    backgroundColor: AppColor.primaryLight.withValues(alpha: 0.5),
                    valueColor: AlwaysStoppedAnimation(AppColor.success),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Recent activity section
  Widget _buildRecentActivitySection(ChannelPartnerDashboard d) {
    final orders = d.recentOrders;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.space16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'partner_dashboard.recent_activity'.tr(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColor.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                GestureDetector(
                  onTap: () => context.push(AppRoutes.partnerOperations),
                  child: Text(
                    'partner_dashboard.view_all_activity'.tr(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColor.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.space12),
          if (orders.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppTheme.space32),
              child: EmptyStateWidget(
                icon: FontAwesomeIcons.history,
                title: 'partner_dashboard.no_activity'.tr(),
                subtitle: 'partner_dashboard.no_activity_subtitle'.tr(),
              ),
            )
          else
            Column(
              children: orders.take(5).map((order) {
                return _buildActivityTile(order);
              }).toList(),
            ),
        ],
      ),
    );
  }

  /// Activity tile
  Widget _buildActivityTile(dynamic order) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.space16,
        vertical: AppTheme.space8,
      ),
      padding: const EdgeInsets.all(AppTheme.space12),
      decoration: BoxDecoration(
        color: AppColor.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppColor.cardBorder, width: 0.5),
        boxShadow: AppTheme.e1,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColor.primaryLight,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Icon(
              Icons.local_shipping_rounded,
              color: AppColor.primary,
              size: 18,
            ),
          ),
          const SizedBox(width: AppTheme.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.id ?? 'Order',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColor.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  order.status ?? 'Pending',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppColor.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '₹${_formatCurrency(order.amount ?? 0)}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColor.primary,
            ),
          ),
        ],
      ),
    );
  }

  /// Helper to format currency
  String _formatCurrency(dynamic value) {
    final val = value is num ? value : 0;
    if (val >= 100000) {
      return '${(val / 100000).toStringAsFixed(1)}L';
    } else if (val >= 1000) {
      return '${(val / 1000).toStringAsFixed(1)}K';
    }
    return val.toStringAsFixed(0);
  }

  /// Calculate completion rate
  int _calculateCompletionRate(ChannelPartnerDashboard d) {
    final total = d.totalPickups;
    if (total == 0) return 0;
    return ((d.completedPickups / total) * 100).toInt();
  }
}

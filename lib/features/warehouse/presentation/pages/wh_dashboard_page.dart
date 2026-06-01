import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/widgets/dashboard_stat_card.dart';
import '../../../../core/widgets/metric_grid.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../domain/models/warehouse_dashboard.dart';
import '../../domain/models/warehouse_request.dart';
import '../../providers/warehouse_provider.dart';
import 'wh_request_detail_page.dart';
import 'wh_requests_page.dart';

class WhDashboardPage extends ConsumerStatefulWidget {
  const WhDashboardPage({super.key});

  @override
  ConsumerState<WhDashboardPage> createState() => _WhDashboardPageState();
}

class _WhDashboardPageState extends ConsumerState<WhDashboardPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(warehouseProvider.notifier).loadDashboard(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(warehouseProvider);
    final d = state.dashboard;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildModernAppBar(d?.warehouse?.name),
            Expanded(
              child: state.isLoading && d == null
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: () =>
                          ref.read(warehouseProvider.notifier).loadDashboard(),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (state.error != null)
                              _buildErrorBanner(state.error!),
                            _buildModernHeader(d?.warehouse?.name),
                            _buildModernMetrics(d),
                            _buildQuickActions(),
                            _buildRecentPickupRequests(d),
                            if (d != null && d.totalPickupBoys > 0)
                              _buildPickupBoysSection(d),
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

  /// Modern app bar with warehouse icon and name
  Widget _buildModernAppBar(String? warehouseName) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.space16,
        vertical: AppTheme.space12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColor.hairline, width: 0.5)),
        boxShadow: AppTheme.e1,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColor.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Icon(
              Icons.warehouse_rounded,
              color: AppColor.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: AppTheme.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  warehouseName ?? 'Warehouse',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColor.textPrimary,
                    letterSpacing: -0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'warehouse_dashboard.operational_overview'.tr(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColor.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
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
          width: 1,
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

  /// Modern header with title and subtitle
  Widget _buildModernHeader(String? warehouseName) {
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
            warehouseName ?? 'warehouse_dashboard.title'.tr(),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: AppColor.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'warehouse_dashboard.operational_overview'.tr(),
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

  /// Modern metrics grid with 4 key stats
  Widget _buildModernMetrics(WarehouseDashboard? d) {
    final metrics = [
      DashboardStatCard(
        label: 'warehouse_dashboard.assigned_pickups'.tr(),
        value: '${d?.assignedRequests ?? 0}',
        icon: Icons.local_shipping_rounded,
        iconColor: AppColor.primary,
        backgroundColor: AppColor.surface,
      ),
      DashboardStatCard(
        label: 'warehouse_dashboard.pending_pickups'.tr(),
        value: '${d?.unassignedRequests ?? 0}',
        icon: Icons.schedule_rounded,
        iconColor: AppColor.warning,
        valueColor: AppColor.warning,
        backgroundColor: AppColor.surface,
      ),
      DashboardStatCard(
        label: 'warehouse_dashboard.completed_today'.tr(),
        value: '${d?.completedPickups ?? 0}',
        icon: Icons.check_circle_rounded,
        iconColor: AppColor.success,
        valueColor: AppColor.success,
        backgroundColor: AppColor.surface,
      ),
      DashboardStatCard(
        label: 'warehouse_dashboard.todays_workload'.tr(),
        value: '${d?.totalRequests ?? 0}',
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

  /// Quick action buttons
  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.space16,
        vertical: AppTheme.space16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
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
                child: _buildQuickActionCard(
                  icon: Icons.assignment_rounded,
                  label: 'View Requests',
                  color: AppColor.primary,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const WhRequestsPage(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: AppTheme.space12),
              Expanded(
                child: _buildQuickActionCard(
                  icon: Icons.group_rounded,
                  label: 'Assign Partner',
                  color: AppColor.info,
                  onTap: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Quick action card
  Widget _buildQuickActionCard({
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
            width: 1,
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

  /// Recent pickup requests section
  Widget _buildRecentPickupRequests(WarehouseDashboard? d) {
    // Parse raw JSON to WarehouseRequest objects
    final rawRequests = d?.recentRequests ?? [];
    final requests = rawRequests
        .map((r) => r is WarehouseRequest
            ? r
            : WarehouseRequest.fromJson(r as Map<String, dynamic>))
        .cast<WarehouseRequest>()
        .toList();

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
                  'warehouse_dashboard.recent_requests'.tr(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColor.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const WhRequestsPage(),
                      ),
                    );
                  },
                  child: Text(
                    'warehouse_dashboard.view_all_requests'.tr(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColor.primary,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.space12),
          if (requests.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppTheme.space32),
              child: EmptyStateWidget(
                icon: FontAwesomeIcons.inbox,
                title: 'warehouse_dashboard.no_requests'.tr(),
                subtitle: 'warehouse_dashboard.no_requests_subtitle'.tr(),
              ),
            )
          else
            Column(
              children: requests.take(5).map((req) {
                return _buildPickupRequestTile(req);
              }).toList(),
            ),
        ],
      ),
    );
  }

  /// Individual pickup request tile
  Widget _buildPickupRequestTile(WarehouseRequest req) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => WhRequestDetailPage(request: req),
          ),
        );
      },
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        req.orderCode,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColor.textMuted,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        req.customerName,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColor.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                StatusBadge(
                  status: req.status,
                ),
              ],
            ),
            const SizedBox(height: AppTheme.space10),
            Row(
              children: [
                Icon(
                  FontAwesomeIcons.mapPin,
                  color: AppColor.textMuted,
                  size: 12,
                ),
                const SizedBox(width: AppTheme.space8),
                Expanded(
                  child: Text(
                    req.address,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColor.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.space8),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        FontAwesomeIcons.box,
                        color: AppColor.textMuted,
                        size: 11,
                      ),
                      const SizedBox(width: AppTheme.space6),
                      Expanded(
                        child: Text(
                          req.itemSummary ?? 'Items',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: AppColor.textMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppTheme.space8),
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        FontAwesomeIcons.weight,
                        color: AppColor.textMuted,
                        size: 11,
                      ),
                      const SizedBox(width: AppTheme.space6),
                      Text(
                        '${req.estimatedWeight ?? 0}kg',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: AppColor.textMuted,
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
    );
  }

  Widget _buildPickupBoysSection(WarehouseDashboard d) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.space16,
        vertical: AppTheme.space16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'warehouse_dashboard.pickup_boys'.tr(),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColor.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: AppTheme.space12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(AppTheme.space12),
                  decoration: BoxDecoration(
                    color: AppColor.surface,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    border: Border.all(color: AppColor.cardBorder),
                    boxShadow: AppTheme.e1,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColor.textMuted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${d.totalPickupBoys}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColor.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.space12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(AppTheme.space12),
                  decoration: BoxDecoration(
                    color: AppColor.surface,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    border: Border.all(color: AppColor.cardBorder),
                    boxShadow: AppTheme.e1,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Active',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColor.success,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${d.activePickupBoys}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColor.success,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

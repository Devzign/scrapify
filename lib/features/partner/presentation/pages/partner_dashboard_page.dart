import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/utils/app_routes.dart';
import '../../../../features/auth/providers/auth_provider.dart';
import '../../../../features/channel_partner/domain/models/channel_partner_dashboard.dart';
import '../../../../features/channel_partner/providers/channel_partner_provider.dart';
import '../partner_locale.dart';

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
            _buildAppBar(user?.name),
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
                            _buildHeaderSection(user?.name, user?.id),
                            _buildQuickActions(context),
                            _buildMetricsGrid(d),
                            _buildOrderHealthAndFleet(d),
                            _buildRecentOrders(d),
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
          Row(
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(40),
                onTap: () => context.push(AppRoutes.notifications),
                child: Container(
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
              ),
              const SizedBox(width: 8),
              InkWell(
                borderRadius: BorderRadius.circular(40),
                onTap: () => context.push(AppRoutes.partnerProfile),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColor.backgroundCream,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person_outline_rounded,
                    color: AppColor.textSecondary,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => context.push(AppRoutes.partnerOperations),
              icon: const Icon(Icons.tune_rounded, size: 16),
              label: const Text('Operations'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => context.push(AppRoutes.helpSupport),
              icon: const Icon(Icons.support_agent_rounded, size: 16),
              label: const Text('Support'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(String? name, int? userId) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.partnerText('Partner Dashboard', 'पार्टनर डैशबोर्ड'),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: AppTheme.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                name ?? 'Channel Partner',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
              if (userId != null) ...[
                const SizedBox(width: 8),
                Text(
                  '| ID: $userId',
                  style: TextStyle(fontSize: 11, color: AppColor.textMuted),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(ChannelPartnerDashboard? d) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Total Orders — Large Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppTheme.cardBorderRadius,
              border: AppTheme.cardBorder,
              boxShadow: AppTheme.cardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.partnerText('TOTAL ORDERS', 'कुल ऑर्डर'),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primaryColor,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _fmt(d?.totalOrders ?? 0),
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppTheme.primarySurface,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.analytics_rounded,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.hairline,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.partnerText('ACTIVE', 'सक्रिय'),
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: AppColor.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${d?.activeOrders ?? 0}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.hairline,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.partnerText('COMPLETED', 'पूरा हुआ'),
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: AppColor.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _fmt(d?.completedOrders ?? 0),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textPrimary,
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
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _statBadge('Total Customers', '${d?.totalCustomers ?? 0}')),
              const SizedBox(width: 10),
              Expanded(child: _statBadge('Total Pickups', '${d?.totalPickups ?? d?.totalOrders ?? 0}')),
              const SizedBox(width: 10),
              Expanded(child: _statBadge('Pending', '${d?.pendingPickups ?? d?.activeOrders ?? 0}')),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _statBadge('Assigned', '${d?.assignedPickups ?? 0}')),
              const SizedBox(width: 10),
              Expanded(child: _statBadge('Delivered', '${d?.deliveredToWarehouse ?? 0}')),
              const SizedBox(width: 10),
              Expanded(child: _statBadge('Pending Settle', '${d?.pendingSettlement ?? 0}')),
            ],
          ),
          const SizedBox(height: 16),
          // Warehouses & Team Row
          Row(
            children: [
              Expanded(
                child: _buildMiniMetricCard(
                  icon: Icons.warehouse_rounded,
                  title: context.partnerText('WAREHOUSES', 'गोदाम'),
                  items: [
                    _MetricItem(
                      context.partnerText('Active', 'सक्रिय'),
                      '${d?.activeWarehouses ?? 0}',
                      AppTheme.primaryColor,
                    ),
                    _MetricItem(
                      context.partnerText('Pending', 'लंबित'),
                      '${d?.pendingWarehouseApprovals ?? 0}',
                      AppColor.textSecondary,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMiniMetricCard(
                  icon: Icons.group_rounded,
                  title: context.partnerText('TEAM', 'टीम'),
                  items: [
                    _MetricItem(
                      context.partnerText('Available', 'उपलब्ध'),
                      '${d?.availablePickupBoys ?? 0}',
                      AppTheme.primaryColor,
                    ),
                    _MetricItem(
                      context.partnerText('Active', 'सक्रिय'),
                      '${d?.activePickupBoys ?? 0}',
                      AppColor.textSecondary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniMetricCard({
    required IconData icon,
    required String title,
    required List<_MetricItem> items,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.cardBorderRadius,
        border: AppTheme.cardBorder,
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.primaryColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: AppColor.textSecondary,
                    letterSpacing: 1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item.label,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: item.color == AppTheme.primaryColor
                          ? AppTheme.primarySurface
                          : AppTheme.outline,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      item.value,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: item.color == AppTheme.primaryColor
                            ? AppTheme.primaryDark
                            : AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statBadge(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.backgroundCream,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: AppColor.textMuted,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderHealthAndFleet(ChannelPartnerDashboard? d) {
    final cancelled = d?.cancelledOrders ?? 0;
    final rescheduled = d?.rescheduledOrders ?? 0;
    final maxVal = [cancelled, rescheduled, 1].reduce((a, b) => a > b ? a : b);
    const maxBarH = 120.0;
    final cancelH = (cancelled / maxVal * maxBarH).clamp(20.0, maxBarH);
    final reschedH = (rescheduled / maxVal * maxBarH).clamp(20.0, maxBarH);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Order Health Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
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
                  context.partnerText('Order Health', 'ऑर्डर स्थिति'),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColor.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            height: cancelH,
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFFEF4444,
                              ).withValues(alpha: 0.1),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(8),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '$cancelled',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppColor.error,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            context.partnerText('Cancelled', 'रद्द'),
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: AppColor.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            height: reschedH,
                            decoration: BoxDecoration(
                              color: AppColor.cardBorder.withValues(
                                alpha: 0.5,
                              ),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(8),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '$rescheduled',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppColor.textSecondary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            context.partnerText(
                              'Rescheduled',
                              'पुनर्निर्धारित',
                            ),
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
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
          const SizedBox(height: 16),
          // Fleet Tracking Card — sage gradient (matches customer hero)
          Container(
            width: double.infinity,
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.radiusXl),
              gradient: AppTheme.sageHeader,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.30),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColor.primary.withValues(alpha: 0.30),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -20,
                  top: -20,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.local_shipping_rounded,
                            color: Colors.white.withValues(alpha: 0.9),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            context.partnerText(
                              'FLEET TRACKING',
                              'फ्लीट ट्रैकिंग',
                            ),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Colors.white.withValues(alpha: 0.8),
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        context.partnerText(
                          'Active Fleet Tracking',
                          'सक्रिय फ्लीट ट्रैकिंग',
                        ),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        context.partnerText(
                          'Real-time status of ${d?.totalPickupBoys ?? 0} pickup partners',
                          '${d?.totalPickupBoys ?? 0} पिकअप पार्टनर्स की लाइव स्थिति',
                        ),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentOrders(ChannelPartnerDashboard? d) {
    final rawOrders = d?.recentOrders ?? [];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.partnerText('Recent Orders', 'नवीनतम ऑर्डर'),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    context.partnerText('View All', 'सभी देखें'),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: AppTheme.primaryColor,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (rawOrders.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                context.partnerText('No recent orders', 'कोई नया ऑर्डर नहीं'),
                style: TextStyle(color: AppColor.textMuted, fontSize: 13),
              ),
            )
          else
            ...rawOrders
                .whereType<Map<String, dynamic>>()
                .take(5)
                .map((o) => _buildOrderCard(o)),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> o) {
    final orderCode =
        o['order_code']?.toString() ??
        o['pickup_code']?.toString() ??
        '#${o['id']}';
    final itemSummary =
        o['items_summary']?.toString() ??
        o['item_summary']?.toString() ??
        context.partnerText('Items', 'आइटम');
    final address = o['address']?.toString() ?? '';
    final status = o['status']?.toString() ?? 'pending';
    final statusStyle = _orderStatusStyle(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.cardBorderRadius,
        border: AppTheme.cardBorder,
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppTheme.backgroundCream,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inventory_2_rounded,
              color: AppColor.textSecondary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$orderCode - $itemSummary',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  address.length > 30
                      ? '${address.substring(0, 30)}…'
                      : address,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppColor.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusStyle.$1,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status.toUpperCase().replaceAll('_', ' '),
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: statusStyle.$2,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right, color: AppColor.outline, size: 20),
        ],
      ),
    );
  }

  (Color, Color) _orderStatusStyle(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'paid':
        return (
          AppTheme.primaryColor.withValues(alpha: 0.1),
          AppTheme.primaryColor,
        );
      case 'assigned':
      case 'in_transit':
      case 'on_the_way':
        return (AppTheme.primarySurface, AppTheme.primaryDark);
      case 'cancelled':
        return (AppColor.errorTint, AppColor.error);
      case 'rescheduled':
        return (AppColor.roseTint, AppColor.rose);
      default:
        return (AppTheme.outline, AppTheme.textSecondary);
    }
  }

  String _fmt(int n) {
    if (n >= 1000) {
      final s = n.toString();
      final buf = StringBuffer();
      int count = 0;
      for (int i = s.length - 1; i >= 0; i--) {
        if (count > 0 && count % 3 == 0) buf.write(',');
        buf.write(s[i]);
        count++;
      }
      return buf.toString().split('').reversed.join();
    }
    return '$n';
  }
}

class _MetricItem {
  final String label;
  final String value;
  final Color color;
  const _MetricItem(this.label, this.value, this.color);
}

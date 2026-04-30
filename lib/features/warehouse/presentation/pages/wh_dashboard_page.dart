import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/models/warehouse_dashboard.dart';
import '../../domain/models/warehouse_request.dart';
import '../../providers/warehouse_provider.dart';

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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(d?.warehouse?.name),
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
                              Container(
                                margin: const EdgeInsets.all(16),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.orange.shade200,
                                  ),
                                ),
                                child: Text(
                                  state.error!,
                                  style: TextStyle(
                                    color: Colors.orange.shade800,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            _buildHeader(d?.warehouse?.name),
                            _buildMetricsBento(d),
                            _buildRecentRequests(d),
                            _buildWarehouseVisual(),
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

  Widget _buildAppBar(String? warehouseName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
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
              Icon(
                Icons.warehouse_rounded,
                color: AppTheme.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 10),
              Text(
                warehouseName ?? 'Scrapi5 Warehouse',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_none_rounded,
              color: Colors.grey.shade500,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String? warehouseName) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            warehouseName ?? 'Main Dashboard',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                'Operational Overview',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsBento(WarehouseDashboard? d) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Large Focus Card - Total Requests
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
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
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.warehouse_rounded,
                        color: AppTheme.primaryColor,
                        size: 24,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'LIVE',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF14532D),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '${d?.totalRequests ?? 0}',
                  style: const TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                    height: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.locale.languageCode == 'hi'
                      ? 'कुल अनुरोध'
                      : 'Total Requests',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.only(top: 16),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: Colors.grey.shade50)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${d?.unassignedRequests ?? 0}',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.errorColor,
                              ),
                            ),
                            Text(
                              context.locale.languageCode == 'hi'
                                  ? 'अनिर्दिष्ट'
                                  : 'Unassigned',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${d?.assignedRequests ?? 0}',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            Text(
                              context.locale.languageCode == 'hi'
                                  ? 'सौंपा गया'
                                  : 'Assigned',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade500,
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
          ),
          const SizedBox(height: 12),
          // Active Pickups + Completed row
          Row(
            children: [
              Expanded(
                child: _buildSmallMetricCard(
                  icon: Icons.local_shipping_rounded,
                  label: 'Active Pickups',
                  labelHindi: 'सक्रिय पिकअप',
                  value: '${d?.activePickups ?? 0}',
                  tag: 'Current',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSmallMetricCard(
                  icon: Icons.check_circle_rounded,
                  label: 'Completed',
                  labelHindi: 'पूरा हुआ',
                  value: '${d?.completedPickups ?? 0}',
                  tag: 'Today',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Agents Dark Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: AppTheme.cardBorderRadius,
                    border: AppTheme.cardBorder,
                    boxShadow: AppTheme.cardShadow,
                  ),
                  child: const Icon(
                    Icons.engineering_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${d?.totalPickupBoys ?? 0} Total Agents',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Warehouse Staffing Overview',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF4ADE80),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${d?.availablePickupBoys ?? 0} Available',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Rescheduled Card
          _buildSmallMetricCard(
            icon: Icons.event_repeat_rounded,
            iconColor: AppTheme.errorColor,
            label: 'Rescheduled',
            labelHindi: 'पुनर्निर्धारित',
            value: '${d?.rescheduledRequests ?? 0}',
            valueColor: AppTheme.errorColor,
            fullWidth: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSmallMetricCard({
    required IconData icon,
    required String label,
    required String labelHindi,
    required String value,
    String? tag,
    Color? iconColor,
    Color? valueColor,
    bool fullWidth = false,
  }) {
    return Container(
      width: fullWidth ? double.infinity : null,
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
              Icon(icon, color: iconColor ?? Colors.grey.shade400, size: 24),
              if (tag != null)
                Text(
                  tag.toUpperCase(),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: Colors.grey.shade400,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              color: valueColor ?? const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            context.locale.languageCode == 'hi' ? labelHindi : label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentRequests(WarehouseDashboard? d) {
    final raw = d?.recentRequests ?? [];
    final requests = raw
        .whereType<Map<String, dynamic>>()
        .map((e) => WarehouseRequest.fromJson(e))
        .take(3)
        .toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.locale.languageCode == 'hi'
                        ? 'हालिया अनुरोध'
                        : 'Recent Requests',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              Text(
                context.locale.languageCode == 'hi' ? 'सभी देखें' : 'VIEW ALL',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primaryColor,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (requests.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                context.locale.languageCode == 'hi'
                    ? 'कोई हालिया अनुरोध नहीं'
                    : 'No recent requests',
                style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
              ),
            )
          else
            ...requests.map((r) => _buildRequestCard(_requestItemFromModel(r))),
        ],
      ),
    );
  }

  _RequestItem _requestItemFromModel(WarehouseRequest r) {
    final s = r.status.toLowerCase();
    Color bg;
    Color fg;
    String hindi;
    String label;
    if (s == 'unassigned' || s == 'pending') {
      bg = const Color(0xFFFEE2E2);
      fg = const Color(0xFF991B1B);
      hindi = 'अनिर्दिष्ट';
      label = 'Unassigned';
    } else if (s == 'assigned') {
      bg = const Color(0xFFDCFCE7);
      fg = const Color(0xFF14532D);
      hindi = 'सौंपा गया';
      label = 'Assigned';
    } else if (s == 'active' ||
        s == 'in_progress' ||
        s == 'on_the_way' ||
        s == 'arrived') {
      bg = const Color(0xFFFEF3C7);
      fg = const Color(0xFF92400E);
      hindi = 'सक्रिय';
      label = 'Active';
    } else if (s == 'completed') {
      bg = const Color(0xFFE0E7FF);
      fg = const Color(0xFF3730A3);
      hindi = 'पूरा हुआ';
      label = 'Completed';
    } else if (s == 'rescheduled') {
      bg = const Color(0xFFFFF7ED);
      fg = const Color(0xFF9A3412);
      hindi = 'पुनर्निर्धारित';
      label = 'Rescheduled';
    } else {
      bg = Colors.grey.shade100;
      fg = Colors.grey.shade700;
      hindi = s;
      label = r.status;
    }
    return _RequestItem(
      orderId: r.orderCode,
      customer: r.customerName,
      area: r.address.length > 20
          ? '${r.address.substring(0, 20)}…'
          : r.address,
      status: label,
      statusColor: bg,
      statusTextColor: fg,
      statusHindi: hindi,
    );
  }

  Widget _buildRequestCard(_RequestItem r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
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
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.inventory_2_rounded,
              color: Colors.grey.shade400,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  r.orderId,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Text(
                  '${r.customer} • ${r.area}',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: r.statusColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  context.locale.languageCode == 'hi'
                      ? r.statusHindi.toUpperCase()
                      : r.status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: r.statusTextColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWarehouseVisual() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1E293B), Color(0xFF334155)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E293B).withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              right: -30,
              top: -30,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
            Positioned(
              left: -20,
              bottom: -20,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.03),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.local_shipping_rounded,
                        color: Colors.white.withValues(alpha: 0.7),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'PICKUP OPERATIONS',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.white.withValues(alpha: 0.7),
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Pickup Operations',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Manage and track all pickups from one place.',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RequestItem {
  final String orderId;
  final String customer;
  final String area;
  final String status;
  final Color statusColor;
  final Color statusTextColor;
  final String statusHindi;

  const _RequestItem({
    required this.orderId,
    required this.customer,
    required this.area,
    required this.status,
    required this.statusColor,
    required this.statusTextColor,
    required this.statusHindi,
  });
}

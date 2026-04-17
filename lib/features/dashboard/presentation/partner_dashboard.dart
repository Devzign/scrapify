import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../../channel_partner/providers/channel_partner_provider.dart';

class PartnerDashboard extends ConsumerStatefulWidget {
  const PartnerDashboard({super.key});

  @override
  ConsumerState<PartnerDashboard> createState() => _PartnerDashboardState();
}

class _PartnerDashboardState extends ConsumerState<PartnerDashboard> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(channelPartnerProvider.notifier).loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(channelPartnerProvider);
    final user = ref.watch(authProvider);
    final dashboard = state.dashboard;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Namaste, ${user?.name ?? 'Partner'} 👋',
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.bell,
                color: AppTheme.textPrimary),
            onPressed: () => context.push('/notifications'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: state.isLoading && dashboard == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () =>
                  ref.read(channelPartnerProvider.notifier).loadDashboard(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (state.error != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline,
                                color: Colors.orange),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Some data unavailable — backend endpoints pending',
                                style:
                                    TextStyle(color: Colors.orange.shade800),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Summary Banner
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E2A5E),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFF1E2A5E).withValues(alpha: 0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Business Overview',
                            style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                letterSpacing: 1),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${dashboard?.totalOrders ?? 0} Orders',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${dashboard?.activeOrders ?? 0} active · ${dashboard?.completedOrders ?? 0} done',
                                    style: const TextStyle(
                                        color: Colors.white60, fontSize: 13),
                                  ),
                                ],
                              ),
                              if ((dashboard?.pendingApprovalCount ?? 0) > 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withValues(alpha: 0.3),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                        color: Colors.orange.withValues(
                                            alpha: 0.5)),
                                  ),
                                  child: Text(
                                    '${dashboard!.pendingApprovalCount} pending',
                                    style: const TextStyle(
                                        color: Colors.orange, fontSize: 12),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Orders Metrics
                    const Text(
                      'Orders',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _MetricCard(
                          label: 'Total',
                          value: '${dashboard?.totalOrders ?? 0}',
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 12),
                        _MetricCard(
                          label: 'Active',
                          value: '${dashboard?.activeOrders ?? 0}',
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 12),
                        _MetricCard(
                          label: 'Completed',
                          value: '${dashboard?.completedOrders ?? 0}',
                          color: Colors.green,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Team Metrics
                    const Text(
                      'Team',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _MetricCard(
                          label: 'Pickup Boys',
                          value: '${dashboard?.totalPickupBoys ?? 0}',
                          color: Colors.purple,
                        ),
                        const SizedBox(width: 12),
                        _MetricCard(
                          label: 'Active',
                          value: '${dashboard?.activePickupBoys ?? 0}',
                          color: Colors.green,
                        ),
                        const SizedBox(width: 12),
                        _MetricCard(
                          label: 'Warehouses',
                          value: '${dashboard?.totalWarehouses ?? 0}',
                          color: Colors.teal,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Quick Actions
                    const Text(
                      'Quick Access',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary),
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 2.5,
                      children: [
                        _QuickActionTile(
                          icon: FontAwesomeIcons.clipboardList,
                          label: 'Orders',
                          color: Colors.blue,
                          onTap: () => context.push('/partner/orders'),
                        ),
                        _QuickActionTile(
                          icon: FontAwesomeIcons.userGroup,
                          label: 'Pickup Boys',
                          color: Colors.purple,
                          onTap: () {},
                        ),
                        _QuickActionTile(
                          icon: FontAwesomeIcons.warehouse,
                          label: 'Warehouses',
                          color: Colors.teal,
                          onTap: () {},
                        ),
                        _QuickActionTile(
                          icon: FontAwesomeIcons.clockRotateLeft,
                          label: 'Approvals',
                          color: Colors.orange,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
          switch (index) {
            case 1:
              context.push('/partner/orders');
              break;
            case 4:
              context.push('/profile');
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.house), label: 'Home'),
          BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.clipboardList), label: 'Orders'),
          BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.userGroup), label: 'Team'),
          BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.warehouse), label: 'Warehouse'),
          BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.user), label: 'Profile'),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MetricCard(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(label,
                style:
                    const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            FaIcon(icon, color: color, size: 16),
            const SizedBox(width: 8),
            Text(label,
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

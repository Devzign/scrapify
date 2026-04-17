import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../warehouse/providers/warehouse_provider.dart';

class WarehouseDashboard extends ConsumerStatefulWidget {
  const WarehouseDashboard({super.key});

  @override
  ConsumerState<WarehouseDashboard> createState() => _WarehouseDashboardState();
}

class _WarehouseDashboardState extends ConsumerState<WarehouseDashboard> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(warehouseProvider.notifier).loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(warehouseProvider);
    final dashboard = state.dashboard;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const FaIcon(FontAwesomeIcons.store,
                  color: AppTheme.primaryColor, size: 16),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dashboard?.warehouse?.name ?? 'Warehouse',
                  style: const TextStyle(
                      fontSize: 12, color: AppTheme.textSecondary),
                ),
                const Text(
                  'Warehouse Dashboard',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.bell,
                color: AppTheme.textPrimary),
            onPressed: () => context.push('/notifications'),
          ),
        ],
      ),
      body: state.isLoading && dashboard == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (state.error != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(state.error!,
                                style: const TextStyle(color: Colors.red)),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () =>
                                ref.read(warehouseProvider.notifier).clearError(),
                          ),
                        ],
                      ),
                    ),

                  // Metrics Grid
                  _SectionHeader(title: 'Requests Overview'),
                  const SizedBox(height: 12),
                  _MetricsGrid(items: [
                    _MetricItem(
                      label: 'Total',
                      value: '${dashboard?.totalRequests ?? 0}',
                      icon: FontAwesomeIcons.clipboardList,
                      color: Colors.blue,
                    ),
                    _MetricItem(
                      label: 'Unassigned',
                      value: '${dashboard?.unassignedRequests ?? 0}',
                      icon: FontAwesomeIcons.circleExclamation,
                      color: Colors.orange,
                    ),
                    _MetricItem(
                      label: 'Active',
                      value: '${dashboard?.activePickups ?? 0}',
                      icon: FontAwesomeIcons.truck,
                      color: Colors.purple,
                    ),
                    _MetricItem(
                      label: 'Completed',
                      value: '${dashboard?.completedPickups ?? 0}',
                      icon: FontAwesomeIcons.circleCheck,
                      color: Colors.green,
                    ),
                  ]),

                  const SizedBox(height: 24),
                  _SectionHeader(title: 'Pickup Boys'),
                  const SizedBox(height: 12),
                  _MetricsGrid(items: [
                    _MetricItem(
                      label: 'Total',
                      value: '${dashboard?.totalPickupBoys ?? 0}',
                      icon: FontAwesomeIcons.userGroup,
                      color: Colors.teal,
                    ),
                    _MetricItem(
                      label: 'Available',
                      value: '${dashboard?.availablePickupBoys ?? 0}',
                      icon: FontAwesomeIcons.userCheck,
                      color: Colors.green,
                    ),
                  ]),

                  const SizedBox(height: 24),
                  // Quick Actions
                  _SectionHeader(title: 'Quick Actions'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _QuickActionCard(
                          icon: FontAwesomeIcons.clipboardList,
                          label: 'View Requests',
                          color: AppTheme.primaryColor,
                          onTap: () => context.push('/warehouse/requests'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _QuickActionCard(
                          icon: FontAwesomeIcons.userGroup,
                          label: 'Pickup Boys',
                          color: Colors.teal,
                          onTap: () => context.push('/warehouse/pickup-boys'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
          switch (index) {
            case 1:
              context.push('/warehouse/requests');
              break;
            case 2:
              context.push('/warehouse/pickup-boys');
              break;
            case 3:
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
              icon: FaIcon(FontAwesomeIcons.clipboardList), label: 'Requests'),
          BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.userGroup), label: 'Team'),
          BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.user), label: 'Profile'),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppTheme.textPrimary,
      ),
    );
  }
}

class _MetricItem {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _MetricItem(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});
}

class _MetricsGrid extends StatelessWidget {
  final List<_MetricItem> items;
  const _MetricsGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.0,
      children: items
          .map((item) => Container(
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
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: item.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: FaIcon(item.icon, color: item.color, size: 16),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          item.value,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: item.color,
                          ),
                        ),
                        Text(
                          item.label,
                          style: const TextStyle(
                              fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(icon, color: color, size: 16),
            const SizedBox(width: 8),
            Text(label,
                style: TextStyle(
                    color: color, fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

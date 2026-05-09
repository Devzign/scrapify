import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/warehouse_provider.dart';
import 'pages/wh_dashboard_page.dart';
import 'pages/wh_requests_page.dart';
import 'pages/wh_pickup_boys_page.dart';
import 'pages/wh_profile_page.dart';

class WarehouseBottomNav extends ConsumerStatefulWidget {
  const WarehouseBottomNav({super.key});

  @override
  ConsumerState<WarehouseBottomNav> createState() => _WarehouseBottomNavState();
}

class _WarehouseBottomNavState extends ConsumerState<WarehouseBottomNav> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    WhDashboardPage(),
    WhRequestsPage(),
    WhPickupBoysPage(),
    WhProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade100)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.home_rounded, 'Home', 0),
                _buildNavItem(Icons.assignment_late_rounded, 'Requests', 1),
                _buildNavItem(Icons.local_shipping_rounded, 'Pickups', 2),
                _buildNavItem(Icons.person_rounded, 'Profile', 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onTabChanged(int index) async {
    setState(() => _currentIndex = index);
    final notifier = ref.read(warehouseProvider.notifier);

    if (index == 0) {
      await notifier.loadDashboard();
      return;
    }
    if (index == 1) {
      await notifier.loadRequests();
      return;
    }
    if (index == 2) {
      await notifier.loadPickupBoys();
    }
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () => _onTabChanged(index),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppTheme.primaryColor
                  : AppTheme.textMuted,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? AppTheme.primaryColor
                    : AppTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

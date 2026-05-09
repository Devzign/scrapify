import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_color.dart';
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
      backgroundColor: AppTheme.backgroundLight,
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Container(
            decoration: BoxDecoration(
              color: AppColor.surface,
              borderRadius: BorderRadius.circular(AppTheme.radius2xl + 4),
              border: Border.all(color: AppColor.cardBorder),
              boxShadow: AppTheme.e2,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
            child: Row(
              children: [
                _buildNavItem(FontAwesomeIcons.house, 'Home', 0),
                _buildNavItem(FontAwesomeIcons.clipboardList, 'Requests', 1),
                _buildNavItem(FontAwesomeIcons.truckFast, 'Pickups', 2),
                _buildNavItem(FontAwesomeIcons.user, 'Profile', 3),
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
    return Expanded(
      child: InkWell(
        onTap: () => _onTabChanged(index),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColor.primarySurface
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FaIcon(
                icon,
                color: isSelected ? AppColor.primary : AppColor.textSecondary,
                size: 16,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight:
                      isSelected ? FontWeight.w800 : FontWeight.w600,
                  color:
                      isSelected ? AppColor.primary : AppColor.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

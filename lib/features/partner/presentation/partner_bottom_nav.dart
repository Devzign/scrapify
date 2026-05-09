import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../channel_partner/providers/channel_partner_provider.dart';
import 'partner_locale.dart';
import 'pages/partner_dashboard_page.dart';
import 'pages/partner_orders_page.dart';
import 'pages/partner_team_page.dart';
import 'pages/partner_warehouses_page.dart';
import 'pages/partner_profile_page.dart';

class PartnerBottomNav extends ConsumerStatefulWidget {
  const PartnerBottomNav({super.key});

  @override
  ConsumerState<PartnerBottomNav> createState() => _PartnerBottomNavState();
}

class _PartnerBottomNavState extends ConsumerState<PartnerBottomNav> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    PartnerDashboardPage(),
    PartnerOrdersPage(),
    PartnerTeamPage(),
    PartnerWarehousesPage(),
    PartnerProfilePage(),
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
                _buildNavItem(
                  Icons.home_rounded,
                  context.partnerText('Home', 'होम'),
                  0,
                ),
                _buildNavItem(
                  Icons.list_alt_rounded,
                  context.partnerText('Orders', 'ऑर्डर्स'),
                  1,
                ),
                _buildNavItem(
                  Icons.group_rounded,
                  context.partnerText('Team', 'टीम'),
                  2,
                ),
                _buildNavItem(
                  Icons.warehouse_rounded,
                  context.partnerText('Warehouses', 'गोदाम'),
                  3,
                ),
                _buildNavItem(
                  Icons.person_rounded,
                  context.partnerText('Profile', 'प्रोफ़ाइल'),
                  4,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onTabChanged(int index) async {
    setState(() => _currentIndex = index);
    final notifier = ref.read(channelPartnerProvider.notifier);

    if (index == 0) {
      await notifier.loadDashboard();
      return;
    }
    if (index == 1) {
      await notifier.loadOrders();
      return;
    }
    if (index == 2) {
      await notifier.loadPickupBoys();
      return;
    }
    if (index == 3) {
      await notifier.loadWarehouses();
    }
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () => _onTabChanged(index),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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

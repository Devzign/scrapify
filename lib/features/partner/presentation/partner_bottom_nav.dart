import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'partner_locale.dart';
import 'pages/partner_dashboard_page.dart';
import 'pages/partner_orders_page.dart';
import 'pages/partner_team_page.dart';
import 'pages/partner_warehouses_page.dart';
import 'pages/partner_profile_page.dart';

class PartnerBottomNav extends StatefulWidget {
  const PartnerBottomNav({super.key});

  @override
  State<PartnerBottomNav> createState() => _PartnerBottomNavState();
}

class _PartnerBottomNavState extends State<PartnerBottomNav> {
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

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
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
                  : const Color(0xFF94A3B8),
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
                    : const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

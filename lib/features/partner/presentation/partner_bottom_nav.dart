import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_color.dart';
import '../../channel_partner/providers/channel_partner_provider.dart';
import 'partner_locale.dart';
import 'pages/partner_dashboard_page.dart';
import 'pages/partner_orders_page.dart';
import 'pages/partner_team_page.dart';
import 'pages/partner_warehouses_page.dart';

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
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: Container(
            decoration: BoxDecoration(
              color: AppColor.surface,
              borderRadius: BorderRadius.circular(AppTheme.radius2xl + 4),
              border: Border.all(color: AppColor.cardBorder),
              boxShadow: AppTheme.e2,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
            child: Row(
              children: [
                _buildNavItem(
                  FontAwesomeIcons.house,
                  context.partnerText('Home', 'होम'),
                  0,
                ),
                _buildNavItem(
                  FontAwesomeIcons.listCheck,
                  context.partnerText('Orders', 'ऑर्डर्स'),
                  1,
                ),
                _buildNavItem(
                  FontAwesomeIcons.userGroup,
                  context.partnerText('Team', 'टीम'),
                  2,
                ),
                _buildNavItem(
                  FontAwesomeIcons.warehouse,
                  context.partnerText('Warehouses', 'गोदाम'),
                  3,
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
                size: 15,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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

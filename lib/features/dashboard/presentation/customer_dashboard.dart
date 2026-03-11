import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/utils/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../profile/presentation/user_profile_screen.dart';

class CustomerDashboard extends StatefulWidget {
  const CustomerDashboard({super.key});

  @override
  State<CustomerDashboard> createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends State<CustomerDashboard> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTheme.backgroundLight,
      drawer: _buildDrawer(),
      appBar: AppBar(
        leading: IconButton(
          icon: const FaIcon(
            FontAwesomeIcons.bars,
            color: AppTheme.textPrimary,
          ),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        title: Text(
          _getAppBarTitle(),
          style: const TextStyle(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const FaIcon(
                  FontAwesomeIcons.bell,
                  color: AppTheme.textPrimary,
                ),
                onPressed: () => context.push(AppRoutes.notifications),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 1) {
            // If "Menu" is tapped, open the drawer
            _scaffoldKey.currentState?.openDrawer();
          } else {
            setState(() => _currentIndex = index);
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: [
          BottomNavigationBarItem(
            icon: const FaIcon(FontAwesomeIcons.house, size: 20),
            label: 'dashboard.nav_home'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const FaIcon(FontAwesomeIcons.bars, size: 20),
            label: 'dashboard.nav_menu'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const FaIcon(FontAwesomeIcons.clipboardList, size: 20),
            label: 'dashboard.nav_order'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const FaIcon(FontAwesomeIcons.user, size: 20),
            label: 'dashboard.nav_profile'.tr(),
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () => context.push(AppRoutes.categorySelection),
              backgroundColor: AppTheme.primaryColor,
              elevation: 4,
              icon: const FaIcon(FontAwesomeIcons.plus, color: Colors.white),
              label: Text(
                'dashboard.book_now_fab'.tr(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            )
          : null,
    );
  }

  String _getAppBarTitle() {
    switch (_currentIndex) {
      case 0:
        return 'login.app_name'.tr();
      case 2:
        return 'dashboard.nav_order'.tr();
      case 3:
        return 'profile.title'.tr();
      default:
        return 'login.app_name'.tr();
    }
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeTab();
      case 2:
        return const Center(child: Text('Orders Tab Placeholder'));
      case 3:
        return const UserProfileScreen(showAppBar: false);
      default:
        return _buildHomeTab();
    }
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: AppTheme.primaryColor),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      image: const DecorationImage(
                        image: NetworkImage('https://i.pravatar.cc/150?img=12'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Amit Sharma',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    '+91 98765 43210',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: const FaIcon(
              FontAwesomeIcons.house,
              color: AppTheme.textPrimary,
              size: 20,
            ),
            title: Text('dashboard.nav_home'.tr()),
            onTap: () {
              Navigator.pop(context); // Close drawer
              setState(() => _currentIndex = 0);
            },
          ),
          ListTile(
            leading: const FaIcon(
              FontAwesomeIcons.clipboardList,
              color: AppTheme.textPrimary,
              size: 20,
            ),
            title: Text('dashboard.nav_order'.tr()),
            onTap: () {
              Navigator.pop(context);
              setState(() => _currentIndex = 2);
            },
          ),
          ListTile(
            leading: const FaIcon(
              FontAwesomeIcons.user,
              color: AppTheme.textPrimary,
              size: 20,
            ),
            title: Text('dashboard.nav_profile'.tr()),
            onTap: () {
              Navigator.pop(context);
              setState(() => _currentIndex = 3);
            },
          ),
          const Divider(),
          ListTile(
            leading: const FaIcon(
              FontAwesomeIcons.circleInfo,
              color: AppTheme.textPrimary,
              size: 20,
            ),
            title: Text('profile.about_us'.tr()),
            onTap: () {},
          ),
          ListTile(
            leading: const FaIcon(
              FontAwesomeIcons.arrowRightFromBracket,
              color: Colors.red,
              size: 20,
            ),
            title: Text(
              'profile.logout'.tr(),
              style: const TextStyle(color: Colors.red),
            ),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildHomeTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6F9A7A), Color(0xFF8BB594)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Eco-friendly badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const FaIcon(
                                FontAwesomeIcons.leaf,
                                color: Colors.white,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'dashboard.eco_badge'.tr(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'dashboard.book_pickup'.tr(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'dashboard.book_pickup_desc'.tr(),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      // Placeholder for Truck Graphic
                      Container(
                        width: 100,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const FaIcon(
                          FontAwesomeIcons.truckFast,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                      Transform.translate(
                        offset: const Offset(10, 10),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const FaIcon(
                            FontAwesomeIcons.arrowRight,
                            color: AppTheme.primaryColor,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Categories Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'dashboard.what_to_sell'.tr(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  'dashboard.view_all'.tr(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Horizontal scroll categories
            SizedBox(
              height: 160,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildMaterialCard(
                    title: 'dashboard.categories.metal'.tr(),
                    subtitle: '',
                    iconData: FontAwesomeIcons.screwdriverWrench,
                    isDark: true,
                  ),
                  const SizedBox(width: 16),
                  _buildMaterialCard(
                    title: 'dashboard.categories.ewaste'.tr(),
                    subtitle: '',
                    iconData: FontAwesomeIcons.microchip,
                    isDark: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Paper & Cardboard list item
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: const FaIcon(
                      FontAwesomeIcons.boxArchive,
                      color: AppTheme.primaryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'dashboard.categories.paper'.tr(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const FaIcon(
                    FontAwesomeIcons.chevronRight,
                    color: Colors.grey,
                    size: 16,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Active Request
            Text(
              'dashboard.active_request'.tr(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: FaIcon(
                          FontAwesomeIcons.boxOpen,
                          color: Colors.orange.shade600,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Request #SCR-2024',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'dashboard.pickup_scheduled'.tr(),
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'dashboard.assigned'.tr(),
                          style: TextStyle(
                            color: Colors.orange.shade800,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Divider(color: Colors.grey.shade200),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const FaIcon(
                            FontAwesomeIcons.solidCalendarDays,
                            size: 16,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Today, 4:00 PM',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      InkWell(
                        onTap: () {
                          context.push(AppRoutes.pickupTracking);
                        },
                        child: Text(
                          'dashboard.track'.tr(),
                          style: const TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 80), // Padding for FAB
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialCard({
    required String title,
    required String subtitle,
    required IconData iconData,
    required bool isDark,
  }) {
    return Container(
      width: 140,
      decoration: BoxDecoration(
        color: Colors.black87, // Mocking dark image bg
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: FaIcon(iconData, color: Colors.white, size: 20),
          ),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          if (subtitle.isNotEmpty)
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 12,
              ),
            ),
        ],
      ),
    );
  }
}

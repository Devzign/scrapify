import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/app_routes.dart';
import '../../../core/theme/app_theme.dart';

class PartnerDashboard extends StatelessWidget {
  const PartnerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Sat, 14 Oct', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
            Row(
              children: const [
                Text('Namaste, Rajesh 👋', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
              ],
            ),
          ],
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(icon: const FaIcon(FontAwesomeIcons.bell, color: AppTheme.textPrimary), onPressed: () => context.push(AppRoutes.notifications)),
              Positioned(top: 12, right: 12, child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle))),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dark Earnings Banner
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2A5E), // Dark Navy
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF1E2A5E).withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('TOTAL EARNINGS', style: TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 1.2, fontWeight: FontWeight.bold)),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), shape: BoxShape.circle),
                        child: const FaIcon(FontAwesomeIcons.ellipsis, color: Colors.white, size: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('₹ 12,450', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                        child: Row(
                          children: const [
                            FaIcon(FontAwesomeIcons.arrowTrendUp, color: Colors.green, size: 10),
                            SizedBox(width: 4),
                            Text('+4.2%', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text('+ ₹ 450 today', style: TextStyle(color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Pending Payout', style: TextStyle(color: Colors.white70, fontSize: 12)),
                          SizedBox(height: 4),
                          Text('₹ 2,100', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF1E2A5E),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: const Text('Withdraw', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Frequent Customers Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Frequent Customers', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                const Text('View All', style: TextStyle(color: AppTheme.primaryColor, fontSize: 14, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            
            // Horizontal Scroll for Customers
            SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildCustomerCard(name: 'Amit Electronics', location: 'Andheri East', initials: 'AE'),
                  const SizedBox(width: 16),
                  _buildCustomerCard(name: 'Raj Scrap', location: 'Powai', initials: 'RS'),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Today's Schedule
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Today\'s Schedule', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12)),
                  child: const Text('3 Active', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildScheduleCard(
              status: 'PENDING',
              statusColor: Colors.orange,
              id: '#PICK-8921',
              title: '12kg Mixed E-waste',
              time: '2:00 PM',
              distance: '2.4 km',
              isEnRoute: false,
            ),
            const SizedBox(height: 12),
            _buildScheduleCard(
              status: 'EN ROUTE',
              statusColor: Colors.blue,
              id: '#PICK-8924',
              title: '50kg Copper Wire',
              time: '3:30 PM',
              distance: '5.1 km',
              isEnRoute: true,
            ),
            const SizedBox(height: 12),
            _buildScheduleCard(
              status: 'SCHEDULED',
              statusColor: Colors.grey,
              id: '#PICK-8930',
              title: 'Old Monitor & CPU',
              time: '5:15 PM',
              distance: '1.2 km',
              isEnRoute: false,
            ),
            
            const SizedBox(height: 100), // Bottom padding
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: AppTheme.primaryColor,
        icon: const FaIcon(FontAwesomeIcons.plus, color: Colors.white, size: 16),
        label: const Text('Create Pickup', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      bottomNavigationBar: _buildMockNavBar(),
    );
  }

  Widget _buildCustomerCard({required String name, required String location, required String initials}) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppTheme.primaryLight,
            radius: 20,
            child: Text(initials, style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const FaIcon(FontAwesomeIcons.locationDot, size: 10, color: AppTheme.textSecondary),
                    const SizedBox(width: 4),
                    Text(location, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard({
    required String status,
    required Color statusColor,
    required String id,
    required String title,
    required String time,
    required String distance,
    required bool isEnRoute,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isEnRoute ? Border.all(color: Colors.blue.shade200, width: 2) : null,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 60,
            decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(4)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                      child: Text(status, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 8),
                    Text(id, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const FaIcon(FontAwesomeIcons.clock, size: 12, color: AppTheme.textSecondary),
                    const SizedBox(width: 4),
                    Text(time, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                    const SizedBox(width: 16),
                    const FaIcon(FontAwesomeIcons.locationDot, size: 12, color: AppTheme.textSecondary),
                    const SizedBox(width: 4),
                    Text(distance, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
            child: const FaIcon(FontAwesomeIcons.chevronRight, size: 12, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildMockNavBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -4))],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _navItem(icon: FontAwesomeIcons.house, label: 'Home', isActive: true),
            _navItem(icon: FontAwesomeIcons.clockRotateLeft, label: 'History', isActive: false),
            _navItem(icon: FontAwesomeIcons.solidUser, label: 'Profile', isActive: false),
            _navItem(icon: FontAwesomeIcons.gear, label: 'Settings', isActive: false),
          ],
        ),
      ),
    );
  }

  Widget _navItem({required IconData icon, required String label, required bool isActive}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FaIcon(icon, color: isActive ? const Color(0xFF1E2A5E) : Colors.grey.shade400, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isActive ? const Color(0xFF1E2A5E) : Colors.grey.shade500,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

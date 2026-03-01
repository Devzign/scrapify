import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/theme/app_theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Notifications', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 24)),
            Text('सूचनाएं', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(16)),
                child: Row(
                  children: const [
                    FaIcon(FontAwesomeIcons.checkDouble, size: 10, color: Colors.green),
                    SizedBox(width: 6),
                    Text('Mark all read', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ),
        ],
        backgroundColor: AppTheme.backgroundLight,
        elevation: 0,
        toolbarHeight: 80,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('TODAY / आज', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textSecondary, letterSpacing: 1.1)),
            const SizedBox(height: 16),
            
            _buildNotificationCard(
              icon: FontAwesomeIcons.truckFast,
              iconColor: Colors.green.shade700,
              iconBg: Colors.green.shade200,
              cardBg: Colors.green.shade50,
              borderColor: Colors.green.shade200,
              enTitle: 'Agent Arriving',
              hiTitle: 'एजेंट आ रहा है',
              desc: 'Your pickup agent is 5 mins away.',
              time: '10 mins ago',
              isUnread: true,
            ),
            const SizedBox(height: 16),
            
            _buildNotificationCard(
              icon: FontAwesomeIcons.squareCheck,
              iconColor: Colors.blue.shade700,
              iconBg: Colors.blue.shade100,
              cardBg: Colors.white,
              enTitle: 'Booking Confirmed',
              hiTitle: 'बुकिंग पक्की हो गई',
              desc: 'Pickup scheduled for tomorrow, 10 AM.',
              time: '1 hr ago',
              isUnread: false,
            ),
            
            const SizedBox(height: 32),
            const Text('YESTERDAY / कल', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textSecondary, letterSpacing: 1.1)),
            const SizedBox(height: 16),
            
            _buildNotificationCard(
              icon: FontAwesomeIcons.wallet,
              iconColor: Colors.orange.shade700,
              iconBg: Colors.orange.shade100,
              cardBg: Colors.white,
              enTitle: 'Payment Received',
              hiTitle: 'भुगतान प्राप्त हुआ',
              desc: '₹450 added to your wallet.',
              time: 'Yesterday',
              isUnread: false,
            ),
            const SizedBox(height: 16),
            
            _buildNotificationCard(
              icon: FontAwesomeIcons.bullhorn,
              iconColor: Colors.grey.shade700,
              iconBg: Colors.grey.shade200,
              cardBg: Colors.white,
              enTitle: 'Special Offer',
              hiTitle: 'विशेष प्रस्ताव',
              desc: 'Get extra 10% on copper waste this week.',
              time: '2 days ago',
              isUnread: false,
            ),
            
            const SizedBox(height: 100), // padding for navbar
          ],
        ),
      ),
      bottomNavigationBar: _buildMockNavBar(),
    );
  }

  Widget _buildNotificationCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required Color cardBg,
    required String enTitle,
    required String hiTitle,
    required String desc,
    required String time,
    required bool isUnread,
    Color? borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: borderColor != null ? Border.all(color: borderColor) : null,
        boxShadow: [
          if (borderColor == null) BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: FaIcon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(enTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    if (isUnread) Container(width: 8, height: 8, decoration: BoxDecoration(color: Colors.green.shade400, shape: BoxShape.circle)),
                  ],
                ),
                Text(hiTitle, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textSecondary, fontSize: 13)),
                const SizedBox(height: 8),
                Text(desc, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.4)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const FaIcon(FontAwesomeIcons.clock, size: 10, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(time, style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
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
            _navItem(icon: FontAwesomeIcons.house, label: 'Home', isActive: false),
            _navItem(icon: FontAwesomeIcons.calendarCheck, label: 'Book', isActive: false),
            _navItem(icon: FontAwesomeIcons.solidBell, label: 'Alerts', isActive: true, showDot: true),
            _navItem(icon: FontAwesomeIcons.wallet, label: 'Wallet', isActive: false),
            _navItem(icon: FontAwesomeIcons.solidUser, label: 'Profile', isActive: false),
          ],
        ),
      ),
    );
  }

  Widget _navItem({required IconData icon, required String label, required bool isActive, bool showDot = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: isActive ? const EdgeInsets.symmetric(horizontal: 16, vertical: 8) : EdgeInsets.zero,
              decoration: BoxDecoration(
                color: isActive ? Colors.green.shade50 : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: FaIcon(icon, color: isActive ? Colors.green : Colors.grey.shade400, size: 20),
            ),
            if (showDot)
              Positioned(
                top: 0,
                right: isActive ? 12 : -2,
                child: Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.green : Colors.grey.shade500,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
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
          children: [
            Text('notifications.title'.tr(), style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 24)),
            Text('notifications.title_hi'.tr(), style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.bold)),
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
                  children: [
                    const FaIcon(FontAwesomeIcons.checkDouble, size: 10, color: Colors.green),
                    const SizedBox(width: 6),
                    Text('notifications.mark_all_read'.tr(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
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
            Text('${'notifications.today'.tr()} / ${'notifications.today_hi'.tr()}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textSecondary, letterSpacing: 1.1)),
            const SizedBox(height: 16),
            
            _buildNotificationCard(
              icon: FontAwesomeIcons.truckFast,
              iconColor: Colors.green.shade700,
              iconBg: Colors.green.shade200,
              cardBg: Colors.green.shade50,
              borderColor: Colors.green.shade200,
              enTitle: 'notifications.agent_arriving'.tr(),
              hiTitle: 'notifications.agent_arriving_hi'.tr(),
              desc: 'notifications.agent_arriving_desc'.tr(),
              time: 'notifications.time_mins_ago'.tr(args: ['10']),
              isUnread: true,
            ),
            const SizedBox(height: 16),
            
            _buildNotificationCard(
              icon: FontAwesomeIcons.squareCheck,
              iconColor: Colors.blue.shade700,
              iconBg: Colors.blue.shade100,
              cardBg: Colors.white,
              enTitle: 'notifications.booking_confirmed'.tr(),
              hiTitle: 'notifications.booking_confirmed_hi'.tr(),
              desc: 'notifications.booking_confirmed_desc'.tr(),
              time: 'notifications.time_hr_ago'.tr(args: ['1']),
              isUnread: false,
            ),
            
            const SizedBox(height: 32),
            Text('${'notifications.yesterday'.tr()} / ${'notifications.yesterday_hi'.tr()}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textSecondary, letterSpacing: 1.1)),
            const SizedBox(height: 16),
            
            _buildNotificationCard(
              icon: FontAwesomeIcons.wallet,
              iconColor: Colors.orange.shade700,
              iconBg: Colors.orange.shade100,
              cardBg: Colors.white,
              enTitle: 'notifications.payment_received'.tr(),
              hiTitle: 'notifications.payment_received_hi'.tr(),
              desc: 'notifications.payment_received_desc'.tr(),
              time: 'notifications.time_yesterday'.tr(),
              isUnread: false,
            ),
            const SizedBox(height: 16),
            
            _buildNotificationCard(
              icon: FontAwesomeIcons.bullhorn,
              iconColor: Colors.grey.shade700,
              iconBg: Colors.grey.shade200,
              cardBg: Colors.white,
              enTitle: 'notifications.special_offer'.tr(),
              hiTitle: 'notifications.special_offer_hi'.tr(),
              desc: 'notifications.special_offer_desc'.tr(),
              time: 'notifications.time_days_ago'.tr(args: ['2']),
              isUnread: false,
            ),
            
            const SizedBox(height: 100), // padding for navbar
          ],
        ),
      ),
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
}
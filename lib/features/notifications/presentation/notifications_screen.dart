import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/loading_skeletons.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/notification_provider.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationState = ref.watch(notificationProvider);

    final textTheme = Theme.of(context).textTheme;
    return AppScaffold(
      appBar: AppBar(
        title: Text(
          context.locale.languageCode == 'hi'
              ? 'notifications.title_hi'.tr()
              : 'notifications.title'.tr(),
          style: textTheme.headlineMedium,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: InkWell(
                  onTap: () {
                    ref
                        .read(notificationProvider.notifier)
                        .readAllNotifications();
                  },
                  child: Row(
                    children: [
                      const FaIcon(
                        FontAwesomeIcons.checkDouble,
                        size: 10,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'notifications.mark_all_read'.tr(),
                        style: textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
        backgroundColor: AppTheme.backgroundLight,
        elevation: 0,
        toolbarHeight: 80,
      ),
      body: notificationState.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return Center(
              child: Text(
                context.locale.languageCode == 'hi'
                    ? 'कोई नोटिफिकेशन नहीं मिला।'
                    : 'No notifications found.',
                style: textTheme.bodyMedium,
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            itemCount: notifications.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final notif = notifications[index];
              return _buildNotificationCard(
                context: context,
                icon: FontAwesomeIcons.bell, // Or map based on notif type
                iconColor: Colors.blue.shade700,
                iconBg: Colors.blue.shade100,
                cardBg: notif.isRead ? Colors.white : Colors.blue.shade50,
                title: notif.title,
                desc: notif.body,
                time: notif.createdAt.toString(), // Format as needed
                isUnread: !notif.isRead,
                onTap: () {
                  if (!notif.isRead) {
                    ref
                        .read(notificationProvider.notifier)
                        .readNotification(notif.id);
                  }
                },
              );
            },
          );
        },
        loading: () => const NotificationListLoadingSkeleton(),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildNotificationCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required Color cardBg,
    required String title,
    required String desc,
    required String time,
    required bool isUnread,
    Color? borderColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: AppCard(
        padding: const EdgeInsets.all(20),
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: borderColor != null ? Border.all(color: borderColor) : null,
        boxShadow: borderColor == null ? AppTheme.e1 : null,
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
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      if (isUnread)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.green.shade400,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    desc,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const FaIcon(
                        FontAwesomeIcons.clock,
                        size: 10,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        time,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

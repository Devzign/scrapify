import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/loading_skeletons.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/notification_provider.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationProvider.notifier).getNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
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
        backgroundColor: AppTheme.backgroundLight,
        elevation: 0,
        toolbarHeight: 80,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: notificationState.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return null;
          }
          return SafeArea(
            child: SizedBox(
              width: 210,
              height: 48,
              child: FloatingActionButton.extended(
                heroTag: 'mark_all_read_fab',
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.textPrimary,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                onPressed: () {
                  ref
                      .read(notificationProvider.notifier)
                      .readAllNotifications();
                },
                icon: const FaIcon(
                  FontAwesomeIcons.checkDouble,
                  size: 12,
                  color: Colors.green,
                ),
                label: Text(
                  'notifications.mark_all_read'.tr(),
                  style: textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          );
        },
        loading: () => null,
        error: (_, __) => null,
      ),
      body: notificationState.when(
        data: (notifications) {
          final notifier = ref.read(notificationProvider.notifier);
          if (notifications.isEmpty) {
            return RefreshIndicator(
              onRefresh: notifier.getNotifications,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.55,
                    child: Center(
                      child: Text(
                        context.locale.languageCode == 'hi'
                            ? 'कोई नोटिफिकेशन नहीं मिला।'
                            : 'No notifications found.',
                        style: textTheme.bodyMedium,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: notifier.getNotifications,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              itemCount: notifications.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final notif = notifications[index];
                return _buildNotificationCard(
                  context: context,
                  icon: FontAwesomeIcons.bell, // Or map based on notif type
                  iconColor: AppTheme.primaryColor,
                  iconBg: AppTheme.primaryLight.withValues(alpha: 0.45),
                  cardBg: notif.isRead
                      ? Colors.white
                      : AppTheme.primaryLight.withValues(alpha: 0.22),
                  title: notif.title,
                  desc: notif.body,
                  time: DateFormat('dd MMM yyyy, hh:mm a').format(
                    notif.createdAt.toLocal(),
                  ),
                  isUnread: !notif.isRead,
                  onTap: () async {
                    if (!notif.isRead) {
                      final ok = await ref
                          .read(notificationProvider.notifier)
                          .readNotification(notif.id);
                      if (ok) {
                        await ref
                            .read(notificationProvider.notifier)
                            .getNotifications();
                      }
                    }
                  },
                );
              },
            ),
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
                      Expanded(
                        child: Text(
                          title,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_color.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_routes.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../auth/providers/auth_provider.dart';
import '../domain/models/pickup_assignment.dart';
import '../providers/pickup_boy_provider.dart';

class PickupBoyDashboard extends ConsumerStatefulWidget {
  const PickupBoyDashboard({super.key});

  @override
  ConsumerState<PickupBoyDashboard> createState() => _PickupBoyDashboardState();
}

class _PickupBoyDashboardState extends ConsumerState<PickupBoyDashboard>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.microtask(() {
      ref.read(pickupBoyProvider.notifier).loadDashboard();
      ref.read(pickupBoyProvider.notifier).loadAssignments();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pickupBoyProvider);
    final isOnline = state.dashboard?.isOnline ?? true;

    return AppScaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'pickup_dashboard.title'.tr(),
          style: const TextStyle(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(
              Icons.logout_rounded,
              color: AppColor.error,
            ),
            onPressed: _logout,
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _OnlineToggle(
        isOnline: isOnline,
        isLoading: state.isActionLoading,
        onChanged: (v) => ref.read(pickupBoyProvider.notifier).toggleOnline(v),
      ),
      body: Column(
        children: [
          if (state.dashboard != null) _buildSummaryStrip(state.dashboard!),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: AppCard(
              padding: const EdgeInsets.all(6),
              child: TabBar(
                controller: _tabController,
                onTap: (_) =>
                    ref.read(pickupBoyProvider.notifier).loadAssignments(),
                indicator: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: Colors.white,
                unselectedLabelColor: AppTheme.textSecondary,
                labelStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
                tabs: [
                  Tab(text: 'pickup_dashboard.pending'.tr()),
                  Tab(text: 'pickup_dashboard.completed'.tr()),
                ],
              ),
            ),
          ),
          Expanded(
            child: Builder(
              builder: (context) {
                if (state.error != null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.error!)),
                      );
                      ref.read(pickupBoyProvider.notifier).clearError();
                    }
                  });
                }
                final pending = state.assignments
                    .where((a) => a.status != 'completed')
                    .toList();
                final completed = state.assignments
                    .where((a) => a.status == 'completed')
                    .toList();
                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildAssignmentList(
                      context,
                      pending,
                      isLoading: state.isLoading,
                      emptyTitle: context.locale.languageCode == 'hi'
                          ? 'अभी कोई पेंडिंग पिकअप नहीं है'
                          : 'No pending pickups yet',
                      emptySubtitle: context.locale.languageCode == 'hi'
                          ? 'नई पिकअप असाइन होते ही यहां दिखाई देगी।'
                          : 'New pickups will appear here as they are assigned.',
                      emptyIcon: FontAwesomeIcons.clipboardList,
                    ),
                    _buildAssignmentList(
                      context,
                      completed,
                      isLoading: state.isLoading,
                      emptyTitle: context.locale.languageCode == 'hi'
                          ? 'अभी कोई पूर्ण पिकअप नहीं है'
                          : 'No completed pickups yet',
                      emptySubtitle: context.locale.languageCode == 'hi'
                          ? 'पिकअप पूरा होते ही यहां दिखाई देगा।'
                          : 'Completed pickups will be listed here.',
                      emptyIcon: FontAwesomeIcons.boxArchive,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await ref.read(authProvider.notifier).logout();
    }
  }

  Widget _buildSummaryStrip(dynamic dashboard) {
    final pending = (dashboard.pendingCount ?? 0).toString();
    final completed = (dashboard.completedCount ?? 0).toString();
    final greeting = dashboard.pickupBoy?.name ?? '';
    final isHindi = context.locale.languageCode == 'hi';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: _StatTile(
              icon: FontAwesomeIcons.truckFast,
              label: isHindi ? 'पेंडिंग' : 'Pending',
              value: pending,
              color: AppColor.primary,
            ),
          ),
          const SizedBox(width: AppTheme.space12),
          Expanded(
            child: _StatTile(
              icon: FontAwesomeIcons.circleCheck,
              label: isHindi ? 'पूर्ण' : 'Completed',
              value: completed,
              color: AppColor.brandNavy,
            ),
          ),
          const SizedBox(width: AppTheme.space12),
          Expanded(
            child: _StatTile(
              icon: FontAwesomeIcons.userTie,
              label: isHindi ? 'पार्टनर' : 'Partner',
              value: greeting.isEmpty
                  ? '—'
                  : (greeting.split(' ').first.length > 8
                      ? '${greeting.split(' ').first.substring(0, 8)}…'
                      : greeting.split(' ').first),
              color: AppColor.warning,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignmentList(
    BuildContext context,
    List<PickupAssignment> assignments, {
    required bool isLoading,
    required String emptyTitle,
    required String emptySubtitle,
    required IconData emptyIcon,
  }) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (assignments.isEmpty) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 140),
        children: [
          AppCard(
            padding: const EdgeInsets.all(28),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColor.primarySurface,
                    shape: BoxShape.circle,
                  ),
                  child: FaIcon(
                    emptyIcon,
                    size: 26,
                    color: AppColor.primary,
                  ),
                ),
                const SizedBox(height: AppTheme.space16),
                Text(
                  emptyTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColor.textPrimary,
                  ),
                ),
                const SizedBox(height: AppTheme.space8),
                Text(
                  emptySubtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColor.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(pickupBoyProvider.notifier).loadAssignments();
        await ref.read(pickupBoyProvider.notifier).loadDashboard();
      },
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 140),
        itemCount: assignments.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppTheme.space12),
        itemBuilder: (context, index) =>
            _buildPickupCard(context, assignments[index]),
      ),
    );
  }

  Widget _buildPickupCard(BuildContext context, PickupAssignment assignment) {
    return AppCard(
      onTap: () =>
          context.push('${AppRoutes.pickupBoyDetail}/${assignment.id}'),
      padding: const EdgeInsets.all(AppTheme.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColor.primarySurface,
                  borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                  border: Border.all(color: AppColor.primaryLight),
                ),
                child: Text(
                  assignment.orderCode,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColor.primaryDark,
                    fontSize: 12,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.schedule_rounded,
                    size: 14,
                    color: AppColor.textMuted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(assignment.scheduledAt),
                    style: const TextStyle(
                      color: AppColor.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppTheme.space16),
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColor.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_rounded,
                  size: 22,
                  color: AppColor.primaryDark,
                ),
              ),
              const SizedBox(width: AppTheme.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      assignment.customerName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: AppColor.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const FaIcon(
                          FontAwesomeIcons.locationDot,
                          size: 11,
                          color: AppColor.textMuted,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            assignment.address,
                            style: const TextStyle(
                              color: AppColor.textSecondary,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _QuickIconAction(
                icon: FontAwesomeIcons.phone,
                color: AppColor.info,
                onPressed: () async {
                  final phone = assignment.customerPhone;
                  if (phone.isNotEmpty) {
                    final uri = Uri.parse('tel:$phone');
                    if (await canLaunchUrl(uri)) launchUrl(uri);
                  }
                },
              ),
              const SizedBox(width: AppTheme.space8),
              _QuickIconAction(
                icon: FontAwesomeIcons.mapLocationDot,
                color: AppColor.error,
                onPressed: () async {
                  final lat = assignment.latitude;
                  final lng = assignment.longitude;
                  final addr = assignment.address;
                  Uri uri;
                  if (lat != null && lng != null) {
                    uri = Uri.parse(
                      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng',
                    );
                  } else if (addr.isNotEmpty) {
                    uri = Uri.parse(
                      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(addr)}',
                    );
                  } else {
                    return;
                  }
                  if (await canLaunchUrl(uri)) {
                    launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
              ),
            ],
          ),
          if (assignment.expectedItems.isNotEmpty) ...[
            const SizedBox(height: AppTheme.space12),
            Container(
              padding: const EdgeInsets.all(AppTheme.space12),
              decoration: BoxDecoration(
                color: AppColor.backgroundCream,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(color: AppColor.hairline),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.locale.languageCode == 'hi'
                        ? 'अपेक्षित आइटम'
                        : 'EXPECTED ITEMS',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppColor.primary,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: AppTheme.space8),
                  ...assignment.expectedItems.map((item) {
                    final langCode = context.locale.languageCode;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColor.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item.localizedName(langCode),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColor.textPrimary,
                              ),
                            ),
                          ),
                          if (item.quantity > 1)
                            Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: Text(
                                'x${item.quantity}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColor.textSecondary,
                                ),
                              ),
                            ),
                          if (item.weightKg != null)
                            Text(
                              '${item.weightKg!.toStringAsFixed(1)} kg',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColor.textMuted,
                              ),
                            ),
                        ],
                      ),
                    );
                  }),
                  if (assignment.estimatedWeightKg != null) ...[
                    const Divider(height: 16, color: AppColor.hairline),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          context.locale.languageCode == 'hi'
                              ? 'अनुमानित वज़न'
                              : 'Total Est. Weight',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColor.textSecondary,
                          ),
                        ),
                        Text(
                          '~ ${assignment.estimatedWeightKg!.toStringAsFixed(1)} kg',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColor.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ] else if (assignment.itemsSummary != null &&
              assignment.itemsSummary!.isNotEmpty) ...[
            const SizedBox(height: AppTheme.space12),
            Container(
              padding: const EdgeInsets.all(AppTheme.space12),
              decoration: BoxDecoration(
                color: AppColor.backgroundCream,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(color: AppColor.hairline),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Items',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColor.textMuted,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        assignment.itemsSummary!,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColor.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  if (assignment.estimatedWeightKg != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Est. Weight',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColor.textMuted,
                            letterSpacing: 0.4,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '~ ${assignment.estimatedWeightKg!.toStringAsFixed(1)} kg',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColor.textPrimary,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppTheme.space16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context
                      .push('${AppRoutes.pickupBoyDetail}/${assignment.id}'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColor.textSecondary,
                    side: const BorderSide(color: AppColor.outline),
                    minimumSize: const Size(double.infinity, 46),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                  ),
                  child: Text(
                    'pickup_dashboard.reschedule'.tr(),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.space12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => context
                      .push('${AppRoutes.pickupBoyDetail}/${assignment.id}'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 46),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                  ),
                  icon: const FaIcon(FontAwesomeIcons.play, size: 12),
                  label: Text(
                    'pickup_dashboard.start_pickup'.tr(),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(String scheduledAt) {
    try {
      final dt = DateTime.parse(scheduledAt);
      return '${dt.day}/${dt.month} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return scheduledAt;
    }
  }
}

class _OnlineToggle extends StatelessWidget {
  final bool isOnline;
  final bool isLoading;
  final ValueChanged<bool> onChanged;

  const _OnlineToggle({
    required this.isOnline,
    required this.isLoading,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
        border: Border.all(
          color: isOnline ? AppColor.primaryLight : AppColor.outline,
        ),
        boxShadow: AppTheme.e2,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isOnline ? AppColor.primary : AppColor.textMuted,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isOnline
                ? (context.locale.languageCode == 'hi' ? 'सक्रिय' : 'Active')
                : (context.locale.languageCode == 'hi' ? 'निष्क्रिय' : 'Inactive'),
            style: TextStyle(
              color: isOnline ? AppColor.primaryDark : AppColor.textSecondary,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          Switch(
            value: isOnline,
            onChanged: isLoading ? null : onChanged,
            activeTrackColor: AppColor.primary.withValues(alpha: 0.5),
            activeThumbColor: AppColor.primary,
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: FaIcon(icon, size: 14, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColor.textPrimary,
              height: 1.1,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColor.textSecondary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickIconAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _QuickIconAction({
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      child: Container(
        width: 38,
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: color.withValues(alpha: 0.20)),
        ),
        child: FaIcon(icon, size: 14, color: color),
      ),
    );
  }
}

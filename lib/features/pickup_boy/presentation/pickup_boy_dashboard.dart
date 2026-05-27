import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/utils/app_routes.dart';
import '../../../core/theme/app_color.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/dashboard_stat_card.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/status_badge.dart';
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
      backgroundColor: AppColor.backgroundLight,
      appBar: _buildModernAppBar(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _OnlineToggle(
        isOnline: isOnline,
        isLoading: state.isActionLoading,
        onChanged: (v) => ref.read(pickupBoyProvider.notifier).toggleOnline(v),
      ),
      body: Column(
        children: [
          if (state.dashboard != null) _buildModernSummaryCards(state.dashboard!),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: AppCard(
              padding: const EdgeInsets.all(6),
              child: TabBar(
                controller: _tabController,
                onTap: (index) {
                  final status = index == 0 ? 'active' : 'completed';
                  ref.read(pickupBoyProvider.notifier).loadAssignments(status: status);
                },
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
                  letterSpacing: -0.2,
                ),
                tabs: [
                  Tab(text: 'pickup_partner_dashboard.pending'.tr()),
                  Tab(text: 'pickup_partner_dashboard.completed_today'.tr()),
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
                      emptyTitle:
                          'pickup_partner_dashboard.no_pickups'.tr(),
                      emptySubtitle:
                          'pickup_partner_dashboard.no_pickups_subtitle'.tr(),
                      emptyIcon: FontAwesomeIcons.clipboardList,
                    ),
                    _buildAssignmentList(
                      context,
                      completed,
                      isLoading: state.isLoading,
                      emptyTitle:
                          'pickup_partner_dashboard.no_completed_pickups'.tr(),
                      emptySubtitle:
                          'pickup_partner_dashboard.no_completed_pickups_subtitle'.tr(),
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

  /// Modern app bar with gradient
  AppBar _buildModernAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: AppColor.primary,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColor.primary,
              AppColor.primaryDark,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      title: Text(
        'pickup_partner_dashboard.title'.tr(),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 18,
          letterSpacing: -0.3,
        ),
      ),
      actions: [
        GestureDetector(
          onTap: _logout,
          child: Container(
            margin: const EdgeInsets.only(right: AppTheme.space16),
            padding: const EdgeInsets.all(AppTheme.space8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
              ),
            ),
            child: const Icon(
              Icons.logout_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),
      ],
    );
  }

  /// Modern summary cards
  Widget _buildModernSummaryCards(dynamic dashboard) {
    final pending = dashboard.pendingCount ?? 0;
    final completed = dashboard.completedCount ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.space12,
        vertical: AppTheme.space12,
      ),
      child: Row(
        children: [
          Expanded(
            child: DashboardStatCard(
              label: 'pickup_partner_dashboard.pending'.tr(),
              value: '$pending',
              icon: Icons.schedule_rounded,
              iconColor: AppColor.warning,
              valueColor: AppColor.warning,
              backgroundColor: AppColor.surface,
            ),
          ),
          const SizedBox(width: AppTheme.space12),
          Expanded(
            child: DashboardStatCard(
              label: 'pickup_partner_dashboard.completed_today'.tr(),
              value: '$completed',
              icon: Icons.check_circle_rounded,
              iconColor: AppColor.success,
              valueColor: AppColor.success,
              backgroundColor: AppColor.surface,
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
          EmptyStateWidget(
            icon: emptyIcon,
            title: emptyTitle,
            subtitle: emptySubtitle,
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 140),
      itemCount: assignments.length,
      itemBuilder: (context, index) {
        final assignment = assignments[index];
        return _buildModernAssignmentCard(context, assignment, ref);
      },
    );
  }

  /// Modern pickup card with CTAs
  Widget _buildModernAssignmentCard(
    BuildContext context,
    PickupAssignment assignment,
    WidgetRef ref,
  ) {
    final isPending = assignment.status != 'completed';

    return GestureDetector(
      onTap: () => context.go('${AppRoutes.pickupBoyDetail}/${assignment.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppTheme.space12),
        decoration: BoxDecoration(
          color: AppColor.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(color: AppColor.cardBorder, width: 0.5),
          boxShadow: AppTheme.e1,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.space16),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Customer name + Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        assignment.customerName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColor.textPrimary,
                          letterSpacing: -0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${assignment.id}"}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: AppColor.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                StatusBadge(status: assignment.status),
              ],
            ),
            const SizedBox(height: AppTheme.space12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  FontAwesomeIcons.mapPin,
                  color: AppColor.textSecondary,
                  size: 13,
                ),
                const SizedBox(width: AppTheme.space8),
                Expanded(
                  child: Text(
                    assignment.address,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColor.textSecondary,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.space12),

            if (assignment.itemsSummary != null && assignment.itemsSummary!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'pickup_partner_dashboard.items_to_pickup'.tr(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColor.textPrimary,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    assignment.itemsSummary!,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColor.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: AppTheme.space12),
                ],
              ),

            if (assignment.scheduledAt.isNotEmpty)
              Row(
                children: [
                  Icon(
                    FontAwesomeIcons.clock,
                    color: AppColor.textMuted,
                    size: 12,
                  ),
                  const SizedBox(width: AppTheme.space8),
                  Text(
                    assignment.scheduledAt,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColor.textMuted,
                    ),
                  ),
                ],
              ),

            if (isPending)
              Padding(
                padding: const EdgeInsets.only(top: AppTheme.space16),
                child: Wrap(
                  spacing: AppTheme.space8,
                  runSpacing: AppTheme.space8,
                  children: [
                    _buildCTAButton(
                      label: 'Start Pickup',
                      icon: Icons.play_arrow_rounded,
                      isPrimary: true,
                      onTap: () {
                        // Navigate to detail page
                        context.go('${AppRoutes.pickupBoyDetail}/${assignment.id}');
                      },
                    ),
                    _buildCTAButton(
                      label: 'Call',
                      icon: Icons.phone_rounded,
                      isPrimary: false,
                      onTap: () async {
                        try {
                          final phone = assignment.customerPhone;
                          if (phone.isNotEmpty) {
                            final uri = Uri(scheme: 'tel', path: phone);
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri);
                            } else if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Cannot open phone dialer')),
                              );
                            }
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        }
                      },
                    ),
                    _buildCTAButton(
                      label: 'Navigate',
                      icon: Icons.location_on_rounded,
                      isPrimary: false,
                      onTap: () async {
                        try {
                          final lat = assignment.latitude;
                          final lng = assignment.longitude;
                          if (lat != null && lng != null && lat != 0.0 && lng != 0.0) {
                            final mapsUrl = Uri.parse('https://maps.google.com/?q=$lat,$lng');
                            if (await canLaunchUrl(mapsUrl)) {
                              await launchUrl(mapsUrl, mode: LaunchMode.externalApplication);
                            } else if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Cannot open maps')),
                              );
                            }
                          } else if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Location not available')),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildCTAButton({
    required String label,
    required IconData icon,
    required bool isPrimary,
    required VoidCallback onTap,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Opacity(
        opacity: isLoading ? 0.7 : 1.0,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.space10,
            vertical: AppTheme.space6,
          ),
          decoration: BoxDecoration(
            color: isPrimary ? AppColor.primary : AppColor.primaryLight,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLoading)
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(
                      isPrimary ? AppColor.textOnPrimary : AppColor.primary,
                    ),
                  ),
                )
              else
                Icon(
                  icon,
                  color: isPrimary ? AppColor.textOnPrimary : AppColor.primary,
                  size: 13,
                ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isPrimary ? AppColor.textOnPrimary : AppColor.primary,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnlineToggle extends StatelessWidget {
  final bool isOnline;
  final bool isLoading;
  final Function(bool) onChanged;

  const _OnlineToggle({
    required this.isOnline,
    required this.isLoading,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: isOnline ? AppColor.success : AppColor.error,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            isOnline ? 'Online' : 'Offline',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColor.textPrimary,
            ),
          ),
          const SizedBox(width: 16),
          isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation(AppColor.primary),
                  ),
                )
              : GestureDetector(
                  onTap: () => onChanged(!isOnline),
                  child: Container(
                    width: 44,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isOnline
                          ? AppColor.success.withValues(alpha: 0.2)
                          : AppColor.error.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Align(
                      alignment: isOnline
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        width: 20,
                        height: 20,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: isOnline ? AppColor.success : AppColor.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

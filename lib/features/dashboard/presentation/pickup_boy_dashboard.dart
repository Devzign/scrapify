import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../pickup_boy/domain/models/pickup_assignment.dart';
import '../../pickup_boy/providers/pickup_boy_provider.dart';

class PickupBoyDashboard extends ConsumerStatefulWidget {
  const PickupBoyDashboard({super.key});

  @override
  ConsumerState<PickupBoyDashboard> createState() => _PickupBoyDashboardState();
}

class _PickupBoyDashboardState extends ConsumerState<PickupBoyDashboard> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(pickupBoyProvider.notifier).loadDashboard();
      ref.read(pickupBoyProvider.notifier).loadAssignments(status: 'pending');
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pickupBoyProvider);
    final isOnline = state.dashboard?.isOnline ?? true;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundLight,
        appBar: AppBar(
          title: Text(
            'pickup_dashboard.title'.tr(),
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          actions: [
            Row(
              children: [
                Text(
                  isOnline
                      ? 'pickup_dashboard.active'.tr()
                      : 'pickup_dashboard.offline'.tr(),
                  style: TextStyle(
                    color: isOnline ? AppTheme.primaryColor : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Switch(
                  value: isOnline,
                  onChanged: state.isActionLoading
                      ? null
                      : (val) {
                          ref.read(pickupBoyProvider.notifier).toggleOnline(val);
                        },
                  activeTrackColor: AppTheme.primaryColor.withValues(alpha: 0.5),
                  activeThumbColor: AppTheme.primaryColor,
                ),
              ],
            ),
          ],
          bottom: TabBar(
            labelColor: AppTheme.primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppTheme.primaryColor,
            indicatorWeight: 3,
            onTap: (index) {
              if (index == 0) {
                ref.read(pickupBoyProvider.notifier).loadAssignments(status: 'pending');
              } else {
                ref.read(pickupBoyProvider.notifier).loadAssignments(status: 'completed');
              }
            },
            tabs: [
              Tab(
                child: Text(
                  'pickup_dashboard.pending'.tr(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Tab(
                child: Text(
                  'pickup_dashboard.completed'.tr(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        body: Builder(builder: (context) {
          if (state.error != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.error!),
                    backgroundColor: Colors.red,
                  ),
                );
                ref.read(pickupBoyProvider.notifier).clearError();
              }
            });
          }
          return TabBarView(
            children: [
              _buildAssignmentList(context, state.assignments),
              _buildAssignmentList(context, state.assignments),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildAssignmentList(BuildContext context, List<PickupAssignment> assignments) {
    final state = ref.watch(pickupBoyProvider);

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (assignments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const FaIcon(FontAwesomeIcons.clipboardList, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'pickup_dashboard.no_completed'.tr(),
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: assignments.length,
      itemBuilder: (context, index) {
        return _buildPickupCard(context, assignments[index]);
      },
    );
  }

  Widget _buildPickupCard(BuildContext context, PickupAssignment assignment) {
    return GestureDetector(
      onTap: () => context.push('/pickup-boy/pickups/${assignment.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    assignment.orderCode,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryDark,
                      fontSize: 12,
                    ),
                  ),
                ),
                Text(
                  _formatDate(assignment.scheduledAt),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person, color: Colors.grey),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        assignment.customerName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const FaIcon(FontAwesomeIcons.locationDot,
                              size: 12, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              assignment.address,
                              style: const TextStyle(color: Colors.grey, fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    _buildQuickActionButton(
                      icon: FontAwesomeIcons.phone,
                      color: Colors.blue,
                      onPressed: () {
                        // Call customer
                      },
                    ),
                    const SizedBox(width: 8),
                    _buildQuickActionButton(
                      icon: FontAwesomeIcons.mapLocationDot,
                      color: Colors.red,
                      onPressed: () {
                        // Open map
                      },
                    ),
                  ],
                ),
              ],
            ),
            if (assignment.itemsSummary != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('pickup_dashboard.items'.tr(),
                            style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        Text(
                          assignment.itemsSummary!,
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    if (assignment.estimatedWeightKg != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('pickup_dashboard.est_weight'.tr(),
                              style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          Text(
                            '~ ${assignment.estimatedWeightKg!.toStringAsFixed(1)} kg',
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        context.push('/pickup-boy/pickups/${assignment.id}'),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300),
                      foregroundColor: AppTheme.textSecondary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text('pickup_dashboard.reschedule'.tr()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        context.push('/pickup-boy/pickups/${assignment.id}'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const FaIcon(FontAwesomeIcons.play,
                            size: 14, color: Colors.white),
                        const SizedBox(width: 8),
                        Text('pickup_dashboard.start_pickup'.tr()),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: FaIcon(icon, size: 16, color: color),
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

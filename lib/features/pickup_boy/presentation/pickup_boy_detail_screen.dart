import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_color.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/utils/app_routes.dart';
import '../providers/pickup_boy_provider.dart';

class PickupBoyDetailScreen extends ConsumerStatefulWidget {
  final int pickupId;
  const PickupBoyDetailScreen({super.key, required this.pickupId});

  @override
  ConsumerState<PickupBoyDetailScreen> createState() =>
      _PickupBoyDetailScreenState();
}

class _PickupBoyDetailScreenState extends ConsumerState<PickupBoyDetailScreen> {
  Map<String, dynamic>? _detail;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final repo = ref.read(pickupBoyRepositoryProvider);
    final result = await repo.getPickupDetail(widget.pickupId);
    if (mounted) {
      setState(() {
        _loading = false;
        if (result.isSuccess) {
          _detail = _normalizeDetail(result.data!);
        } else {
          _error = result.errorMessage;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pickupBoyProvider);

    return AppScaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text(
          _detail?['order_code']?.toString() ??
              _detail?['pickup_code']?.toString() ??
              'Pickup #${widget.pickupId}',
          style: const TextStyle(
            color: AppColor.textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 17,
          ),
        ),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColor.primarySurface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColor.primary.withValues(alpha: 0.20)),
            ),
            child: const Icon(Icons.arrow_back_rounded, color: AppColor.primary, size: 18),
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError()
              : _buildContent(context, state),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: AppCard(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColor.errorTint,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  size: 28,
                  color: AppColor.error,
                ),
              ),
              const SizedBox(height: AppTheme.space16),
              const Text(
                'Could not load pickup',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColor.textPrimary,
                ),
              ),
              const SizedBox(height: AppTheme.space8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColor.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: AppTheme.space20),
              CustomButton(text: 'Retry', onPressed: _loadDetail),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, PickupBoyState state) {
    final status = _resolvedStatus(_detail);

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StatusBadge(status: status),
                const SizedBox(height: AppTheme.space16),
                _InfoCard(
                  title: 'Customer Details',
                  icon: FontAwesomeIcons.user,
                  children: [
                    _InfoRow(
                      label: 'Name',
                      value: _detail?['customer_name']?.toString() ?? '-',
                    ),
                    _InfoRow(
                      label: 'Phone',
                      value: _detail?['customer_phone']?.toString() ?? '-',
                    ),
                    _InfoRow(
                      label: 'Address',
                      value: _detail?['address']?.toString() ?? '-',
                    ),
                    _InfoRow(
                      label: 'Scheduled',
                      value: _formatDate(
                        _detail?['scheduled_at']?.toString() ?? '',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.space16),
                if (_detail?['items'] != null &&
                    (_detail!['items'] as List).isNotEmpty) ...[
                  _InfoCard(
                    title: 'Expected Items',
                    icon: FontAwesomeIcons.box,
                    children: [
                      ...(_detail!['items'] as List<dynamic>)
                          .whereType<Map<String, dynamic>>()
                          .map((item) {
                        final rawCat = item['category_name'];
                        String catName;
                        if (rawCat is Map) {
                          catName = rawCat['en']?.toString() ??
                              rawCat.values.first?.toString() ??
                              'Item';
                        } else {
                          catName = rawCat?.toString() ??
                              item['item_name']?.toString() ??
                              'Item';
                        }
                        final weightKg = item['weight_kg']?.toString() ??
                            item['expected_weight']?.toString() ??
                            '-';
                        final qty = item['quantity']?.toString() ?? '-';
                        return _InfoRow(
                          label: catName,
                          value: 'Qty: $qty | Wt: $weightKg kg',
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: AppTheme.space16),
                ],
                Row(
                  children: [
                    Expanded(
                      child: _CallButton(
                        icon: FontAwesomeIcons.phone,
                        label: 'Call Customer',
                        color: AppColor.info,
                        onPressed: () async {
                          final phone =
                              _detail?['customer_phone']?.toString();
                          if (phone != null && phone.isNotEmpty) {
                            final uri = Uri.parse('tel:$phone');
                            if (await canLaunchUrl(uri)) launchUrl(uri);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: AppTheme.space12),
                    Expanded(
                      child: _CallButton(
                        icon: FontAwesomeIcons.mapLocationDot,
                        label: 'Navigate',
                        color: AppColor.error,
                        onPressed: () async {
                          final lat = _detail?['latitude']?.toString();
                          final lng = _detail?['longitude']?.toString();
                          final addr =
                              _detail?['address']?.toString() ?? '';
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
                            launchUrl(uri,
                                mode: LaunchMode.externalApplication);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          decoration: const BoxDecoration(
            color: AppColor.surface,
            border: Border(top: BorderSide(color: AppColor.hairline)),
          ),
          child: SafeArea(
            top: false,
            child: state.isActionLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildActionButtons(context, status),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, String status) {
    switch (status) {
      case 'assigned':
        return Row(
          children: [
            Expanded(
              child: CustomButton(
                text: 'Reject',
                variant: AppButtonVariant.outline,
                backgroundColor: AppColor.error,
                textColor: AppColor.error,
                minHeight: 50,
                onPressed: () => _rejectPickup(context),
              ),
            ),
            const SizedBox(width: AppTheme.space12),
            Expanded(
              flex: 2,
              child: CustomButton(
                text: 'Accept Pickup',
                variant: AppButtonVariant.primary,
                minHeight: 50,
                onPressed: () => _acceptPickup(context),
              ),
            ),
          ],
        );

      case 'accepted':
        return Column(
          children: [
            CustomButton(
              text: 'On The Way',
              variant: AppButtonVariant.primary,
              minHeight: 50,
              leading: const FaIcon(
                FontAwesomeIcons.truck,
                size: 14,
                color: Colors.white,
              ),
              onPressed: () => _updateStatus(context, 'on_the_way'),
            ),
            const SizedBox(height: AppTheme.space8),
            CustomButton(
              text: 'Request Reschedule',
              variant: AppButtonVariant.outline,
              backgroundColor: AppColor.warning,
              textColor: AppColor.warning,
              minHeight: 50,
              leading: const Icon(
                Icons.schedule_rounded,
                size: 16,
                color: AppColor.warning,
              ),
              onPressed: () => context
                  .push('${AppRoutes.agentReschedule}/${widget.pickupId}'),
            ),
          ],
        );

      case 'on_the_way':
        return CustomButton(
          text: 'Mark Arrived',
          variant: AppButtonVariant.primary,
          backgroundColor: AppColor.warning,
          minHeight: 50,
          leading: const Icon(
            Icons.location_on_rounded,
            size: 16,
            color: Colors.white,
          ),
          onPressed: () => _updateStatus(context, 'arrived'),
        );

      case 'arrived':
        return CustomButton(
          text: 'Start Verification',
          variant: AppButtonVariant.primary,
          minHeight: 50,
          leading: const FaIcon(
            FontAwesomeIcons.magnifyingGlass,
            size: 14,
            color: Colors.white,
          ),
          onPressed: () async {
            await context.push(
              '/pickup-boy/pickups/${widget.pickupId}/verify',
            );
            if (!mounted) return;
            await _loadDetail();
            final notifier = ref.read(pickupBoyProvider.notifier);
            notifier.loadAssignments();
            notifier.loadDashboard();
          },
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Future<void> _acceptPickup(BuildContext context) async {
    final notifier = ref.read(pickupBoyProvider.notifier);
    final ok = await notifier.acceptPickup(widget.pickupId);
    if (!context.mounted) return;
    if (ok) {
      // Optimistic UI update — propagate the new status across every status field
      // we look at in `_resolvedStatus`. We deliberately do NOT call `_loadDetail()`
      // afterwards: the GET endpoint can briefly return cached/stale data which
      // would otherwise overwrite the optimistic update and confuse the user.
      if (mounted && _detail != null) {
        setState(() {
          final updated = Map<String, dynamic>.from(_detail!)
            ..['status'] = 'accepted'
            ..['pickup_status'] = 'accepted';
          if (updated['assignment'] is Map<String, dynamic>) {
            updated['assignment'] = Map<String, dynamic>.from(
              updated['assignment'] as Map<String, dynamic>,
            )..['status'] = 'accepted';
          }
          if (updated['pickup_request'] is Map<String, dynamic>) {
            updated['pickup_request'] = Map<String, dynamic>.from(
              updated['pickup_request'] as Map<String, dynamic>,
            )..['status'] = 'accepted';
          }
          _detail = updated;
        });
      }
      // Refresh sibling screens so the dashboard/list reflect the change.
      notifier.loadAssignments();
      notifier.loadDashboard();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pickup accepted!')),
      );
    } else {
      final error = ref.read(pickupBoyProvider).error;
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
        notifier.clearError();
      }
    }
  }

  Future<void> _rejectPickup(BuildContext context) async {
    final ok = await ref
        .read(pickupBoyProvider.notifier)
        .rejectPickup(widget.pickupId);
    if (!context.mounted) {
      return;
    }
    if (ok) {
      context.pop();
    }
  }

  Future<void> _updateStatus(BuildContext context, String newStatus) async {
    final notifier = ref.read(pickupBoyProvider.notifier);
    final ok = await notifier.updateStatus(widget.pickupId, newStatus);
    if (!context.mounted) return;
    if (ok) {
      // Optimistic UI update across every status field. We do NOT re-fetch the
      // detail here — an immediate GET can return cached/stale data that would
      // overwrite the new status and force the user to navigate away and back.
      if (mounted && _detail != null) {
        setState(() {
          final updated = Map<String, dynamic>.from(_detail!)
            ..['status'] = newStatus
            ..['pickup_status'] = newStatus;
          if (updated['assignment'] is Map<String, dynamic>) {
            updated['assignment'] = Map<String, dynamic>.from(
              updated['assignment'] as Map<String, dynamic>,
            )..['status'] = newStatus;
          }
          if (updated['pickup_request'] is Map<String, dynamic>) {
            updated['pickup_request'] = Map<String, dynamic>.from(
              updated['pickup_request'] as Map<String, dynamic>,
            )..['status'] = newStatus;
          }
          _detail = updated;
        });
      }
      // Refresh sibling screens so the dashboard/list reflect the change.
      notifier.loadAssignments();
      notifier.loadDashboard();
      if (!context.mounted) return;
      final label = newStatus.replaceAll('_', ' ');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status updated to $label')),
      );
    } else {
      final error = ref.read(pickupBoyProvider).error;
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
        notifier.clearError();
      }
    }
  }

  String _formatDate(String dt) {
    try {
      final d = DateTime.parse(dt);
      return '${d.day}/${d.month}/${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return dt;
    }
  }

  String _resolvedStatus(Map<String, dynamic>? detail) {
    if (detail == null) {
      return 'assigned';
    }

    final candidates = <String>[];
    final direct = detail['status']?.toString().toLowerCase();
    if (direct != null && direct.isNotEmpty) candidates.add(direct);
    final pickupStatus = detail['pickup_status']?.toString().toLowerCase();
    if (pickupStatus != null && pickupStatus.isNotEmpty) {
      candidates.add(pickupStatus);
    }
    final assignment = detail['assignment'];
    if (assignment is Map<String, dynamic>) {
      final assignmentStatus = assignment['status']?.toString().toLowerCase();
      if (assignmentStatus != null && assignmentStatus.isNotEmpty) {
        candidates.add(assignmentStatus);
      }
    }

    final pickupRequest = detail['pickup_request'];
    if (pickupRequest is Map<String, dynamic>) {
      final requestStatus = pickupRequest['status']?.toString().toLowerCase();
      if (requestStatus != null && requestStatus.isNotEmpty) {
        candidates.add(requestStatus);
      }
    }

    const order = <String, int>{
      'assigned': 1,
      'accepted': 2,
      'on_the_way': 3,
      'arrived': 4,
      'verifying': 5,
      'completed': 6,
      'rejected': 0,
      'cancelled': 0,
    };
    if (candidates.isNotEmpty) {
      candidates.sort((a, b) => (order[a] ?? -1).compareTo(order[b] ?? -1));
      return candidates.last;
    }

    return 'assigned';
  }

  Map<String, dynamic> _normalizeDetail(Map<String, dynamic> raw) {
    if (raw['pickup'] is Map<String, dynamic>) {
      final pickup = Map<String, dynamic>.from(
        raw['pickup'] as Map<String, dynamic>,
      );
      if (raw['final_payout_amount'] != null) {
        pickup['final_payout_amount'] = raw['final_payout_amount'];
      }
      if (raw['verified_items'] != null) {
        pickup['verified_items'] = raw['verified_items'];
      }
      return pickup;
    }
    return Map<String, dynamic>.from(raw);
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  Color get _color {
    switch (status) {
      case 'assigned':
        return AppColor.info;
      case 'accepted':
        return AppColor.brandNavy;
      case 'on_the_way':
        return AppColor.warning;
      case 'arrived':
        return AppColor.rose;
      case 'verifying':
        return AppColor.earth;
      case 'completed':
        return AppColor.primary;
      default:
        return AppColor.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
        border: Border.all(color: _color.withValues(alpha: 0.30)),
      ),
      child: Text(
        status.replaceAll('_', ' ').toUpperCase(),
        style: TextStyle(
          color: _color,
          fontWeight: FontWeight.w800,
          fontSize: 11,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _InfoCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppTheme.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColor.primarySurface,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: FaIcon(icon, size: 13, color: AppColor.primary),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: AppColor.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.space12),
          const Divider(color: AppColor.hairline, height: 1),
          const SizedBox(height: AppTheme.space12),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColor.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColor.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CallButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _CallButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        backgroundColor: color.withValues(alpha: 0.06),
        side: BorderSide(color: color.withValues(alpha: 0.30)),
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(icon, size: 14, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

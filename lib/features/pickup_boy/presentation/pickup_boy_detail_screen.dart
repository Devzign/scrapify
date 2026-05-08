import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';
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

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text(
          _detail?['order_code']?.toString() ??
              _detail?['pickup_code']?.toString() ??
              'Pickup #${widget.pickupId}',
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadDetail,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : _buildContent(context, state),
    );
  }

  Widget _buildContent(BuildContext context, PickupBoyState state) {
    final status = _resolvedStatus(_detail);

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Badge
                _StatusBadge(status: status),
                const SizedBox(height: 16),

                // Customer Info
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
                const SizedBox(height: 16),

                // Items
                if (_detail?['items'] != null &&
                    (_detail!['items'] as List).isNotEmpty) ...[
                  _InfoCard(
                    title: 'Expected Items',
                    icon: FontAwesomeIcons.box,
                    children: [
                      ...(_detail!['items'] as List<dynamic>)
                          .whereType<Map<String, dynamic>>()
                          .map((item) {
                            // category_name can be a Map {"en": "...", "hi": "..."} or a String
                            final rawCat = item['category_name'];
                            String catName;
                            if (rawCat is Map) {
                              catName =
                                  rawCat['en']?.toString() ??
                                  rawCat.values.first?.toString() ??
                                  'Item';
                            } else {
                              catName =
                                  rawCat?.toString() ??
                                  item['item_name']?.toString() ??
                                  'Item';
                            }
                            final weightKg =
                                item['weight_kg']?.toString() ??
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
                  const SizedBox(height: 16),
                ],

                // Quick Actions (Call / Map)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final phone = _detail?['customer_phone']?.toString();
                          if (phone != null && phone.isNotEmpty) {
                            final uri = Uri.parse('tel:$phone');
                            if (await canLaunchUrl(uri)) launchUrl(uri);
                          }
                        },
                        icon: const FaIcon(FontAwesomeIcons.phone, size: 14),
                        label: const Text('Call Customer'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final lat = _detail?['latitude']?.toString();
                          final lng = _detail?['longitude']?.toString();
                          final addr = _detail?['address']?.toString() ?? '';
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
                            launchUrl(
                              uri,
                              mode: LaunchMode.externalApplication,
                            );
                          }
                        },
                        icon: const FaIcon(
                          FontAwesomeIcons.mapLocationDot,
                          size: 14,
                        ),
                        label: const Text('Navigate'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          color: Colors.white,
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
              child: OutlinedButton(
                onPressed: () => _rejectPickup(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                ),
                child: const Text('Reject'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () => _acceptPickup(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                ),
                child: const Text(
                  'Accept Pickup',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        );

      case 'accepted':
        return Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _updateStatus(context, 'on_the_way'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FaIcon(
                      FontAwesomeIcons.truck,
                      size: 16,
                      color: Colors.white,
                    ),
                    SizedBox(width: 8),
                    Text('On The Way', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => context.push(
                  '${AppRoutes.agentReschedule}/${widget.pickupId}',
                ),
                icon: const Icon(Icons.schedule_rounded, size: 16),
                label: const Text('Request Reschedule'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.orange,
                  side: const BorderSide(color: Colors.orange),
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ),
          ],
        );

      case 'on_the_way':
        return ElevatedButton(
          onPressed: () => _updateStatus(context, 'arrived'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            minimumSize: const Size(double.infinity, 48),
          ),
          child: const Text(
            'Mark Arrived',
            style: TextStyle(color: Colors.white),
          ),
        );

      case 'arrived':
        return ElevatedButton(
          onPressed: () async {
            await context.push('/pickup-boy/pickups/${widget.pickupId}/verify');
            if (!mounted) return;
            await _loadDetail();
            final notifier = ref.read(pickupBoyProvider.notifier);
            notifier.loadAssignments();
            notifier.loadDashboard();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            minimumSize: const Size(double.infinity, 48),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FaIcon(
                FontAwesomeIcons.magnifyingGlass,
                size: 16,
                color: Colors.white,
              ),
              SizedBox(width: 8),
              Text('Start Verification', style: TextStyle(color: Colors.white)),
            ],
          ),
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
      if (mounted && _detail != null) {
        setState(() {
          _detail = Map<String, dynamic>.from(_detail!)
            ..['status'] = 'accepted'
            ..['pickup_status'] = 'accepted';
          if (_detail!['pickup_request'] is Map<String, dynamic>) {
            _detail!['pickup_request'] = Map<String, dynamic>.from(
              _detail!['pickup_request'] as Map<String, dynamic>,
            )..['status'] = 'accepted';
          }
        });
      }
      // Reload the detail from API so all fields are fresh
      await _loadDetail();
      // Reload assignments so dashboard reflects the change
      notifier.loadAssignments();
      notifier.loadDashboard();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pickup accepted!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      final error = ref.read(pickupBoyProvider).error;
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
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
      if (mounted && _detail != null) {
        setState(() {
          _detail = Map<String, dynamic>.from(_detail!)
            ..['status'] = newStatus
            ..['pickup_status'] = newStatus;
          if (_detail!['assignment'] is Map<String, dynamic>) {
            _detail!['assignment'] = Map<String, dynamic>.from(
              _detail!['assignment'] as Map<String, dynamic>,
            )..['status'] = newStatus;
          }
          if (_detail!['pickup_request'] is Map<String, dynamic>) {
            _detail!['pickup_request'] = Map<String, dynamic>.from(
              _detail!['pickup_request'] as Map<String, dynamic>,
            )..['status'] = newStatus;
          }
        });
      }
      // Reload the detail from API so all fields are fresh
      await _loadDetail();
      // Reload assignments and dashboard so they reflect the new status
      notifier.loadAssignments();
      notifier.loadDashboard();
      if (!context.mounted) return;
      final label = newStatus.replaceAll('_', ' ');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status updated to $label'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      final error = ref.read(pickupBoyProvider).error;
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
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
        return Colors.blue;
      case 'accepted':
        return Colors.indigo;
      case 'on_the_way':
        return Colors.orange;
      case 'arrived':
        return Colors.purple;
      case 'verifying':
        return Colors.amber;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withValues(alpha: 0.4)),
      ),
      child: Text(
        status.replaceAll('_', ' ').toUpperCase(),
        style: TextStyle(
          color: _color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
          letterSpacing: 0.5,
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FaIcon(icon, size: 14, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const Divider(height: 16),
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
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

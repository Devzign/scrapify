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
          _detail = result.data;
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
    final status = _detail?['status']?.toString() ?? 'assigned';

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
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
              if (_detail?['items'] != null) ...[
                _InfoCard(
                  title: 'Expected Items',
                  icon: FontAwesomeIcons.box,
                  children: [
                    ...(_detail!['items'] as List<dynamic>)
                        .whereType<Map<String, dynamic>>()
                        .map(
                          (item) => _InfoRow(
                            label: item['item_name']?.toString() ?? 'Item',
                            value:
                                'Qty: ${item['quantity'] ?? '-'} | Wt: ${item['expected_weight'] ?? '-'} kg',
                          ),
                        ),
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
                          launchUrl(uri, mode: LaunchMode.externalApplication);
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

        // Bottom action buttons
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
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
          onPressed: () =>
              context.push('/pickup-boy/pickups/${widget.pickupId}/verify'),
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
    final ok = await ref
        .read(pickupBoyProvider.notifier)
        .acceptPickup(widget.pickupId);
    if (!context.mounted) {
      return;
    }
    if (ok) {
      setState(() => _detail?['status'] = 'accepted');
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
        ref.read(pickupBoyProvider.notifier).clearError();
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

  Future<void> _updateStatus(BuildContext context, String status) async {
    final ok = await ref
        .read(pickupBoyProvider.notifier)
        .updateStatus(widget.pickupId, status);
    if (!context.mounted) {
      return;
    }
    if (ok) {
      setState(() => _detail?['status'] = status);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status updated to $status'),
          backgroundColor: Colors.green,
        ),
      );
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

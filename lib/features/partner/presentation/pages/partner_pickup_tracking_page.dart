import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../channel_partner/providers/channel_partner_provider.dart';

class PartnerPickupTrackingPage extends ConsumerStatefulWidget {
  const PartnerPickupTrackingPage({super.key});

  @override
  ConsumerState<PartnerPickupTrackingPage> createState() =>
      _PartnerPickupTrackingPageState();
}

class _PartnerPickupTrackingPageState
    extends ConsumerState<PartnerPickupTrackingPage> {
  String? _status;
  final _queryController = TextEditingController();
  String _query = '';

  static const _statuses = [
    'created',
    'assigned',
    'accepted',
    'reached_location',
    'pickup_started',
    'pickup_completed',
    'delivered_to_warehouse',
    'cancelled',
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(channelPartnerProvider.notifier).loadPartnerPickups(),
    );
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(channelPartnerProvider);
    final pickups = state.pickups.whereType<Map<String, dynamic>>().toList();
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(title: const Text('Pickup Tracking')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
            child: TextField(
              controller: _queryController,
              decoration: const InputDecoration(
                hintText: 'Search by pickup ID / customer / mobile',
                prefixIcon: Icon(Icons.search_rounded),
              ),
              onSubmitted: (v) {
                _query = v.trim();
                _load();
              },
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemBuilder: (_, i) {
                final s = i == 0 ? null : _statuses[i - 1];
                final selected = _status == s;
                final label = s == null ? 'All' : s.replaceAll('_', ' ');
                return InkWell(
                  onTap: () {
                    setState(() => _status = s);
                    _load();
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? AppTheme.primaryColor : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected ? AppTheme.primaryColor : AppTheme.outline,
                      ),
                    ),
                    child: Text(
                      _capitalize(label),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: selected ? Colors.white : AppTheme.textSecondary,
                      ),
                    ),
                  ),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemCount: _statuses.length + 1,
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _load,
              child: pickups.isEmpty && !state.isLoading
                  ? ListView(
                      children: const [
                        SizedBox(height: 220),
                        Center(child: Text('No pickups found')),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                      itemBuilder: (_, i) {
                        final p = pickups[i];
                        final pickupId = int.tryParse('${p['id'] ?? p['pickup_id'] ?? ''}');
                        final code =
                            p['pickup_code']?.toString() ??
                            p['order_code']?.toString() ??
                            '#${p['id']}';
                        final customer = p['customer_name']?.toString() ?? 'Customer';
                        final mobile = p['customer_phone']?.toString() ?? '-';
                        final status = p['status']?.toString() ?? 'created';
                        final timeline = (p['timeline'] as List?)?.whereType<Map<String, dynamic>>().toList() ??
                            (p['status_history'] as List?)?.whereType<Map<String, dynamic>>().toList() ??
                            const <Map<String, dynamic>>[];
                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: AppTheme.cardBorderRadius,
                            border: AppTheme.cardBorder,
                            boxShadow: AppTheme.cardShadow,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      code,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                  _statusPill(status),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '$customer • $mobile',
                                style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 10),
                              if (timeline.isNotEmpty) ...[
                                const Text(
                                  'Timeline',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                ...timeline.take(4).map(
                                  (t) => Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.circle,
                                          size: 7,
                                          color: AppTheme.primaryColor,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            '${_capitalize('${t['status'] ?? t['key'] ?? '-'}')} • ${t['time'] ?? t['created_at'] ?? ''}',
                                            style: const TextStyle(fontSize: 12),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: pickupId == null
                                          ? null
                                          : () => _assignPickupBoy(
                                                pickupId,
                                                reassign: status != 'created' && status != 'pending',
                                              ),
                                      child: Text(
                                        status == 'assigned' ? 'Reassign Pickup Boy' : 'Assign Pickup Boy',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemCount: pickups.length,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _load() async {
    await ref.read(channelPartnerProvider.notifier).loadPartnerPickups(
          status: _status,
          q: _query.isEmpty ? null : _query,
        );
  }

  Widget _statusPill(String status) {
    final s = status.toLowerCase();
    final color = switch (s) {
      'completed' || 'pickup_completed' || 'delivered_to_warehouse' => AppTheme.primaryColor,
      'cancelled' => AppColor.error,
      _ => AppColor.textSecondary,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _capitalize(status.replaceAll('_', ' ')),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Future<void> _assignPickupBoy(int pickupId, {required bool reassign}) async {
    final boys = await ref.read(channelPartnerProvider.notifier).getAssignablePickupBoys(pickupId);
    if (!mounted) return;
    if (boys.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No pickup boys available to assign')),
      );
      return;
    }
    final typed = boys.whereType<Map<String, dynamic>>().toList();
    int? selected;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (context, setLocal) => Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                reassign ? 'Reassign Pickup Boy' : 'Assign Pickup Boy',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              ...typed.map((b) {
                final id = int.tryParse('${b['id'] ?? ''}');
                final capacity = (b['daily_capacity'] ?? b['capacity'] ?? '-').toString();
                final assigned = (b['today_assigned_count'] ?? b['assigned_today'] ?? 0).toString();
                final online = b['is_online'] == true || '${b['status']}'.toLowerCase() == 'online';
                final full = id != null &&
                    int.tryParse(assigned) != null &&
                    int.tryParse(capacity) != null &&
                    int.parse(assigned) >= int.parse(capacity);
                // ignore: deprecated_member_use
                return RadioListTile<int>(
                  value: id ?? -1,
                  // ignore: deprecated_member_use
                  groupValue: selected,
                  // ignore: deprecated_member_use
                  onChanged: full ? null : (v) => setLocal(() => selected = v),
                  title: Text(b['name']?.toString() ?? 'Pickup Boy'),
                  subtitle: Text(
                    'Status: ${online ? 'Online' : 'Offline'} • Assigned: $assigned/$capacity${full ? ' (Capacity Full)' : ''}',
                  ),
                );
              }),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: selected == null || selected == -1
                      ? null
                      : () async {
                          final modalContext = context;
                          final ok = await ref.read(channelPartnerProvider.notifier).assignPickupBoy(
                                pickupId: pickupId,
                                pickupBoyId: selected!,
                                reassign: reassign,
                              );
                          if (!modalContext.mounted) return;
                          Navigator.pop(modalContext);
                          ScaffoldMessenger.of(modalContext).showSnackBar(
                            SnackBar(content: Text(ok ? 'Pickup boy assigned' : 'Assignment failed')),
                          );
                          _load();
                        },
                  child: const Text('Confirm Assignment'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}

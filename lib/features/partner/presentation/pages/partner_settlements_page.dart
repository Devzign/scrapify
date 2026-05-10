import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../channel_partner/providers/channel_partner_provider.dart';

class PartnerSettlementsPage extends ConsumerStatefulWidget {
  const PartnerSettlementsPage({super.key});

  @override
  ConsumerState<PartnerSettlementsPage> createState() => _PartnerSettlementsPageState();
}

class _PartnerSettlementsPageState extends ConsumerState<PartnerSettlementsPage> {
  String? _status;
  static const _filters = ['pending', 'processing', 'paid', 'hold', 'rejected'];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(channelPartnerProvider.notifier).loadSettlements());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(channelPartnerProvider);
    final settlements = state.settlements.whereType<Map<String, dynamic>>().toList();

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(title: const Text('Settlement & Payout')),
      body: Column(
        children: [
          SizedBox(
            height: 42,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              scrollDirection: Axis.horizontal,
              itemBuilder: (_, i) {
                final status = i == 0 ? null : _filters[i - 1];
                final selected = _status == status;
                return InkWell(
                  onTap: () {
                    setState(() => _status = status);
                    ref.read(channelPartnerProvider.notifier).loadSettlements(status: status);
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? AppTheme.primaryColor : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: selected ? AppTheme.primaryColor : AppTheme.outline),
                    ),
                    child: Text(
                      status == null ? 'All' : _capitalize(status),
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
              itemCount: _filters.length + 1,
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.read(channelPartnerProvider.notifier).loadSettlements(status: _status),
              child: settlements.isEmpty && !state.isLoading
                  ? ListView(
                      children: const [
                        SizedBox(height: 220),
                        Center(child: Text('No settlements found')),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                      itemBuilder: (_, i) {
                        final s = settlements[i];
                        final total = '${s['total_amount'] ?? s['gross_amount'] ?? 0}';
                        final commission = '${s['commission'] ?? 0}';
                        final payable = '${s['payable_amount'] ?? s['net_amount'] ?? 0}';
                        final status = (s['payout_status'] ?? s['status'] ?? 'pending').toString();
                        final payoutDate = s['payout_date']?.toString() ?? '-';
                        final remarks = s['remarks']?.toString() ?? '';
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
                                      s['pickup_code']?.toString() ?? s['id']?.toString() ?? 'Settlement',
                                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _statusColor(status).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      _capitalize(status),
                                      style: TextStyle(
                                        color: _statusColor(status),
                                        fontWeight: FontWeight.w800,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              _line('Total amount', total),
                              _line('Commission', commission),
                              _line('Payable amount', payable),
                              _line('Payout date', payoutDate),
                              if (remarks.isNotEmpty) _line('Remarks', remarks),
                              if (s['payment_proof_url'] != null) _line('Payment proof', s['payment_proof_url']),
                            ],
                          ),
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemCount: settlements.length,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _line(String k, dynamic v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: '$k: ', style: const TextStyle(fontWeight: FontWeight.w700)),
            TextSpan(text: v?.toString() ?? '-'),
          ],
        ),
      ),
    );
  }

  String _capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  Color _statusColor(String status) {
    return switch (status.toLowerCase()) {
      'paid' => AppTheme.primaryColor,
      'rejected' => AppColor.error,
      'hold' => AppColor.warning,
      'processing' => AppColor.info,
      _ => AppTheme.textSecondary,
    };
  }
}


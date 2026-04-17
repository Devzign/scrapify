import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/channel_partner_provider.dart';

class PartnerOrdersScreen extends ConsumerStatefulWidget {
  const PartnerOrdersScreen({super.key});

  @override
  ConsumerState<PartnerOrdersScreen> createState() => _PartnerOrdersScreenState();
}

class _PartnerOrdersScreenState extends ConsumerState<PartnerOrdersScreen> {
  String? _selectedStatus;

  final _statuses = [null, 'pending', 'assigned', 'active', 'completed', 'cancelled'];
  final _statusLabels = ['All', 'Pending', 'Assigned', 'Active', 'Completed', 'Cancelled'];

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        ref.read(channelPartnerProvider.notifier).loadOrders());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(channelPartnerProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Orders',
            style: TextStyle(
                color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Status Filter Chips
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _statuses.length,
              itemBuilder: (ctx, idx) {
                final isSelected = _selectedStatus == _statuses[idx];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(_statusLabels[idx]),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() => _selectedStatus = _statuses[idx]);
                      ref
                          .read(channelPartnerProvider.notifier)
                          .loadOrders(status: _statuses[idx]);
                    },
                    selectedColor: AppTheme.primaryColor.withValues(alpha: 0.15),
                    checkmarkColor: AppTheme.primaryColor,
                    labelStyle: TextStyle(
                      color: isSelected ? AppTheme.primaryColor : Colors.grey,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          ),

          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.orders.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.inbox_outlined,
                                size: 64, color: Colors.grey),
                            const SizedBox(height: 16),
                            Text(
                              state.error != null
                                  ? 'API not yet available — backend in progress'
                                  : 'No orders found',
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 15),
                              textAlign: TextAlign.center,
                            ),
                            if (state.error != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                state.error!,
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 12),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => ref
                            .read(channelPartnerProvider.notifier)
                            .loadOrders(status: _selectedStatus),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: state.orders.length,
                          itemBuilder: (ctx, idx) {
                            final order = state.orders[idx];
                            if (order is! Map<String, dynamic>) {
                              return const SizedBox.shrink();
                            }
                            return _OrderCard(order: order);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final status = order['status']?.toString() ?? 'pending';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order['order_code']?.toString() ??
                    order['pickup_code']?.toString() ??
                    '#${order['id']}',
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryDark,
                    fontSize: 13),
              ),
              _StatusChip(status: status),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            order['customer_name']?.toString() ?? '-',
            style: const TextStyle(
                fontWeight: FontWeight.w600, fontSize: 15),
          ),
          const SizedBox(height: 4),
          Text(
            order['address']?.toString() ?? '-',
            style: const TextStyle(color: Colors.grey, fontSize: 13),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order['scheduled_at']?.toString() ?? '-',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              if (order['estimated_amount'] != null)
                Text(
                  '₹${order['estimated_amount']}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                      fontSize: 14),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  Color get _color {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'assigned':
        return Colors.blue;
      case 'active':
        return Colors.purple;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _color.withValues(alpha: 0.4)),
      ),
      child: Text(
        status,
        style: TextStyle(
            color: _color,
            fontSize: 11,
            fontWeight: FontWeight.bold),
      ),
    );
  }
}

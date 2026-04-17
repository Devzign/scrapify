import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/pickup_provider.dart';
import '../domain/models/pickup_request.dart';
import '../../../core/utils/app_routes.dart' as routes;

class PickupDetailsScreen extends ConsumerStatefulWidget {
  final int? pickupId;
  const PickupDetailsScreen({super.key, this.pickupId});

  @override
  ConsumerState<PickupDetailsScreen> createState() =>
      _PickupDetailsScreenState();
}

class _PickupDetailsScreenState extends ConsumerState<PickupDetailsScreen> {
  PickupRequest? _pickup;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.pickupId != null) _loadDetail();
    else setState(() => _loading = false);
  }

  Future<void> _loadDetail() async {
    setState(() { _loading = true; _error = null; });
    final repo = ref.read(pickupRepositoryProvider);
    final result = await repo.getPickupDetail(widget.pickupId!);
    if (mounted) {
      setState(() {
        _loading = false;
        if (result.isSuccess) _pickup = result.data;
        else _error = result.errorMessage;
      });
    }
  }

  Color _dotColor(String status, String step) {
    final order = ['pending', 'assigned', 'on_the_way', 'arrived', 'completed'];
    final current = order.indexOf(status.toLowerCase());
    final stepIdx = order.indexOf(step);
    if (stepIdx <= current) return AppTheme.primaryColor;
    return Colors.grey.shade300;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeft,
              color: AppTheme.textPrimary, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Column(
          children: [
            Text(
              _pickup?.orderCode ?? 'Pickup #${widget.pickupId ?? ""}',
              style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null && _pickup == null
              ? _buildError()
              : _buildContent(),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const FaIcon(FontAwesomeIcons.triangleExclamation,
              color: Colors.orange, size: 48),
          const SizedBox(height: 16),
          Text(_error ?? 'Failed to load details',
              style: const TextStyle(color: AppTheme.textSecondary)),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _loadDetail, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final p = _pickup;
    final status = p?.status ?? 'pending';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4))
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1E2A5E),
                      borderRadius:
                          BorderRadius.horizontal(right: Radius.circular(6)),
                    ),
                  ),
                ),
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          shape: BoxShape.circle),
                      child: const FaIcon(FontAwesomeIcons.truckFast,
                          size: 24, color: Color(0xFF1E2A5E)),
                    ),
                    const SizedBox(height: 16),
                    const Text('STATUS',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textSecondary,
                            letterSpacing: 1.2)),
                    const SizedBox(height: 8),
                    Text(
                      status.replaceAll('_', ' ').toUpperCase(),
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E2A5E)),
                    ),
                    if (p?.scheduledAt != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                            color: AppTheme.primaryLight,
                            borderRadius: BorderRadius.circular(20)),
                        child: Text(
                          'Scheduled: ${p!.scheduledAt.length > 10 ? p.scheduledAt.substring(0, 10) : p.scheduledAt}',
                          style: const TextStyle(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Address Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4))
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                      color: AppTheme.primaryLight, shape: BoxShape.circle),
                  child: const FaIcon(FontAwesomeIcons.locationDot,
                      color: AppTheme.primaryColor, size: 14),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Pickup Address',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 6),
                      Text(
                        p?.address ?? 'N/A',
                        style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 13,
                            height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Items
          if (p != null && p.items.isNotEmpty) ...[
            const Text('Pickup Items',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4))
                ],
              ),
              child: Column(
                children: p.items.asMap().entries.map((e) {
                  final item = e.value;
                  final isLast = e.key == p.items.length - 1;
                  return Column(
                    children: [
                      _buildItemRow(
                        name: item.itemName ?? 'Item',
                        weight: item.weight != null
                            ? '${item.weight} kg'
                            : '—',
                        price: item.rate != null ? '₹${item.rate}' : '—',
                      ),
                      if (!isLast) ...[
                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 12),
                      ],
                    ],
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Estimated / Final Amount
          if (p?.estimatedAmount != null || p?.finalAmount != null) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4))
                ],
              ),
              child: Column(
                children: [
                  if (p?.estimatedAmount != null)
                    _buildAmountRow(
                        'Estimated Amount', '₹${p!.estimatedAmount}'),
                  if (p?.finalAmount != null) ...[
                    const SizedBox(height: 8),
                    _buildAmountRow('Final Amount', '₹${p!.finalAmount}',
                        bold: true),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Status Timeline
          const Text('Order Status',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary)),
          const SizedBox(height: 24),
          _buildTimelineStep('Requested', dotColor: _dotColor(status, 'pending'), isFirst: true),
          _buildTimelineStep('Assigned', dotColor: _dotColor(status, 'assigned')),
          _buildTimelineStep('On The Way', dotColor: _dotColor(status, 'on_the_way')),
          _buildTimelineStep('Picked Up', dotColor: _dotColor(status, 'arrived')),
          _buildTimelineStep('Completed', dotColor: _dotColor(status, 'completed'), isLast: true),

          const SizedBox(height: 40),

          // Rate button if completed
          if (status == 'completed')
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const FaIcon(FontAwesomeIcons.solidStar, size: 16),
                label: const Text('Rate This Pickup'),
                onPressed: () => context.push(routes.AppRoutes.ratePickup,
                    extra: {'pickup_id': widget.pickupId}),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildItemRow(
      {required String name, required String weight, required String price}) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10)),
          child: const Center(
              child: FaIcon(FontAwesomeIcons.boxesStacked,
                  color: AppTheme.textSecondary, size: 18)),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(name,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 14)),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(weight,
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 12)),
            Text(price,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AppTheme.primaryColor)),
          ],
        ),
      ],
    );
  }

  Widget _buildAmountRow(String label, String value,
      {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: bold ? 15 : 13,
                color: bold ? AppTheme.textPrimary : AppTheme.textSecondary,
                fontWeight:
                    bold ? FontWeight.bold : FontWeight.normal)),
        Text(value,
            style: TextStyle(
                fontSize: bold ? 18 : 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor)),
      ],
    );
  }

  Widget _buildTimelineStep(String label,
      {required Color dotColor, bool isFirst = false, bool isLast = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            if (!isFirst)
              Container(width: 2, height: 16, color: Colors.grey.shade200)
            else
              const SizedBox(height: 16),
            Container(
                width: 12,
                height: 12,
                decoration:
                    BoxDecoration(color: dotColor, shape: BoxShape.circle)),
            if (!isLast)
              Container(width: 2, height: 32, color: Colors.grey.shade200)
            else
              const SizedBox(height: 32),
          ],
        ),
        const SizedBox(width: 16),
        Padding(
          padding: EdgeInsets.only(top: isFirst ? 12 : 0),
          child: Text(label,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: dotColor == Colors.grey.shade300
                      ? AppTheme.textSecondary
                      : AppTheme.textPrimary)),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/warehouse_provider.dart';

class WarehouseRequestDetailScreen extends ConsumerStatefulWidget {
  final int requestId;
  const WarehouseRequestDetailScreen({super.key, required this.requestId});

  @override
  ConsumerState<WarehouseRequestDetailScreen> createState() =>
      _WarehouseRequestDetailScreenState();
}

class _WarehouseRequestDetailScreenState
    extends ConsumerState<WarehouseRequestDetailScreen> {
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
    final repo = ref.read(warehouseRepositoryProvider);
    final result = await repo.getRequestDetail(widget.requestId);
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

  void _showAssignSheet(BuildContext context, {bool isReassign = false}) {
    // Load assignable boys
    ref
        .read(warehouseProvider.notifier)
        .loadAssignablePickupBoys(widget.requestId);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _AssignBottomSheet(
        requestId: widget.requestId,
        isReassign: isReassign,
        onAssigned: () {
          _loadDetail();
          Navigator.pop(ctx);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(warehouseProvider);
    final hasAssignment =
        _detail?['pickup_boy_id'] != null || _detail?['assigned_pickup_boy'] != null;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text(
          _detail?['order_code']?.toString() ??
              'Request #${widget.requestId}',
          style: const TextStyle(
              color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
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
                      const Icon(Icons.error_outline,
                          size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(_error!,
                          style: const TextStyle(color: Colors.red)),
                      ElevatedButton(
                          onPressed: _loadDetail,
                          child: const Text('Retry')),
                    ],
                  ),
                )
              : Stack(
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Customer Card
                          _DetailCard(
                            title: 'Customer',
                            children: [
                              _Row('Name', _detail?['customer_name'] ?? '-'),
                              _Row('Phone', _detail?['customer_phone'] ?? '-'),
                              _Row('Address', _detail?['address'] ?? '-'),
                              _Row('Scheduled', _formatDate(_detail?['scheduled_at'] ?? '')),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Items
                          if (_detail?['items'] != null)
                            _DetailCard(
                              title: 'Items',
                              children: (_detail!['items'] as List<dynamic>)
                                  .whereType<Map<String, dynamic>>()
                                  .map((item) => _Row(
                                        item['item_name']?.toString() ?? 'Item',
                                        'Qty: ${item['quantity'] ?? '-'}',
                                      ))
                                  .toList(),
                            ),
                          const SizedBox(height: 16),

                          // Assignment
                          _DetailCard(
                            title: 'Assignment',
                            children: [
                              _Row(
                                'Status',
                                _detail?['status']?.toString() ?? '-',
                              ),
                              if (hasAssignment)
                                _Row(
                                  'Assigned To',
                                  (_detail?['assigned_pickup_boy']
                                              as Map<String, dynamic>?)?['name']
                                          ?.toString() ??
                                      _detail?['pickup_boy_name']?.toString() ??
                                      '-',
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        color: Colors.white,
                        child: state.isActionLoading
                            ? const Center(child: CircularProgressIndicator())
                            : Row(
                                children: [
                                  if (hasAssignment) ...[
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () =>
                                            _showAssignSheet(context,
                                                isReassign: true),
                                        child: const Text('Reassign'),
                                      ),
                                    ),
                                  ] else ...[
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () =>
                                            _showAssignSheet(context),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              AppTheme.primaryColor,
                                          minimumSize:
                                              const Size(double.infinity, 48),
                                        ),
                                        child: const Text(
                                          'Assign Pickup Boy',
                                          style:
                                              TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
    );
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

class _AssignBottomSheet extends ConsumerStatefulWidget {
  final int requestId;
  final bool isReassign;
  final VoidCallback onAssigned;

  const _AssignBottomSheet({
    required this.requestId,
    required this.isReassign,
    required this.onAssigned,
  });

  @override
  ConsumerState<_AssignBottomSheet> createState() =>
      _AssignBottomSheetState();
}

class _AssignBottomSheetState extends ConsumerState<_AssignBottomSheet> {
  int? _selectedPickupBoyId;
  final _reasonCtrl = TextEditingController();

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    if (_selectedPickupBoyId == null) return;

    bool ok;
    if (widget.isReassign) {
      if (_reasonCtrl.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a reason for reassignment')),
        );
        return;
      }
      ok = await ref.read(warehouseProvider.notifier).reassignPickupBoy(
            widget.requestId,
            _selectedPickupBoyId!,
            _reasonCtrl.text.trim(),
          );
    } else {
      ok = await ref.read(warehouseProvider.notifier).assignPickupBoy(
            widget.requestId,
            _selectedPickupBoyId!,
          );
    }

    if (ok && mounted) {
      widget.onAssigned();
    } else if (mounted) {
      final error = ref.read(warehouseProvider).error;
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
        ref.read(warehouseProvider.notifier).clearError();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(warehouseProvider);
    final boys = state.assignablePickupBoys;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      builder: (ctx, scroll) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.isReassign ? 'Reassign Pickup Boy' : 'Assign Pickup Boy',
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 16),

            if (widget.isReassign) ...[
              TextField(
                controller: _reasonCtrl,
                decoration: const InputDecoration(
                  labelText: 'Reason for Reassignment *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
            ],

            const Text('Select Pickup Boy:',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),

            if (state.isActionLoading && boys.isEmpty)
              const Center(child: CircularProgressIndicator())
            else if (boys.isEmpty)
              const Text('No available pickup boys',
                  style: TextStyle(color: Colors.grey))
            else
              Expanded(
                child: ListView.builder(
                  controller: scroll,
                  itemCount: boys.length,
                  itemBuilder: (ctx, idx) {
                    final boy = boys[idx];
                    final isSelected = _selectedPickupBoyId == boy.id;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: boy.isAvailable
                            ? Colors.green.shade100
                            : Colors.grey.shade200,
                        child: Text(boy.name[0].toUpperCase()),
                      ),
                      title: Text(boy.name),
                      subtitle: Text(
                        boy.isAvailable ? 'Available' : 'Busy',
                        style: TextStyle(
                          color: boy.isAvailable ? Colors.green : Colors.orange,
                          fontSize: 12,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle,
                              color: AppTheme.primaryColor)
                          : null,
                      selected: isSelected,
                      onTap: () =>
                          setState(() => _selectedPickupBoyId = boy.id),
                    );
                  },
                ),
              ),

            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    _selectedPickupBoyId == null || state.isActionLoading
                        ? null
                        : _confirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: state.isActionLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        widget.isReassign ? 'Confirm Reassignment' : 'Assign',
                        style: const TextStyle(color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _DetailCard({required this.title, required this.children});

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
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppTheme.textPrimary)),
          const Divider(height: 16),
          ...children,
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(label,
                style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

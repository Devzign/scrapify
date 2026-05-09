import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/models/warehouse_request.dart';
import '../../domain/models/warehouse_pickup_boy.dart';
import '../../providers/warehouse_provider.dart';
import 'wh_request_detail_page.dart';

class WhRequestsPage extends ConsumerStatefulWidget {
  const WhRequestsPage({super.key});

  @override
  ConsumerState<WhRequestsPage> createState() => _WhRequestsPageState();
}

class _WhRequestsPageState extends ConsumerState<WhRequestsPage> {
  int _selectedFilter = 0;
  final _filters = [
    'All',
    'Unassigned',
    'Assigned',
    'In Progress',
    'Completed',
    'Rescheduled',
  ];
  final _statusParams = [
    null,
    'unassigned',
    'assigned',
    'in_progress',
    'completed',
    'rescheduled',
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(warehouseProvider.notifier).loadRequests());
  }

  void _applyFilter(int index) {
    setState(() => _selectedFilter = index);
    ref
        .read(warehouseProvider.notifier)
        .loadRequests(status: _statusParams[index]);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(warehouseProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(state.dashboard?.warehouse?.name),
            Expanded(
              child: state.isLoading && state.requests.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: () => ref
                          .read(warehouseProvider.notifier)
                          .loadRequests(status: _statusParams[_selectedFilter]),
                      child: CustomScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          SliverToBoxAdapter(
                            child: _buildHeader(state.requests.length),
                          ),
                          SliverToBoxAdapter(child: _buildFilterChips()),
                          if (state.error != null)
                            SliverToBoxAdapter(
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 8,
                                ),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.orange.shade200,
                                  ),
                                ),
                                child: Text(
                                  state.error!,
                                  style: TextStyle(
                                    color: Colors.orange.shade800,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          if (state.requests.isEmpty && !state.isLoading)
                            SliverFillRemaining(
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.inbox_rounded,
                                      size: 48,
                                      color: Colors.grey.shade300,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'No requests found',
                                      style: TextStyle(
                                        color: Colors.grey.shade400,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            SliverPadding(
                              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (ctx, i) =>
                                      _buildRequestCard(state.requests[i]),
                                  childCount: state.requests.length,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(String? warehouseName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.warehouse_rounded,
                color: AppTheme.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 10),
              Text(
                warehouseName ?? 'Scrapi5 Warehouse',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_none_rounded,
              color: Colors.grey.shade500,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ACTIVE QUEUE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryColor,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Pickup Requests',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Operational Status',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade500,
                ),
              ),
              Text(
                '$count Requests',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final isSelected = _selectedFilter == index;
          return GestureDetector(
            onTap: () => _applyFilter(index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryColor : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.primaryColor
                      : const Color(0xFFD8E2DC),
                  width: 1.2,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppTheme.primaryColor.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  _filters[index],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.white : Colors.grey.shade600,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRequestCard(WarehouseRequest r) {
    final statusStyle = _statusStyle(r.status);
    final isUnassigned =
        r.status.toLowerCase() == 'unassigned' ||
        (r.status.toLowerCase() == 'pending' && r.assignedPickupBoyId == null);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => WhRequestDetailPage(request: r)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'ORDER CODE  ',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: Colors.grey.shade400,
                            letterSpacing: -0.3,
                          ),
                        ),
                        Text(
                          r.orderCode,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      r.customerName,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusStyle.$1,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    r.status.toUpperCase().replaceAll('_', ' '),
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: statusStyle.$2,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              icon: Icons.access_time_rounded,
              label: 'Scheduled Time',
              value: _formatScheduled(r.scheduledAt),
              labelColor: AppTheme.primaryColor,
            ),
            const SizedBox(height: 10),
            _buildDetailRow(
              icon: Icons.location_on_rounded,
              label: r.assignedPickupBoyName != null
                  ? 'Driver Assigned'
                  : 'Address',
              value: r.assignedPickupBoyName ?? r.address,
              labelColor: AppTheme.primaryColor,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: isUnassigned
                      ? ElevatedButton.icon(
                          onPressed: () => _showAssignSheet(r),
                          icon: const Icon(Icons.person_add_rounded, size: 18),
                          label: const Text(
                            'Assign Driver',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                        )
                      : OutlinedButton(
                          onPressed: r.assignedPickupBoyId != null
                              ? () => _showReassignSheet(r)
                              : null,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey.shade200),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            r.assignedPickupBoyId != null
                                ? 'Reassign'
                                : 'View Details',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                ),
                if (r.customerPhone.isNotEmpty) ...[
                  const SizedBox(width: 10),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: () async {
                        final uri = Uri.parse('tel:${r.customerPhone}');
                        if (await canLaunchUrl(uri)) launchUrl(uri);
                      },
                      icon: Icon(
                        Icons.call,
                        color: AppTheme.primaryColor,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required Color labelColor,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey.shade500, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: labelColor,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  (Color, Color) _statusStyle(String status) {
    switch (status.toLowerCase()) {
      case 'unassigned':
      case 'pending':
        return (const Color(0xFFFEE2E2), const Color(0xFF991B1B));
      case 'assigned':
        return (AppTheme.primarySurface, AppTheme.primaryDark);
      case 'active':
      case 'in_progress':
      case 'on_the_way':
      case 'arrived':
        return (AppTheme.hintPeach, const Color(0xFF92400E));
      case 'completed':
        return (const Color(0xFFE0E7FF), const Color(0xFF3730A3));
      case 'rescheduled':
        return (const Color(0xFFFFD9DF), const Color(0xFF6F3443));
      default:
        return (Colors.grey.shade100, Colors.grey.shade700);
    }
  }

  String _formatScheduled(String raw) {
    try {
      final dt = DateTime.parse(raw).toLocal();
      return '${dt.day}/${dt.month}/${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return raw;
    }
  }

  Future<void> _showAssignSheet(WarehouseRequest request) async {
    await ref
        .read(warehouseProvider.notifier)
        .loadAssignablePickupBoys(request.id);
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _AssignSheet(
        requestId: request.id,
        orderCode: request.orderCode,
        onAssigned: () {
          ref
              .read(warehouseProvider.notifier)
              .loadRequests(status: _statusParams[_selectedFilter]);
        },
      ),
    );
  }

  Future<void> _showReassignSheet(WarehouseRequest request) async {
    await ref
        .read(warehouseProvider.notifier)
        .loadAssignablePickupBoys(request.id);
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _ReassignSheet(
        requestId: request.id,
        orderCode: request.orderCode,
        onReassigned: () {
          ref
              .read(warehouseProvider.notifier)
              .loadRequests(status: _statusParams[_selectedFilter]);
        },
      ),
    );
  }
}

class _AssignSheet extends ConsumerStatefulWidget {
  final int requestId;
  final String orderCode;
  final VoidCallback onAssigned;

  const _AssignSheet({
    required this.requestId,
    required this.orderCode,
    required this.onAssigned,
  });

  @override
  ConsumerState<_AssignSheet> createState() => _AssignSheetState();
}

class _AssignSheetState extends ConsumerState<_AssignSheet> {
  int? _selectedBoyId;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(warehouseProvider);
    final boys = state.assignablePickupBoys;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Assign Driver',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      widget.orderCode,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (state.isActionLoading)
              const Center(child: CircularProgressIndicator())
            else if (boys.isEmpty)
              Center(
                child: Text(
                  'No available pickup boys',
                  style: TextStyle(color: Colors.grey.shade400),
                ),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: boys.length,
                  itemBuilder: (_, i) => _PickupBoyTile(
                    boy: boys[i],
                    selected: _selectedBoyId == boys[i].id,
                    onTap: () => setState(() => _selectedBoyId = boys[i].id),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedBoyId == null || state.isActionLoading
                    ? null
                    : () async {
                        final ok = await ref
                            .read(warehouseProvider.notifier)
                            .assignPickupBoy(widget.requestId, _selectedBoyId!);
                        if (!context.mounted) {
                          return;
                        }
                        if (ok) {
                          Navigator.pop(context);
                          widget.onAssigned();
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: state.isActionLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Confirm Assignment',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReassignSheet extends ConsumerStatefulWidget {
  final int requestId;
  final String orderCode;
  final VoidCallback onReassigned;

  const _ReassignSheet({
    required this.requestId,
    required this.orderCode,
    required this.onReassigned,
  });

  @override
  ConsumerState<_ReassignSheet> createState() => _ReassignSheetState();
}

class _ReassignSheetState extends ConsumerState<_ReassignSheet> {
  int? _selectedBoyId;
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(warehouseProvider);
    final boys = state.assignablePickupBoys;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Reassign Driver',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      widget.orderCode,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _reasonController,
              decoration: InputDecoration(
                labelText: 'Reason for reassignment',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            if (state.isActionLoading)
              const Center(child: CircularProgressIndicator())
            else if (boys.isEmpty)
              Center(
                child: Text(
                  'No available pickup boys',
                  style: TextStyle(color: Colors.grey.shade400),
                ),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: boys.length,
                  itemBuilder: (_, i) => _PickupBoyTile(
                    boy: boys[i],
                    selected: _selectedBoyId == boys[i].id,
                    onTap: () => setState(() => _selectedBoyId = boys[i].id),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    _selectedBoyId == null ||
                        _reasonController.text.trim().isEmpty ||
                        state.isActionLoading
                    ? null
                    : () async {
                        final ok = await ref
                            .read(warehouseProvider.notifier)
                            .reassignPickupBoy(
                              widget.requestId,
                              _selectedBoyId!,
                              _reasonController.text.trim(),
                            );
                        if (!context.mounted) {
                          return;
                        }
                        if (ok) {
                          Navigator.pop(context);
                          widget.onReassigned();
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: state.isActionLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Confirm Reassignment',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PickupBoyTile extends StatelessWidget {
  final WarehousePickupBoy boy;
  final bool selected;
  final VoidCallback onTap;

  const _PickupBoyTile({
    required this.boy,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.primaryColor.withValues(alpha: 0.08)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppTheme.primaryColor : Colors.grey.shade200,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppTheme.primaryLight.withValues(alpha: 0.3),
              child: Text(
                boy.name.isNotEmpty ? boy.name[0].toUpperCase() : '?',
                style: TextStyle(
                  color: AppTheme.primaryDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    boy.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  if (boy.phone.isNotEmpty)
                    Text(
                      boy.phone,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                ],
              ),
            ),
            if (selected)
              Icon(
                Icons.check_circle_rounded,
                color: AppTheme.primaryColor,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../domain/models/warehouse_request.dart';
import '../providers/warehouse_provider.dart';

class WarehouseRequestsScreen extends ConsumerStatefulWidget {
  const WarehouseRequestsScreen({super.key});

  @override
  ConsumerState<WarehouseRequestsScreen> createState() =>
      _WarehouseRequestsScreenState();
}

class _WarehouseRequestsScreenState
    extends ConsumerState<WarehouseRequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _statuses = ['unassigned', 'assigned', 'active', 'completed'];
  final _tabLabels = ['Unassigned', 'Assigned', 'Active', 'Completed'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    Future.microtask(() => _loadForTab(0));
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _loadForTab(_tabController.index);
      }
    });
  }

  void _loadForTab(int index) {
    ref
        .read(warehouseProvider.notifier)
        .loadRequests(status: _statuses[index]);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(warehouseProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Requests',
            style: TextStyle(
                color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppTheme.primaryColor,
          isScrollable: true,
          tabs: _tabLabels.map((l) => Tab(text: l)).toList(),
        ),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null && state.requests.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 48, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        state.error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => _loadForTab(_tabController.index),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: _statuses.map((_) {
                    if (state.requests.isEmpty) {
                      return const Center(
                          child: Text('No requests',
                              style: TextStyle(color: Colors.grey)));
                    }
                    return RefreshIndicator(
                      onRefresh: () async => _loadForTab(_tabController.index),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.requests.length,
                        itemBuilder: (ctx, idx) =>
                            _RequestCard(request: state.requests[idx]),
                      ),
                    );
                  }).toList(),
                ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final WarehouseRequest request;
  const _RequestCard({required this.request});

  @override
  Widget build(BuildContext context) {
    final hasAssignment = request.assignedPickupBoyName != null;
    return GestureDetector(
      onTap: () => context.push('/warehouse/requests/${request.id}'),
      child: Container(
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
                  request.orderCode,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryDark,
                      fontSize: 13),
                ),
                _StatusChip(status: request.status),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              request.customerName,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 15),
            ),
            const SizedBox(height: 4),
            Text(
              request.address,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDate(request.scheduledAt),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                if (hasAssignment)
                  Row(
                    children: [
                      const Icon(Icons.person, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        request.assignedPickupBoyName!,
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  )
                else
                  const Text(
                    'Unassigned',
                    style: TextStyle(
                        color: Colors.orange,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dt) {
    try {
      final d = DateTime.parse(dt);
      return '${d.day}/${d.month} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return dt;
    }
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  Color get _color {
    switch (status) {
      case 'unassigned':
        return Colors.orange;
      case 'assigned':
        return Colors.blue;
      case 'active':
      case 'on_the_way':
      case 'arrived':
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
        status.replaceAll('_', ' '),
        style: TextStyle(
            color: _color,
            fontSize: 11,
            fontWeight: FontWeight.bold),
      ),
    );
  }
}

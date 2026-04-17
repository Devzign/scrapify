import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../domain/models/warehouse_pickup_boy.dart';
import '../providers/warehouse_provider.dart';

class WarehousePickupBoysScreen extends ConsumerStatefulWidget {
  const WarehousePickupBoysScreen({super.key});

  @override
  ConsumerState<WarehousePickupBoysScreen> createState() =>
      _WarehousePickupBoysScreenState();
}

class _WarehousePickupBoysScreenState
    extends ConsumerState<WarehousePickupBoysScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(warehouseProvider.notifier).loadPickupBoys());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(warehouseProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Pickup Boys',
            style: TextStyle(
                color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.pickupBoys.isEmpty
              ? Center(
                  child: state.error != null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline,
                                size: 48, color: Colors.grey),
                            const SizedBox(height: 16),
                            Text(state.error!,
                                style: const TextStyle(color: Colors.grey),
                                textAlign: TextAlign.center),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => ref
                                  .read(warehouseProvider.notifier)
                                  .loadPickupBoys(),
                              child: const Text('Retry'),
                            ),
                          ],
                        )
                      : const Text('No pickup boys',
                          style: TextStyle(color: Colors.grey)),
                )
              : RefreshIndicator(
                  onRefresh: () =>
                      ref.read(warehouseProvider.notifier).loadPickupBoys(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.pickupBoys.length,
                    itemBuilder: (ctx, idx) =>
                        _PickupBoyCard(boy: state.pickupBoys[idx]),
                  ),
                ),
    );
  }
}

class _PickupBoyCard extends StatelessWidget {
  final WarehousePickupBoy boy;
  const _PickupBoyCard({required this.boy});

  @override
  Widget build(BuildContext context) {
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
      child: Row(
        children: [
          // Avatar with online indicator
          Stack(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: AppTheme.primaryLight,
                child: Text(
                  boy.name.isNotEmpty ? boy.name[0].toUpperCase() : '?',
                  style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: boy.isOnline ? Colors.green : Colors.grey,
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  boy.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppTheme.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  boy.phone,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _StatusPill(
                      label: boy.isOnline ? 'Online' : 'Offline',
                      color: boy.isOnline ? Colors.green : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    _StatusPill(
                      label: boy.isAvailable ? 'Available' : 'Busy',
                      color:
                          boy.isAvailable ? Colors.blue : Colors.orange,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${boy.currentAssignmentCount}',
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor),
              ),
              const Text('active',
                  style: TextStyle(color: Colors.grey, fontSize: 11)),
              const SizedBox(height: 4),
              Text(
                '${boy.completedCount} done',
                style: const TextStyle(color: Colors.grey, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
            color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}

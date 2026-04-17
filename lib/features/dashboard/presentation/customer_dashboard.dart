import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/utils/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../../pickup/providers/pickup_provider.dart';
import '../../pickup/domain/models/pickup_request.dart';

class CustomerDashboard extends ConsumerStatefulWidget {
  const CustomerDashboard({super.key});

  @override
  ConsumerState<CustomerDashboard> createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends ConsumerState<CustomerDashboard> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(pickupProvider.notifier).loadPickups(status: 'active');
      ref.read(pickupProvider.notifier).loadStats();
      ref.read(pickupProvider.notifier).loadCategories();
    });
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'assigned':
        return Colors.blue;
      case 'on_the_way':
        return Colors.purple;
      case 'arrived':
        return Colors.indigo;
      case 'completed':
        return AppTheme.primaryColor;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    final pickupState = ref.watch(pickupProvider);
    final activePickups = pickupState.requests;
    final stats = pickupState.stats;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.bars, color: AppTheme.textPrimary),
          onPressed: () {},
        ),
        title: Text(
          'login.app_name'.tr(),
          style: const TextStyle(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.bell,
                color: AppTheme.textPrimary),
            onPressed: () => context.push(AppRoutes.notifications),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref
              .read(pickupProvider.notifier)
              .loadPickups(status: 'active');
          await ref.read(pickupProvider.notifier).loadStats();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting
                if (user != null) ...[
                  Text(
                    'Hello, ${user.name.split(' ').first}! 👋',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.phone,
                    style: const TextStyle(
                        fontSize: 13, color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 16),
                ],

                // Stats Row
                if (stats != null) ...[
                  Row(
                    children: [
                      _buildStatChip(
                          '${stats.total}', 'Total', AppTheme.primaryColor),
                      const SizedBox(width: 8),
                      _buildStatChip(
                          '${stats.completed}', 'Done', Colors.green),
                      const SizedBox(width: 8),
                      _buildStatChip(
                          '${stats.pending}', 'Pending', Colors.orange),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],

                // Top Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6F9A7A), Color(0xFF8BB594)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const FaIcon(FontAwesomeIcons.leaf,
                                      color: Colors.white, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    'dashboard.eco_badge'.tr(),
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'dashboard.book_pickup'.tr(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'dashboard.book_pickup_desc'.tr(),
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const FaIcon(FontAwesomeIcons.truckFast,
                          size: 60, color: Colors.white),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Categories
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'dashboard.what_to_sell'.tr(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.push(AppRoutes.categorySelection),
                      child: Text(
                        'dashboard.view_all'.tr(),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 100,
                  child: Builder(builder: (context) {
                    final cats = pickupState.categories
                        .whereType<Map<String, dynamic>>()
                        .take(4)
                        .toList();
                    if (cats.isEmpty) {
                      return _buildDefaultCategories(context);
                    }
                    return ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: cats.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, i) {
                        final name =
                            cats[i]['name']?.toString() ?? 'Category';
                        return GestureDetector(
                          onTap: () =>
                              context.push(AppRoutes.categorySelection),
                          child: _buildCategoryChip(name),
                        );
                      },
                    );
                  }),
                ),

                const SizedBox(height: 32),

                // Active Pickups
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'dashboard.active_request'.tr(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    if (activePickups.isNotEmpty)
                      Text(
                        '${activePickups.length} active',
                        style: const TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w600),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                if (pickupState.isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (activePickups.isEmpty)
                  _buildNoActivePickup(context)
                else
                  ...activePickups
                      .map((p) => _buildPickupCard(context, p))
                      .toList(),

                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.categorySelection),
        backgroundColor: AppTheme.primaryColor,
        elevation: 4,
        icon: const FaIcon(FontAwesomeIcons.plus, color: Colors.white),
        label: Text(
          'dashboard.book_now_fab'.tr(),
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
    );
  }

  Widget _buildStatChip(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color)),
            Text(label,
                style: const TextStyle(
                    fontSize: 11, color: AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultCategories(BuildContext context) {
    final items = [
      (FontAwesomeIcons.screwdriverWrench, 'Metal'),
      (FontAwesomeIcons.microchip, 'E-Waste'),
      (FontAwesomeIcons.newspaper, 'Paper'),
      (FontAwesomeIcons.recycle, 'Plastic'),
    ];
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(width: 12),
      itemBuilder: (_, i) => GestureDetector(
        onTap: () => context.push(AppRoutes.categorySelection),
        child: _buildCategoryChip(items[i].$2, icon: items[i].$1),
      ),
    );
  }

  Widget _buildCategoryChip(String name, {IconData? icon}) {
    return Container(
      width: 110,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (icon != null)
            FaIcon(icon, color: Colors.white, size: 20),
          const Spacer(),
          Text(
            name,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildPickupCard(BuildContext context, PickupRequest p) {
    final statusColor = _statusColor(p.status);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: FaIcon(FontAwesomeIcons.boxOpen,
                    color: statusColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.orderCode ?? 'Request #${p.id}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      p.address,
                      style: const TextStyle(
                          fontSize: 12, color: AppTheme.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  p.status.replaceAll('_', ' ').toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.grey.shade200),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const FaIcon(FontAwesomeIcons.solidCalendarDays,
                      size: 14, color: AppTheme.textSecondary),
                  const SizedBox(width: 6),
                  Text(
                    p.scheduledAt.length > 10
                        ? p.scheduledAt.substring(0, 10)
                        : p.scheduledAt,
                    style: const TextStyle(
                        fontSize: 13, color: AppTheme.textSecondary),
                  ),
                ],
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => context.push(AppRoutes.pickupDetails,
                        extra: {'pickup_id': p.id}),
                    child: const Text(
                      'Details',
                      style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => context.push(AppRoutes.pickupTracking,
                        extra: {'pickup_id': p.id}),
                    child: Text(
                      'dashboard.track'.tr(),
                      style: const TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoActivePickup(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          FaIcon(FontAwesomeIcons.truckFast,
              size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'No active pickups',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade500),
          ),
          const SizedBox(height: 8),
          Text(
            'Book a pickup to get started',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => context.push(AppRoutes.categorySelection),
            child: const Text('Book Now'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../channel_partner/providers/channel_partner_provider.dart';
import '../partner_locale.dart';

class PartnerWarehousesPage extends ConsumerStatefulWidget {
  const PartnerWarehousesPage({super.key});

  @override
  ConsumerState<PartnerWarehousesPage> createState() =>
      _PartnerWarehousesPageState();
}

class _PartnerWarehousesPageState extends ConsumerState<PartnerWarehousesPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(channelPartnerProvider.notifier).loadWarehouses(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(channelPartnerProvider);
    final user = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(
          Icons.add_business_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(user?.name ?? ''),
            Expanded(
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: () => ref
                          .read(channelPartnerProvider.notifier)
                          .loadWarehouses(),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 80),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (state.error != null)
                              Container(
                                margin: const EdgeInsets.fromLTRB(
                                  20,
                                  20,
                                  20,
                                  0,
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
                            _buildHeader(state.warehouses.length),
                            _buildWarehouseList(state.warehouses),
                            _buildQuickActions(),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(String name) {
    final initial = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : 'P';
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
              CircleAvatar(
                radius: 18,
                backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.12),
                child: Text(
                  initial,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                context.partnerText('Warehouses', 'गोदाम'),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 8),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  context.partnerText('$count hubs', '$count हब'),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            context.partnerText(
              'Regional hubs managed under your network.',
              'आपके नेटवर्क के अंतर्गत प्रबंधित क्षेत्रीय हब।',
            ),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarehouseList(List<dynamic> warehouses) {
    if (warehouses.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.warehouse_rounded,
                size: 48,
                color: Colors.grey.shade300,
              ),
              const SizedBox(height: 12),
              Text(
                context.partnerText(
                  'No warehouses assigned yet',
                  'अभी कोई गोदाम असाइन नहीं हुआ',
                ),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final wList = warehouses.whereType<Map<String, dynamic>>().toList();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          if (wList.isNotEmpty) _buildLargeWarehouseCard(wList[0]),
          if (wList.length > 1) ...[
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemCount: wList.length - 1,
              itemBuilder: (context, index) =>
                  _buildSmallWarehouseCard(wList[index + 1]),
            ),
          ],
        ],
      ),
    );
  }

  (Color, Color) _whStatusStyle(Map<String, dynamic> wh) {
    final isActive = wh['is_active'] == true || wh['status'] == 'active';
    if (isActive) {
      return (const Color(0xFFDCFCE7), const Color(0xFF14532D));
    }
    return (const Color(0xFFFEE2E2), const Color(0xFFEF4444));
  }

  Widget _buildLargeWarehouseCard(Map<String, dynamic> wh) {
    final name = wh['name']?.toString() ?? 'Warehouse';
    final region =
        wh['address']?.toString() ?? wh['location']?.toString() ?? '';
    final pickupBoys =
        (wh['pickup_boys_count'] ?? wh['total_pickup_boys'] ?? 0) as int;
    final totalOrders = (wh['total_orders'] ?? wh['orders_count'] ?? 0) as int;
    final isActive = wh['is_active'] == true || wh['status'] == 'active';
    final (statusBg, statusText) = _whStatusStyle(wh);
    final initials = name.trim().isNotEmpty
        ? name.trim()[0].toUpperCase()
        : 'W';

    return Container(
      width: double.infinity,
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
              CircleAvatar(
                radius: 20,
                backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.15),
                child: Text(
                  initials,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  localizedPartnerStatus(
                    context,
                    isActive ? 'active' : 'offline',
                  ),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: statusText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
            ),
          ),
          if (region.isNotEmpty)
            Text(
              region,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade500,
              ),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.partnerText('PICKUP BOYS', 'पिकअप बॉय'),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade400,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$pickupBoys',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.partnerText('TOTAL ORDERS', 'कुल ऑर्डर'),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade400,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$totalOrders',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    context.partnerText('Manage Hub', 'हब प्रबंधित करें'),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.chevron_right, size: 16, color: Colors.white),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallWarehouseCard(Map<String, dynamic> wh) {
    final name = wh['name']?.toString() ?? 'Warehouse';
    final region =
        wh['address']?.toString() ?? wh['location']?.toString() ?? '';
    final pickupBoys =
        (wh['pickup_boys_count'] ?? wh['total_pickup_boys'] ?? 0) as int;
    final totalOrders = (wh['total_orders'] ?? wh['orders_count'] ?? 0) as int;
    final isActive = wh['is_active'] == true || wh['status'] == 'active';
    final (statusBg, statusText) = _whStatusStyle(wh);
    final initials = name.trim().isNotEmpty
        ? name.trim()[0].toUpperCase()
        : 'W';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.cardBorderRadius,
        boxShadow: AppTheme.cardShadow,
        border: !isActive ? Border.all(color: const Color(0xFFFEE2E2)) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor:
                        (isActive ? AppTheme.primaryColor : Colors.grey)
                            .withValues(alpha: 0.15),
                    child: Text(
                      initials,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: isActive ? AppTheme.primaryColor : Colors.grey,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      localizedPartnerStatus(
                        context,
                        isActive ? 'active' : 'offline',
                      ),
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        color: statusText,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                name,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: isActive
                      ? const Color(0xFF0F172A)
                      : Colors.grey.shade400,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (region.isNotEmpty)
                Text(
                  region,
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.person_rounded,
                    size: 14,
                    color: isActive
                        ? AppTheme.primaryColor
                        : Colors.grey.shade300,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    context.partnerText('$pickupBoys boys', '$pickupBoys बॉय'),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isActive
                          ? const Color(0xFF334155)
                          : Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.shopping_bag_rounded,
                    size: 14,
                    color: isActive
                        ? Colors.grey.shade400
                        : Colors.grey.shade300,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    context.partnerText(
                      '$totalOrders orders',
                      '$totalOrders ऑर्डर',
                    ),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isActive
                          ? Colors.grey.shade500
                          : Colors.grey.shade400,
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

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.partnerText('Quick Actions', 'क्विक एक्शन'),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  icon: Icons.add_business_rounded,
                  label: context.partnerText('Add Hub', 'हब जोड़ें'),
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionCard(
                  icon: Icons.local_shipping_rounded,
                  label: context.partnerText(
                    'Assign Agent',
                    'एजेंट असाइन करें',
                  ),
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionCard(
                  icon: Icons.view_in_ar_rounded,
                  label: context.partnerText('Audit', 'ऑडिट'),
                  color: const Color(0xFF6366F1),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.cardBorderRadius,
        border: AppTheme.cardBorder,
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../features/auth/providers/auth_provider.dart';
import '../../../../features/channel_partner/providers/channel_partner_provider.dart';
import '../partner_locale.dart';

class PartnerOrdersPage extends ConsumerStatefulWidget {
  const PartnerOrdersPage({super.key});

  @override
  ConsumerState<PartnerOrdersPage> createState() => _PartnerOrdersPageState();
}

class _PartnerOrdersPageState extends ConsumerState<PartnerOrdersPage> {
  String? _statusFilter;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(channelPartnerProvider.notifier).loadOrders(),
    );
  }

  void _applyStatus(String? status) {
    setState(() => _statusFilter = status);
    ref.read(channelPartnerProvider.notifier).loadOrders(status: status);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(channelPartnerProvider);
    final user = ref.watch(authProvider);
    final orders = state.orders.whereType<Map<String, dynamic>>().toList();

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(user?.name),
            Expanded(
              child: state.isLoading && state.orders.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: () => ref
                          .read(channelPartnerProvider.notifier)
                          .loadOrders(status: _statusFilter),
                      child: CustomScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          SliverToBoxAdapter(
                            child: _buildHeader(orders.length),
                          ),
                          SliverToBoxAdapter(child: _buildSearchBar()),
                          SliverToBoxAdapter(child: _buildStatusChips()),
                          if (state.error != null)
                            SliverToBoxAdapter(
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 8,
                                ),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColor.hintPeach,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppColor.warning.withValues(alpha: 0.30),
                                  ),
                                ),
                                child: Text(
                                  state.error!,
                                  style: TextStyle(
                                    color: AppColor.warning,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          if (orders.isEmpty && !state.isLoading)
                            SliverFillRemaining(
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.inbox_rounded,
                                      size: 48,
                                      color: AppColor.outline,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      context.partnerText(
                                        'No orders found',
                                        'कोई ऑर्डर नहीं मिला',
                                      ),
                                      style: TextStyle(
                                        color: AppColor.textMuted,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            SliverPadding(
                              padding: const EdgeInsets.fromLTRB(
                                20,
                                12,
                                20,
                                24,
                              ),
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (ctx, i) => _buildOrderCard(orders[i]),
                                  childCount: orders.length,
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

  Widget _buildAppBar(String? name) {
    final initial = (name?.trim().isNotEmpty ?? false)
        ? name!.trim()[0].toUpperCase()
        : 'P';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColor.hairline)),
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
                name ?? 'Partner',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColor.backgroundCream,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_none_rounded,
              color: AppColor.textSecondary,
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
                context.partnerText('Orders', 'ऑर्डर्स'),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            context.partnerText(
              'Manage and track your regional distribution requests.',
              'अपने क्षेत्रीय अनुरोध और ऑर्डर ट्रैक करें।',
            ),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColor.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppTheme.cardBorderRadius,
          border: AppTheme.cardBorder,
          boxShadow: AppTheme.cardShadow,
        ),
        child: TextField(
          decoration: InputDecoration(
            hintText: context.partnerText(
              'Search order ID or customer...',
              'ऑर्डर आईडी या ग्राहक खोजें...',
            ),
            hintStyle: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColor.textMuted,
            ),
            prefixIcon: Icon(Icons.search, color: AppColor.textMuted),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChips() {
    final statuses = [
      (null, context.partnerText('All', 'सभी')),
      ('active', localizedPartnerStatus(context, 'active')),
      ('assigned', localizedPartnerStatus(context, 'assigned')),
      ('completed', localizedPartnerStatus(context, 'completed')),
      ('cancelled', localizedPartnerStatus(context, 'cancelled')),
      ('rescheduled', localizedPartnerStatus(context, 'rescheduled')),
    ];

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: statuses.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final isSelected = _statusFilter == statuses[i].$1;
          return GestureDetector(
            onTap: () => _applyStatus(statuses[i].$1),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primaryColor
                    : AppTheme.primaryLight.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.primaryColor
                      : AppTheme.outline,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppTheme.primaryColor.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                statuses[i].$2,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.white : AppTheme.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> o) {
    final orderCode =
        o['order_code']?.toString() ??
        o['pickup_code']?.toString() ??
        '#${o['id']}';
    final customerName = o['customer_name']?.toString() ?? 'Customer';
    final scheduledAt = o['scheduled_at']?.toString() ?? '';
    final address = o['address']?.toString() ?? '';
    final status = o['status']?.toString() ?? 'pending';
    final assignedBoy = o['assigned_pickup_boy'] as Map<String, dynamic>?;
    final pickupBoyName =
        assignedBoy?['name']?.toString() ?? o['pickup_boy_name']?.toString();
    final statusStyle = _statusStyle(status);
    final initial = customerName.isNotEmpty
        ? customerName[0].toUpperCase()
        : '?';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.cardBorderRadius,
        border: AppTheme.cardBorder,
        boxShadow: AppTheme.cardShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppTheme.primaryLight.withValues(
                        alpha: 0.3,
                      ),
                      child: Text(
                        initial,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          color: AppTheme.primaryDark,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customerName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          context.partnerText('Customer', 'ग्राहक'),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AppColor.textMuted,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
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
                    localizedPartnerStatus(context, status),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: statusStyle.$2,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border.symmetric(
                  horizontal: BorderSide(color: AppColor.backgroundCream),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.partnerText('ORDER ID', 'ऑर्डर आईडी'),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AppColor.textMuted,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          orderCode,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColor.brandNavy,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.partnerText('SCHEDULED', 'समय'),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AppColor.textMuted,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _fmtDate(scheduledAt),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColor.brandNavy,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.location_on_rounded,
              iconColor: AppColor.textSecondary,
              label: context.partnerText('Address', 'पता'),
              value: address.length > 35
                  ? '${address.substring(0, 35)}…'
                  : address,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              icon: pickupBoyName != null
                  ? Icons.moped_rounded
                  : Icons.add_circle_rounded,
              iconColor: pickupBoyName != null
                  ? AppColor.textSecondary
                  : AppTheme.primaryColor,
              label: context.partnerText('Pickup Boy', 'पिकअप बॉय'),
              value:
                  pickupBoyName ??
                  context.partnerText('Not yet assigned', 'अभी असाइन नहीं हुआ'),
              valueColor: pickupBoyName == null ? AppTheme.primaryColor : null,
              bgColor: pickupBoyName == null
                  ? AppTheme.primaryColor.withValues(alpha: 0.1)
                  : null,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: ref.watch(channelPartnerProvider).isActionLoading
                    ? null
                    : () => _showOrderDetail(o),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      context.partnerText('View Details', 'विवरण देखें'),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.chevron_right, size: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showOrderDetail(Map<String, dynamic> order) async {
    final id = int.tryParse('${order['id'] ?? ''}');
    if (id == null) {
      _presentOrderDetail(order);
      return;
    }

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final detail = await ref
        .read(channelPartnerProvider.notifier)
        .getOrderDetail(id);

    if (mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }

    if (!mounted) return;

    if (detail == null) {
      final message =
          ref.read(channelPartnerProvider).error ??
          context.partnerText(
            'Failed to load order details',
            'ऑर्डर विवरण लोड नहीं हो सका',
          );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: AppColor.error),
      );
      return;
    }

    _presentOrderDetail(detail);
  }

  void _presentOrderDetail(Map<String, dynamic> detail) {
    final assignedBoy = detail['assigned_pickup_boy'] as Map<String, dynamic>?;
    final orderCode =
        detail['order_code']?.toString() ??
        detail['pickup_code']?.toString() ??
        '#${detail['id']}';
    final customerName = detail['customer_name']?.toString() ?? 'Customer';
    final customerPhone = detail['customer_phone']?.toString() ?? '';
    final address = detail['address']?.toString() ?? 'Address unavailable';
    final status = detail['status']?.toString() ?? 'pending';
    final scheduledAt = detail['scheduled_at']?.toString() ?? '';
    final notes = detail['notes']?.toString() ?? '';
    final pickupBoyName =
        assignedBoy?['name']?.toString() ??
        detail['pickup_boy_name']?.toString() ??
        'Not assigned';
    final warehouseName =
        detail['warehouse_name']?.toString() ??
        detail['assigned_warehouse']?.toString() ??
        '';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.72,
        minChildSize: 0.5,
        maxChildSize: 0.92,
        expand: false,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppTheme.cardBorderRadius,
            border: AppTheme.cardBorder,
            boxShadow: AppTheme.cardShadow,
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColor.outline,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                orderCode,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                customerName,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColor.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildDetailChip(
                    icon: Icons.schedule_rounded,
                    label: _fmtDate(scheduledAt),
                  ),
                  _buildDetailChip(
                    icon: Icons.flag_rounded,
                    label: localizedPartnerStatus(context, status),
                    accent: _statusStyle(status).$2,
                    background: _statusStyle(status).$1,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildDetailSection(
                title: context.partnerText('Order Details', 'ऑर्डर विवरण'),
                children: [
                  _buildDetailRow(
                    context.partnerText('Customer', 'ग्राहक'),
                    customerName,
                  ),
                  if (customerPhone.isNotEmpty)
                    _buildDetailRow(
                      context.partnerText('Phone', 'फ़ोन'),
                      customerPhone,
                    ),
                  _buildDetailRow(
                    context.partnerText('Pickup Boy', 'पिकअप बॉय'),
                    pickupBoyName,
                  ),
                  if (warehouseName.isNotEmpty)
                    _buildDetailRow(
                      context.partnerText('Warehouse', 'गोदाम'),
                      warehouseName,
                    ),
                  _buildDetailRow(
                    context.partnerText('Address', 'पता'),
                    address,
                  ),
                ],
              ),
              if (notes.isNotEmpty) ...[
                const SizedBox(height: 20),
                _buildDetailSection(
                  title: context.partnerText('Notes', 'नोट्स'),
                  children: [
                    Text(
                      notes,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: AppColor.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailChip({
    required IconData icon,
    required String label,
    Color? accent,
    Color? background,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: background ?? AppTheme.backgroundCream,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: accent ?? AppTheme.textSecondary),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: accent ?? AppColor.brandNavy,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundCream,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColor.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColor.brandNavy,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    Color? valueColor,
    Color? bgColor,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bgColor ?? AppTheme.backgroundCream,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: AppColor.textMuted,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: valueColor ?? AppColor.brandNavy,
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
      case 'completed':
      case 'delivered':
      case 'paid':
        return (AppTheme.primarySurface, AppTheme.primaryDark);
      case 'assigned':
      case 'in_transit':
      case 'on_the_way':
        return (AppTheme.primarySurface, AppTheme.primaryDark);
      case 'active':
      case 'pending':
        return (AppTheme.hintPeach, AppColor.warning);
      case 'cancelled':
        return (AppColor.errorTint, AppColor.error);
      case 'rescheduled':
        return (AppColor.roseTint, AppColor.rose);
      default:
        return (AppTheme.hairline, AppTheme.textSecondary);
    }
  }

  String _fmtDate(String raw) {
    try {
      final dt = DateTime.parse(raw).toLocal();
      return '${dt.day}/${dt.month}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return raw.isNotEmpty ? raw : '—';
    }
  }
}

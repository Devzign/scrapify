import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/utils/app_routes.dart';
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
  Widget build(BuildContext context) {
    final state = ref.watch(channelPartnerProvider);
    final user = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
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
                            _buildHeader(state.warehouses.length),
                            _buildWarehouseList(state.warehouses),
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
                name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          Row(
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(40),
                onTap: () => context.push(AppRoutes.notifications),
                child: Container(
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
              ),
              const SizedBox(width: 8),
              InkWell(
                borderRadius: BorderRadius.circular(40),
                onTap: () => context.push(AppRoutes.partnerProfile),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColor.backgroundCream,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person_outline_rounded,
                    color: AppColor.textSecondary,
                    size: 22,
                  ),
                ),
              ),
            ],
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
                  color: AppTheme.textPrimary,
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
              color: AppColor.textSecondary,
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
                color: AppColor.outline,
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
                  color: AppColor.textMuted,
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
      return (AppTheme.primarySurface, AppTheme.primaryDark);
    }
    return (AppColor.errorTint, AppColor.error);
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
              color: AppTheme.textPrimary,
            ),
          ),
          if (region.isNotEmpty)
            Text(
              region,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColor.textSecondary,
              ),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.hairline,
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
                          color: AppColor.textMuted,
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
                    color: AppTheme.hairline,
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
                          color: AppColor.textMuted,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$totalOrders',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.textPrimary,
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
        border: !isActive ? Border.all(color: AppColor.errorTint) : null,
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
                        (isActive ? AppTheme.primaryColor : AppColor.textMuted)
                            .withValues(alpha: 0.15),
                    child: Text(
                      initials,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: isActive ? AppTheme.primaryColor : AppColor.textMuted,
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
                      ? AppTheme.textPrimary
                      : AppColor.textMuted,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (region.isNotEmpty)
                Text(
                  region,
                  style: TextStyle(fontSize: 10, color: AppColor.textMuted),
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
                        : AppColor.outline,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    context.partnerText('$pickupBoys boys', '$pickupBoys बॉय'),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isActive
                          ? AppColor.brandNavy
                          : AppColor.textMuted,
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
                        ? AppColor.textMuted
                        : AppColor.outline,
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
                          ? AppColor.textSecondary
                          : AppColor.textMuted,
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

}

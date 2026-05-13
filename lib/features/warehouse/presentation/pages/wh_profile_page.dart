import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_color.dart';
import '../../../../core/utils/app_routes.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../providers/warehouse_provider.dart';

class WhProfilePage extends ConsumerWidget {
  const WhProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isHindi = context.locale.languageCode == 'hi';
    final user = ref.watch(authProvider);
    final dashboard = ref.watch(warehouseProvider).dashboard;
    final warehouse = dashboard?.warehouse;

    final name = user?.name ?? '';
    final phone = user?.phone ?? '';
    final initials = name.trim().isNotEmpty
        ? name.trim().split(' ').map((w) => w[0]).take(2).join().toUpperCase()
        : 'W';
    final warehouseName = warehouse?.name ?? '';
    final warehouseAddress = warehouse?.address ?? warehouse?.city ?? '';

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(warehouseName, isHindi),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeroProfile(name, phone, initials, isHindi),
                    _buildInfoSection(warehouseName, warehouseAddress, isHindi),
                    _buildLogout(context, ref, isHindi),
                    _buildAppVersion(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(String warehouseName, bool isHindi) {
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
              Icon(
                Icons.warehouse_rounded,
                color: AppTheme.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 10),
              Text(
                warehouseName.isNotEmpty
                    ? warehouseName
                    : (isHindi ? 'गोदाम' : 'Warehouse'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroProfile(
    String name,
    String phone,
    String initials,
    bool isHindi,
  ) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppTheme.cardBorderRadius,
          border: AppTheme.cardBorder,
          boxShadow: AppTheme.cardShadow,
        ),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primarySurface,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: AppTheme.cardShadow,
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.verified_rounded,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name.isNotEmpty
                        ? name
                        : (isHindi ? 'गोदाम प्रशासक' : 'Warehouse Admin'),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    isHindi ? 'गोदाम पर्यवेक्षक' : 'Warehouse Supervisor',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  if (phone.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.call_rounded,
                          size: 14,
                          color: AppColor.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          phone,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColor.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(
    String warehouseName,
    String warehouseAddress,
    bool isHindi,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
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
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primarySurface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.location_on_rounded,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  isHindi ? 'गोदाम पहचान' : 'Warehouse Identity',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildInfoField(
              label: isHindi ? 'संस्था का नाम' : 'ENTITY NAME',
              value: warehouseName.isNotEmpty ? warehouseName : '—',
              isLarge: true,
            ),
            const SizedBox(height: 14),
            _buildInfoField(
              label: isHindi ? 'पता' : 'ADDRESS',
              value: warehouseAddress.isNotEmpty ? warehouseAddress : '—',
              isLarge: false,
            ),
            const SizedBox(height: 18),
            _buildSmallButton(
              Icons.map_rounded,
              isHindi ? 'मानचित्र' : 'View Map',
              onTap: warehouseAddress.isNotEmpty
                  ? () => _openMap(warehouseAddress)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoField({
    required String label,
    required String value,
    required bool isLarge,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryColor,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: isLarge ? 16 : 13,
            fontWeight: isLarge ? FontWeight.w700 : FontWeight.w500,
            color: isLarge ? AppTheme.textPrimary : AppColor.textSecondary,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildSmallButton(IconData icon, String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.outline,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppTheme.textPrimary),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openMap(String address) async {
    final encoded = Uri.encodeComponent(address);
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$encoded');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildLogout(BuildContext context, WidgetRef ref, bool isHindi) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (_) => AlertDialog(
                title: Text(isHindi ? 'लॉगआउट' : 'Logout'),
                content: Text(
                  isHindi
                      ? 'क्या आप लॉगआउट करना चाहते हैं?'
                      : 'Are you sure you want to logout?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(isHindi ? 'रद्द करें' : 'Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: Text(
                      isHindi ? 'लॉगआउट' : 'Logout',
                      style: TextStyle(color: AppTheme.errorColor),
                    ),
                  ),
                ],
              ),
            );
            if (confirmed == true) {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                context.go(AppRoutes.role);
              }
            }
          },
          icon: Icon(Icons.logout_rounded, color: AppTheme.errorColor),
          label: Text(
            isHindi ? 'लॉगआउट' : 'Logout',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: AppTheme.errorColor,
            ),
          ),
          style: OutlinedButton.styleFrom(
            backgroundColor: AppTheme.backgroundLight,
            side: BorderSide(
              color: AppTheme.errorColor.withValues(alpha: 0.1),
              width: 2,
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppVersion() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 24),
      child: Center(
        child: Text(
          'App Version 2.4.1 (Production)\n© 2024 Scrapi5 Waste Solutions Pvt. Ltd.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            color: AppColor.textMuted,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}

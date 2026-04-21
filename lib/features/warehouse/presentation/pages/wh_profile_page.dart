import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
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
      backgroundColor: const Color(0xFFF7F7F7),
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
                    _buildSupportSection(isHindi),
                    _buildAccountSettings(isHindi),
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
                warehouseName.isNotEmpty
                    ? warehouseName
                    : (isHindi ? 'गोदाम' : 'Warehouse'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
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
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppTheme.softShadow,
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
                    color: const Color(0xFFDCFCE7),
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: AppTheme.softShadow,
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
                      color: Color(0xFF0F172A),
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
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          phone,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
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
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppTheme.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
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
                    color: Color(0xFF0F172A),
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
            Row(
              children: [
                _buildSmallButton(
                  Icons.map_rounded,
                  isHindi ? 'मानचित्र' : 'View Map',
                ),
                const SizedBox(width: 8),
                _buildSmallButton(
                  Icons.edit_rounded,
                  isHindi ? 'संपादित करें' : 'Edit Details',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportSection(bool isHindi) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.support_agent_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  isHindi ? 'सहायता' : 'Support',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              isHindi
                  ? 'लॉजिस्टिक्स या इन्वेंटरी में मदद चाहिए? हमारी 24/7 सपोर्ट लाइन यहाँ है।'
                  : 'Need help with logistics or inventory? Our 24/7 support line is here.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.85),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _buildSupportAction(
                    Icons.phone_in_talk_rounded,
                    isHindi ? 'कॉल करें' : 'Call Support',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildSupportAction(
                    Icons.chat_bubble_rounded,
                    isHindi ? 'WhatsApp' : 'WhatsApp Chat',
                  ),
                ),
              ],
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
            color: isLarge ? const Color(0xFF0F172A) : Colors.grey.shade500,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildSmallButton(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF0F172A)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportAction(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSettings(bool isHindi) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppTheme.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: Text(
                isHindi ? 'खाता सेटिंग्स' : 'Account Settings',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
            const SizedBox(height: 8),
            _buildSettingsItem(
              icon: Icons.lock_rounded,
              title: isHindi ? 'सुरक्षा' : 'Security',
              subtitle: isHindi
                  ? 'पासवर्ड और 2FA अपडेट करें'
                  : 'Update password and 2FA',
            ),
            Divider(height: 1, color: Colors.grey.shade50),
            _buildSettingsItem(
              icon: Icons.translate_rounded,
              title: isHindi ? 'भाषा' : 'Language',
              subtitle: isHindi ? 'हिंदी, अंग्रेजी' : 'English, Hindi',
            ),
            Divider(height: 1, color: Colors.grey.shade50),
            _buildSettingsItem(
              icon: Icons.policy_rounded,
              title: isHindi ? 'अनुपालन दस्तावेज़' : 'Compliance Docs',
              subtitle: isHindi
                  ? 'गोदाम प्रमाणपत्र देखें'
                  : 'View warehouse certifications',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.grey.shade500, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey.shade400,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogout(BuildContext context, WidgetRef ref, bool isHindi) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
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
            backgroundColor: Colors.white,
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
            color: Colors.grey.shade400,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}

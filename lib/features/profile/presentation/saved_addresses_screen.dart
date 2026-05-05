import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_routes.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/loading_skeletons.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/address_provider.dart';

class SavedAddressesScreen extends ConsumerWidget {
  const SavedAddressesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = context.locale;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final addressState = ref.watch(addressProvider);

    return Scaffold(
      key: ValueKey('saved_addresses_${locale.languageCode}'),
      backgroundColor: isDark ? const Color(0xFF102213) : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark
            ? const Color(0xFF102213).withValues(alpha: 0.9)
            : Colors.white.withValues(alpha: 0.9),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: isDark ? Colors.white : const Color(0xFF0F172A), // slate-900
            size: 24,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'address_book.title'.tr(),
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF0F172A), // slate-900
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: 100,
            ),
            children: [
              addressState.when(
                data: (addresses) {
                  if (addresses.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Text(
                          'No saved addresses found.',
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    );
                  }
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: addresses.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final addr = addresses[index];
                      return _buildAddressCard(
                        context,
                        title: addr.title,
                        address:
                            '${addr.addressLine1}${addr.addressLine2 != null ? ', ${addr.addressLine2}' : ''}\nPincode: ${addr.pincode}',
                        icon: addr.title.toLowerCase() == 'home'
                            ? Icons.home
                            : (addr.title.toLowerCase() == 'work'
                                  ? Icons.work
                                  : Icons.location_on),
                        isPrimary: addr.isDefault,
                        isDark: isDark,
                        onDelete: () => ref
                            .read(addressProvider.notifier)
                            .deleteAddress(addr.id),
                      );
                    },
                  );
                },
                loading: () => const AddressListLoadingSkeleton(),
                error: (err, stack) => Center(child: Text('Error: $err')),
              ),
              const SizedBox(height: 16),
              // Info hint
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  border: Border.all(
                    color: AppTheme.primaryColor.withValues(alpha: 0.2),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: isDark
                          ? AppTheme.primaryColor
                          : const Color(0xFF0FB825),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'address_book.info'.tr(),
                            style: TextStyle(
                              color: isDark
                                  ? const Color(0xFFCBD5E1)
                                  : const Color(0xFF334155),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Floating Action Button Area
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 48, 20, 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    isDark ? const Color(0xFF102213) : Colors.white,
                    isDark
                        ? const Color(0xFF102213).withValues(alpha: 0.8)
                        : Colors.white.withValues(alpha: 0.8),
                    isDark
                        ? const Color(0xFF102213).withValues(alpha: 0.0)
                        : Colors.white.withValues(alpha: 0.0),
                  ],
                ),
              ),
              child: SafeArea(
                child: CustomButton(
                  onPressed: () => context.push(AppRoutes.addAddress),
                  text: 'address_book.add_new'.tr(),
                  leading: const Icon(Icons.add),
                  borderRadius: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(
    BuildContext context, {
    required String title,
    required String address,
    required IconData icon,
    required bool isPrimary,
    required bool isDark,
    required VoidCallback onDelete,
  }) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF0F172A)
            : Colors.white, // slate-900 or white
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? const Color(0xFF1E293B)
              : const Color(0xFFF1F5F9), // slate-800 or slate-100
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Selection Indicator strip
            if (isPrimary)
              Container(
                width: 6,
                color: AppTheme.primaryColor, // primary
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon Circular Avatar
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: isPrimary
                                ? (isDark
                                      ? AppTheme.primaryColor.withValues(
                                          alpha: 0.1,
                                        )
                                      : AppTheme.primaryColor.withValues(
                                          alpha: 0.2,
                                        ))
                                : (isDark
                                      ? const Color(0xFF1E293B)
                                      : const Color(0xFFF1F5F9)),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            icon,
                            color: isPrimary
                                ? (isDark
                                      ? AppTheme.primaryColor
                                      : const Color(0xFF0FB825))
                                : (isDark
                                      ? const Color(0xFF94A3B8)
                                      : const Color(0xFF475569)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Title and Address lines
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      title,
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.white
                                            : const Color(0xFF0F172A),
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (isPrimary) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryColor.withValues(
                                          alpha: 0.2,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Text(
                                        'DEFAULT',
                                        style: TextStyle(
                                          color: Color(0xFF0FB825),
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                address,
                                style: TextStyle(
                                  color: isDark
                                      ? const Color(0xFF94A3B8)
                                      : const Color(0xFF475569),
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Actions row
                    Container(
                      padding: const EdgeInsets.only(top: 16),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: isDark
                                ? const Color(0xFF1E293B)
                                : const Color(0xFFF1F5F9),
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildActionButton(
                              text: 'address_book.edit'.tr(),
                              icon: Icons.edit_outlined,
                              backgroundColor: isDark
                                  ? const Color(0xFF1E293B)
                                  : const Color(0xFFF8FAFC),
                              hoverColor: isDark
                                  ? const Color(0xFF334155)
                                  : const Color(0xFFF1F5F9),
                              textColor: isDark
                                  ? const Color(0xFFE2E8F0)
                                  : const Color(0xFF334155),
                              onTap: () {},
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildActionButton(
                              text: 'address_book.delete'.tr(),
                              icon: Icons.delete_outline,
                              backgroundColor: isDark
                                  ? const Color(
                                      0xFF7F1D1D,
                                    ).withValues(alpha: 0.2)
                                  : const Color(0xFFFEF2F2),
                              hoverColor: isDark
                                  ? const Color(
                                      0xFF7F1D1D,
                                    ).withValues(alpha: 0.3)
                                  : const Color(0xFFFEE2E2),
                              textColor: isDark
                                  ? const Color(0xFFF87171)
                                  : const Color(0xFFDC2626),
                              onTap: onDelete,
                            ),
                          ),
                        ],
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

  Widget _buildActionButton({
    required String text,
    required IconData icon,
    required Color backgroundColor,
    required Color hoverColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: textColor),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

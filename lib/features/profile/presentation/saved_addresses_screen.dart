import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_color.dart';
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
    final locale = Localizations.maybeLocaleOf(context) ?? const Locale('en');
    final addressState = ref.watch(addressProvider);

    return Scaffold(
      key: ValueKey('saved_addresses_${locale.languageCode}'),
      backgroundColor: AppColor.backgroundLight,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Column(
          children: [
            // ── Green gradient header ───────────────────────────────────
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1A5C35), AppColor.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(28)),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.16),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.30),
                            ),
                          ),
                          child: const Icon(
                            Icons.arrow_back_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'address_book.title'.tr(),
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: -0.3,
                              ),
                            ),
                            Text(
                              'Your saved pickup addresses',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.80),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.16),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.30),
                          ),
                        ),
                        child: const Icon(
                          Icons.location_on_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Address list ────────────────────────────────────────────
            Expanded(
              child: Stack(
                children: [
                  ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    children: [
                      addressState.when(
                        data: (addresses) {
                          if (addresses.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 48),
                              child: Center(
                                child: Column(
                                  children: [
                                    Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: AppColor.primarySurface,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.location_off_rounded,
                                        size: 36,
                                        color: AppColor.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'No saved addresses yet',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        color: AppColor.deepNavy,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    const Text(
                                      'Add an address to schedule pickups',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: AppColor.textSecondary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                          return ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: addresses.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final addr = addresses[index];
                              return _buildAddressCard(
                                context,
                                title: addr.title,
                                address:
                                    '${addr.addressLine1}${addr.addressLine2 != null ? ', ${addr.addressLine2}' : ''}\nPincode: ${addr.pincode}',
                                icon: addr.title.toLowerCase() == 'home'
                                    ? Icons.home_rounded
                                    : (addr.title.toLowerCase() == 'work'
                                        ? Icons.work_rounded
                                        : Icons.location_on_rounded),
                                isPrimary: addr.isDefault,
                                onDelete: () => ref
                                    .read(addressProvider.notifier)
                                    .deleteAddress(addr.id),
                              );
                            },
                          );
                        },
                        loading: () => const AddressListLoadingSkeleton(),
                        error: (err, stack) =>
                            Center(child: Text('Error: $err')),
                      ),
                      const SizedBox(height: 16),
                      // Info hint
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColor.primarySurface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColor.primary.withValues(alpha: 0.20),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.info_outline_rounded,
                              color: AppColor.primary,
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'address_book.info'.tr(),
                                style: const TextStyle(
                                  color: AppColor.primaryDark,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // ── Sticky "Add Address" button ─────────────────────
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            AppColor.backgroundLight,
                            AppColor.backgroundLight.withValues(alpha: 0.85),
                            AppColor.backgroundLight.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                      child: SafeArea(
                        child: CustomButton(
                          onPressed: () => context.push(AppRoutes.addAddress),
                          text: 'address_book.add_new'.tr(),
                          leading: const Icon(Icons.add, size: 20),
                          borderRadius: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressCard(
    BuildContext context, {
    required String title,
    required String address,
    required IconData icon,
    required bool isPrimary,
    required VoidCallback onDelete,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        border: Border.all(
          color: isPrimary ? AppColor.primary : AppColor.cardBorder,
          width: isPrimary ? 1.5 : 1.2,
        ),
        boxShadow: AppTheme.e1,
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Primary indicator strip
            if (isPrimary)
              Container(width: 5, color: AppColor.primary),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: isPrimary
                                ? AppColor.primarySurface
                                : AppColor.backgroundCream,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            icon,
                            color: isPrimary
                                ? AppColor.primary
                                : AppColor.textSecondary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      title,
                                      style: const TextStyle(
                                        color: AppColor.deepNavy,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: -0.1,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (isPrimary) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppColor.primary,
                                        borderRadius:
                                            BorderRadius.circular(AppTheme.radiusPill),
                                      ),
                                      child: const Text(
                                        'DEFAULT',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                address,
                                style: const TextStyle(
                                  color: AppColor.textSecondary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    // Action row
                    Container(
                      padding: const EdgeInsets.only(top: 14),
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: AppColor.hairline),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildActionButton(
                              text: 'address_book.edit'.tr(),
                              icon: Icons.edit_outlined,
                              backgroundColor: AppColor.backgroundCream,
                              textColor: AppColor.deepNavy,
                              onTap: () {},
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildActionButton(
                              text: 'address_book.delete'.tr(),
                              icon: Icons.delete_outline_rounded,
                              backgroundColor: AppColor.errorTint,
                              textColor: AppColor.error,
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
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: textColor),
            const SizedBox(width: 6),
            Text(
              text,
              style: TextStyle(
                color: textColor,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

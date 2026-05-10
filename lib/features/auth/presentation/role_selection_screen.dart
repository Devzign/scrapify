import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_color.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_routes.dart';
import '../../../core/widgets/custom_button.dart';
import '../domain/models/user_type_option.dart';
import 'view_models/role_selection_view_model.dart';
import 'widgets/role_option_card.dart';

class RoleSelectionScreen extends ConsumerWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(roleSelectionViewModelProvider);
    final viewModel = ref.read(roleSelectionViewModelProvider.notifier);

    if (!state.hasLoadedRoles && !state.isLoading) {
      Future<void>.microtask(viewModel.loadRoles);
    }

    // Source of truth for the visible cards:
    //   - If we have roles from the API, show them.
    //   - Else if the API failed (error AND we're not still loading), fall back
    //     to the hardcoded list so the screen is at least usable offline.
    //   - Else show a skeleton — never flash the wrong number of cards.
    final hasApiRoles = state.roles.isNotEmpty;
    final apiFailed =
        state.hasLoadedRoles && !state.isLoading && state.roles.isEmpty;
    final List<UserTypeOption> roles = hasApiRoles
        ? state.roles
        : (apiFailed ? _fallbackRoles() : const <UserTypeOption>[]);
    final showLoading = !hasApiRoles && !apiFailed;

    return Scaffold(
      backgroundColor: AppColor.backgroundLight,
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (state.selectedRole == null && !state.isLoading) ...[
              const Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Text(
                  'Please select a role to continue',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColor.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            CustomButton(
              onPressed: (state.isLoading || state.selectedRole == null)
                  ? null
                  : () {
                      context.push(
                        AppRoutes.login,
                        extra: {'role': state.selectedRole},
                      );
                    },
              text: 'common.continue'.tr(),
              trailing: const FaIcon(FontAwesomeIcons.arrowRight, size: 18),
            ),
          ],
        ),
      ),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Stack(
          children: [
            Positioned(
              top: -120,
              left: -80,
              right: -80,
              child: IgnorePointer(
                child: Container(
                  height: 360,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColor.primary.withValues(alpha: 0.14),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 8.h),
                    Center(
                      child: Container(
                        height: 76.w,
                        width: 76.w,
                        decoration: BoxDecoration(
                          color: AppColor.primarySurface,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColor.primary.withValues(alpha: 0.18),
                            width: 1,
                          ),
                        ),
                        child: const Center(
                          child: FaIcon(
                            FontAwesomeIcons.users,
                            color: AppColor.primary,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 22.h),
                    const Text(
                      'Select Your Role',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColor.deepNavy,
                        letterSpacing: -0.4,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'role.subtitle'.tr(),
                      style: const TextStyle(
                        color: AppColor.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 22.h),
                    Expanded(
                      child: showLoading
                          ? ListView.separated(
                              padding: EdgeInsets.only(bottom: 16.h),
                              itemCount: 4,
                              separatorBuilder: (_, _) =>
                                  SizedBox(height: 14.h),
                              itemBuilder: (_, _) => const _RoleCardSkeleton(),
                            )
                          : ListView.separated(
                              padding: EdgeInsets.only(bottom: 16.h),
                              itemCount: roles.length,
                              separatorBuilder: (_, _) =>
                                  SizedBox(height: 14.h),
                              itemBuilder: (context, index) {
                                final role = roles[index];
                                return RoleOptionCard(
                                  icon: _iconForRole(role.code),
                                  title: _titleForRole(role),
                                  description: _descriptionForRole(role),
                                  isSelected: state.selectedRole == role.code,
                                  onTap: () => viewModel.selectRole(role.code),
                                );
                              },
                            ),
                    ),
                    if (state.error != null && state.roles.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          state.error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppTheme.errorColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
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

  List<UserTypeOption> _fallbackRoles() {
    return const [
      UserTypeOption(
        code: 'customer',
        name: 'Customer',
        description: '',
        visible: true,
        sortOrder: 1,
      ),
      UserTypeOption(
        code: 'pickup_boy',
        name: 'Pickup Partner',
        description: '',
        visible: true,
        sortOrder: 2,
      ),
      UserTypeOption(
        code: 'warehouse',
        name: 'Warehouse',
        description: '',
        visible: true,
        sortOrder: 3,
      ),
    ];
  }

  String _titleForRole(UserTypeOption role) {
    switch (role.code) {
      case 'customer':
        return 'role.customer.title'.tr();
      case 'pickup_boy':
      case 'pickup_partner':
        return 'role.partner.title'.tr();
      case 'warehouse':
        return 'role.warehouse.title'.tr();
      case 'channel_partner':
      case 'dealer':
        return 'role.dealer.title'.tr();
      default:
        return role.name;
    }
  }

  String _descriptionForRole(UserTypeOption role) {
    switch (role.code) {
      case 'customer':
        return 'role.customer.desc'.tr();
      case 'pickup_boy':
      case 'pickup_partner':
        return 'role.partner.desc'.tr();
      case 'warehouse':
        return 'role.warehouse.desc'.tr();
      case 'channel_partner':
      case 'dealer':
        return 'role.dealer.desc'.tr();
      default:
        return role.description;
    }
  }

  IconData _iconForRole(String code) {
    switch (code) {
      case 'pickup_boy':
      case 'pickup_partner':
        return FontAwesomeIcons.truckFast;
      case 'warehouse':
        return FontAwesomeIcons.warehouse;
      case 'channel_partner':
      case 'dealer':
        return FontAwesomeIcons.handshake;
      case 'customer':
      default:
        return FontAwesomeIcons.houseUser;
    }
  }
}

/// Placeholder card shown while the user-types API call is in flight.
/// Sized to roughly match `RoleOptionCard` so the layout doesn't jump.
class _RoleCardSkeleton extends StatelessWidget {
  const _RoleCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 88,
      decoration: BoxDecoration(
        color: AppColor.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppColor.cardBorder),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColor.backgroundCream,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 140,
                  height: 14,
                  decoration: BoxDecoration(
                    color: AppColor.backgroundCream,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 200,
                  height: 11,
                  decoration: BoxDecoration(
                    color: AppColor.backgroundCream,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

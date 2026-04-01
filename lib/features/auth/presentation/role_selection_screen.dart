import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_routes.dart';
import 'view_models/role_selection_view_model.dart';
import 'widgets/role_option_card.dart';

class RoleSelectionScreen extends ConsumerWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(roleSelectionViewModelProvider);
    final viewModel = ref.read(roleSelectionViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: ElevatedButton(
          onPressed: () {
            context.push(AppRoutes.login, extra: {'role': state.selectedRole});
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'common.continue'.tr(),
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(width: 8),
              const FaIcon(FontAwesomeIcons.arrowRight, size: 20),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 48.h),
              Center(
                child: Container(
                  height: 80.w,
                  width: 80.w,
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: FaIcon(
                      FontAwesomeIcons.users,
                      color: AppTheme.primaryColor,
                      size: 32,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 32.h),
              Text(
                'role.title'.tr(),
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontSize: 24),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              Text(
                'role.subtitle'.tr(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32.h),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.only(bottom: 16.h),
                  children: [
                    RoleOptionCard(
                      icon: FontAwesomeIcons.houseUser,
                      title: 'role.customer.title'.tr(),
                      description: 'role.customer.desc'.tr(),
                      isSelected: state.selectedRole == 'customer',
                      onTap: () => viewModel.selectRole('customer'),
                    ),
                    SizedBox(height: 16.h),
                    RoleOptionCard(
                      icon: FontAwesomeIcons.truckFast,
                      title: 'role.partner.title'.tr(),
                      description: 'role.partner.desc'.tr(),
                      isSelected: state.selectedRole == 'pickup_partner',
                      onTap: () => viewModel.selectRole('pickup_partner'),
                    ),
                    SizedBox(height: 16.h),
                    RoleOptionCard(
                      icon: FontAwesomeIcons.warehouse,
                      title: 'role.warehouse.title'.tr(),
                      description: 'role.warehouse.desc'.tr(),
                      isSelected: state.selectedRole == 'warehouse',
                      onTap: () => viewModel.selectRole('warehouse'),
                    ),
                    SizedBox(height: 16.h),
                    RoleOptionCard(
                      icon: FontAwesomeIcons.handshake,
                      title: 'role.dealer.title'.tr(),
                      description: 'role.dealer.desc'.tr(),
                      isSelected: state.selectedRole == 'dealer',
                      onTap: () => viewModel.selectRole('dealer'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

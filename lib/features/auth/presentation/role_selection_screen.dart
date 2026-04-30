import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

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
    final roles = state.roles.isNotEmpty ? state.roles : _fallbackRoles();

    if (!state.hasLoadedRoles && !state.isLoading) {
      Future<void>.microtask(viewModel.loadRoles);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: CustomButton(
          onPressed: () {
            context.push(AppRoutes.login, extra: {'role': state.selectedRole});
          },
          text: 'common.continue'.tr(),
          trailing: const FaIcon(FontAwesomeIcons.arrowRight, size: 20),
        ),
      ),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 16.h),
                Center(
                  child: Container(
                    height: 72.w,
                    width: 72.w,
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
                SizedBox(height: 24.h),
                Text(
                  'role.title'.tr(),
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontSize: 24),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12.h),
                Text(
                  'role.subtitle'.tr(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24.h),
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.only(bottom: 16.h),
                    itemCount: roles.length,
                    separatorBuilder: (_, _) => SizedBox(height: 16.h),
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
      UserTypeOption(
        code: 'channel_partner',
        name: 'Channel Partner',
        description: '',
        visible: true,
        sortOrder: 4,
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

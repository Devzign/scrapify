import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_routes.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String _selectedRole = 'customer'; // default

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 48.h),
              
              // Icon Logo
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
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 24),
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
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Customer Card
                      _buildRoleCard(
                        id: 'customer',
                        icon: FontAwesomeIcons.houseUser,
                        title: 'role.customer.title'.tr(),
                        description: 'role.customer.desc'.tr(),
                        isSelected: _selectedRole == 'customer',
                      ),
                      SizedBox(height: 16.h),

                      // Pickup Boy Card
                      _buildRoleCard(
                        id: 'pickup_partner',
                        icon: FontAwesomeIcons.truckFast,
                        title: 'role.partner.title'.tr(),
                        description: 'role.partner.desc'.tr(),
                        isSelected: _selectedRole == 'pickup_partner',
                      ),
                      SizedBox(height: 16.h),

                      // Warehouse Card
                      _buildRoleCard(
                        id: 'warehouse',
                        icon: FontAwesomeIcons.warehouse,
                        title: 'role.warehouse.title'.tr(),
                        description: 'role.warehouse.desc'.tr(),
                        isSelected: _selectedRole == 'warehouse',
                      ),
                      SizedBox(height: 16.h),

                      // Scrap Partner Card
                      _buildRoleCard(
                        id: 'dealer',
                        icon: FontAwesomeIcons.handshake,
                        title: 'role.dealer.title'.tr(),
                        description: 'role.dealer.desc'.tr(),
                        isSelected: _selectedRole == 'dealer',
                      ),
                    ],
                  ),
                ),
              ),

              // Continue Button
              ElevatedButton(
                onPressed: () {
                  // In a real app we'd save this role to local storage / state
                  context.push(AppRoutes.login, extra: {'role': _selectedRole});
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
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required String id,
    required IconData icon,
    required String title,
    required String description,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRole = id;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryLight : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey.shade200,
            width: 2,
          ),
          boxShadow: [
            if (!isSelected)
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryColor : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: FaIcon(
                  icon,
                  color: isSelected ? Colors.white : AppTheme.textSecondary,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? AppTheme.primaryColor : AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const FaIcon(
                FontAwesomeIcons.solidCircleCheck,
                color: AppTheme.primaryColor,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}

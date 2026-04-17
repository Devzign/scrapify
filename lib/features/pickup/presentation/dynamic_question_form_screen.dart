import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_routes.dart';
import '../providers/pickup_draft_provider.dart';

class DynamicQuestionFormScreen extends ConsumerStatefulWidget {
  const DynamicQuestionFormScreen({super.key});

  @override
  ConsumerState<DynamicQuestionFormScreen> createState() =>
      _DynamicQuestionFormScreenState();
}

class _DynamicQuestionFormScreenState
    extends ConsumerState<DynamicQuestionFormScreen> {
  late String _selectedWeight;

  @override
  void initState() {
    super.initState();
    _selectedWeight = ref.read(pickupDraftProvider).estimatedWeight;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeft,
              color: AppTheme.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'pickup.title'.tr(),
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: Text(
              'common.help'.tr(),
              style: const TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stepper
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'pickup.step_2_of_4'.tr(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  'pickup.50_complete'.tr(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: 0.5,
                backgroundColor: AppTheme.primaryLight,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 32),

            // Category hint
            Consumer(builder: (context, ref, _) {
              final draft = ref.watch(pickupDraftProvider);
              if (draft.categoryName.isNotEmpty) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const FaIcon(FontAwesomeIcons.tag,
                          size: 12, color: AppTheme.primaryColor),
                      const SizedBox(width: 6),
                      Text(
                        draft.categoryName,
                        style: const TextStyle(
                          color: AppTheme.primaryDark,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            }),

            // Header
            Text(
              'pickup.how_much_weight'.tr(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 32),

            // Weight Options
            _buildWeightCard(
              id: 'small',
              icon: FontAwesomeIcons.bagShopping,
              title: 'pickup.small_load'.tr(),
              subtitle: 'pickup.small_load_desc'.tr(),
              isSelected: _selectedWeight == 'small',
            ),
            const SizedBox(height: 16),
            _buildWeightCard(
              id: 'medium',
              icon: FontAwesomeIcons.box,
              title: 'pickup.medium_load'.tr(),
              subtitle: 'pickup.medium_load_desc'.tr(),
              isSelected: _selectedWeight == 'medium',
            ),
            const SizedBox(height: 16),
            _buildWeightCard(
              id: 'large',
              icon: FontAwesomeIcons.truckFast,
              title: 'pickup.large_load'.tr(),
              subtitle: 'pickup.large_load_desc'.tr(),
              isSelected: _selectedWeight == 'large',
            ),
            const SizedBox(height: 24),

            // Info Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor.withValues(alpha: 0.8),
                    AppTheme.secondaryColor.withValues(alpha: 0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'pickup.ensure_dry'.tr(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: ElevatedButton(
            onPressed: () {
              ref
                  .read(pickupDraftProvider.notifier)
                  .setWeight(_selectedWeight);
              context.push(AppRoutes.uploadPhoto);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'common.next'.tr(),
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 8),
                const FaIcon(FontAwesomeIcons.arrowRight, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeightCard({
    required String id,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => setState(() => _selectedWeight = id),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryLight.withValues(alpha: 0.5)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                isSelected ? AppTheme.primaryColor : Colors.grey.shade200,
            width: 2,
          ),
          boxShadow: [
            if (!isSelected)
              BoxShadow(
                color: Colors.grey.shade200,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primaryColor
                    : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: FaIcon(
                  icon,
                  color:
                      isSelected ? Colors.white : AppTheme.textSecondary,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
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
              )
            else
              Container(
                height: 24,
                width: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border:
                      Border.all(color: Colors.grey.shade300, width: 2),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

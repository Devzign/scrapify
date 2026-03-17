import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/theme/app_theme.dart';

class PickupTrackingScreen extends StatelessWidget {
  const PickupTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        leading: IconButton(
          icon: const FaIcon(
            FontAwesomeIcons.arrowLeft,
            color: AppTheme.textPrimary,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          '${'tracking.title'.tr()} #OD-4921',
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Map Placeholder
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  height: 200,
                  width: double.infinity,
                  color: Colors.grey.shade200,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FaIcon(
                          FontAwesomeIcons.mapLocationDot,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'tracking.map_placeholder'.tr(),
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: -20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const FaIcon(
                          FontAwesomeIcons.truck,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'tracking.status_assigned'.tr(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 48),

            // Status Headers
            Text(
              'tracking.collection_progress'.tr(),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'tracking.est_arrival'.tr(),
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 32),

            // Custom Timeline/Stepper
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                children: [
                  _buildTimelineStep(
                    icon: FontAwesomeIcons.check,
                    iconBgColor: AppTheme.primaryColor,
                    isLast: false,
                    title: 'tracking.step_1_title'.tr(),
                    titleColor: AppTheme.textPrimary,
                    subtitle: 'tracking.step_1_sub'.tr(),
                    lineColor: AppTheme.primaryColor,
                  ),
                  _buildTimelineStep(
                    icon: FontAwesomeIcons.user,
                    iconBgColor: Colors.blue.shade500,
                    isLast: false,
                    title: 'tracking.step_2_title'.tr(),
                    titleColor: Colors.blue.shade600,
                    subtitle: 'tracking.step_2_sub'.tr(),
                    lineColor: Colors.grey.shade300,
                    child: _buildAgentCard(),
                  ),
                  _buildTimelineStep(
                    icon: FontAwesomeIcons.circle,
                    iconBgColor: Colors.grey.shade300,
                    iconColor: Colors.white,
                    isLast: true,
                    title: 'tracking.step_3_title'.tr(),
                    titleColor: Colors.grey.shade500,
                    subtitle: 'tracking.step_3_sub'.tr(),
                    lineColor: Colors.transparent,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Bottom Action Section
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const FaIcon(
                          FontAwesomeIcons.solidCircleQuestion,
                          color: Colors.grey,
                          size: 18,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'tracking.need_help'.tr(),
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const FaIcon(
                          FontAwesomeIcons.chevronRight,
                          color: Colors.grey,
                          size: 14,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2C3E50), // Dark Blue
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const FaIcon(FontAwesomeIcons.phone, size: 16),
                        const SizedBox(width: 8),
                        Text('tracking.call_agent'.tr()),
                      ],
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

  Widget _buildTimelineStep({
    required IconData icon,
    required Color iconBgColor,
    Color iconColor = Colors.white,
    required bool isLast,
    required String title,
    required Color titleColor,
    required String subtitle,
    required Color lineColor,
    Widget? child,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Column for Icon and Line
          Column(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                  border: isLast
                      ? Border.all(color: Colors.grey.shade300, width: 2)
                      : null,
                ),
                child: Center(child: FaIcon(icon, color: iconColor, size: 14)),
              ),
              if (!isLast)
                Expanded(child: Container(width: 2, color: lineColor)),
            ],
          ),
          const SizedBox(width: 16),
          // Column for Text and optional Child
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // Let it size to content
              children: [
                const SizedBox(height: 4), // Alignment tweak
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                ),
                if (child != null) ...[const SizedBox(height: 12), child],
                const SizedBox(height: 24), // Spacing for next step
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgentCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // Avatar + Badge
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade300,
                  image: const DecorationImage(
                    image: NetworkImage(
                      'https://i.pravatar.cc/100?img=11',
                    ), // Mock avatar
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                bottom: -4,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        '4.8',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 2),
                      Icon(Icons.star, size: 8),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          // Agent details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ramesh Kumar',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'tracking.agent_details'.tr(),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
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

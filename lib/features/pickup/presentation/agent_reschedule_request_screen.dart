import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_routes.dart';
import '../../pickup_boy/providers/pickup_boy_provider.dart';
import '../../../core/theme/app_color.dart';

class AgentRescheduleRequestScreen extends ConsumerStatefulWidget {
  final int? pickupId;
  const AgentRescheduleRequestScreen({super.key, this.pickupId});

  @override
  ConsumerState<AgentRescheduleRequestScreen> createState() =>
      _AgentRescheduleRequestScreenState();
}

class _AgentRescheduleRequestScreenState
    extends ConsumerState<AgentRescheduleRequestScreen> {
  String? _selectedReason;
  final TextEditingController _detailsController = TextEditingController();

  final List<Map<String, String>> _reasons = [
    {
      'id': 'vehicle_breakdown',
      'label': 'Vehicle Breakdown',
      'label_hi': 'वाहन खराब',
      'icon': 'car_repair',
    },
    {
      'id': 'heavy_traffic',
      'label': 'Heavy Traffic',
      'label_hi': 'भारी जाम',
      'icon': 'traffic',
    },
    {
      'id': 'personal_issue',
      'label': 'Personal Issue',
      'label_hi': 'व्यक्तिगत आपात',
      'icon': 'emergency_home',
    },
    {
      'id': 'other',
      'label': 'Other Reason',
      'label_hi': 'अन्य कारण',
      'icon': 'more_horiz',
    },
  ];

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isHindi = context.locale.languageCode == 'hi';
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColor.primarySurface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColor.primary.withValues(alpha: 0.20)),
            ),
            child: const Icon(Icons.arrow_back_rounded, color: AppColor.primary, size: 18),
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          isHindi ? 'पुनर्निर्धारण का अनुरोध' : 'Reschedule Pickup',
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.grey),
            onPressed: () => context.push(AppRoutes.notifications),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildActivePickupCard(),
            const SizedBox(height: 32),
            _buildReasonSelectionHeader(isHindi),
            const SizedBox(height: 16),
            _buildReasonGrid(isHindi),
            const SizedBox(height: 32),
            _buildAdditionalDetailsSection(isHindi),
            const SizedBox(height: 40),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildActivePickupCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppTheme.primaryLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.location_on,
              color: AppTheme.primaryColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        '#SC9022',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'ACTIVE PICKUP',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Sector 45, Green Park',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const Text(
                  'Gurugram, Haryana',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReasonSelectionHeader(bool isHindi) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isHindi ? 'कारण चुनें' : 'Select a Reason',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: AppTheme.textPrimary,
          ),
        ),
        Text(
          isHindi ? 'आप क्यों नहीं पहुंच सकते?' : "Why can't you make it?",
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildReasonGrid(bool isHindi) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemCount: _reasons.length,
      itemBuilder: (context, index) {
        final reason = _reasons[index];
        final isSelected = _selectedReason == reason['id'];

        return InkWell(
          onTap: () => setState(() => _selectedReason = reason['id']),
          borderRadius: BorderRadius.circular(30),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primaryColor : Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: isSelected ? AppTheme.primaryColor : Colors.transparent,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primaryColor
                        : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    _getIconData(reason['icon']!),
                    color: isSelected ? Colors.white : AppTheme.primaryColor,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  isHindi ? reason['label_hi']! : reason['label']!,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: isSelected ? Colors.white : AppTheme.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'car_repair':
        return Icons.car_repair;
      case 'traffic':
        return Icons.traffic;
      case 'emergency_home':
        return Icons.emergency;
      case 'more_horiz':
        return Icons.more_horiz;
      default:
        return Icons.help_outline;
    }
  }

  Widget _buildAdditionalDetailsSection(bool isHindi) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isHindi
              ? 'अतिरिक्त विवरण (वैकल्पिक)'
              : 'Additional Details (Optional)',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _detailsController,
          maxLines: 4,
          maxLength: 500,
          decoration: InputDecoration(
            hintText: isHindi
                ? 'संक्षेप में स्थिति बताएं...'
                : 'Briefly explain the situation for the customer...',
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
            fillColor: Colors.white,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: const BorderSide(
                color: AppTheme.primaryColor,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _selectedReason == null ? null : _submitReschedule,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 60),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 8,
            shadowColor: AppTheme.primaryColor.withValues(alpha: 0.3),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Send Request to Customer',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
              SizedBox(width: 8),
              Icon(Icons.send, size: 20),
            ],
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.textPrimary,
            minimumSize: const Size(double.infinity, 60),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            side: BorderSide(color: Colors.grey.shade200, width: 2),
            backgroundColor: Colors.white,
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.support_agent, color: AppTheme.primaryColor),
              SizedBox(width: 8),
              Text(
                'Call Support',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _submitReschedule() async {
    final id = widget.pickupId;
    if (id == null) return;

    final reason = _selectedReason;
    if (reason == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please pick a reason for rescheduling.')),
      );
      return;
    }

    final notes = _detailsController.text.trim();
    // "Other" requires explanatory details so the customer/dispatch can act on it.
    if (reason == 'other' && notes.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please add at least 10 characters of detail when choosing "Other".',
          ),
        ),
      );
      return;
    }
    if (notes.length > 500) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Details cannot exceed 500 characters.'),
        ),
      );
      return;
    }

    final ok = await ref
        .read(pickupBoyProvider.notifier)
        .rescheduleRequest(
          id,
          reasonCode: reason,
          additionalNote: notes.isNotEmpty ? notes : null,
        );

    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reschedule request sent.'),
          backgroundColor: AppTheme.primaryColor,
        ),
      );
      context.pop();
    } else if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to send reschedule request.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

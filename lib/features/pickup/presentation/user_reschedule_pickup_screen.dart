import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/pickup_provider.dart';

class UserReschedulePickupScreen extends ConsumerStatefulWidget {
  final int? pickupId;
  const UserReschedulePickupScreen({super.key, this.pickupId});

  @override
  ConsumerState<UserReschedulePickupScreen> createState() =>
      _UserReschedulePickupScreenState();
}

class _UserReschedulePickupScreenState
    extends ConsumerState<UserReschedulePickupScreen> {
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String? _selectedTimeSlot;
  String? _selectedReason;

  final List<Map<String, dynamic>> _timeSlots = [
    {
      'id': 'morning',
      'label': 'Morning',
      'time': '9 AM - 12 PM',
      'icon': Icons.light_mode,
      'status': 'AVAILABLE',
    },
    {
      'id': 'afternoon',
      'label': 'Afternoon',
      'time': '12 PM - 3 PM',
      'icon': Icons.sunny,
      'status': 'ACTIVE',
    },
    {
      'id': 'evening',
      'label': 'Evening',
      'time': '3 PM - 6 PM',
      'icon': Icons.dark_mode,
      'status': 'FEW SLOTS',
    },
  ];

  final List<Map<String, String>> _reasons = [
    {'code': 'i_am_busy', 'label': 'I am busy'},
    {'code': 'out_of_town', 'label': 'Out of town'},
    {'code': 'need_more_time', 'label': 'Need more time'},
    {'code': 'emergency', 'label': 'Emergency'},
  ];

  List<Map<String, dynamic>> get _dateOptions {
    final now = DateTime.now();
    return List.generate(4, (index) {
      final date = now.add(Duration(days: index));
      final label = switch (index) {
        0 => 'Today',
        1 => 'Tomorrow',
        _ => DateFormat('EEE').format(date).toUpperCase(),
      };

      return {
        'label': label,
        'day': date.day,
        'month': DateFormat('MMM').format(date).toUpperCase(),
        'date': date,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final pickupState = ref.watch(pickupProvider);
    final isHindi = context.locale.languageCode == 'hi';

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.grey),
          onPressed: () => context.pop(),
        ),
        title: Text(
          isHindi ? 'पिकअप पुनर्निर्धारित करें' : 'Reschedule Pickup',
          style: const TextStyle(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.grey),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: 120,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCurrentSlotCard(),
                const SizedBox(height: 32),
                _buildDateSelectionHeader(),
                const SizedBox(height: 16),
                _buildDateList(),
                const SizedBox(height: 32),
                _buildTimeSlotHeader(),
                const SizedBox(height: 16),
                _buildTimeSlotList(),
                const SizedBox(height: 32),
                _buildReasonHeader(),
                const SizedBox(height: 16),
                _buildReasonChips(),
              ],
            ),
          ),
          _buildBottomAction(pickupState.isActionLoading),
        ],
      ),
    );
  }

  Widget _buildCurrentSlotCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.primaryLight.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CURRENT SLOT',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 10,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Oct 24, 4:00 PM',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Too busy for this time? No worries.',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.calendar_month,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelectionHeader() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Select Date',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: AppTheme.textPrimary,
          ),
        ),
        Text(
          'तारीख चुनें',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildDateList() {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _dateOptions.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final option = _dateOptions[index];
          final isSelected = DateUtils.isSameDay(_selectedDate, option['date']);

          return InkWell(
            onTap: () => setState(() => _selectedDate = option['date']),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 90,
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryColor : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppTheme.primaryColor.withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ]
                    : [],
                border: Border.all(color: Colors.transparent, width: 2),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    option['label'].toUpperCase(),
                    style: TextStyle(
                      color: isSelected ? Colors.white70 : Colors.grey,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${option['day']}',
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    option['month'],
                    style: TextStyle(
                      color: isSelected ? Colors.white70 : Colors.grey,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeSlotHeader() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Select Time Slot',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: AppTheme.textPrimary,
          ),
        ),
        Text(
          'समय स्लॉट चुनें',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSlotList() {
    return Column(
      children: _timeSlots.map((slot) {
        final isSelected = _selectedTimeSlot == slot['id'];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => setState(() => _selectedTimeSlot = slot['id']),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryLight : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.primaryColor
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primaryColor.withValues(alpha: 0.2)
                          : Colors.grey.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      slot['icon'],
                      color: isSelected ? AppTheme.primaryColor : Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          slot['label'],
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: isSelected
                                ? AppTheme.primaryDark
                                : AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          slot['time'],
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected
                                ? AppTheme.primaryDark.withValues(alpha: 0.7)
                                : Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    const Icon(Icons.check_circle, color: AppTheme.primaryColor)
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: slot['status'] == 'AVAILABLE'
                            ? AppTheme.primaryLight
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        slot['status'],
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: slot['status'] == 'AVAILABLE'
                              ? AppTheme.primaryColor
                              : Colors.grey,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildReasonHeader() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Reason for Rescheduling',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: AppTheme.textPrimary,
          ),
        ),
        Text(
          'Optional',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppTheme.primaryColor,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildReasonChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _reasons.map((reason) {
        final code = reason['code']!;
        final label = reason['label']!;
        final isSelected = _selectedReason == code;
        return InkWell(
          onTap: () => setState(() => _selectedReason = code),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primaryLight : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? AppTheme.primaryColor.withValues(alpha: 0.2)
                    : Colors.grey.shade100,
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                color: isSelected
                    ? AppTheme.primaryDark
                    : AppTheme.textSecondary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBottomAction(bool isActionLoading) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _selectedTimeSlot == null || isActionLoading
                  ? null
                  : _submitReschedule,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 10,
                shadowColor: AppTheme.primaryColor.withValues(alpha: 0.4),
              ),
              child: isActionLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Confirm New Slot',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward),
                      ],
                    ),
            ),
            const SizedBox(height: 8),
            Text(
              'नया स्लॉट सुनिश्चित करें'.toUpperCase(),
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w900,
                color: Colors.grey,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitReschedule() async {
    final id = widget.pickupId;
    if (id == null || _selectedTimeSlot == null) return;

    final date =
        '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';

    final ok = await ref
        .read(pickupProvider.notifier)
        .reschedulePickup(
          id,
          scheduledDate: date,
          timeSlot: _selectedTimeSlot!,
          reason: _selectedReason,
        );

    if (ok && mounted) {
      ref.invalidate(pickupsProvider);
      ref.invalidate(pickupDetailProvider(id));
      ref.invalidate(trackingProvider(id));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pickup rescheduled successfully.'),
          backgroundColor: AppTheme.primaryColor,
        ),
      );
      context.pop();
    } else if (!ok && mounted) {
      final error =
          ref.read(pickupProvider).error ?? 'Failed to reschedule pickup.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    }
  }
}

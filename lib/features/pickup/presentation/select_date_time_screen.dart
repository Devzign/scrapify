import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../profile/providers/address_provider.dart';
import '../providers/booking_provider.dart';
import '../providers/basket_provider.dart';

class SelectAddressTimeScreen extends ConsumerStatefulWidget {
  const SelectAddressTimeScreen({super.key});

  @override
  ConsumerState<SelectAddressTimeScreen> createState() => _SelectAddressTimeScreenState();
}

class _SelectAddressTimeScreenState extends ConsumerState<SelectAddressTimeScreen> {
  final List<String> _timeSlots = [
    '10:00 AM - 01:00 PM',
    '02:00 PM - 05:00 PM',
  ];

  @override
  void initState() {
    super.initState();
    // Default date if not set
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final booking = ref.read(bookingProvider);
      if (booking.selectedDate == null) {
        ref.read(bookingProvider.notifier).setSelectedDate(DateTime.now().add(const Duration(days: 1)));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final basketItems = ref.watch(basketProvider);
    final totalEstimate = basketItems.fold<double>(0, (sum, item) => sum + item.totalEstimate);
    final booking = ref.watch(bookingProvider);
    final addressesAsync = ref.watch(addressProvider);

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
        title: const Text(
          'Address & Time',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Address Selection ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Select Address',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.push(AppRoutes.addAddress),
                          child: const Text('+ Add New'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    addressesAsync.when(
                      data: (addresses) {
                        if (addresses.isEmpty) {
                          return const Text('No addresses found. Please add one.');
                        }
                        return Column(
                          children: addresses.map((addr) {
                            final isSelected = booking.selectedAddress?.id == addr.id;
                            return GestureDetector(
                              onTap: () => ref.read(bookingProvider.notifier).setSelectedAddress(addr),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: AppTheme.softShadow,
                                  border: Border.all(
                                    color: isSelected ? AppTheme.primaryColor : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isSelected ? AppTheme.primaryColor : const Color(0xFFE2E8F0),
                                          width: isSelected ? 7 : 2,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            addr.title.toUpperCase(),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w800,
                                              color: AppTheme.primaryColor,
                                              fontSize: 11,
                                              letterSpacing: 1.1,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            addr.addressLine1,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                              color: AppTheme.textPrimary,
                                            ),
                                          ),
                                          Text(
                                            '${addr.cityName}, ${addr.pincode}',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: AppTheme.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const FaIcon(FontAwesomeIcons.pen, color: Color(0xFF94A3B8), size: 14),
                                    const SizedBox(width: 16),
                                    const FaIcon(FontAwesomeIcons.trashCan, color: Color(0xFFFCA5A5), size: 14),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (err, stack) => Text('Error loading addresses: $err'),
                    ),

                    const SizedBox(height: 40),

                    // --- Date Selection ---
                    Text(
                      'date_time.select_date'.tr(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 7,
                        itemBuilder: (context, index) {
                          final date = DateTime.now().add(Duration(days: index));
                          final isSelected = booking.selectedDate?.year == date.year &&
                              booking.selectedDate?.month == date.month &&
                              booking.selectedDate?.day == date.day;

                          return GestureDetector(
                            onTap: () => ref.read(bookingProvider.notifier).setSelectedDate(date),
                            child: Container(
                              width: 75,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                gradient: isSelected ? AppTheme.primaryGradient : null,
                                color: isSelected ? null : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: isSelected ? AppTheme.softShadow : null,
                                border: Border.all(
                                  color: isSelected ? Colors.transparent : const Color(0xFFF1F5F9),
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    DateFormat('MMM').format(date).toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: isSelected ? Colors.white.withValues(alpha: 0.9) : AppTheme.textSecondary,
                                      letterSpacing: 1.1,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    DateFormat('dd').format(date),
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w900,
                                      color: isSelected ? Colors.white : AppTheme.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    DateFormat('EEE').format(date).toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: isSelected ? Colors.white.withValues(alpha: 0.7) : AppTheme.textSecondary,
                                      letterSpacing: 1.1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 32),

                    // --- Time Selection ---
                    Text(
                      'date_time.select_time'.tr(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Column(
                      children: _timeSlots.map((time) {
                        final isSelected = booking.selectedTimeSlot == time;
                        return GestureDetector(
                          onTap: () => ref.read(bookingProvider.notifier).setSelectedTimeSlot(time),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: AppTheme.softShadow,
                              border: Border.all(
                                color: isSelected ? AppTheme.primaryColor : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppTheme.primaryColor : const Color(0xFFF8FAFC),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: FaIcon(
                                      FontAwesomeIcons.clock,
                                      color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                                      size: 18,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Text(
                                    time,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: isSelected ? AppTheme.primaryColor : AppTheme.textPrimary,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  const FaIcon(
                                    FontAwesomeIcons.solidCircleCheck,
                                    color: AppTheme.primaryColor,
                                    size: 22,
                                  ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            // --- Bottom Button ---
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 20,
                    offset: const Offset(0, -10),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PAYOUT ESTIMATE',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF94A3B8),
                                letterSpacing: 1.2,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Calculated at Pickup',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'NET PAYOUT',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.primaryColor,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '₹${totalEstimate.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: booking.selectedAddress != null && booking.selectedDate != null && booking.selectedTimeSlot != null
                          ? () => context.push(AppRoutes.reviewBooking)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        minimumSize: const Size(double.infinity, 60),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        disabledBackgroundColor: const Color(0xFFF1F5F9),
                      ),
                      child: const Text(
                        'REVIEW BOOKING',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
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
}

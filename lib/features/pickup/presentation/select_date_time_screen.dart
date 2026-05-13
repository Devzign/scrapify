import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_button.dart';
import '../../profile/providers/address_provider.dart';
import '../domain/repositories/pickup_repository.dart';
import '../providers/booking_provider.dart';
import '../providers/basket_provider.dart';
import '../providers/donation_provider.dart';
import '../../../core/theme/app_color.dart';

class SelectAddressTimeScreen extends ConsumerStatefulWidget {
  const SelectAddressTimeScreen({super.key});

  @override
  ConsumerState<SelectAddressTimeScreen> createState() =>
      _SelectAddressTimeScreenState();
}

class _SelectAddressTimeScreenState
    extends ConsumerState<SelectAddressTimeScreen> {
  final List<String> _fallbackTimeSlots = [
    '10:00 AM - 01:00 PM',
    '02:00 PM - 05:00 PM',
  ];
  List<String> _apiTimeSlots = const [];
  String? _lastSlotsKey;
  bool _isSlotsLoading = false;
  bool _hasSlotApiError = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final booking = ref.read(bookingProvider);
      if (booking.selectedDate == null) {
        ref
            .read(bookingProvider.notifier)
            .setSelectedDate(DateTime.now().add(const Duration(days: 1)));
      }
      _syncSlotsIfNeeded(ref.read(bookingProvider));
    });
  }

  @override
  Widget build(BuildContext context) {
    final basketItems = ref.watch(basketProvider);
    final donationItems = ref.watch(donationProvider);

    final booking = ref.watch(bookingProvider);
    final isDonationFlow = booking.isDonationFlow;
    final addressesAsync = ref.watch(addressProvider);
    _syncSlotsIfNeeded(booking);
    final availableTimeSlots = _getAvailableTimeSlots(booking.selectedDate);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final selectedTimeSlot = booking.selectedTimeSlot;
      if (selectedTimeSlot != null &&
          !availableTimeSlots.contains(selectedTimeSlot) &&
          mounted) {
        ref.read(bookingProvider.notifier).clearSelectedTimeSlot();
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
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
                padding: const EdgeInsets.fromLTRB(24, 14, 24, 12),
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
                            fontSize: 18,
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
                    const SizedBox(height: 10),
                    addressesAsync.when(
                      data: (addresses) {
                        if (addresses.isEmpty) {
                          return const Text(
                            'No addresses found. Please add one.',
                          );
                        }
                        return Column(
                          children: addresses.map((addr) {
                            final isSelected =
                                booking.selectedAddress?.id == addr.id;
                            return GestureDetector(
                              onTap: () => ref
                                  .read(bookingProvider.notifier)
                                  .setSelectedAddress(addr),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: AppTheme.cardBorderRadius,
                                  boxShadow: AppTheme.cardShadow,
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
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isSelected
                                              ? AppTheme.primaryColor
                                              : AppTheme.outline,
                                          width: isSelected ? 7 : 2,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                          const SizedBox(height: 2),
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
                                    const FaIcon(
                                      FontAwesomeIcons.pen,
                                      color: AppTheme.textMuted,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 16),
                                    const FaIcon(
                                      FontAwesomeIcons.trashCan,
                                      color: AppTheme.errorColor,
                                      size: 14,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (err, stack) =>
                          Text('Error loading addresses: $err'),
                    ),

                    const SizedBox(height: 18),

                    // --- Date Selection ---
                    Text(
                      'date_time.select_date'.tr(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 112,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 7,
                        itemBuilder: (context, index) {
                          final date = DateTime.now().add(
                            Duration(days: index),
                          );
                          final isSelected =
                              booking.selectedDate?.year == date.year &&
                              booking.selectedDate?.month == date.month &&
                              booking.selectedDate?.day == date.day;

                          return GestureDetector(
                            onTap: () => ref
                                .read(bookingProvider.notifier)
                                .setSelectedDate(date),
                            child: Container(
                              width: 92,
                              margin: const EdgeInsets.only(right: 10),
                              decoration: BoxDecoration(
                                gradient: isSelected
                                    ? AppTheme.primaryGradient
                                    : null,
                                color: isSelected ? null : Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: isSelected
                                    ? AppTheme.softShadow
                                    : null,
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.transparent
                                      : AppTheme.hairline,
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    DateFormat(
                                      'MMM',
                                    ).format(date).toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: isSelected
                                          ? Colors.white.withValues(alpha: 0.9)
                                          : AppTheme.textSecondary,
                                      letterSpacing: 1.1,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    DateFormat('dd').format(date),
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w900,
                                      color: isSelected
                                          ? Colors.white
                                          : AppTheme.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    DateFormat(
                                      'EEE',
                                    ).format(date).toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: isSelected
                                          ? Colors.white.withValues(alpha: 0.7)
                                          : AppTheme.textSecondary,
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

                    const SizedBox(height: 18),

                    // --- Time Selection ---
                    Text(
                      'date_time.select_time'.tr(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (_isSlotsLoading)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: LinearProgressIndicator(
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    if (_hasSlotApiError)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: Text(
                          'Live slots unavailable, showing fallback slots.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    if (availableTimeSlots.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: AppTheme.cardBorderRadius,
                          border: AppTheme.cardBorder,
                          boxShadow: AppTheme.cardShadow,
                        ),
                        child: const Text(
                          'No pickup slots are available for the selected date.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      )
                    else
                      Column(
                        children: availableTimeSlots.map((time) {
                          final isSelected = booking.selectedTimeSlot == time;
                          return GestureDetector(
                            onTap: () => ref
                                .read(bookingProvider.notifier)
                                .setSelectedTimeSlot(time),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: AppTheme.cardBorderRadius,
                                boxShadow: AppTheme.cardShadow,
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
                                          ? AppTheme.primaryColor
                                          : AppTheme.backgroundCream,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: FaIcon(
                                        FontAwesomeIcons.clock,
                                        color: isSelected
                                            ? Colors.white
                                            : AppTheme.textMuted,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      time,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        color: isSelected
                                            ? AppTheme.primaryColor
                                            : AppTheme.textPrimary,
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    const FaIcon(
                                      FontAwesomeIcons.solidCircleCheck,
                                      color: AppTheme.primaryColor,
                                      size: 20,
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
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isDonationFlow
                                  ? 'DONATION PICKUP'
                                  : 'SCRAP PICKUP',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textMuted,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isDonationFlow
                                  ? 'Schedule donation collection'
                                  : 'Scrap pickup booking',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              isDonationFlow ? 'ITEMS' : 'ITEMS',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.primaryColor,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isDonationFlow
                                  ? '${donationItems.items.fold<int>(0, (sum, item) => sum + item.quantity.round())} item(s)'
                                  : '${basketItems.length} item(s)',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    CustomButton(
                      onPressed:
                          booking.selectedAddress != null &&
                              booking.selectedDate != null &&
                              booking.selectedTimeSlot != null &&
                              availableTimeSlots.contains(
                                booking.selectedTimeSlot,
                              )
                          ? () => context.push(AppRoutes.reviewBooking)
                          : null,
                      text: isDonationFlow
                          ? 'REVIEW DONATION'
                          : 'REVIEW BOOKING',
                      minHeight: 52,
                      borderRadius: 20,
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

  List<String> _getAvailableTimeSlots(DateTime? selectedDate) {
    final slots = _apiTimeSlots.isNotEmpty ? _apiTimeSlots : _fallbackTimeSlots;
    if (selectedDate == null) {
      return slots;
    }

    final now = DateTime.now();
    final isToday =
        selectedDate.year == now.year &&
        selectedDate.month == now.month &&
        selectedDate.day == now.day;

    if (!isToday) {
      return slots;
    }

    return slots.where((slot) {
      final endTimeText = slot.split(' - ').last.trim();
      final slotEnd = _parseSlotTime(selectedDate, endTimeText);
      return slotEnd.isAfter(now);
    }).toList();
  }

  void _syncSlotsIfNeeded(BookingState booking) {
    final date = booking.selectedDate;
    final address = booking.selectedAddress;
    if (date == null || address == null) {
      return;
    }

    final key =
        '${DateFormat('yyyy-MM-dd').format(date)}_${address.cityId}_${address.pincode}';
    if (_lastSlotsKey == key || _isSlotsLoading) {
      return;
    }
    _lastSlotsKey = key;
    Future.microtask(
      () => _loadSlots(
        date: date,
        cityId: address.cityId,
        pincode: address.pincode,
      ),
    );
  }

  Future<void> _loadSlots({
    required DateTime date,
    required int cityId,
    required String pincode,
  }) async {
    if (!mounted) {
      return;
    }
    setState(() {
      _isSlotsLoading = true;
      _hasSlotApiError = false;
    });

    final response = await ref
        .read(pickupRepositoryProvider)
        .getPickupSlots(
          date: DateFormat('yyyy-MM-dd').format(date),
          cityId: cityId,
          pincode: pincode,
        );

    if (!mounted) {
      return;
    }

    setState(() {
      _isSlotsLoading = false;
      if (response.isSuccess) {
        _apiTimeSlots = response.data ?? const [];
        _hasSlotApiError = false;
      } else {
        _apiTimeSlots = const [];
        _hasSlotApiError = true;
      }
    });
  }

  DateTime _parseSlotTime(DateTime date, String timeText) {
    final parts = timeText.split(' ');
    final hourMinute = parts.first.split(':');
    var hour = int.parse(hourMinute.first);
    final minute = int.parse(hourMinute.last);
    final meridian = parts.last.toUpperCase();

    if (meridian == 'PM' && hour != 12) {
      hour += 12;
    } else if (meridian == 'AM' && hour == 12) {
      hour = 0;
    }

    return DateTime(date.year, date.month, date.day, hour, minute);
  }
}

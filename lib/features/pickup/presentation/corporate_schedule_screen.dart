import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_color.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_routes.dart';
import '../../../core/widgets/custom_button.dart';
import '../../profile/providers/address_provider.dart';
import '../providers/corporate_provider.dart';

class CorporateScheduleScreen extends ConsumerStatefulWidget {
  const CorporateScheduleScreen({super.key});

  @override
  ConsumerState<CorporateScheduleScreen> createState() =>
      _CorporateScheduleScreenState();
}

class _CorporateScheduleScreenState
    extends ConsumerState<CorporateScheduleScreen> {
  final List<String> _timeSlots = const [
    '10:00 AM - 01:00 PM',
    '02:00 PM - 05:00 PM',
  ];
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final booking = ref.read(corporateBookingProvider);
      if (booking.selectedDate == null) {
        ref
            .read(corporateBookingProvider.notifier)
            .setDate(DateTime.now().add(const Duration(days: 1)));
      }
    });
  }

  List<String> _availableSlots(DateTime? date) {
    if (date == null) return _timeSlots;
    final now = DateTime.now();
    final isToday =
        date.year == now.year && date.month == now.month && date.day == now.day;
    if (!isToday) return _timeSlots;

    return _timeSlots.where((slot) {
      final end = slot.split(' - ').last.trim();
      final parts = end.split(' ');
      var h = int.parse(parts[0].split(':')[0]);
      final m = int.parse(parts[0].split(':')[1]);
      if (parts[1].toUpperCase() == 'PM' && h != 12) h += 12;
      return DateTime(date.year, date.month, date.day, h, m).isAfter(now);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isHindi = context.locale.languageCode == 'hi';
    final booking = ref.watch(corporateBookingProvider);
    final addressesAsync = ref.watch(addressProvider);
    final slots = _availableSlots(booking.selectedDate);

    return Scaffold(
      backgroundColor: const Color(0xFFF5FAF3),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColor.primarySurface,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColor.primary.withValues(alpha: 0.20),
              ),
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              color: AppColor.primary,
              size: 18,
            ),
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          isHindi ? 'शेड्यूल और पता' : 'Schedule & Address',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildItemsSummary(booking, isHindi),
                  const SizedBox(height: 24),
                  _title(isHindi ? 'पता चुनें' : 'Select Address'),
                  const SizedBox(height: 10),
                  addressesAsync.when(
                    data: (addresses) => addresses.isEmpty
                        ? TextButton.icon(
                            onPressed: () => context.push(AppRoutes.addAddress),
                            icon: const Icon(Icons.add),
                            label: Text(isHindi ? 'पता जोड़ें' : 'Add Address'),
                          )
                        : Column(
                            children: addresses.map((addr) {
                              final selected =
                                  booking.selectedAddress?.id == addr.id;
                              return GestureDetector(
                                onTap: () => ref
                                    .read(corporateBookingProvider.notifier)
                                    .setAddress(addr),
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: selected
                                          ? AppTheme.primaryColor
                                          : AppTheme.outline,
                                      width: selected ? 2 : 1,
                                    ),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        selected
                                            ? Icons.radio_button_checked
                                            : Icons.radio_button_off,
                                        size: 20,
                                        color: selected
                                            ? AppTheme.primaryColor
                                            : AppTheme.textMuted,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          '${addr.title} - ${addr.addressLine1}, ${addr.cityName}, ${addr.pincode}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Text('$e'),
                  ),
                  const SizedBox(height: 20),
                  _title(isHindi ? 'तारीख चुनें' : 'Select Date'),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 90,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 7,
                      itemBuilder: (_, i) {
                        final date = DateTime.now().add(Duration(days: i));
                        final selected =
                            booking.selectedDate?.year == date.year &&
                            booking.selectedDate?.month == date.month &&
                            booking.selectedDate?.day == date.day;
                        return GestureDetector(
                          onTap: () => ref
                              .read(corporateBookingProvider.notifier)
                              .setDate(date),
                          child: Container(
                            width: 72,
                            margin: const EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppTheme.primaryColor
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppTheme.outline),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  DateFormat('dd').format(date),
                                  style: TextStyle(
                                    color: selected
                                        ? Colors.white
                                        : AppTheme.textPrimary,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 20,
                                  ),
                                ),
                                Text(
                                  DateFormat('EEE').format(date),
                                  style: TextStyle(
                                    color: selected
                                        ? Colors.white70
                                        : AppTheme.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  _title(isHindi ? 'समय चुनें' : 'Select Time'),
                  const SizedBox(height: 10),
                  ...slots.map((slot) {
                    final selected = booking.selectedTimeSlot == slot;
                    return GestureDetector(
                      onTap: () => ref
                          .read(corporateBookingProvider.notifier)
                          .setTimeSlot(slot),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected
                                ? AppTheme.primaryColor
                                : AppTheme.outline,
                            width: selected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                slot,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: selected
                                      ? AppTheme.primaryColor
                                      : AppTheme.textPrimary,
                                ),
                              ),
                            ),
                            if (selected)
                              const Icon(
                                Icons.check_circle,
                                color: AppTheme.primaryColor,
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 20),
                  _title(isHindi ? 'फोटो (वैकल्पिक)' : 'Photos (Optional)'),
                  const SizedBox(height: 10),
                  if (booking.images.isEmpty)
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 90,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.outline),
                        ),
                        child: const Icon(Icons.add_a_photo_outlined),
                      ),
                    )
                  else
                    SizedBox(
                      height: 90,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: booking.images.length + 1,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (_, i) {
                          if (i == booking.images.length) {
                            return GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                width: 90,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppTheme.outline),
                                ),
                                child: const Icon(Icons.add),
                              ),
                            );
                          }
                          return Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  File(booking.images[i].path),
                                  width: 90,
                                  height: 90,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                right: 4,
                                top: 4,
                                child: GestureDetector(
                                  onTap: () => ref
                                      .read(corporateBookingProvider.notifier)
                                      .removeImage(i),
                                  child: const CircleAvatar(
                                    radius: 10,
                                    backgroundColor: Colors.red,
                                    child: Icon(
                                      Icons.close,
                                      size: 12,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
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
              child: SizedBox(
                width: double.infinity,
                child: CustomButton(
                  onPressed:
                      booking.items.isNotEmpty &&
                          booking.selectedAddress != null &&
                          booking.selectedDate != null &&
                          booking.selectedTimeSlot != null
                      ? () => context.push(AppRoutes.corporateDetails)
                      : null,
                  text: isHindi ? 'अगला: कंपनी विवरण' : 'NEXT: COMPANY DETAILS',
                  minHeight: 56,
                  borderRadius: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _title(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: AppTheme.textPrimary,
      ),
    );
  }

  Widget _buildItemsSummary(CorporateBookingState booking, bool isHindi) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isHindi
                ? '${booking.items.length} श्रेणी चुनी गई'
                : '${booking.items.length} category selected',
            style: const TextStyle(
              color: Color(0xFF1F7A45),
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          ...booking.items.map(
                (item) => Text(
              '${item.category.name.en} - ${item.quantity % 1 == 0 ? item.quantity.toInt() : item.quantity} ${item.unit}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    final image = await _picker.pickImage(source: source, imageQuality: 80);
    if (image != null && mounted) {
      ref.read(corporateBookingProvider.notifier).addImage(image);
    }
  }
}

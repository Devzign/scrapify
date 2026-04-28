import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

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
  final List<String> _timeSlots = [
    '10:00 AM - 01:00 PM',
    '02:00 PM - 05:00 PM',
  ];
  late final TextEditingController _notesController;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final booking = ref.read(corporateBookingProvider);
      if (booking.selectedDate == null) {
        ref
            .read(corporateBookingProvider.notifier)
            .setDate(DateTime.now().add(const Duration(days: 1)));
      }
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
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
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const FaIcon(
            FontAwesomeIcons.arrowLeft,
            color: AppTheme.textPrimary,
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
                  // Items summary
                  _buildItemsSummary(booking, isHindi),
                  const SizedBox(height: 24),
                  // Address
                  _buildSectionTitle(
                    isHindi ? 'पता चुनें' : 'Select Address',
                    context,
                  ),
                  const SizedBox(height: 12),
                  addressesAsync.when(
                    data: (addresses) => addresses.isEmpty
                        ? TextButton.icon(
                            onPressed: () => context.push(AppRoutes.addAddress),
                            icon: const Icon(Icons.add),
                            label: Text(isHindi ? 'पता जोड़ें' : 'Add Address'),
                          )
                        : Column(
                            children: addresses.map((addr) {
                              final sel =
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
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: AppTheme.softShadow,
                                    border: Border.all(
                                      color: sel
                                          ? AppTheme.primaryColor
                                          : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 22,
                                        height: 22,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: sel
                                                ? AppTheme.primaryColor
                                                : const Color(0xFFE2E8F0),
                                            width: sel ? 7 : 2,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 14),
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
                                            Text(
                                              addr.addressLine1,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                                color: AppTheme.textPrimary,
                                              ),
                                            ),
                                            Text(
                                              '${addr.cityName}, ${addr.pincode}',
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
                                ),
                              );
                            }).toList(),
                          ),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Text('$e'),
                  ),
                  const SizedBox(height: 24),
                  // Date
                  _buildSectionTitle(
                    isHindi ? 'तारीख चुनें' : 'Select Date',
                    context,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 7,
                      itemBuilder: (_, i) {
                        final date = DateTime.now().add(Duration(days: i));
                        final sel =
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
                              gradient: sel ? AppTheme.primaryGradient : null,
                              color: sel ? null : Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: sel ? AppTheme.softShadow : null,
                              border: Border.all(
                                color: sel
                                    ? Colors.transparent
                                    : const Color(0xFFF1F5F9),
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  DateFormat('MMM').format(date).toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: sel
                                        ? Colors.white.withValues(alpha: 0.9)
                                        : AppTheme.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat('dd').format(date),
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: sel
                                        ? Colors.white
                                        : AppTheme.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  DateFormat('EEE').format(date).toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: sel
                                        ? Colors.white.withValues(alpha: 0.7)
                                        : AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Time
                  _buildSectionTitle(
                    isHindi ? 'समय चुनें' : 'Select Time',
                    context,
                  ),
                  const SizedBox(height: 12),
                  ...slots.map((slot) {
                    final sel = booking.selectedTimeSlot == slot;
                    return GestureDetector(
                      onTap: () => ref
                          .read(corporateBookingProvider.notifier)
                          .setTimeSlot(slot),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: AppTheme.softShadow,
                          border: Border.all(
                            color: sel
                                ? AppTheme.primaryColor
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            FaIcon(
                              FontAwesomeIcons.clock,
                              color: sel
                                  ? AppTheme.primaryColor
                                  : const Color(0xFF94A3B8),
                              size: 18,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                slot,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: sel
                                      ? AppTheme.primaryColor
                                      : AppTheme.textPrimary,
                                ),
                              ),
                            ),
                            if (sel)
                              const FaIcon(
                                FontAwesomeIcons.solidCircleCheck,
                                color: AppTheme.primaryColor,
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 24),
                  // Notes
                  _buildSectionTitle(
                    isHindi ? 'नोट्स (वैकल्पिक)' : 'Notes (Optional)',
                    context,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppTheme.softShadow,
                    ),
                    child: TextField(
                      controller: _notesController,
                      maxLines: 3,
                      onChanged: (v) => ref
                          .read(corporateBookingProvider.notifier)
                          .setNotes(v),
                      decoration: InputDecoration(
                        hintText: isHindi
                            ? 'जैसे: 200 कंप्यूटर, टूटे फर्नीचर, आदि'
                            : 'e.g. 200 computers, broken furniture, etc.',
                        hintStyle: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 13,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        fillColor: Colors.white,
                        filled: true,
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Photos
                  _buildSectionTitle(
                    isHindi
                        ? 'फ़ोटो अपलोड करें (वैकल्पिक)'
                        : 'Upload Photos (Optional)',
                    context,
                  ),
                  const SizedBox(height: 12),
                  _buildPhotoSection(booking, isHindi),
                ],
              ),
            ),
          ),
          _buildBottomBar(context, booking, isHindi),
        ],
      ),
    );
  }

  Widget _buildItemsSummary(CorporateBookingState booking, bool isHindi) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const FaIcon(
                FontAwesomeIcons.layerGroup,
                color: AppTheme.primaryColor,
                size: 14,
              ),
              const SizedBox(width: 8),
              Text(
                isHindi
                    ? '${booking.items.length} श्रेणी चुनी गई'
                    : '${booking.items.length} categor${booking.items.length == 1 ? 'y' : 'ies'} selected',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: booking.items.map((item) {
              final name = isHindi
                  ? item.category.name.hi
                  : item.category.name.en;
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$name — ${item.quantity % 1 == 0 ? item.quantity.toInt() : item.quantity} ${item.unit}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoSection(CorporateBookingState booking, bool isHindi) {
    return Column(
      children: [
        if (booking.images.isNotEmpty)
          SizedBox(
            height: 90,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: booking.images.length + 1,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) {
                if (i == booking.images.length) {
                  return _AddPhotoTile(onTap: _pickImage, isHindi: isHindi);
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
                        errorBuilder: (_, __, ___) => Container(
                          width: 90,
                          height: 90,
                          color: const Color(0xFFF0FDF4),
                          child: const Icon(
                            Icons.image,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => ref
                            .read(corporateBookingProvider.notifier)
                            .removeImage(i),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          )
        else
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: double.infinity,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
                boxShadow: AppTheme.softShadow,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const FaIcon(
                    FontAwesomeIcons.camera,
                    color: Color(0xFF94A3B8),
                    size: 24,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isHindi ? 'फ़ोटो जोड़ें' : 'Add Photos',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF94A3B8),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
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

  Widget _buildSectionTitle(String title, BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppTheme.textPrimary,
      ),
    );
  }

  Widget _buildBottomBar(
    BuildContext context,
    CorporateBookingState booking,
    bool isHindi,
  ) {
    final canProceed = booking.isReadyToSubmit;
    return Container(
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
        child: CustomButton(
          onPressed: canProceed
              ? () => context.push(AppRoutes.corporateReview)
              : null,
          text: isHindi ? 'समीक्षा करें' : 'REVIEW BOOKING',
          minHeight: 60,
          borderRadius: 20,
        ),
      ),
    );
  }
}

class _AddPhotoTile extends StatelessWidget {
  final VoidCallback onTap;
  final bool isHindi;
  const _AddPhotoTile({required this.onTap, required this.isHindi});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(FontAwesomeIcons.plus, color: Color(0xFF94A3B8), size: 18),
          ],
        ),
      ),
    );
  }
}

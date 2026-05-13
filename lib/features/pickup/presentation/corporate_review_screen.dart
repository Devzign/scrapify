import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_routes.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_section_header.dart';
import '../../../core/widgets/custom_button.dart';
import '../../auth/providers/auth_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../domain/repositories/pickup_repository.dart';
import '../providers/corporate_provider.dart';
import '../../../core/theme/app_color.dart';

class CorporateReviewScreen extends ConsumerWidget {
  const CorporateReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isHindi = context.locale.languageCode == 'hi';
    final booking = ref.watch(corporateBookingProvider);

    return AppScaffold(
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
              border: Border.all(color: AppColor.primary.withValues(alpha: 0.20)),
            ),
            child: const Icon(Icons.arrow_back_rounded, color: AppColor.primary, size: 18),
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          isHindi ? 'बुकिंग समीक्षा' : 'Review Booking',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSectionHeader(
              title: isHindi ? 'बुकिंग समीक्षा' : 'Review Booking',
              subtitle: isHindi
                  ? 'सबमिट करने से पहले अपनी जानकारी जांच लें'
                  : 'Check your details before submitting',
            ),
            const SizedBox(height: 16),
            _row(
              isHindi ? 'चुनी गई श्रेणियां' : 'Selected categories',
              '${booking.items.length}',
            ),
            const SizedBox(height: 10),
            _row(isHindi ? 'फोटो' : 'Photos', '${booking.images.length}'),
            const SizedBox(height: 10),
            _row(
              isHindi ? 'समय स्लॉट' : 'Time slot',
              booking.selectedTimeSlot ?? '-',
            ),
            const SizedBox(height: 10),
            _row(
              isHindi ? 'तारीख' : 'Date',
              booking.selectedDate != null
                  ? DateFormat('dd MMM yyyy').format(booking.selectedDate!)
                  : '-',
            ),
            const SizedBox(height: 10),
            _row(
              isHindi ? 'पता' : 'Address',
              booking.selectedAddress != null
                  ? '${booking.selectedAddress!.title} - ${booking.selectedAddress!.addressLine1}'
                  : '-',
            ),
            const Spacer(),
            CustomButton(
              onPressed: booking.isReadyToSubmit
                  ? () => _submit(context, ref)
                  : null,
              text: isHindi ? 'अनुरोध भेजें' : 'SUBMIT REQUEST',
              minHeight: 56,
              borderRadius: 16,
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => context.pop(),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(isHindi ? 'वापस जाएं' : 'GO BACK'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit(BuildContext context, WidgetRef ref) async {
    final booking = ref.read(corporateBookingProvider);
    final user = ref.read(authProvider);
    final settings = ref.read(settingsProvider).settings;
    final corporateCategories =
        (settings['corporate_categories'] as List<dynamic>?)
            ?.map((e) => e.toString().trim())
            .where((e) => e.isNotEmpty)
            .toList() ??
        const [
          'E-Waste',
          'General Waste',
          'Hazardous Waste (Industrial Waste)',
        ];
    final meetingTypes =
        (settings['corporate_meeting_types'] as List<dynamic>?)
            ?.map((e) => e.toString().trim().toLowerCase())
            .where((e) => e.isNotEmpty)
            .toList() ??
        const ['in_person', 'google_meet', 'skype'];
    if (!booking.isReadyToSubmit) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all required fields')),
      );
      return;
    }

    final selectedDate = booking.selectedDate!;
    final scheduledAt = _buildScheduledAt(
      selectedDate,
      booking.selectedTimeSlot!,
    );

    final items = booking.items
        .map(
          (item) => {
            'category_id': item.category.id,
            // Keep both for backend compatibility across donation/scrap-style parsers.
            'quantity': item.unit == 'pcs' ? item.quantity.round() : 1,
            'weight': item.unit == 'kg' ? item.quantity : null,
            'attributes': <Map<String, dynamic>>[],
          },
        )
        .toList();

    final data = <String, dynamic>{
      'request_type': 'corporate',
      'address':
          '${booking.selectedAddress!.addressLine1}, ${booking.selectedAddress!.pincode}',
      'address_id': booking.selectedAddress!.id,
      'city_id': booking.selectedAddress!.cityId,
      'pincode': booking.selectedAddress!.pincode,
      'latitude': booking.selectedAddress!.latitude ?? 28.6139,
      'longitude': booking.selectedAddress!.longitude ?? 77.2090,
      'scheduled_at': scheduledAt,
      'notes': booking.notes?.isNotEmpty == true
          ? booking.notes!
          : 'Corporate quotation request from mobile app',
      'company_name': user?.name ?? 'N/A',
      'contact_name': user?.name ?? 'N/A',
      'contact_mobile': user?.phone ?? '0000000000',
      'contact_email': user?.email ?? 'na@example.com',
      'corporate_category': corporateCategories.first,
      'meeting_type': meetingTypes.first,
      'items': items,
      'images': booking.images,
    };

    final response = await ref
        .read(pickupRepositoryProvider)
        .createCorporateBooking(data);
    if (!context.mounted) return;

    if (response.isSuccess && response.data != null) {
      ref.read(corporateBookingProvider.notifier).reset();
      context.go(
        AppRoutes.successConfirmation,
        extra: {'pickup': response.data, 'isDonation': false},
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(response.errorMessage ?? 'Failed to submit request'),
      ),
    );
  }

  String _buildScheduledAt(DateTime date, String timeSlot) {
    final startTime = timeSlot.split(' - ').first.trim();
    final timeParts = startTime.split(' ');
    final hourMinute = timeParts.first.split(':');
    var hour = int.parse(hourMinute.first);
    final minute = int.parse(hourMinute.last);
    final meridian = timeParts.length > 1 ? timeParts.last.toUpperCase() : 'AM';

    if (meridian == 'PM' && hour != 12) {
      hour += 12;
    } else if (meridian == 'AM' && hour == 12) {
      hour = 0;
    }

    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    final hourText = hour.toString().padLeft(2, '0');
    final minuteText = minute.toString().padLeft(2, '0');
    return '${date.year}-$month-$day $hourText:$minuteText:00';
  }

  Widget _row(String label, String value) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              maxLines: 3,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

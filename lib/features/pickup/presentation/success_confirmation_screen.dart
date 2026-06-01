import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_routes.dart';
import '../domain/models/pickup_request_model.dart';
import '../providers/pickup_provider.dart';
import '../../../core/theme/app_color.dart';

class SuccessConfirmationScreen extends ConsumerWidget {
  final PickupRequestModel? pickup;
  final bool isDonation;

  const SuccessConfirmationScreen({
    super.key,
    this.pickup,
    this.isDonation = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isHindi = context.locale.languageCode == 'hi';

    final bookingId = pickup?.pickupCode.isNotEmpty == true
        ? pickup!.pickupCode
        : 'SCR-2026-001';

    final scheduledDate = pickup?.scheduledAt.toLocal() ?? DateTime.now();
    final dateStr = isHindi
        ? "कल, सुबह ${DateFormat('hh:mm').format(scheduledDate)} बजे"
        : DateFormat('EEEE, hh:mm a').format(scheduledDate);

    final itemCount = pickup?.items.length ?? 0;
    final firstCategory = pickup?.items.isNotEmpty == true
        ? (pickup?.items.first.name ?? (isHindi ? 'स्क्रैप' : 'Scrap'))
        : (isHindi ? 'आइटम' : 'Items');
    final itemsSummary = isHindi
        ? "$itemCount आइटम ($firstCategory)"
        : "$itemCount Items ($firstCategory)";

    final address =
        pickup?.address ??
        "Flat 402, Green Valley Apartments, HSR Layout, Bangalore";

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundLight,
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
          onPressed: () {
            ref.invalidate(pickupsProvider);
            context.go(AppRoutes.customerDashboard);
          },
        ),
        title: Text(
          isHindi
              ? (isDonation ? 'दान पुष्टि' : 'बुकिंग पुष्टि')
              : (isDonation ? 'Donation Confirmed' : 'Booking Confirmed'),
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: AppTheme.textPrimary),
            onPressed: () => context.push(AppRoutes.helpSupport),
          ),
        ],
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 12),
            _buildHeroSection(),
            const SizedBox(height: 16),
            Text(
              isHindi
                  ? (isDonation ? 'दान सफल!' : 'बुकिंग सफल!')
                  : (isDonation
                        ? 'Donation Successful!'
                        : 'Booking Successful!'),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 10),
            _buildBookingIdChip(bookingId, isHindi),
            const SizedBox(height: 20),
            _buildIllustrationCard(),
            const SizedBox(height: 16),
            _buildPickupSummary(
              dateStr: dateStr,
              itemsSummary: itemsSummary,
              address: address,
              isHindi: isHindi,
            ),
            if (pickup != null && pickup!.images.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildItemImagesRow(pickup!.images, isHindi),
            ],
            const SizedBox(height: 20),
            _buildActionButtons(context, ref, isHindi),
            const SizedBox(height: 20),
            _buildBottomBanner(isHindi, address),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
            ),
          ),
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primaryColor.withValues(alpha: 0.2),
            ),
          ),
          Container(
            width: 75,
            height: 75,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primaryColor,
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 40),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingIdChip(String bookingId, bool isHindi) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.outline.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isHindi ? 'बुकिंग ID: ' : 'BOOKING ID: ',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppTheme.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          Text(
            bookingId,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIllustrationCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      height: 148,
      decoration: BoxDecoration(
        color: AppTheme.primarySurface,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            bottom: -10,
            child: Icon(
              Icons.recycling,
              size: 100,
              color: AppTheme.primaryColor.withValues(alpha: 0.15),
            ),
          ),
          Center(
            child: Image.asset(
              'assets/images/trash_bin_success.png',
              height: 120,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const FaIcon(
                  FontAwesomeIcons.trashCan,
                  size: 80,
                  color: AppTheme.primaryColor,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPickupSummary({
    required String dateStr,
    required String itemsSummary,
    required String address,
    required bool isHindi,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppTheme.hairline),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.receipt_long_outlined,
                color: AppTheme.primaryColor,
                size: 22,
              ),
              const SizedBox(width: 12),
              Text(
                isHindi ? 'पिकअप सारांश' : 'Pickup Summary',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSummaryItem(
            icon: Icons.calendar_today_outlined,
            label: isHindi ? 'समय-सारणी' : 'SCHEDULED FOR',
            value: dateStr,
          ),
          const SizedBox(height: 14),
          _buildSummaryItem(
            icon: Icons.inventory_2_outlined,
            label: isHindi ? 'आइटम' : 'ITEMS',
            value: itemsSummary,
          ),
          const SizedBox(height: 14),
          _buildSummaryItem(
            icon: Icons.location_on_outlined,
            label: isHindi ? 'पिकअप पता' : 'PICKUP ADDRESS',
            value: address,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String label,
    required String value,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.backgroundCream,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppTheme.textSecondary, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textMuted,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textPrimary,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildItemImagesRow(List<PickupImageModel> images, bool isHindi) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppTheme.hairline),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.photo_library_outlined,
                color: AppTheme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                isHindi
                    ? 'अपलोड की गई तस्वीरें (${images.length})'
                    : 'Uploaded Photos (${images.length})',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 72,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final img = images[index];
                final url = img.url ?? '';
                return ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: url.isNotEmpty
                      ? Image.network(
                          url,
                          width: 72,
                          height: 72,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 72,
                            height: 72,
                            color: AppTheme.primarySurface,
                            child: const Icon(
                              Icons.image_not_supported,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        )
                      : Container(
                          width: 72,
                          height: 72,
                          color: AppTheme.primarySurface,
                          child: const Icon(
                            Icons.image,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    WidgetRef ref,
    bool isHindi,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          ElevatedButton(
            onPressed: pickup == null
                ? null
                : () => context.go(
                    '${AppRoutes.pickupTracking}/${pickup!.id}',
                    extra: pickup,
                  ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 64),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
            ),
            child: Text(
              isHindi
                  ? (isDonation ? 'दान ट्रैक करें' : 'पिकअप ट्रैक करें')
                  : (isDonation ? 'TRACK DONATION' : 'TRACK PICKUP'),
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              ref.invalidate(pickupsProvider);
              context.go(AppRoutes.customerDashboard);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.hairline,
              foregroundColor: AppTheme.textPrimary,
              minimumSize: const Size(double.infinity, 64),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
            ),
            child: Text(
              isHindi ? 'होम पर जाएं' : 'Back to Home',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBanner(bool isHindi, String address) {
    return Container(
      width: double.infinity,
      height: 140,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppTheme.hintPeach,
        borderRadius: BorderRadius.circular(24),
        image: const DecorationImage(
          image: AssetImage('assets/images/map_banner.png'),
          fit: BoxFit.cover,
          opacity: 0.7,
        ),
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: AppTheme.cardBorderRadius,
            border: AppTheme.cardBorder,
            boxShadow: AppTheme.cardShadow,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                isHindi ? 'ड्राइवर जल्द पहुंचेगा' : 'Driver will arrive soon',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

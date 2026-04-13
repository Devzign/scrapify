import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_endpoints.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_routes.dart';
import '../../../core/widgets/custom_button.dart';
import '../providers/basket_provider.dart';
import '../providers/booking_provider.dart';
import '../providers/donation_provider.dart';
import 'widgets/add_payment_popup.dart';
import 'widgets/payment_selection_sheet.dart';

class ReviewBookingScreen extends ConsumerWidget {
  const ReviewBookingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final basketItems = ref.watch(basketProvider);
    final donationState = ref.watch(donationProvider);
    final booking = ref.watch(bookingProvider);
    final isDonationFlow = booking.isDonationFlow;
    final items = isDonationFlow ? donationState.items : basketItems;
    final totalEstimate = ref.read(basketProvider.notifier).totalEstimate;

    final lat = booking.selectedAddress?.latitude ?? 28.6139;
    final lng = booking.selectedAddress?.longitude ?? 77.2090;
    final mapUrl =
        'https://maps.googleapis.com/maps/api/staticmap?center=$lat,$lng&zoom=15&size=600x300&markers=color:red%7C$lat,$lng&key=${ApiEndpoints.googleMapsApiKey}';

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
          isDonationFlow ? 'Review Donation' : 'Review Booking',
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      image: DecorationImage(
                        image: NetworkImage(mapUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: AppTheme.softShadow,
                        ),
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (booking.images.isNotEmpty) ...[
                          const Text(
                            'SELECTED PHOTOS',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primaryColor,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 100,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: booking.images.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(width: 12),
                              itemBuilder: (context, index) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    File(booking.images[index].path),
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                        Text(
                          isDonationFlow
                              ? 'DONATION SUMMARY'
                              : 'BOOKING SUMMARY',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primaryColor,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildDetailCard(
                          icon: FontAwesomeIcons.locationDot,
                          title: booking.selectedAddress?.title ?? 'No Address',
                          subtitle: booking.selectedAddress?.addressLine1 ?? '',
                        ),
                        const SizedBox(height: 12),
                        _buildDetailCard(
                          icon: FontAwesomeIcons.calendarDay,
                          title: booking.selectedDate != null
                              ? DateFormat(
                                  'EEEE, dd MMM',
                                ).format(booking.selectedDate!)
                              : 'No Date',
                          subtitle: booking.selectedTimeSlot ?? 'No Time Slot',
                        ),
                        if (!isDonationFlow) ...[
                          const SizedBox(height: 32),
                          const Text(
                            'PAYOUT METHOD',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primaryColor,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildPayoutSelectionCard(context, ref, booking),
                        ],
                        const SizedBox(height: 32),
                        Text(
                          isDonationFlow ? 'DONATION ITEMS' : 'SCRAP ITEMS',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primaryColor,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...items.map(_buildItemSummaryRow),
                        const SizedBox(height: 32),
                        _buildTrustBadge(
                          isDonationFlow
                              ? 'Donation pickup scheduled with verified collection partner'
                              : 'Verified Scrap Value',
                        ),
                        _buildTrustBadge(
                          isDonationFlow
                              ? 'No payout or payment details required'
                              : 'Standard Pickup (Verified Partner)',
                        ),
                        _buildTrustBadge(
                          isDonationFlow
                              ? '100% eco-friendly reuse and redistribution'
                              : '100% Eco-Friendly Processing',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(24),
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
                  if (isDonationFlow)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'DONATION FLOW',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF94A3B8),
                                letterSpacing: 1.2,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Donation pickup',
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
                              'ITEM COUNT',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.primaryColor,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${items.fold<int>(0, (sum, item) => sum + item.quantity.round())}',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PAYOUT SCALE',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF94A3B8),
                                letterSpacing: 1.2,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Estimated Payout',
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
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  const SizedBox(height: 20),
                  CustomButton(
                    onPressed: _canSubmit(booking, isDonationFlow)
                        ? () => _submit(context, ref, isDonationFlow)
                        : null,
                    isLoading: booking.isSubmitting,
                    text: isDonationFlow
                        ? 'CONFIRM DONATION'
                        : 'CONFIRM BOOKING',
                    minHeight: 60,
                    borderRadius: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _canSubmit(BookingState booking, bool isDonationFlow) {
    if (isDonationFlow) {
      return true;
    }
    return booking.payoutMethod != null &&
        booking.selectedPaymentDetail != null;
  }

  Future<void> _submit(
    BuildContext context,
    WidgetRef ref,
    bool isDonationFlow,
  ) async {
    final createdPickup = isDonationFlow
        ? await ref
              .read(bookingProvider.notifier)
              .submitDonation(ref.read(donationProvider).items)
        : await ref
              .read(bookingProvider.notifier)
              .submitBooking(ref.read(basketProvider));

    if (!context.mounted) {
      return;
    }

    if (createdPickup != null) {
      if (isDonationFlow) {
        ref.read(donationProvider.notifier).clear();
      } else {
        ref.read(basketProvider.notifier).clearBasket();
      }
      ref.read(bookingProvider.notifier).reset();
      context.go(
        AppRoutes.successConfirmation,
        extra: {'pickup': createdPickup, 'isDonation': isDonationFlow},
      );
      return;
    }

    final updatedBooking = ref.read(bookingProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          updatedBooking.error ??
              (isDonationFlow ? 'Donation failed' : 'Booking failed'),
        ),
        backgroundColor: Colors.red,
      ),
    );
  }

  Widget _buildPayoutSelectionCard(
    BuildContext context,
    WidgetRef ref,
    BookingState booking,
  ) {
    String title = 'Select Payout Method';
    String subtitle = 'How would you like to get paid?';
    IconData icon = FontAwesomeIcons.wallet;

    if (booking.payoutMethod != null) {
      if (booking.payoutMethod == 'upi') {
        title = 'UPI Transfer';
        subtitle = booking.selectedPaymentDetail?.upiId ?? 'Select UPI ID';
        icon = FontAwesomeIcons.mobileScreenButton;
      } else if (booking.payoutMethod == 'bank') {
        title = 'Bank Transfer';
        subtitle = booking.selectedPaymentDetail?.bankName != null
            ? '${booking.selectedPaymentDetail!.bankName} (${booking.selectedPaymentDetail!.maskedAccountNumber})'
            : 'Select Bank Account';
        icon = FontAwesomeIcons.buildingColumns;
      }
    }

    return InkWell(
      onTap: () => _showPayoutTypeSheet(context, ref),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: AppTheme.softShadow,
          border: Border.all(
            color:
                (booking.payoutMethod != null &&
                    booking.selectedPaymentDetail != null)
                ? AppTheme.primaryColor
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: FaIcon(icon, color: AppTheme.primaryColor, size: 18),
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
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: booking.selectedPaymentDetail == null
                          ? Colors.orange.shade700
                          : AppTheme.textSecondary,
                      fontWeight: booking.selectedPaymentDetail == null
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFFCBD5E1)),
          ],
        ),
      ),
    );
  }

  void _showPayoutTypeSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose Payout Method',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            _buildPayoutTypeTile(
              context,
              ref,
              title: 'UPI Transfer',
              icon: FontAwesomeIcons.mobileScreenButton,
              onTap: () {
                ref.read(bookingProvider.notifier).setPayoutMethod('upi');
                Navigator.pop(context);
                _showPaymentDetailSheet(context, ref, 'upi');
              },
            ),
            const SizedBox(height: 12),
            _buildPayoutTypeTile(
              context,
              ref,
              title: 'Bank Transfer',
              icon: FontAwesomeIcons.buildingColumns,
              onTap: () {
                ref.read(bookingProvider.notifier).setPayoutMethod('bank');
                Navigator.pop(context);
                _showPaymentDetailSheet(context, ref, 'bank');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPayoutTypeTile(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            FaIcon(icon, color: AppTheme.primaryColor, size: 18),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: AppTheme.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  void _showPaymentDetailSheet(
    BuildContext context,
    WidgetRef ref,
    String type,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PaymentSelectionSheet(
        payoutType: type,
        selectedMethod: ref.watch(bookingProvider).selectedPaymentDetail,
        onSelect: (method) {
          ref.read(bookingProvider.notifier).setSelectedPaymentDetail(method);
        },
        onAddNew: () async {
          await showDialog<bool>(
            context: context,
            builder: (context) => AddPaymentPopup(
              type: type,
              onAdded: (method) {
                ref
                    .read(bookingProvider.notifier)
                    .setSelectedPaymentDetail(method);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildItemSummaryRow(dynamic item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: FaIcon(
              _getIconForCategory(item.category.slug),
              size: 14,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.category.name.en,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  item.pricePerUnit > 0
                      ? '${item.quantity.toInt()} ${item.unit} @ ₹${item.pricePerUnit.toStringAsFixed(0)}'
                      : '${item.quantity.toInt()} ${item.unit}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (item.pricePerUnit > 0)
            Text(
              '₹${item.totalEstimate.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.softShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: FaIcon(icon, color: AppTheme.primaryColor, size: 18),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primaryColor,
                    letterSpacing: 1.1,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrustBadge(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF22C55E), size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForCategory(String slug) {
    switch (slug.toLowerCase()) {
      case 'clothes':
        return FontAwesomeIcons.shirt;
      case 'furniture':
        return FontAwesomeIcons.couch;
      case 'metal':
      case 'iron':
      case 'steel':
      case 'iron-steel':
        return FontAwesomeIcons.screwdriverWrench;
      case 'plastic':
        return FontAwesomeIcons.recycle;
      case 'e-waste':
      case 'electronics':
        return FontAwesomeIcons.microchip;
      case 'appliances':
        return FontAwesomeIcons.kitchenSet;
      case 'paper':
        return FontAwesomeIcons.boxArchive;
      default:
        return FontAwesomeIcons.box;
    }
  }
}

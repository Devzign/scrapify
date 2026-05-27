import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_endpoints.dart';
import '../../../core/theme/app_color.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_routes.dart';
import '../../../core/utils/user_role_helper.dart';
import '../../../core/widgets/custom_button.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/basket_provider.dart';
import '../providers/booking_provider.dart';
import '../providers/donation_provider.dart';
import '../../referral/providers/referral_provider.dart';
import '../../settings/providers/settings_provider.dart';
import 'widgets/add_payment_popup.dart';
import 'widgets/payment_selection_sheet.dart';

class ReviewBookingScreen extends ConsumerStatefulWidget {
  const ReviewBookingScreen({super.key});

  @override
  ConsumerState<ReviewBookingScreen> createState() =>
      _ReviewBookingScreenState();
}

class _ReviewBookingScreenState extends ConsumerState<ReviewBookingScreen> {
  late final TextEditingController _couponController;
  String? _couponError;

  @override
  void initState() {
    super.initState();
    _couponController = TextEditingController();
  }

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final basketItems = ref.watch(basketProvider);
    final donationState = ref.watch(donationProvider);
    final booking = ref.watch(bookingProvider);
    final isDonationFlow = booking.isDonationFlow;
    final items = isDonationFlow ? donationState.items : basketItems;
    final totalEstimate = ref.read(basketProvider.notifier).totalEstimate;
    final appSettings = ref.watch(settingsProvider);
    final minimumFreePickupAmount = _toDouble(
      appSettings.settings['minimum_free_pickup_amount'],
      1500,
    );
    final lowValueShippingCharge = _toDouble(
      appSettings.settings['low_value_shipping_charge'],
      100,
    );
    final shippingCharge = isDonationFlow
        ? 0.0
        : (totalEstimate < minimumFreePickupAmount
              ? lowValueShippingCharge
              : 0);
    final estimatedAfterShipping = isDonationFlow
        ? totalEstimate
        : (totalEstimate - shippingCharge).clamp(0, double.infinity).toDouble();
    final authUser = ref.watch(authProvider);
    final isCustomer = isCustomerUser(authUser);
    final isCouponValidating = ref.watch(referralProvider).isCouponValidating;
    final appliedCoupon = booking.appliedCoupon;

    final mapUrl = _buildStaticMapUrl(booking);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
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
                    color: AppTheme.outline,
                    child: _buildMapPreview(mapUrl),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
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
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 92,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: booking.images.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(width: 8),
                              itemBuilder: (context, index) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    File(booking.images[index].path),
                                    width: 92,
                                    height: 92,
                                    fit: BoxFit.cover,
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 18),
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
                        const SizedBox(height: 10),
                        _buildDetailCard(
                          icon: FontAwesomeIcons.locationDot,
                          title: booking.selectedAddress?.title ?? 'No Address',
                          subtitle: booking.selectedAddress?.addressLine1 ?? '',
                        ),
                        const SizedBox(height: 8),
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
                          const SizedBox(height: 18),
                          const Text(
                            'PAYOUT METHOD',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primaryColor,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 10),
                          _buildPayoutSelectionCard(context, ref, booking),
                          if (isCustomer) ...[
                            const SizedBox(height: 16),
                            _buildCouponSection(
                              ref: ref,
                              booking: booking,
                              isValidating: isCouponValidating,
                              totalEstimate: estimatedAfterShipping,
                              appliedCouponCode: booking.appliedCouponCode,
                              appliedCouponExtraValue:
                                  appliedCoupon?.finalExtraValue,
                            ),
                          ],
                        ],
                        const SizedBox(height: 18),
                        Text(
                          isDonationFlow ? 'DONATION ITEMS' : 'SCRAP ITEMS',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primaryColor,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              context.push(
                                isDonationFlow
                                    ? AppRoutes.donationCategorySelection
                                    : AppRoutes.categorySelection,
                              );
                            },
                            icon: const Icon(Icons.add, size: 18),
                            label: Text(
                              isDonationFlow
                                  ? 'Add More Donation Items'
                                  : 'Add More Product',
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.primaryColor,
                              side: const BorderSide(
                                color: AppTheme.primaryColor,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...items.map(_buildItemSummaryRow),
                        const SizedBox(height: 16),
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
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
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
                                color: AppTheme.textMuted,
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
                                color: AppTheme.textMuted,
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
                        Builder(
                          builder: (_) {
                            final extra = appliedCoupon?.finalExtraValue ?? 0;
                            final hasCoupon = extra > 0;
                            final net = estimatedAfterShipping + extra;
                            return Column(
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
                                if (hasCoupon)
                                  Text(
                                    '₹${estimatedAfterShipping.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppTheme.textMuted,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                if (!isDonationFlow && shippingCharge > 0)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Text(
                                      '- ₹${shippingCharge.toStringAsFixed(0)} shipping',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.redAccent,
                                      ),
                                    ),
                                  ),
                                if (hasCoupon)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Text(
                                      '+ ₹${extra.toStringAsFixed(0)} coupon',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.successColor,
                                      ),
                                    ),
                                  ),
                                Text(
                                  '₹${net.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  const SizedBox(height: 12),
                  CustomButton(
                    onPressed: _canSubmit(booking, isDonationFlow)
                        ? () => _submit(context, ref, isDonationFlow)
                        : null,
                    isLoading: booking.isSubmitting,
                    text: isDonationFlow
                        ? 'CONFIRM DONATION'
                        : 'CONFIRM BOOKING',
                    minHeight: 54,
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
    final errorMessage =
        updatedBooking.error ??
        (isDonationFlow ? 'Donation failed' : 'Booking failed');
    final isMinimumValueError =
        !isDonationFlow &&
        (errorMessage.toLowerCase().contains('minimum order value') ||
            errorMessage.contains('pickup.minimum_value_not_met'));

    if (isMinimumValueError) {
      _showMinimumValuePopup(context, errorMessage);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
    );
  }

  Future<void> _showMinimumValuePopup(
    BuildContext context,
    String message,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Minimum Value Required',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          content: Text(
            message,
            style: const TextStyle(color: AppTheme.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Close'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.push(AppRoutes.categorySelection);
              },
              icon: const Icon(Icons.add),
              label: const Text('Add More Product'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCouponSection({
    required WidgetRef ref,
    required BookingState booking,
    required bool isValidating,
    required double totalEstimate,
    required String? appliedCouponCode,
    required double? appliedCouponExtraValue,
  }) {
    final hasAppliedCoupon =
        appliedCouponCode != null && appliedCouponCode.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'COUPON',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: AppTheme.primaryColor,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: TextField(
                  controller: _couponController,
                  textCapitalization: TextCapitalization.characters,
                  maxLength: 20,
                  onChanged: (_) {
                    if (_couponError != null) {
                      setState(() => _couponError = null);
                    }
                  },
                  decoration: InputDecoration(
                    hintText: 'Enter coupon code',
                    counterText: '',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: AppTheme.primaryColor,
                        width: 1.5,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: Colors.red,
                        width: 1.5,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: Colors.red,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 104,
              height: 48,
              child: ElevatedButton(
                onPressed: isValidating
                    ? null
                    : () => _applyCoupon(
                        ref: ref,
                        booking: booking,
                        totalEstimate: totalEstimate,
                      ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  minimumSize: const Size(104, 48),
                  maximumSize: const Size(104, 48),
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: isValidating
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Apply',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ],
        ),
        if (_couponError != null) ...[
          const SizedBox(height: 6),
          Text(
            _couponError!,
            style: const TextStyle(color: Colors.red, fontSize: 12),
          ),
        ],
        if (hasAppliedCoupon) ...[
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryLight.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.primaryColor),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Applied: $appliedCouponCode (+₹${(appliedCouponExtraValue ?? 0).toStringAsFixed(0)} extra value)',
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    ref.read(bookingProvider.notifier).clearAppliedCoupon();
                    _couponController.clear();
                    setState(() => _couponError = null);
                  },
                  child: const Text(
                    'Remove',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  double _toDouble(dynamic value, double fallback) {
    if (value == null) return fallback;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? fallback;
  }

  Future<void> _applyCoupon({
    required WidgetRef ref,
    required BookingState booking,
    required double totalEstimate,
  }) async {
    final rawCode = _couponController.text.trim().toUpperCase();
    _couponController.value = _couponController.value.copyWith(
      text: rawCode,
      selection: TextSelection.collapsed(offset: rawCode.length),
    );

    if (rawCode.isEmpty) {
      setState(() => _couponError = 'Please enter coupon code');
      return;
    }
    if (rawCode.length > 20) {
      setState(
        () => _couponError = 'Coupon code must be at most 20 characters',
      );
      return;
    }
    if (!RegExp(r'^[A-Z0-9]+$').hasMatch(rawCode)) {
      setState(() => _couponError = 'Use only letters and numbers');
      return;
    }

    setState(() => _couponError = null);
    final result = await ref
        .read(referralProvider.notifier)
        .validateCoupon(couponCode: rawCode, bookingAmount: totalEstimate);

    if (!mounted) return;

    if (result == null) {
      final msg =
          ref.read(referralProvider).error ?? 'Failed to validate coupon';
      setState(() => _couponError = msg);
      return;
    }

    ref.read(bookingProvider.notifier).setAppliedCoupon(result);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Coupon applied: +₹${result.finalExtraValue.toStringAsFixed(0)}',
        ),
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppTheme.cardBorderRadius,
          boxShadow: AppTheme.cardShadow,
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
                color: AppTheme.backgroundCream,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: FaIcon(icon, color: AppTheme.primaryColor, size: 18),
              ),
            ),
            const SizedBox(width: 12),
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
            const Icon(Icons.chevron_right_rounded, color: AppTheme.outline),
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
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppTheme.cardBorderRadius,
          border: AppTheme.cardBorder,
          boxShadow: AppTheme.cardShadow,
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
          border: Border.all(color: AppTheme.outline),
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
              color: AppTheme.hairline,
              borderRadius: BorderRadius.circular(10),
            ),
            child: FaIcon(
              _getIconForCategory(item.category.slug),
              size: 14,
              color: AppTheme.textSecondary,
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

  String? _buildStaticMapUrl(BookingState booking) {
    final lat = booking.selectedAddress?.latitude;
    final lng = booking.selectedAddress?.longitude;
    if (lat != null && lng != null) {
      return 'https://maps.googleapis.com/maps/api/staticmap?center=$lat,$lng&zoom=15&size=600x300&markers=color:red%7C$lat,$lng&key=${ApiEndpoints.googleMapsApiKey}';
    }

    final addrParts = <String>[
      if (booking.selectedAddress?.addressLine1.trim().isNotEmpty == true)
        booking.selectedAddress!.addressLine1.trim(),
      if (booking.selectedAddress?.cityName?.trim().isNotEmpty == true)
        booking.selectedAddress!.cityName!.trim(),
      if (booking.selectedAddress?.pincode.trim().isNotEmpty == true)
        booking.selectedAddress!.pincode.trim(),
    ];
    if (addrParts.isEmpty || ApiEndpoints.googleMapsApiKey.trim().isEmpty) {
      return null;
    }

    final encoded = Uri.encodeComponent(addrParts.join(', '));
    return 'https://maps.googleapis.com/maps/api/staticmap?center=$encoded&zoom=15&size=600x300&markers=color:red%7C$encoded&key=${ApiEndpoints.googleMapsApiKey}';
  }

  Widget _buildMapPreview(String? mapUrl) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (mapUrl != null)
          Image.network(
            mapUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildMapFallback();
            },
          )
        else
          _buildMapFallback(),
        Center(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: AppTheme.cardBorder,
              boxShadow: AppTheme.cardShadow,
            ),
            child: const Icon(Icons.location_on, color: Colors.red, size: 28),
          ),
        ),
      ],
    );
  }

  Widget _buildMapFallback() {
    return Container(
      color: AppTheme.outline,
      alignment: Alignment.center,
      child: const Text(
        'Map preview unavailable',
        style: TextStyle(
          color: AppTheme.textSecondary,
          fontWeight: FontWeight.w600,
        ),
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
        borderRadius: AppTheme.cardBorderRadius,
        border: AppTheme.cardBorder,
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: AppTheme.backgroundCream,
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
          const Icon(
            Icons.check_circle,
            color: AppTheme.successColor,
            size: 18,
          ),
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

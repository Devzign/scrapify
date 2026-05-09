import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/booking_provider.dart';
import '../providers/basket_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_routes.dart';
import '../../../core/widgets/custom_button.dart';

class PayoutMethodScreen extends ConsumerWidget {
  const PayoutMethodScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booking = ref.watch(bookingProvider);
    final basketItems = ref.watch(basketProvider);

    final payoutMethods = [
      {
        'id': 'upi',
        'title': 'UPI Transfer',
        'icon': FontAwesomeIcons.mobileScreenButton,
      },
      {
        'id': 'bank',
        'title': 'Bank Transfer',
        'icon': FontAwesomeIcons.buildingColumns,
      },
    ];

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
          'Payout Method',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PAYMENT PREFERENCE',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppTheme.primaryColor,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Choose how you\'d like to get paid',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: AppTheme.textPrimary,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 24),

            // Trust Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primarySurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.successColor),
              ),
              child: const Row(
                children: [
                  FaIcon(
                    FontAwesomeIcons.shieldHalved,
                    color: AppTheme.successColor,
                    size: 18,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Safe & Secure Payments guaranteed by Scrapify.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.successColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            ...payoutMethods.map((method) {
              final isSelected = booking.payoutMethod == method['id'];
              return GestureDetector(
                onTap: () => ref
                    .read(bookingProvider.notifier)
                    .setPayoutMethod(method['id'] as String),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(20),
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
                      const SizedBox(width: 20),
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppTheme.backgroundCream,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: FaIcon(
                            method['icon'] as IconData,
                            color: isSelected
                                ? AppTheme.primaryColor
                                : AppTheme.textMuted,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              method['title'] as String,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            Text(
                              'Within 2-4 hours of pickup',
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
            }),
            const Spacer(),
            CustomButton(
              onPressed: booking.payoutMethod != null
                  ? () async {
                      final createdPickup = await ref
                          .read(bookingProvider.notifier)
                          .submitBooking(basketItems);
                      if (!context.mounted) {
                        return;
                      }
                      if (createdPickup != null) {
                        ref.read(basketProvider.notifier).clearBasket();
                        ref.read(bookingProvider.notifier).reset();
                        context.go(
                          AppRoutes.successConfirmation,
                          extra: {
                            'pickup': createdPickup,
                            'isDonation': false,
                          },
                        );
                        return;
                      }
                      final updatedBooking = ref.read(bookingProvider);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            updatedBooking.error ?? 'Booking failed',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  : null,
              isLoading: booking.isSubmitting,
              text: 'CONFIRM BOOKING',
              minHeight: 60,
              borderRadius: 20,
            ),
          ],
        ),
      ),
    );
  }
}

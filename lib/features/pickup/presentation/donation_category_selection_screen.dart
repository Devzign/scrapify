import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_routes.dart';
import '../../../core/widgets/custom_button.dart';
import '../providers/booking_provider.dart';
import '../providers/donation_provider.dart';

class DonationCategorySelectionScreen extends ConsumerWidget {
  const DonationCategorySelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedItems = ref.watch(donationProvider);
    final donationNotifier = ref.read(donationProvider.notifier);
    final isHindi = context.locale.languageCode == 'hi';

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
          context.locale.languageCode == 'hi'
              ? 'वस्तुएं दान करें'
              : 'Donate Items',
          style: const TextStyle(
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
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: AppTheme.cardBorderRadius,
                        border: Border.all(color: const Color(0xFFE8EAF2)),
                        boxShadow: AppTheme.cardShadow,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFEEF1),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.favorite_rounded,
                                  color: Color(0xFFF43F5E),
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  isHindi
                                      ? 'समुदाय को वापस दें'
                                      : 'Give Back to Community',
                                  style: const TextStyle(
                                    color: Color(0xFFF43F5E),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 22),
                          Text(
                            isHindi ? 'वस्तुएं दान करें' : 'Donate Items',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            isHindi
                                ? 'पुराने कपड़े और फर्नीचर दान करें।'
                                : 'Support social causes with reusable goods',
                            style: const TextStyle(
                              fontSize: 17,
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            isHindi
                                ? 'आज आप क्या दान करना चाहते हैं? हम अभी कपड़े और पुराने फर्नीचर स्वीकार कर रहे हैं।'
                                : 'Choose what you want to donate today. We are currently accepting clothes and old furniture.',
                            style: const TextStyle(
                              fontSize: 15,
                              height: 1.5,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      isHindi
                          ? 'आज क्या दान करना है?'
                          : 'What would you like to donate today?',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isHindi
                          ? 'डोनेशन पिकअप शुरू करने के लिए एक या दोनों श्रेणियां चुनें।'
                          : 'Choose one or both categories to start your donation pickup.',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 18),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: DonationNotifier.donationCategories.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            childAspectRatio: 0.9,
                          ),
                      itemBuilder: (context, index) {
                        final category =
                            DonationNotifier.donationCategories[index];
                        final quantity = donationNotifier.quantityFor(
                          category.id,
                        );

                        return _DonationCategoryCard(
                          title: category.getName(context),
                          subtitle: category.name.hi,
                          quantity: quantity,
                          icon: _iconForSlug(category.slug),
                          onIncrement: () => donationNotifier.setQuantity(
                            category,
                            quantity + 1,
                          ),
                          onDecrement: quantity > 0
                              ? () => donationNotifier.setQuantity(
                                  category,
                                  quantity - 1,
                                )
                              : null,
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF6EE),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFD7ECDD)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD9EEDC),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Text(
                              'ECO-PREMIUM',
                              style: TextStyle(
                                color: AppTheme.primaryDark,
                                fontWeight: FontWeight.w800,
                                fontSize: 10,
                                letterSpacing: 1.1,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            isHindi
                                ? 'हर वस्तु मायने रखती है।'
                                : 'Every piece counts.',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primaryDark,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isHindi
                                ? 'आपके दान से सर्कुलर इकोनॉमी बनती है और लैंडफिल वेस्ट कम होता है।'
                                : 'Your donations help build a circular economy and reduce landfill waste.',
                            style: const TextStyle(
                              height: 1.5,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
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
                child: CustomButton(
                  onPressed: selectedItems.items.isEmpty
                      ? null
                      : () {
                          ref
                              .read(bookingProvider.notifier)
                              .startDonationFlow(
                                donationCategory: ref
                                    .read(donationProvider.notifier)
                                    .donationCategoryKey,
                              );
                          context.push(AppRoutes.donationItems);
                        },
                  text: isHindi
                      ? 'पिकअप विवरण जारी रखें'
                      : 'CONTINUE TO PICKUP DETAILS',
                  minHeight: 60,
                  borderRadius: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static IconData _iconForSlug(String slug) {
    switch (slug) {
      case 'clothes':
        return Icons.checkroom_rounded;
      case 'furniture':
        return Icons.chair_rounded;
      default:
        return Icons.volunteer_activism_rounded;
    }
  }
}

class _DonationCategoryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final int quantity;
  final IconData icon;
  final VoidCallback onIncrement;
  final VoidCallback? onDecrement;

  const _DonationCategoryCard({
    required this.title,
    required this.subtitle,
    required this.quantity,
    required this.icon,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = quantity > 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.cardBorderRadius,
        boxShadow: AppTheme.cardShadow,
        border: Border.all(
          color: isSelected ? AppTheme.primaryColor : const Color(0xFFE9EEF5),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF6EE),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppTheme.primaryColor),
          ),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _QuantityButton(icon: Icons.remove, onTap: onDecrement),
              Expanded(
                child: Center(
                  child: Text(
                    '$quantity',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isSelected
                          ? AppTheme.primaryColor
                          : AppTheme.textSecondary,
                    ),
                  ),
                ),
              ),
              _QuantityButton(icon: Icons.add, onTap: onIncrement),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _QuantityButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: onTap == null
              ? const Color(0xFFF1F5F9)
              : const Color(0xFFEAF6EE),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          size: 18,
          color: onTap == null
              ? const Color(0xFFB6C1CD)
              : AppTheme.primaryColor,
        ),
      ),
    );
  }
}

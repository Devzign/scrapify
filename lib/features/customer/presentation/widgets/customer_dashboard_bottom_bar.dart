import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_routes.dart';
import '../../../../core/widgets/app_card.dart';

class CustomerDashboardBottomBar extends StatelessWidget {
  final int currentIndex;
  final int basketItemCount;
  final bool scrapPickupEnabled;
  final bool isServiceable;
  final String serviceMessage;
  final VoidCallback onDashboardTap;
  final VoidCallback onOrdersTap;
  final VoidCallback onMoneyTap;

  const CustomerDashboardBottomBar({
    super.key,
    required this.currentIndex,
    required this.basketItemCount,
    required this.scrapPickupEnabled,
    required this.isServiceable,
    required this.serviceMessage,
    required this.onDashboardTap,
    required this.onOrdersTap,
    required this.onMoneyTap,
  });

  @override
  Widget build(BuildContext context) {
    final showBasketButton = currentIndex == 0 && basketItemCount > 0;
    final isHindi = context.locale.languageCode == 'hi';

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showBasketButton) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: _BasketFloatingButton(itemCount: basketItemCount),
              ),
              const SizedBox(height: 12),
            ],
            SizedBox(
              height: 104,
              child: Stack(
                alignment: Alignment.topCenter,
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    top: 12,
                    child: AppCard(
                      padding: const EdgeInsets.fromLTRB(22, 18, 22, 14),
                      color: AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: AppTheme.e2,
                      child: Row(
                        children: [
                          Expanded(
                            child: _NavItem(
                              icon: FontAwesomeIcons.house,
                              label: isHindi ? 'डैशबोर्ड' : 'Dashboard',
                              isSelected: currentIndex == 0,
                              onTap: onDashboardTap,
                            ),
                          ),
                          const SizedBox(width: 96),
                          Expanded(
                            child: _NavItem(
                              icon: FontAwesomeIcons.clipboardList,
                              label: isHindi ? 'ऑर्डर्स' : 'Orders',
                              isSelected: currentIndex == 1,
                              onTap: onOrdersTap,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  _MoneyFloatingButton(onTap: onMoneyTap),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(
            icon,
            size: 18,
            color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected
                  ? AppTheme.primaryColor
                  : AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _MoneyFloatingButton extends StatelessWidget {
  final VoidCallback onTap;

  const _MoneyFloatingButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 84,
      height: 84,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.circular(42),
        border: Border.all(color: Colors.white, width: 8),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: FloatingActionButton(
        heroTag: 'dashboard_money_fab',
        onPressed: onTap,
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.currency_rupee_rounded,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(height: 6),
            Text(
              context.locale.languageCode == 'hi' ? 'मनी' : 'Money',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BasketFloatingButton extends StatelessWidget {
  final int itemCount;

  const _BasketFloatingButton({required this.itemCount});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: AppCard(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.e2,
        child: FloatingActionButton.extended(
        heroTag: 'dashboard_basket_fab',
        onPressed: () => context.push(AppRoutes.basket),
        backgroundColor: Colors.white,
        elevation: 0,
        icon: Stack(
          clipBehavior: Clip.none,
          children: [
            const FaIcon(
              FontAwesomeIcons.basketShopping,
              color: AppTheme.primaryColor,
              size: 18,
            ),
            Positioned(
              right: -10,
              top: -8,
              child: Container(
                constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$itemCount',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
        label: Text(
          context.locale.languageCode == 'hi' ? 'बास्केट' : 'Basket',
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}

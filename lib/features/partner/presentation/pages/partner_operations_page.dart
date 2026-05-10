import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_routes.dart';

class PartnerOperationsPage extends StatelessWidget {
  const PartnerOperationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(title: const Text('Partner Operations')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          _tile(
            context,
            icon: Icons.people_alt_rounded,
            title: 'Customer Management',
            subtitle: 'List, add, edit and view customer details',
            onTap: () => context.push(AppRoutes.partnerCustomers),
          ),
          _tile(
            context,
            icon: Icons.add_box_rounded,
            title: 'Create Pickup Request',
            subtitle: 'Create request with item details, images and slot',
            onTap: () => context.push(AppRoutes.partnerCreatePickup),
          ),
          _tile(
            context,
            icon: Icons.route_rounded,
            title: 'Pickup Tracking',
            subtitle: 'Track timeline, status, assign and reassign pickup boys',
            onTap: () => context.push(AppRoutes.partnerPickupTracking),
          ),
          _tile(
            context,
            icon: Icons.local_shipping_rounded,
            title: 'Deliver to Warehouse',
            subtitle: 'Submit final weight/amount with delivery proofs',
            onTap: () => context.push(AppRoutes.partnerHandover),
          ),
          _tile(
            context,
            icon: Icons.currency_rupee_rounded,
            title: 'Settlement & Payout',
            subtitle: 'Track payable amount and payout status',
            onTap: () => context.push(AppRoutes.partnerSettlements),
          ),
        ],
      ),
    );
  }

  Widget _tile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppTheme.cardBorderRadius,
        child: Container(
          padding: const EdgeInsets.all(14),
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
                  color: AppTheme.primarySurface,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppTheme.primaryColor, size: 22),
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
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}


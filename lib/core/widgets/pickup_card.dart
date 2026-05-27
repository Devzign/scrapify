import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_color.dart';
import '../theme/app_theme.dart';
import 'status_badge.dart';

/// Modern pickup request card component.
/// Displays customer info, address, items, time, status, and action buttons.
class PickupCard extends StatelessWidget {
  final String? id;
  final String customerName;
  final String address;
  final String? phone;
  final String? items;
  final String? scheduledTime;
  final String status;
  final VoidCallback? onTap;
  final List<PickupCardAction>? actions;
  final bool isCompact;

  const PickupCard({
    Key? key,
    this.id,
    required this.customerName,
    required this.address,
    this.phone,
    this.items,
    this.scheduledTime,
    required this.status,
    this.onTap,
    this.actions,
    this.isCompact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppTheme.space16,
          vertical: AppTheme.space8,
        ),
        decoration: BoxDecoration(
          color: AppColor.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(color: AppColor.cardBorder, width: 1),
          boxShadow: AppTheme.e1,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Name + Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customerName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColor.textPrimary,
                            letterSpacing: -0.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ID: ${id ?? "N/A"}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColor.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  StatusBadge(status: status),
                ],
              ),
              const SizedBox(height: AppTheme.space12),

              // Address
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    FontAwesomeIcons.mapPin,
                    color: AppColor.textSecondary,
                    size: 12,
                  ),
                  const SizedBox(width: AppTheme.space8),
                  Expanded(
                    child: Text(
                      address,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColor.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.space12),

              // Meta info: Items + Time
              if (!isCompact) ...[
                Row(
                  children: [
                    if (items != null)
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              FontAwesomeIcons.box,
                              color: AppColor.textMuted,
                              size: 12,
                            ),
                            const SizedBox(width: AppTheme.space6),
                            Expanded(
                              child: Text(
                                items!,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: AppColor.textMuted,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (scheduledTime != null)
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              FontAwesomeIcons.clock,
                              color: AppColor.textMuted,
                              size: 12,
                            ),
                            const SizedBox(width: AppTheme.space6),
                            Text(
                              scheduledTime!,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: AppColor.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppTheme.space12),
              ],

              // Action buttons
              if (actions != null && actions!.isNotEmpty)
                Wrap(
                  spacing: AppTheme.space8,
                  runSpacing: AppTheme.space8,
                  children: actions!.map((action) {
                    return _ActionButton(action: action);
                  }).toList(),
                ),

              // Phone (if available and compact)
              if (phone != null && isCompact)
                Padding(
                  padding: const EdgeInsets.only(top: AppTheme.space12),
                  child: Row(
                    children: [
                      Icon(
                        FontAwesomeIcons.phone,
                        color: AppColor.primary,
                        size: 12,
                      ),
                      const SizedBox(width: AppTheme.space8),
                      Text(
                        phone!,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColor.primary,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class PickupCardAction {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary;

  PickupCardAction({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isPrimary = false,
  });
}

class _ActionButton extends StatelessWidget {
  final PickupCardAction action;

  const _ActionButton({required this.action});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: action.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.space10,
          vertical: AppTheme.space6,
        ),
        decoration: BoxDecoration(
          color: action.isPrimary
              ? AppColor.primary
              : AppColor.primaryLight,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              action.icon,
              color: action.isPrimary
                  ? AppColor.textOnPrimary
                  : AppColor.primary,
              size: 12,
            ),
            const SizedBox(width: 4),
            Text(
              action.label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: action.isPrimary
                    ? AppColor.textOnPrimary
                    : AppColor.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

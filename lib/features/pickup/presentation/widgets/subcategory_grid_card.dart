import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_theme.dart';

/// Sub-category / catalog card. Visual treatment lifted from scrapi5.com:
///   - White card body, rounded 20, soft shadow.
///   - Warm-cream image panel on top (full width, square-ish).
///   - Navy title below.
///   - Bottom row: green ₹ price on the left, outlined SELL pill on the right.
///
/// Either pass a [price] / [unit] for the website-style "₹ X / SELL" footer,
/// or omit them and the card falls back to the older "subtitle" line.
class SubCategoryGridCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData iconData;
  final VoidCallback onTap;
  final String? imageUrl;

  /// Optional. When provided, the footer row shows `₹ price` + a SELL pill,
  /// matching the website cards. If null, the older [subtitle] line shows.
  final double? price;

  /// Optional unit suffix, e.g. "/kg", "/pc", "/L". Rendered after [price].
  final String? unit;

  /// Optional override for the SELL pill label.
  final String? actionLabel;

  const SubCategoryGridCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.iconData,
    required this.onTap,
    this.imageUrl,
    this.price,
    this.unit,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    final hasPrice = price != null;
    return Material(
      color: AppColor.surface,
      borderRadius: BorderRadius.circular(AppTheme.radiusXl),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColor.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusXl),
            border: Border.all(color: AppColor.cardBorder, width: 1.2),
            boxShadow: AppTheme.e1,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Square-ish image panel so the photography matches the website.
              final imageSide = constraints.maxWidth - 2; // tight margin
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image panel — warm cream backdrop.
                  Container(
                    height: imageSide * 0.78,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: _imagePanelColor(title),
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _buildLeadingVisual(),
                  ),
                  const SizedBox(height: 10),
                  // Title.
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: AppColor.deepNavy,
                        height: 1.2,
                        letterSpacing: -0.1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Footer: ₹ price + SELL pill (website style) OR fall back
                  // to a subtitle line if no price is provided.
                  if (hasPrice)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              _formatPrice(price!, unit),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColor.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          _SellPill(label: actionLabel ?? 'SELL'),
                        ],
                      ),
                    )
                  else if (subtitle.trim().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColor.primary,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  String _formatPrice(double value, String? unit) {
    // Strip trailing `.0` for whole-rupee prices.
    final formatted = value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(2);
    final suffix = (unit == null || unit.isEmpty) ? '' : unit;
    return '₹ $formatted$suffix';
  }

  Widget _buildLeadingVisual() {
    final normalizedImageUrl = imageUrl?.trim() ?? '';
    if (normalizedImageUrl.isEmpty) {
      return Center(child: FaIcon(iconData, size: 30, color: AppColor.primary));
    }

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Image.network(
        normalizedImageUrl,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) {
          return Center(
            child: FaIcon(iconData, size: 30, color: AppColor.primary),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }
          return const Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
      ),
    );
  }

  Color _imagePanelColor(String seed) {
    const palette = <Color>[
      Color(0xFFF1EFE7),
      Color(0xFFEAF4EC),
      Color(0xFFF2F3F7),
      Color(0xFFEEF5F2),
      Color(0xFFF6F1E8),
      Color(0xFFE9F0EB),
      Color(0xFFF0F2EC),
    ];
    final index = seed.trim().isEmpty
        ? 0
        : seed.codeUnits.fold<int>(0, (a, b) => a + b) % palette.length;
    return palette[index];
  }
}

/// Solid "SELL" pill — green fill, white text, bold — matches the website.
class _SellPill extends StatelessWidget {
  final String label;
  const _SellPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: AppColor.primary,
        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: Colors.white,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

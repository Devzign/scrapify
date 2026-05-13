import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_theme.dart';

/// Parent-category row used on the category-selection screen.
///
/// Visual treatment mirrors the scrapi5.com website: a white card with a
/// warm-cream thumbnail panel on the left, bold navy title + grey subtitle,
/// sub-count pill, and a green chevron circle on the right.
class CategoryListTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData iconData;
  final VoidCallback onTap;
  final String? imageUrl;

  /// Optional trailing badge text (e.g. "12 sub-categories").
  final String? badgeLabel;

  const CategoryListTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.iconData,
    required this.onTap,
    this.imageUrl,
    this.badgeLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColor.surface,
      borderRadius: BorderRadius.circular(AppTheme.radiusXl),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColor.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusXl),
            border: Border.all(color: AppColor.cardBorder, width: 1.2),
            boxShadow: AppTheme.e1,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Warm-cream image panel ─────────────────────────────────
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: _imagePanelColor(title),
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                ),
                clipBehavior: Clip.antiAlias,
                child: _buildLeadingVisual(),
              ),
              const SizedBox(width: 16),

              // ── Text content ───────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppColor.deepNavy,
                        height: 1.2,
                        letterSpacing: -0.2,
                      ),
                    ),
                    if (subtitle.trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColor.textSecondary,
                          height: 1.3,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    if ((badgeLabel ?? '').trim().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _CountPill(label: badgeLabel!),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // ── Green chevron button ───────────────────────────────────
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColor.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeadingVisual() {
    final url = imageUrl?.trim() ?? '';
    if (url.isEmpty) {
      return Center(child: FaIcon(iconData, size: 28, color: AppColor.primary));
    }
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Image.network(
        url,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) {
          return Center(
            child: FaIcon(iconData, size: 28, color: AppColor.primary),
          );
        },
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const Center(
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
      ),
    );
  }

  Color _imagePanelColor(String seed) {
    const palette = <Color>[
      Color(0xFFEAF4EC),
      Color(0xFFF1EFE7),
      Color(0xFFF2F3F7),
      Color(0xFFEEF5F2),
      Color(0xFFF6F1E8),
      Color(0xFFE9F0EB),
    ];
    final index = seed.trim().isEmpty
        ? 0
        : seed.codeUnits.fold<int>(0, (a, b) => a + b) % palette.length;
    return palette[index];
  }
}

/// "N SUB-CATEGORIES" pill — matches the website's green-tinted badge exactly.
class _CountPill extends StatelessWidget {
  final String label;
  const _CountPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColor.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
        border: Border.all(
          color: AppColor.primary.withValues(alpha: 0.22),
          width: 1,
        ),
      ),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: AppColor.primaryDark,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

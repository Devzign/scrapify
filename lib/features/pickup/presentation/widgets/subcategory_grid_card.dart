import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_theme.dart';

class SubCategoryGridCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData iconData;
  final VoidCallback onTap;
  final String? imageUrl;

  const SubCategoryGridCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.iconData,
    required this.onTap,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColor.surface,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColor.surface,
            borderRadius: AppTheme.cardBorderRadius,
            border: Border.all(color: AppColor.primaryLight.withValues(alpha: 0.38)),
            boxShadow: AppTheme.e1,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final imageHeight = (constraints.maxHeight * 0.50).clamp(
                62.0,
                92.0,
              );
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: imageHeight,
                    decoration: BoxDecoration(
                      color: AppColor.primarySurface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColor.hairline),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _buildLeadingVisual(),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                      height: 1.2,
                    ),
                  ),
                  if (subtitle.trim().isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 1),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLeadingVisual() {
    final normalizedImageUrl = imageUrl?.trim() ?? '';
    if (normalizedImageUrl.isEmpty) {
      return Center(
        child: FaIcon(iconData, size: 24, color: AppTheme.primaryColor),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(6),
      child: Image.network(
        normalizedImageUrl,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) {
          return Center(
            child: FaIcon(iconData, size: 24, color: AppTheme.primaryColor),
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
}

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppTheme.cardBorderRadius,
            border: AppTheme.cardBorder,
            boxShadow: AppTheme.cardShadow,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final imageHeight = (constraints.maxHeight * 0.44).clamp(
                48.0,
                68.0,
              );
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: imageHeight,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7FAF8),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _buildLeadingVisual(),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                            height: 1.1,
                          ),
                        ),
                        if (subtitle.trim().isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ],
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

  Widget _buildLeadingVisual() {
    final normalizedImageUrl = imageUrl?.trim() ?? '';
    if (normalizedImageUrl.isEmpty) {
      return Center(
        child: FaIcon(iconData, size: 24, color: AppTheme.primaryColor),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(10),
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

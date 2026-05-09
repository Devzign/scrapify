import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class FaqHeaderDelegate extends SliverPersistentHeaderDelegate {
  final bool isDark;
  final Color primaryColor;
  final TextEditingController searchController;
  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;
  final VoidCallback onPop;

  FaqHeaderDelegate({
    required this.isDark,
    required this.primaryColor,
    required this.searchController,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.onPop,
  });

  @override
  double get minExtent => 180;

  @override
  double get maxExtent => 180;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.textPrimary.withValues(alpha: 0.95)
            : Colors.white.withValues(alpha: 0.95),
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppTheme.textPrimary : AppTheme.hairline,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      size: 28,
                      color: isDark ? Colors.white : AppTheme.textPrimary,
                    ),
                    onPressed: onPop,
                  ),
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 40),
                        child: Text(
                          'faq.title'.tr(),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white
                                : AppTheme.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppTheme.textPrimary
                      : AppTheme.hairline,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: searchController,
                  style: TextStyle(
                    color: isDark ? Colors.white : AppTheme.textPrimary,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppTheme.textSecondary,
                    ),
                    hintText: 'faq.search_hint'.tr(),
                    hintStyle: const TextStyle(color: AppTheme.textSecondary),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 12),
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final isSelected = selectedCategory == category;

                    return GestureDetector(
                      onTap: () => onCategorySelected(category),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? primaryColor
                              : (isDark
                                    ? AppTheme.textPrimary
                                    : Colors.white),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? Colors.transparent
                                : (isDark
                                      ? const Color(0xFF334155)
                                      : AppTheme.outline),
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: primaryColor.withValues(alpha: 0.2),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          category,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : (isDark
                                      ? AppTheme.outline
                                      : AppTheme.textPrimary),
                            fontSize: 14,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant FaqHeaderDelegate oldDelegate) {
    return isDark != oldDelegate.isDark ||
        primaryColor != oldDelegate.primaryColor ||
        selectedCategory != oldDelegate.selectedCategory;
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_color.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/utils/app_routes.dart';
import '../../../core/widgets/loading_skeletons.dart';
import '../domain/models/category.dart';
import '../domain/models/pickup_catalog_item.dart';
import '../providers/category_provider.dart';
import 'widgets/category_support_banner.dart';
import 'widgets/subcategory_grid_card.dart';

class SubCategorySelectionScreen extends ConsumerStatefulWidget {
  final int parentId;

  const SubCategorySelectionScreen({super.key, required this.parentId});

  @override
  ConsumerState<SubCategorySelectionScreen> createState() =>
      _SubCategorySelectionScreenState();
}

class _SubCategorySelectionScreenState
    extends ConsumerState<SubCategorySelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoryDetailAsync = ref.watch(
      categoryDetailProvider(widget.parentId),
    );
    final subCategoriesAsync = ref.watch(
      subCategoriesProvider(widget.parentId),
    );

    return AppScaffold(
      backgroundColor: AppColor.backgroundLight,
      body: categoryDetailAsync.when(
        data: (parentCategory) {
          return subCategoriesAsync.when(
            data: (subCategories) {
              final filtered =
                  _filterCategories(subCategories, _searchQuery);

              return CustomScrollView(
                slivers: [
                  // ── Website-style category hero header ─────────────────────
                  SliverAppBar(
                    backgroundColor: AppColor.primary,
                    surfaceTintColor: Colors.transparent,
                    pinned: true,
                    expandedHeight: 230,
                    elevation: 0,
                    scrolledUnderElevation: 0,
                    leading: IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.16),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.30),
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      onPressed: () => context.pop(),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      collapseMode: CollapseMode.pin,
                      background: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF1A5C35), AppColor.primary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: SafeArea(
                          child: Padding(
                            padding:
                                const EdgeInsets.fromLTRB(20, 56, 20, 18),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Category title
                                Text(
                                  parentCategory.getName(context),
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    height: 1.2,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _buildDescription(parentCategory),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white
                                        .withValues(alpha: 0.80),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                // Sub-categories count badge — matches website
                                _SubCountBadge(
                                    count: subCategories.length),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ── Sticky search bar ──────────────────────────────────────
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _SearchBarDelegate(
                      searchController: _searchController,
                      hint: context.locale.languageCode == 'hi'
                          ? 'उप-श्रेणियां खोजें...'
                          : 'Search sub-categories...',
                      onChanged: (v) =>
                          setState(() => _searchQuery = v.trim()),
                    ),
                  ),

                  // ── Grid of sub-category cards ─────────────────────────────
                  if (filtered.isEmpty)
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverToBoxAdapter(child: _buildEmptyState()),
                    )
                  else
                    SliverPadding(
                      padding:
                          const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final sub = filtered[index];
                            return SubCategoryGridCard(
                              title: sub.getName(context),
                              subtitle: context.locale.languageCode ==
                                      'hi'
                                  ? 'रेट देखने के लिए खोलें'
                                  : 'View rates and continue',
                              iconData: _getIconForCategory(
                                  sub.slug, sub.name.en),
                              imageUrl: sub.imageUrl,
                              price: sub.basePrice,
                              unit: _displayUnit(sub.pricingType),
                              onTap: () {
                                if (sub.requiresDetails) {
                                  context.push(
                                    AppRoutes.householdItemDetails,
                                    extra: {
                                      'item': PickupCatalogItem(
                                        id: sub.id,
                                        name: sub.name.en,
                                        price: sub.basePrice ?? 0,
                                        unit: _unitFromPricingType(
                                            sub.pricingType),
                                        materialType: '',
                                        pickupSize: '',
                                        priceType: sub.pricingType ??
                                            'per_piece',
                                        condition: '',
                                        imageUrl: sub.imageUrl,
                                      ),
                                      'parentCategoryName':
                                          parentCategory.getName(context),
                                      'applianceCategoryId': sub.id,
                                      'parentCategoryId':
                                          parentCategory.id,
                                    },
                                  );
                                  return;
                                }
                                context.push(
                                  '${AppRoutes.itemSelection}/${sub.id}',
                                );
                              },
                            );
                          },
                          childCount: filtered.length,
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.78,
                        ),
                      ),
                    ),

                  // ── Support banner ─────────────────────────────────────────
                  SliverPadding(
                    padding:
                        const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    sliver: SliverToBoxAdapter(
                      child: CategorySupportBanner(
                        title: context.locale.languageCode == 'hi'
                            ? '${parentCategory.getName(context)} प्रोसेसिंग स्टैंडर्ड'
                            : '${parentCategory.getName(context)} disposal standard',
                        description: context.locale.languageCode == 'hi'
                            ? '${parentCategory.getName(context)} से जुड़ी सभी वस्तुओं के लिए सुरक्षित कलेक्शन सुनिश्चित की जाती है।'
                            : 'We ensure compliant collection and processing across all ${parentCategory.getName(context).toLowerCase()} items.',
                      ),
                    ),
                  ),
                ],
              );
            },
            loading: () => const GridLoadingSkeleton(),
            error: (err, stack) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Error loading sub-categories: $err',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red.shade700),
                ),
              ),
            ),
          );
        },
        loading: () => const GridLoadingSkeleton(includeHeader: false),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Error loading category: $err',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red.shade700),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColor.surface,
        borderRadius: AppTheme.cardBorderRadius,
        border: AppTheme.cardBorder,
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          const Icon(Icons.search_off_rounded,
              size: 40, color: AppColor.textMuted),
          const SizedBox(height: 12),
          Text(
            context.locale.languageCode == 'hi'
                ? 'कोई उप-श्रेणी नहीं मिली।'
                : 'No sub-categories match your search.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColor.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  List<Category> _filterCategories(List<Category> categories, String query) {
    if (query.isEmpty) return categories;
    final normalized = query.toLowerCase();
    return categories.where((c) {
      return c.name.en.toLowerCase().contains(normalized) ||
          c.name.hi.toLowerCase().contains(normalized) ||
          c.slug.toLowerCase().contains(normalized);
    }).toList();
  }

  String _buildDescription(Category parentCategory) {
    return context.locale.languageCode == 'hi'
        ? 'रेट देखने के लिए एक उप-श्रेणी चुनें'
        : 'Select a sub-category to view rates and book pickup';
  }

  String _unitFromPricingType(String? pricingType) {
    return switch ((pricingType ?? '').toLowerCase()) {
      'per_kg' => 'per_kg',
      'per_capacity' => 'per_capacity',
      _ => 'per_piece',
    };
  }

  String? _displayUnit(String? pricingType) {
    switch ((pricingType ?? '').toLowerCase()) {
      case 'per_kg':
        return '/kg';
      case 'per_capacity':
      case 'per_litre':
      case 'per_liter':
        return '/L';
      case 'per_piece':
        return '/pc';
      default:
        return null;
    }
  }

  IconData _getIconForCategory(String slug, String title) {
    final n = '${slug.toLowerCase()} ${title.toLowerCase()}';
    if (n.contains('computer') || n.contains('laptop')) {
      return FontAwesomeIcons.laptop;
    }
    if (n.contains('mobile') || n.contains('phone')) {
      return FontAwesomeIcons.mobileScreenButton;
    }
    if (n.contains('monitor') || n.contains('display')) {
      return FontAwesomeIcons.desktop;
    }
    if (n.contains('accessories')) return FontAwesomeIcons.keyboard;
    if (n.contains('printer') || n.contains('office')) {
      return FontAwesomeIcons.print;
    }
    if (n.contains('power') || n.contains('backup')) {
      return FontAwesomeIcons.carBattery;
    }
    if (n.contains('audio')) return FontAwesomeIcons.headphones;
    if (n.contains('home appliance')) return FontAwesomeIcons.blender;
    if (n.contains('network')) return FontAwesomeIcons.wifi;
    if (n.contains('security')) return FontAwesomeIcons.shieldHalved;
    if (n.contains('lighting')) return FontAwesomeIcons.lightbulb;
    if (n.contains('cable') || n.contains('wire')) return FontAwesomeIcons.plug;
    if (n.contains('component')) return FontAwesomeIcons.microchip;
    if (n.contains('industrial')) return FontAwesomeIcons.industry;
    return FontAwesomeIcons.box;
  }
}

// ── Sub-count badge — matches website "8 SUB-CATEGORIES" pill ─────────────

class _SubCountBadge extends StatelessWidget {
  final int count;
  const _SubCountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Text(
        '$count SUB-CATEGORIES',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

// ── Pinned search bar delegate ─────────────────────────────────────────────

class _SearchBarDelegate extends SliverPersistentHeaderDelegate {
  final TextEditingController searchController;
  final String hint;
  final ValueChanged<String> onChanged;

  const _SearchBarDelegate({
    required this.searchController,
    required this.hint,
    required this.onChanged,
  });

  @override
  double get minExtent => 68;
  @override
  double get maxExtent => 68;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox(
      height: maxExtent,
      child: Container(
        color: AppColor.backgroundLight,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: TextField(
          controller: searchController,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: AppColor.textMuted,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: AppColor.primary,
              size: 22,
            ),
            filled: true,
            fillColor: AppColor.surface,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColor.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColor.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide:
                  const BorderSide(color: AppColor.primary, width: 1.5),
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _SearchBarDelegate oldDelegate) => false;
}

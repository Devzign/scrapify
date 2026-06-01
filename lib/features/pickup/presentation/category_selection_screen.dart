import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_color.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_routes.dart';
import '../../../core/widgets/loading_skeletons.dart';
import '../../settings/providers/settings_provider.dart';
import '../domain/models/category.dart';
import '../providers/category_provider.dart';
import 'widgets/category_list_tile.dart';
import 'widgets/category_support_banner.dart';

class CategorySelectionScreen extends ConsumerStatefulWidget {
  const CategorySelectionScreen({super.key});

  @override
  ConsumerState<CategorySelectionScreen> createState() =>
      _CategorySelectionScreenState();
}

class _CategorySelectionScreenState
    extends ConsumerState<CategorySelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appSettings = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: AppColor.backgroundLight,
      body: ref
          .watch(categoriesProvider)
          .when(
            data: (categories) {
              final filtered = _filterCategories(categories, _searchQuery);
              final showDonationTile =
                  appSettings.features.donationEnabled &&
                  _matchesDonationQuery(_searchQuery);

              return CustomScrollView(
                slivers: [
                  // ── App bar / hero header ──────────────────────────────────
                  SliverAppBar(
                    backgroundColor: AppColor.primary,
                    surfaceTintColor: Colors.transparent,
                    pinned: true,
                    expandedHeight: 140,
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
                    // Only shows when collapsed (scrolled up)
                    title: const Text(
                      'Select Category',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      collapseMode: CollapseMode.pin,
                      // No title here — avoids overlap with background text
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
                            padding: const EdgeInsets.fromLTRB(64, 0, 20, 16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Select Category',
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: -0.5,
                                    height: 1.1,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  context.locale.languageCode == 'hi'
                                      ? 'पिकअप बुकिंग के लिए एक श्रेणी चुनें'
                                      : 'Choose a category to continue with pickup',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white.withValues(alpha: 0.82),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
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
                          ? 'धातु, कागज, ई-वेस्ट खोजें...'
                          : 'Search metal, paper, e-waste...',
                      onChanged: (v) => setState(() => _searchQuery = v.trim()),
                    ),
                  ),

                  // ── Category list ──────────────────────────────────────────
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // Empty state
                        if (filtered.isEmpty && !showDonationTile)
                          _buildEmptyState(),

                        // Category tiles
                        for (final category in filtered)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: CategoryListTile(
                              title: category.getName(context),
                              subtitle: _categorySubtitle(category),
                              iconData: _getIconForCategory(category.slug),
                              imageUrl: category.imageUrl,
                              badgeLabel: category.children.isEmpty
                                  ? null
                                  : '${category.children.length} sub-categories',
                              onTap: () => context.push(
                                '${AppRoutes.subCategorySelection}/${category.id}',
                              ),
                            ),
                          ),

                        // Donation tile
                        if (showDonationTile)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: CategoryListTile(
                              title: context.locale.languageCode == 'hi'
                                  ? 'दान आइटम्स'
                                  : 'Donate Items',
                              subtitle: context.locale.languageCode == 'hi'
                                  ? 'कपड़े, फर्नीचर और उपयोगी वस्तुएं दान करें'
                                  : 'Donate clothes, furniture & reusable goods',
                              iconData: FontAwesomeIcons.heartCirclePlus,
                              onTap: () => context.push(
                                AppRoutes.donationCategorySelection,
                              ),
                            ),
                          ),

                        // Support banner
                        const Padding(
                          padding: EdgeInsets.only(top: 4, bottom: 16),
                          child: CategorySupportBanner(
                            title: 'Not sure where it fits?',
                            description:
                                'Choose the nearest category for now. You can refine the exact item on the next screen.',
                          ),
                        ),
                      ]),
                    ),
                  ),
                ],
              );
            },
            loading: () => const _LoadingBody(),
            error: (error, stack) => _ErrorBody(error: error),
          ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColor.surface,
        borderRadius: AppTheme.cardBorderRadius,
        border: AppTheme.cardBorder,
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          const Icon(
            Icons.search_off_rounded,
            size: 40,
            color: AppColor.textMuted,
          ),
          const SizedBox(height: 12),
          Text(
            context.locale.languageCode == 'hi'
                ? 'कोई श्रेणी नहीं मिली'
                : 'No categories match your search.',
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

  bool _matchesDonationQuery(String query) {
    if (query.isEmpty) return true;
    final n = query.toLowerCase();
    return n.contains('donat') ||
        n.contains('charity') ||
        n.contains('cloth') ||
        n.contains('furniture') ||
        n.contains('reuse') ||
        n.contains('दान') ||
        n.contains('कप') ||
        n.contains('फर्नी');
  }

  String _categorySubtitle(Category category) {
    return context.locale.languageCode == 'hi'
        ? 'उप-श्रेणियां देखने के लिए टैप करें'
        : 'Tap to explore sub-categories';
  }

  IconData _getIconForCategory(String slug) {
    switch (slug.toLowerCase()) {
      case 'e-waste':
      case 'electronics':
        return FontAwesomeIcons.microchip;
      case 'hazardous-waste':
        return FontAwesomeIcons.triangleExclamation;
      case 'metal-scrap':
      case 'metal':
      case 'iron-steel':
        return FontAwesomeIcons.screwdriverWrench;
      case 'plastic-scrap':
      case 'plastic':
        return FontAwesomeIcons.recycle;
      case 'paper-carton-scrap':
      case 'paper':
        return FontAwesomeIcons.boxArchive;
      case 'vehicle-machinery-waste':
        return FontAwesomeIcons.truckMonster;
      case 'furniture-scrap':
        return FontAwesomeIcons.couch;
      default:
        return FontAwesomeIcons.box;
    }
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
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
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
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 14,
            ),
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
              borderSide: const BorderSide(color: AppColor.primary, width: 1.5),
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _SearchBarDelegate oldDelegate) => false;
}

// ── Loading + error bodies ─────────────────────────────────────────────────

class _LoadingBody extends StatelessWidget {
  const _LoadingBody();

  @override
  Widget build(BuildContext context) {
    return const CustomScrollView(
      slivers: [SliverFillRemaining(child: CategoryListLoadingSkeleton())],
    );
  }
}

class _ErrorBody extends StatelessWidget {
  final Object error;
  const _ErrorBody({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: AppColor.error,
              size: 40,
            ),
            const SizedBox(height: 12),
            Text(
              'Error loading categories',
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

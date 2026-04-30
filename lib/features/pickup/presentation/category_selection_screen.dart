import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_routes.dart';
import '../../../core/widgets/loading_skeletons.dart';
import '../../settings/providers/settings_provider.dart';
import '../domain/models/category.dart';
import '../providers/booking_provider.dart';
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
  void initState() {
    super.initState();
    // Always start a fresh scrap flow when entering category selection
    Future.microtask(() {
      ref.read(bookingProvider.notifier).startScrapFlow();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appSettings = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const FaIcon(
            FontAwesomeIcons.arrowLeft,
            color: AppTheme.textPrimary,
          ),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Select Category',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
      body: ref
          .watch(categoriesProvider)
          .when(
            data: (categories) {
              final filtered = _filterCategories(categories, _searchQuery);
              final showDonationTile =
                  appSettings.features.donationEnabled &&
                  _matchesDonationQuery(_searchQuery);
              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                children: [
                  const Text(
                    'Scrapify',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    context.locale.languageCode == 'hi'
                        ? 'पिकअप बुकिंग जारी रखने के लिए एक श्रेणी चुनें।'
                        : 'Choose a category to continue with pickup booking.',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSearchField(),
                  const SizedBox(height: 24),
                  if (filtered.isEmpty && !showDonationTile) _buildEmptyState(),
                  if (filtered.isNotEmpty)
                    ...filtered.map(
                      (category) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: CategoryListTile(
                          title: category.getName(context),
                          subtitle: _categorySubtitle(category),
                          iconData: _getIconForCategory(category.slug),
                          imageUrl: category.imageUrl,
                          onTap: () => context.push(
                            '${AppRoutes.subCategorySelection}/${category.id}',
                          ),
                        ),
                      ),
                    ),
                  if (showDonationTile) ...[
                    const SizedBox(height: 4),
                    CategoryListTile(
                      title: context.locale.languageCode == 'hi'
                          ? 'दान आइटम्स'
                          : 'Donate Items',
                      subtitle: context.locale.languageCode == 'hi'
                          ? 'कपड़े, फर्नीचर और उपयोगी वस्तुएं दान करें'
                          : 'Donate clothes, furniture, and reusable goods',
                      iconData: FontAwesomeIcons.heartCirclePlus,
                      onTap: () =>
                          context.push(AppRoutes.donationCategorySelection),
                    ),
                    const SizedBox(height: 14),
                  ],
                  const SizedBox(height: 12),
                  const CategorySupportBanner(
                    title: 'Not sure where it fits?',
                    description:
                        'Choose the nearest category for now. You can refine the exact item on the next screen.',
                  ),
                ],
              );
            },
            loading: () => const CategoryListLoadingSkeleton(),
            error: (error, stack) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Error loading categories: $error',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red.shade700),
                ),
              ),
            ),
          ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      onChanged: (value) => setState(() => _searchQuery = value.trim()),
      decoration: InputDecoration(
        hintText: context.locale.languageCode == 'hi'
            ? 'धातु, कागज, ई-वेस्ट, प्लास्टिक खोजें...'
            : 'Find metal, paper, e-waste, plastic...',
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: AppTheme.primaryColor,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.cardBorderRadius,
        border: AppTheme.cardBorder,
        boxShadow: AppTheme.cardShadow,
      ),
      child: Text(
        context.locale.languageCode == 'hi'
            ? 'आपकी खोज से कोई श्रेणी मेल नहीं खाती।'
            : 'No categories match your search.',
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppTheme.textSecondary,
        ),
      ),
    );
  }

  List<Category> _filterCategories(List<Category> categories, String query) {
    if (query.isEmpty) {
      return categories;
    }
    final normalized = query.toLowerCase();
    return categories.where((category) {
      return category.name.en.toLowerCase().contains(normalized) ||
          category.name.hi.toLowerCase().contains(normalized) ||
          category.slug.toLowerCase().contains(normalized);
    }).toList();
  }

  bool _matchesDonationQuery(String query) {
    if (query.isEmpty) {
      return true;
    }
    final normalized = query.toLowerCase();
    return normalized.contains('donat') ||
        normalized.contains('charity') ||
        normalized.contains('cloth') ||
        normalized.contains('furniture') ||
        normalized.contains('reuse') ||
        normalized.contains('दान') ||
        normalized.contains('कप') ||
        normalized.contains('फर्नी');
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

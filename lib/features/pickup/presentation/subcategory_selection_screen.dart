import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
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
          'Scrapify',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
      body: categoryDetailAsync.when(
        data: (parentCategory) {
          return subCategoriesAsync.when(
            data: (subCategories) {
              final filtered = _filterCategories(subCategories, _searchQuery);
              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                children: [
                  _buildSearchField(),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Text(
                        parentCategory.getName(context),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _buildDescription(parentCategory),
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (filtered.isEmpty)
                    _buildEmptyState()
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            childAspectRatio: 0.9,
                          ),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final sub = filtered[index];
                        return SubCategoryGridCard(
                          title: sub.getName(context),
                          subtitle: context.locale.languageCode == 'hi'
                              ? 'रेट देखने के लिए खोलें'
                              : 'View rates and continue',
                          iconData: _getIconForCategory(sub.slug, sub.name.en),
                          imageUrl: sub.imageUrl,
                          onTap: () {
                            if (_requiresHouseholdDetails(sub)) {
                              context.push(
                                AppRoutes.householdItemDetails,
                                extra: {
                                  'item': PickupCatalogItem(
                                    id: sub.id,
                                    name: sub.name.en,
                                    price: 65,
                                    unit: 'per_piece',
                                    materialType: 'E-Waste',
                                    pickupSize: 'Medium',
                                    priceType: 'per_piece',
                                    condition: 'Working',
                                    imageUrl: sub.imageUrl,
                                  ),
                                  'parentCategoryName': parentCategory.getName(
                                    context,
                                  ),
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
                    ),
                  const SizedBox(height: 20),
                  CategorySupportBanner(
                    title: context.locale.languageCode == 'hi'
                        ? '${parentCategory.getName(context)} प्रोसेसिंग स्टैंडर्ड'
                        : '${parentCategory.getName(context)} disposal standard',
                    description: context.locale.languageCode == 'hi'
                        ? '${parentCategory.getName(context)} से जुड़ी सभी वस्तुओं के लिए सुरक्षित कलेक्शन और प्रोसेसिंग सुनिश्चित की जाती है।'
                        : 'We ensure compliant collection and processing across all ${parentCategory.getName(context).toLowerCase()} items.',
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

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      onChanged: (value) => setState(() => _searchQuery = value.trim()),
      decoration: InputDecoration(
        hintText: context.locale.languageCode == 'hi'
            ? 'उप-श्रेणियां खोजें...'
            : 'Search sub-categories...',
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
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.softShadow,
      ),
      child: Text(
        context.locale.languageCode == 'hi'
            ? 'आपकी खोज से कोई उप-श्रेणी मेल नहीं खाती।'
            : 'No sub-categories match your search.',
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

  String _buildDescription(Category parentCategory) {
    return context.locale.languageCode == 'hi'
        ? 'रेट देखने के लिए एक उप-श्रेणी चुनें'
        : 'Select a sub-category to view rates';
  }

  bool _requiresHouseholdDetails(Category category) {
    final name = category.name.en.toLowerCase();
    return name.contains('air conditioner') ||
        name.contains('refrigerator') ||
        name.contains('washing machine');
  }

  IconData _getIconForCategory(String slug, String title) {
    final normalized = '${slug.toLowerCase()} ${title.toLowerCase()}';
    if (normalized.contains('computer') || normalized.contains('laptop')) {
      return FontAwesomeIcons.laptop;
    }
    if (normalized.contains('mobile') || normalized.contains('phone')) {
      return FontAwesomeIcons.mobileScreenButton;
    }
    if (normalized.contains('monitor') || normalized.contains('display')) {
      return FontAwesomeIcons.desktop;
    }
    if (normalized.contains('accessories')) {
      return FontAwesomeIcons.keyboard;
    }
    if (normalized.contains('printer') || normalized.contains('office')) {
      return FontAwesomeIcons.print;
    }
    if (normalized.contains('power') || normalized.contains('backup')) {
      return FontAwesomeIcons.carBattery;
    }
    if (normalized.contains('audio')) {
      return FontAwesomeIcons.headphones;
    }
    if (normalized.contains('home appliance')) {
      return FontAwesomeIcons.blender;
    }
    if (normalized.contains('network')) {
      return FontAwesomeIcons.wifi;
    }
    if (normalized.contains('security')) {
      return FontAwesomeIcons.shieldHalved;
    }
    if (normalized.contains('lighting')) {
      return FontAwesomeIcons.lightbulb;
    }
    if (normalized.contains('cable') || normalized.contains('wire')) {
      return FontAwesomeIcons.plug;
    }
    if (normalized.contains('component')) {
      return FontAwesomeIcons.microchip;
    }
    if (normalized.contains('industrial')) {
      return FontAwesomeIcons.industry;
    }
    return FontAwesomeIcons.box;
  }
}

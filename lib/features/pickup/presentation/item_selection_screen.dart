import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_routes.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/loading_skeletons.dart';
import '../domain/models/basket_item.dart';
import '../domain/models/category.dart';
import '../domain/models/pickup_catalog_item.dart';
import '../providers/basket_provider.dart';
import '../providers/category_provider.dart';
import 'widgets/pickup_item_card.dart';
import 'widgets/subcategory_grid_card.dart';

class ItemSelectionScreen extends ConsumerStatefulWidget {
  final int categoryId;

  const ItemSelectionScreen({super.key, required this.categoryId});

  @override
  ConsumerState<ItemSelectionScreen> createState() =>
      _ItemSelectionScreenState();
}

class _ItemSelectionScreenState extends ConsumerState<ItemSelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Map<int, int> _quantities = <int, int>{};
  String _searchQuery = '';
  bool _syncedFromBasket = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoryAsync = ref.watch(categoryDetailProvider(widget.categoryId));
    final basketItems = ref.watch(basketProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
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
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          if (basketItems.isNotEmpty)
            IconButton(
              onPressed: () => context.push(AppRoutes.basket),
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const FaIcon(
                    FontAwesomeIcons.basketShopping,
                    color: AppTheme.primaryColor,
                    size: 18,
                  ),
                  Positioned(
                    right: -8,
                    top: -8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${basketItems.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: categoryAsync.when(
        data: (category) {
          if (category.children.isNotEmpty) {
            final filteredChildren = _filterCategories(
              category.children,
              _searchQuery,
            );
            return ListView(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
              children: [
                Text(
                  category.getName(context),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.textPrimary,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  context.locale.languageCode == 'hi'
                      ? 'जारी रखने के लिए एक आइटम प्रकार चुनें'
                      : 'Select an item type to continue',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 18),
                _buildSearchField(category),
                const SizedBox(height: 18),
                if (filteredChildren.isEmpty)
                  _buildEmptyState(message: 'No item types match your search.')
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
                    itemCount: filteredChildren.length,
                    itemBuilder: (context, index) {
                      final child = filteredChildren[index];
                      return SubCategoryGridCard(
                        title: child.getName(context),
                        subtitle: context.locale.languageCode == 'hi'
                            ? 'विवरण देखें'
                            : 'View details',
                        iconData: _childIcon(child.name.en),
                        imageUrl: child.imageUrl,
                        onTap: () {
                          if (_requiresHouseholdCategoryDetails(child)) {
                            context.push(
                              AppRoutes.householdItemDetails,
                              extra: {
                                'item': PickupCatalogItem(
                                  id: child.id,
                                  name: child.name.en,
                                  price: 65,
                                  unit: 'per_piece',
                                  materialType: 'E-Waste',
                                  pickupSize: 'Medium',
                                  priceType: 'per_piece',
                                  condition: 'Working',
                                  imageUrl: child.imageUrl,
                                ),
                                'parentCategoryName': category.getName(context),
                                'applianceCategoryId': child.id,
                              },
                            );
                            return;
                          }

                          context.push(
                            '${AppRoutes.itemSelection}/${child.id}',
                          );
                        },
                      );
                    },
                  ),
              ],
            );
          }

          final itemsAsync = ref.watch(itemsProvider(widget.categoryId));
          return itemsAsync.when(
            data: (items) {
              _syncQuantitiesFromBasket(items, basketItems);
              final filteredItems = _filterItems(items, _searchQuery);
              final selectedCount = _selectedUnits;
              final totalEstimate = _totalEstimate(items);

              return Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
                      children: [
                        Text(
                          category.getName(context),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.textPrimary,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          context.locale.languageCode == 'hi'
                              ? 'रीसायक्लिंग के लिए आइटम चुनें'
                              : 'Select items for recycling',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 18),
                        _buildSearchField(category),
                        const SizedBox(height: 18),
                        if (filteredItems.isEmpty)
                          _buildEmptyState(
                            message: 'No items match your search.',
                          )
                        else
                          ...filteredItems.map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: PickupItemCard(
                                item: item,
                                quantity: _quantities[item.id] ?? 0,
                                onIncrement: () => _changeQuantity(item.id, 1),
                                onDecrement: () => _changeQuantity(item.id, -1),
                                showQuantityControls: !_requiresHouseholdCategoryDetails(category),
                                onTap: _requiresHouseholdCategoryDetails(category)
                                    ? () => context.push(
                                        AppRoutes.householdItemDetails,
                                        extra: {
                                          'item': item,
                                          'parentCategoryName': category
                                              .getName(context),
                                          'applianceCategoryId':
                                              widget.categoryId,
                                        },
                                      )
                                    : null,
                              ),
                            ),
                          ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                  if (selectedCount > 0)
                    _buildBottomBar(
                      selectedCount: selectedCount,
                      totalEstimate: totalEstimate,
                      items: items,
                      parentCategory: category,
                    ),
                ],
              );
            },
            loading: () => const ItemListLoadingSkeleton(),
            error: (error, stack) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Error loading items: $error',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red.shade700),
                ),
              ),
            ),
          );
        },
        loading: () => const ItemListLoadingSkeleton(),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Error loading category: $error',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red.shade700),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField(Category category) {
    return TextField(
      controller: _searchController,
      onChanged: (value) => setState(() => _searchQuery = value.trim()),
      decoration: InputDecoration(
        hintText: context.locale.languageCode == 'hi'
            ? '${category.getName(context)} आइटम खोजें...'
            : 'Search ${category.getName(context).toLowerCase()} items...',
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: AppTheme.primaryColor,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildEmptyState({required String message}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.softShadow,
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildBottomBar({
    required int selectedCount,
    required double totalEstimate,
    required List<PickupCatalogItem> items,
    required Category parentCategory,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6FBF7),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$selectedCount items selected',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '₹${totalEstimate.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAF8EC),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Text(
                            'Eco-Savings',
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                onPressed: () =>
                    _addSelectedItemsToBasket(items, parentCategory),
                text: 'Add to Basket',
                minHeight: 54,
                borderRadius: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PickupCatalogItem> _filterItems(
    List<PickupCatalogItem> items,
    String query,
  ) {
    if (query.isEmpty) {
      return items;
    }
    final normalized = query.toLowerCase();
    return items.where((item) {
      return item.name.toLowerCase().contains(normalized) ||
          item.condition.toLowerCase().contains(normalized) ||
          item.materialType.toLowerCase().contains(normalized);
    }).toList();
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

  void _changeQuantity(int itemId, int delta) {
    setState(() {
      final current = _quantities[itemId] ?? 0;
      final next = current + delta;
      if (next <= 0) {
        _quantities.remove(itemId);
      } else {
        _quantities[itemId] = next;
      }
    });
  }

  int get _selectedUnits {
    return _quantities.values.fold(0, (sum, qty) => sum + qty);
  }

  double _totalEstimate(List<PickupCatalogItem> items) {
    final byId = {for (final item in items) item.id: item};
    return _quantities.entries.fold(0.0, (sum, entry) {
      final item = byId[entry.key];
      if (item == null) {
        return sum;
      }
      return sum + (entry.value * item.price);
    });
  }

  void _addSelectedItemsToBasket(
    List<PickupCatalogItem> items,
    Category parentCategory,
  ) {
    final basket = ref.read(basketProvider.notifier);
    final byId = {for (final item in items) item.id: item};

    for (final entry in _quantities.entries) {
      final item = byId[entry.key];
      if (item == null || entry.value <= 0) {
        continue;
      }

      basket.setItem(
        BasketItem(
          category: Category(
            id: item.id,
            name: LocalizedName(en: item.name, hi: item.name),
            slug: item.name.toLowerCase().replaceAll(' ', '-'),
            pricingType: item.priceType,
            basePrice: item.price,
            imageUrl: item.imageUrl,
            attributes: const [],
            children: const [],
          ),
          subCategoryName: parentCategory.getName(context),
          quantity: entry.value.toDouble(),
          unit: _basketUnit(item.unit),
          pricePerUnit: item.price,
        ),
      );
    }

    context.push(AppRoutes.basket);
  }

  void _syncQuantitiesFromBasket(
    List<PickupCatalogItem> items,
    List<BasketItem> basketItems,
  ) {
    if (_syncedFromBasket) {
      return;
    }

    final itemIds = items.map((item) => item.id).toSet();
    final basketQuantities = <int, int>{};

    for (final basketItem in basketItems) {
      if (!itemIds.contains(basketItem.category.id)) {
        continue;
      }
      basketQuantities[basketItem.category.id] = basketItem.quantity.round();
    }

    if (basketQuantities.isEmpty) {
      _syncedFromBasket = true;
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _quantities
          ..clear()
          ..addAll(basketQuantities);
        _syncedFromBasket = true;
      });
    });
  }

  String _basketUnit(String unit) {
    return switch (unit.toLowerCase()) {
      'per_kg' => 'kg',
      'per_piece' => 'piece',
      _ => unit.replaceAll('per_', ''),
    };
  }

  bool _requiresHouseholdCategoryDetails(Category category) {
    if (category.hasAttributes) return true;
    final name = category.name.en.toLowerCase();
    return name.contains('air conditioner') ||
        name.contains('refrigerator') ||
        name.contains('washing machine') ||
        name.contains('television') ||
        name.contains('microwave') ||
        category.id == 3 ||
        category.id == 4;
  }

  IconData _childIcon(String name) {
    final normalized = name.toLowerCase();
    if (normalized.contains('television')) {
      return FontAwesomeIcons.tv;
    }
    if (normalized.contains('refrigerator')) {
      return FontAwesomeIcons.kitchenSet;
    }
    if (normalized.contains('washing machine')) {
      return FontAwesomeIcons.shirt;
    }
    if (normalized.contains('microwave')) {
      return FontAwesomeIcons.waveSquare;
    }
    if (normalized.contains('air conditioner')) {
      return FontAwesomeIcons.snowflake;
    }
    return FontAwesomeIcons.box;
  }
}

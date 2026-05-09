import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/utils/app_routes.dart';
import '../../pickup/providers/pickup_provider.dart';

class MaterialPriceListScreen extends ConsumerStatefulWidget {
  const MaterialPriceListScreen({super.key});

  @override
  ConsumerState<MaterialPriceListScreen> createState() =>
      _MaterialPriceListScreenState();
}

class _MaterialPriceListScreenState
    extends ConsumerState<MaterialPriceListScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(pickupProvider.notifier).loadCategories());
  }

  IconData _iconFor(String name) {
    final l = name.toLowerCase();
    if (l.contains('copper')) {
      return FontAwesomeIcons.boltLightning;
    }
    if (l.contains('iron') || l.contains('steel')) {
      return FontAwesomeIcons.screwdriverWrench;
    }
    if (l.contains('brass')) {
      return FontAwesomeIcons.hammer;
    }
    if (l.contains('paper') || l.contains('newspaper')) {
      return FontAwesomeIcons.newspaper;
    }
    if (l.contains('phone') || l.contains('mobile')) {
      return FontAwesomeIcons.mobileScreen;
    }
    if (l.contains('ac') || l.contains('air')) {
      return FontAwesomeIcons.snowflake;
    }
    if (l.contains('plastic')) {
      return FontAwesomeIcons.recycle;
    }
    if (l.contains('electronic') || l.contains('e-waste')) {
      return FontAwesomeIcons.microchip;
    }
    return FontAwesomeIcons.boxesStacked;
  }

  Color _iconColorFor(String name) {
    final l = name.toLowerCase();
    if (l.contains('copper')) {
      return Colors.orange;
    }
    if (l.contains('iron') || l.contains('steel')) {
      return Colors.grey.shade700;
    }
    if (l.contains('brass')) {
      return Colors.yellow.shade700;
    }
    if (l.contains('paper') || l.contains('newspaper')) {
      return Colors.grey.shade800;
    }
    if (l.contains('phone') || l.contains('mobile')) {
      return Colors.blue;
    }
    if (l.contains('ac') || l.contains('air')) {
      return Colors.cyan;
    }
    if (l.contains('plastic')) {
      return Colors.green;
    }
    return Colors.teal;
  }

  Color _iconBgFor(String name) => _iconColorFor(name).withValues(alpha: 0.1);

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pickupProvider);
    final cats = state.categories.whereType<Map<String, dynamic>>().toList();

    // Build category filter list
    final categoryNames = [
      'All',
      ...cats
          .map((c) => c['name']?.toString() ?? '')
          .where((n) => n.isNotEmpty),
    ];

    // Filter items
    List<Map<String, dynamic>> displayed = cats;
    if (_selectedCategory != 'All') {
      displayed = cats
          .where((c) => (c['name']?.toString() ?? '') == _selectedCategory)
          .toList();
    }
    if (_searchQuery.isNotEmpty) {
      displayed = displayed
          .where(
            (c) => (c['name']?.toString() ?? '').toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ),
          )
          .toList();
    }

    return AppScaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const FaIcon(
            FontAwesomeIcons.arrowLeft,
            color: AppTheme.textPrimary,
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Material Price List',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: const InputDecoration(
                  icon: FaIcon(
                    FontAwesomeIcons.magnifyingGlass,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                  hintText: 'Search items / सामान खोजें',
                  hintStyle: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),

          // Category Filters
          if (categoryNames.length > 1)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: categoryNames.map((category) {
                  final isSelected = _selectedCategory == category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      onTap: () => setState(() => _selectedCategory = category),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.primaryColor
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          category,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppTheme.textSecondary,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'TODAY\'S RATES / आज के भाव',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: const [
                    FaIcon(
                      FontAwesomeIcons.arrowsRotate,
                      size: 10,
                      color: AppTheme.primaryColor,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Live',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // List
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : displayed.isEmpty
                ? _buildFallbackList()
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: displayed.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final cat = displayed[i];
                      final name = cat['name']?.toString() ?? 'Category';
                      final rate =
                          cat['rate_per_kg'] ?? cat['price'] ?? cat['rate'];
                      final unit = cat['unit']?.toString() ?? 'kg';
                      return _buildPriceCard(
                        icon: _iconFor(name),
                        iconColor: _iconColorFor(name),
                        iconBg: _iconBgFor(name),
                        titleEn: name,
                        titleHi: cat['name_hi']?.toString() ?? '',
                        rate: rate != null ? '₹$rate' : '—',
                        unit: '/ $unit',
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.categorySelection),
        backgroundColor: AppTheme.primaryColor,
        icon: const FaIcon(
          FontAwesomeIcons.truckFast,
          size: 16,
          color: Colors.white,
        ),
        label: const Text(
          'Sell Now',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // Fallback static list if API returns nothing
  Widget _buildFallbackList() {
    final items = [
      (
        'Copper Wire',
        'तांबे की तार',
        '₹450',
        '/ kg',
        FontAwesomeIcons.boltLightning,
        Colors.orange,
        Colors.orange.shade50,
      ),
      (
        'Iron Heavy',
        'लोहा भारी',
        '₹32',
        '/ kg',
        FontAwesomeIcons.screwdriverWrench,
        Colors.grey.shade700,
        Colors.grey.shade100,
      ),
      (
        'Brass Mix',
        'पीतल मिक्स',
        '₹305',
        '/ kg',
        FontAwesomeIcons.hammer,
        Colors.yellow.shade700,
        Colors.yellow.shade100,
      ),
      (
        'Newspaper',
        'पुराना अखबार',
        '₹14',
        '/ kg',
        FontAwesomeIcons.newspaper,
        Colors.grey.shade800,
        Colors.grey.shade200,
      ),
      (
        'Smartphone',
        'स्मार्टफोन',
        '₹20',
        '/ pc',
        FontAwesomeIcons.mobileScreen,
        Colors.blue,
        Colors.blue.shade50,
      ),
      (
        'Split AC (1.5T)',
        'एसी (पुराना)',
        '₹3500',
        '/ pc',
        FontAwesomeIcons.snowflake,
        Colors.cyan,
        Colors.cyan.shade50,
      ),
    ];
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final it = items[i];
        return _buildPriceCard(
          icon: it.$5,
          iconColor: it.$6,
          iconBg: it.$7,
          titleEn: it.$1,
          titleHi: it.$2,
          rate: it.$3,
          unit: it.$4,
        );
      },
    );
  }

  Widget _buildPriceCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String titleEn,
    required String titleHi,
    required String rate,
    required String unit,
  }) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.grey.shade200),
      boxShadow: null,
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: FaIcon(icon, color: iconColor, size: 24)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titleEn,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AppTheme.textPrimary,
                  ),
                ),
                if (titleHi.isNotEmpty)
                  Text(
                    titleHi,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    rate,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  Text(
                    unit,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

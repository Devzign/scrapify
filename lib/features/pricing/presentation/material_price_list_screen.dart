import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_color.dart';
import '../../../core/theme/app_theme.dart';
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
      backgroundColor: AppColor.backgroundLight,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: AppBar(
          backgroundColor: const Color(0xFF1A5C35),
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
      ),
      body: Column(
        children: [
          // ── Green gradient header ─────────────────────────────────────
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A5C35), AppColor.primary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: Container(
                            padding: const EdgeInsets.all(8),
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
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Material Price List',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: -0.3,
                                  height: 1.1,
                                ),
                              ),
                              Text(
                                'आज के स्क्रैप भाव',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.30),
                            ),
                          ),
                          child: const Row(
                            children: [
                              FaIcon(
                                FontAwesomeIcons.arrowsRotate,
                                size: 9,
                                color: Colors.white,
                              ),
                              SizedBox(width: 5),
                              Text(
                                'LIVE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Search bar embedded in header
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        onChanged: (v) => setState(() => _searchQuery = v),
                        style: const TextStyle(
                          color: AppColor.deepNavy,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: const InputDecoration(
                          icon: FaIcon(
                            FontAwesomeIcons.magnifyingGlass,
                            size: 15,
                            color: AppColor.textSecondary,
                          ),
                          hintText: 'Search items / सामान खोजें',
                          hintStyle: TextStyle(
                            color: AppColor.textMuted,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Category filter chips ─────────────────────────────────────
          if (categoryNames.length > 1)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
              child: Row(
                children: categoryNames.map((category) {
                  final isSelected = _selectedCategory == category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () =>
                          setState(() => _selectedCategory = category),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 9),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColor.primary
                              : Colors.white,
                          borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                          border: Border.all(
                            color: isSelected
                                ? AppColor.primary
                                : AppColor.cardBorder,
                            width: 1.2,
                          ),
                          boxShadow: isSelected ? AppTheme.e1 : null,
                        ),
                        child: Text(
                          category,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppColor.textSecondary,
                            fontWeight: isSelected
                                ? FontWeight.w800
                                : FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

          // ── Sub-header ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: Row(
              children: [
                const Text(
                  "TODAY'S RATES  •  आज के भाव",
                  style: TextStyle(
                    color: AppColor.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColor.primarySurface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'UPDATED DAILY',
                    style: TextStyle(
                      color: AppColor.primaryDark,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Price list ────────────────────────────────────────────────
          Expanded(
            child: state.isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColor.primary,
                    ),
                  )
                : displayed.isEmpty
                    ? _buildFallbackList()
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                        itemCount: displayed.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, i) {
                          final cat = displayed[i];
                          final name =
                              cat['name']?.toString() ?? 'Category';
                          final rate = cat['rate_per_kg'] ??
                              cat['price'] ??
                              cat['rate'];
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
        backgroundColor: AppColor.primary,
        elevation: 4,
        icon: const FaIcon(
          FontAwesomeIcons.truckFast,
          size: 16,
          color: Colors.white,
        ),
        label: const Text(
          'SELL NOW',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 0.6,
          ),
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
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        border: Border.all(color: AppColor.cardBorder, width: 1.2),
        boxShadow: AppTheme.e1,
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            ),
            child: Center(child: FaIcon(icon, color: iconColor, size: 22)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titleEn,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    color: AppColor.deepNavy,
                    letterSpacing: -0.1,
                  ),
                ),
                if (titleHi.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    titleHi,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColor.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
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
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                      color: AppColor.primary,
                    ),
                  ),
                  Text(
                    unit,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColor.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColor.primarySurface,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'SELL',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: AppColor.primaryDark,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

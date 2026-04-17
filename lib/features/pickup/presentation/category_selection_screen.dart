import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_routes.dart';
import '../providers/pickup_provider.dart';
import '../providers/pickup_draft_provider.dart';

class CategorySelectionScreen extends ConsumerStatefulWidget {
  const CategorySelectionScreen({super.key});

  @override
  ConsumerState<CategorySelectionScreen> createState() =>
      _CategorySelectionScreenState();
}

class _CategorySelectionScreenState
    extends ConsumerState<CategorySelectionScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(pickupProvider.notifier).loadCategories());
  }

  static final _fallbackCategories = [
    {
      'id': null,
      'name': 'Iron / Steel',
      'name_hi': 'लोहा / स्टील',
      'icon': FontAwesomeIcons.screwdriverWrench,
    },
    {
      'id': null,
      'name': 'Plastic',
      'name_hi': 'प्लास्टिक',
      'icon': FontAwesomeIcons.recycle,
    },
    {
      'id': null,
      'name': 'E-Waste',
      'name_hi': 'ई-कचरा',
      'icon': FontAwesomeIcons.computer,
    },
    {
      'id': null,
      'name': 'Appliances',
      'name_hi': 'बड़े उपकरण',
      'icon': FontAwesomeIcons.kitchenSet,
    },
  ];

  IconData _iconForCategory(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('iron') || lower.contains('steel') || lower.contains('metal'))
      return FontAwesomeIcons.screwdriverWrench;
    if (lower.contains('plastic')) return FontAwesomeIcons.recycle;
    if (lower.contains('e-waste') || lower.contains('electronic'))
      return FontAwesomeIcons.computer;
    if (lower.contains('paper') || lower.contains('newspaper'))
      return FontAwesomeIcons.newspaper;
    if (lower.contains('appliance') || lower.contains('ac') || lower.contains('fridge'))
      return FontAwesomeIcons.kitchenSet;
    if (lower.contains('glass')) return FontAwesomeIcons.wineGlass;
    if (lower.contains('copper')) return FontAwesomeIcons.boltLightning;
    return FontAwesomeIcons.boxesStacked;
  }

  void _onCategoryTap(int? id, String name) {
    ref.read(pickupDraftProvider.notifier).setCategory(id ?? 0, name);
    context.push(AppRoutes.questionForm);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pickupProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeft,
              color: AppTheme.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'login.app_name'.tr(),
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const FaIcon(FontAwesomeIcons.bell,
                    color: AppTheme.textPrimary),
                onPressed: () {},
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding:
            const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Items / सामान चुनें',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'What do you want to sell today?\nआज आप क्या बेचना चाहते हैं?',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.primaryColor,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),

            if (state.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (state.categories.isNotEmpty)
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.9,
                children: state.categories
                    .whereType<Map<String, dynamic>>()
                    .take(8)
                    .map((cat) {
                  final id = cat['id'] as int?;
                  final name = cat['name']?.toString() ?? 'Category';
                  final nameHi = cat['name_hi']?.toString() ??
                      cat['hindi_name']?.toString() ?? '';
                  return _buildCategoryCard(
                    title: name,
                    subtitle: nameHi,
                    icon: _iconForCategory(name),
                    onTap: () => _onCategoryTap(id, name),
                  );
                }).toList(),
              )
            else
              // Fallback to hardcoded
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.9,
                children: _fallbackCategories.map((cat) {
                  return _buildCategoryCard(
                    title: cat['name'] as String,
                    subtitle: cat['name_hi'] as String,
                    icon: cat['icon'] as IconData,
                    onTap: () => _onCategoryTap(
                        cat['id'] as int?, cat['name'] as String),
                  );
                }).toList(),
              ),

            const SizedBox(height: 24),

            // View All Categories
            Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundLight,
                      shape: BoxShape.circle,
                    ),
                    child: const FaIcon(FontAwesomeIcons.ellipsis,
                        color: AppTheme.textSecondary),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'View All Categories',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          'अन्य श्रेणियां देखें',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const FaIcon(FontAwesomeIcons.chevronRight,
                      color: Colors.grey, size: 16),
                ],
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        elevation: 10,
        backgroundColor: Colors.white,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey.shade400,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.house), label: 'Home'),
          BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.listCheck), label: 'Orders'),
          BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.indianRupeeSign), label: 'Rates'),
          BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.user), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildCategoryCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppTheme.primaryLight,
                shape: BoxShape.circle,
              ),
              child: FaIcon(icon, color: AppTheme.primaryColor, size: 28),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AppTheme.textPrimary,
              ),
            ),
            if (subtitle.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

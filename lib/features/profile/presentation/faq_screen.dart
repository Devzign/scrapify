import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  final List<String> _categories = [
    'All',
    'Pickups / पिकअप',
    'Pricing / रेट्स',
    'Payments / भुगतान',
    'Account / खाता'
  ];
  
  String _selectedCategory = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Define Colors from the HTML
    final primaryColor = const Color(0xFF0a0ac2);
    final bgLightColor = const Color(0xFFf5f5f8);
    final bgDarkColor = const Color(0xFF101022);

    return Scaffold(
      backgroundColor: isDark ? bgDarkColor : bgLightColor,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Sticky Header
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverHeaderDelegate(
                  isDark: isDark,
                  primaryColor: primaryColor,
                  searchController: _searchController,
                  categories: _categories,
                  selectedCategory: _selectedCategory,
                  onCategorySelected: (category) {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                  onPop: () => context.pop(),
                ),
              ),
              
              // Main Content: Scrollable FAQ Items
              SliverPadding(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 16,
                  bottom: 100, // Space for chat button
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildFaqItem(
                      questionKey: 'faq.q1.question',
                      answerKey: 'faq.q1.answer',
                      isDark: isDark,
                      primaryColor: primaryColor,
                      initiallyExpanded: true,
                    ),
                    const SizedBox(height: 16),
                    _buildFaqItem(
                      questionKey: 'faq.q2.question',
                      answerKey: 'faq.q2.answer',
                      isDark: isDark,
                      primaryColor: primaryColor,
                    ),
                    const SizedBox(height: 16),
                    _buildFaqItem(
                      questionKey: 'faq.q3.question',
                      answerKey: 'faq.q3.answer',
                      isDark: isDark,
                      primaryColor: primaryColor,
                    ),
                    const SizedBox(height: 16),
                    _buildFaqItem(
                      questionKey: 'faq.q4.question',
                      answerKey: 'faq.q4.answer',
                      isDark: isDark,
                      primaryColor: primaryColor,
                    ),
                    const SizedBox(height: 16),
                    _buildFaqItem(
                      questionKey: 'faq.q5.question',
                      answerKey: 'faq.q5.answer',
                      isDark: isDark,
                      primaryColor: primaryColor,
                    ),
                  ]),
                ),
              ),
            ],
          ),

          // Sticky Floating Support Button
          Positioned(
            bottom: 32, // Adjusted to not hit bottom navigation if present globally, though this screen hides it anyway
            left: 16,
            right: 16,
            child: ElevatedButton(
              onPressed: () {
                 // Action for chatting
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                elevation: 8,
                shadowColor: primaryColor.withValues(alpha: 0.3),
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const FaIcon(FontAwesomeIcons.solidCommentDots, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'faq.chat_support'.tr(),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem({
    required String questionKey,
    required String answerKey,
    required bool isDark,
    required Color primaryColor,
    bool initiallyExpanded = false,
  }) {
    final currentLocale = context.locale.languageCode;
    final isEnglish = currentLocale == 'en';

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9), // slate-700 / slate-100
        ),
        boxShadow: isDark ? [] : [
          const BoxShadow(
            color: Color(0x0A000000), // shadow-[0_2px_8px_rgba(0,0,0,0.04)]
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent, // Remove default divider
        ),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          tilePadding: const EdgeInsets.all(20),
          childrenPadding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
          collapsedIconColor: const Color(0xFF475569), // slate-600
          iconColor: primaryColor,
          // Custom expanding chevron to match design
          trailing: Container(
             width: 32,
             height: 32,
             decoration: BoxDecoration(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
             ),
             child: const Icon(Icons.expand_more, size: 20),
          ),
          title: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
                Text(
                   questionKey.tr(),
                   style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                   ),
                ),
                if (!isEnglish) ...[
                  const SizedBox(height: 4),
                  Text(
                     questionKey.tr(), // Removed invalid locale parameter
                     style: TextStyle(
                        color: isDark ? const Color(0xFF93C5FD) : primaryColor.withValues(alpha: 0.9), // primary-300 approx
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                     ),
                  ),
                ],
             ],
          ),
          children: [
            Text(
              answerKey.tr(),
              style: TextStyle(
                color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                fontSize: 15,
                height: 1.5,
              ),
            ),
            if (!isEnglish) ...[
              const SizedBox(height: 12),
              Container(
                 padding: const EdgeInsets.only(top: 12),
                 decoration: BoxDecoration(
                    border: Border(
                       top: BorderSide(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                       )
                    )
                 ),
                 child: Text(
                   answerKey.tr(), // Removed invalid locale parameter
                   style: TextStyle(
                     color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                     fontSize: 15,
                     height: 1.5,
                   ),
                 ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  final bool isDark;
  final Color primaryColor;
  final TextEditingController searchController;
  final List<String> categories;
  final String selectedCategory;
  final Function(String) onCategorySelected;
  final VoidCallback onPop;

  _SliverHeaderDelegate({
    required this.isDark,
    required this.primaryColor,
    required this.searchController,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.onPop,
  });

  @override
  double get minExtent => 180.0;
  
  @override
  double get maxExtent => 180.0;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A).withOpacity(0.95) : Colors.white.withOpacity(0.95),
        border: Border(
          bottom: BorderSide(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
             // Header Row
             Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                   children: [
                      IconButton(
                         icon: Icon(
                            Icons.arrow_back,
                            size: 28,
                            color: isDark ? Colors.white : const Color(0xFF1E293B),
                         ),
                         onPressed: onPop,
                      ),
                      Expanded(
                         child: Center(
                            child: Padding(
                               padding: const EdgeInsets.only(right: 40), // Offset for back button to center text
                               child: Text(
                                  'faq.title'.tr(),
                                  style: TextStyle(
                                     fontSize: 18,
                                     fontWeight: FontWeight.bold,
                                     color: isDark ? Colors.white : const Color(0xFF0F172A),
                                  ),
                               ),
                            ),
                         ),
                      ),
                   ],
                ),
             ),
             
             // Search Bar
             Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                   height: 52,
                   decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9), // slate-800 / slate-100
                      borderRadius: BorderRadius.circular(12),
                   ),
                   child: TextField(
                      controller: searchController,
                      style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A)),
                      decoration: InputDecoration(
                         border: InputBorder.none,
                         prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8)),
                         hintText: 'faq.search_hint'.tr(),
                         hintStyle: const TextStyle(color: Color(0xFF64748B)),
                         contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                   ),
                ),
             ),
             
             // Categories
             Expanded(
                child: Padding(
                   padding: const EdgeInsets.only(top: 12, bottom: 12),
                   child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 12),
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
                                     : (isDark ? const Color(0xFF1E293B) : Colors.white),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                     color: isSelected 
                                        ? Colors.transparent 
                                        : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                                  ),
                                  boxShadow: isSelected ? [
                                     BoxShadow(
                                        color: primaryColor.withValues(alpha: 0.2),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                     )
                                  ] : null,
                               ),
                               alignment: Alignment.center,
                               child: Text(
                                  category,
                                  style: TextStyle(
                                     color: isSelected 
                                        ? Colors.white 
                                        : (isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155)),
                                     fontSize: 14,
                                     fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
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
  bool shouldRebuild(covariant _SliverHeaderDelegate oldDelegate) {
    return isDark != oldDelegate.isDark || 
           primaryColor != oldDelegate.primaryColor ||
           selectedCategory != oldDelegate.selectedCategory;
  }
}

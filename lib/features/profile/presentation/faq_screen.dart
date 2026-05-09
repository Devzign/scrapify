import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'widgets/faq_header_delegate.dart';
import '../../../core/utils/app_routes.dart';
import '../../../core/theme/app_theme.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<String> _getCategories(BuildContext context) {
    final isHindi = context.locale.languageCode == 'hi';
    return [
      isHindi ? 'सभी' : 'All',
      isHindi ? 'पिकअप' : 'Pickups',
      isHindi ? 'रेट्स' : 'Pricing',
      isHindi ? 'भुगतान' : 'Payments',
      isHindi ? 'खाता' : 'Account',
    ];
  }

  int _selectedCategoryIndex = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    const primaryColor = AppTheme.primaryColor;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Sticky Header
              SliverPersistentHeader(
                pinned: true,
                delegate: FaqHeaderDelegate(
                  isDark: isDark,
                  primaryColor: primaryColor,
                  searchController: _searchController,
                  categories: _getCategories(context),
                  selectedCategory: _getCategories(
                    context,
                  )[_selectedCategoryIndex],
                  onCategorySelected: (category) {
                    setState(() {
                      _selectedCategoryIndex = _getCategories(
                        context,
                      ).indexOf(category);
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

          Positioned(
            bottom:
                32,
            left: 16,
            right: 16,
            child: ElevatedButton(
              onPressed: () {
                context.push(AppRoutes.helpSupport);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                elevation: 8,
                shadowColor: primaryColor.withValues(alpha: 0.3),
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 24,
                ),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? const Color(0xFF334155)
              : AppTheme.outline,
        ),
        boxShadow: isDark
            ? []
            : [
                const BoxShadow(
                  color: Color(
                    0x0A000000,
                  ),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          tilePadding: const EdgeInsets.all(20),
          childrenPadding: const EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: 20,
          ),
          collapsedIconColor: AppTheme.textSecondary,
          iconColor: primaryColor,
          trailing: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF334155) : AppTheme.hairline,
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
                      color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
              if (!isEnglish) ...[
                const SizedBox(height: 4),
                Text(
                  questionKey.tr(),
                  style: TextStyle(
                    color: isDark
                        ? const Color(0xFF93C5FD)
                        : primaryColor.withValues(
                            alpha: 0.9,
                          ),
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
                    color: AppTheme.textSecondary,
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
                      color: isDark
                          ? const Color(0xFF334155)
                          : AppTheme.hairline,
                    ),
                  ),
                ),
                child: Text(
                  answerKey.tr(),
                  style: TextStyle(
                    color: isDark
                        ? AppTheme.textMuted
                        : AppTheme.textSecondary,
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

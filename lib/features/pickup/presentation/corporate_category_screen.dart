import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_routes.dart';
import '../../../core/widgets/custom_button.dart';
import '../domain/models/category.dart';
import '../providers/category_provider.dart';
import '../providers/corporate_provider.dart';

class CorporateCategoryScreen extends ConsumerStatefulWidget {
  const CorporateCategoryScreen({super.key});

  @override
  ConsumerState<CorporateCategoryScreen> createState() =>
      _CorporateCategoryScreenState();
}

class _CorporateCategoryScreenState
    extends ConsumerState<CorporateCategoryScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(corporateBookingProvider.notifier).reset());
  }

  @override
  Widget build(BuildContext context) {
    final isHindi = context.locale.languageCode == 'hi';
    final categoriesAsync = ref.watch(categoriesProvider);
    final booking = ref.watch(corporateBookingProvider);

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
        title: Text(
          isHindi ? 'कॉर्पोरेट स्क्रैप बिक्री' : 'Corporate Scrap Sale',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: categoriesAsync.when(
              data: (categories) =>
                  _buildCategoryList(context, categories, booking, isHindi),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
          _buildBottomBar(context, booking, isHindi),
        ],
      ),
    );
  }

  Widget _buildCategoryList(
    BuildContext context,
    List<Category> categories,
    CorporateBookingState booking,
    bool isHindi,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text(
            isHindi
                ? 'श्रेणियां चुनें और मात्रा दर्ज करें'
                : 'Select categories & enter quantity',
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.hintPeach,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.warningColor, width: 1),
            ),
            child: Row(
              children: [
                const FaIcon(
                  FontAwesomeIcons.circleInfo,
                  color: AppTheme.warningColor,
                  size: 16,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isHindi
                        ? 'कीमत पिकअप के समय एजेंट तय करेगा। कोई पेमेंट पहले नहीं।'
                        : 'Price will be quoted by agent at pickup. No payment now.',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.warningColor,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ...categories.map(
            (cat) => _CategoryQuantityCard(
              category: cat,
              item: booking.items
                  .where((i) => i.category.id == cat.id)
                  .firstOrNull,
              isHindi: isHindi,
              onChanged: (qty, unit) => ref
                  .read(corporateBookingProvider.notifier)
                  .setItem(cat, qty, unit),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(
    BuildContext context,
    CorporateBookingState booking,
    bool isHindi,
  ) {
    final itemCount = booking.items.length;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (itemCount > 0) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isHindi
                        ? '$itemCount श्रेणी चुनी गई'
                        : '$itemCount categor${itemCount == 1 ? 'y' : 'ies'} selected',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  Text(
                    isHindi ? 'कोटेशन पिकअप पर' : 'Quotation at pickup',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            CustomButton(
              onPressed: itemCount > 0
                  ? () => context.push(AppRoutes.corporateSchedule)
                  : null,
              text: isHindi ? 'शेड्यूल करें' : 'SCHEDULE PICKUP',
              minHeight: 60,
              borderRadius: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryQuantityCard extends StatefulWidget {
  final Category category;
  final CorporateItem? item;
  final bool isHindi;
  final void Function(double qty, String unit) onChanged;

  const _CategoryQuantityCard({
    required this.category,
    required this.item,
    required this.isHindi,
    required this.onChanged,
  });

  @override
  State<_CategoryQuantityCard> createState() => _CategoryQuantityCardState();
}

class _CategoryQuantityCardState extends State<_CategoryQuantityCard> {
  late final TextEditingController _controller;
  late String _unit;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.item != null && widget.item!.quantity > 0
          ? widget.item!.quantity.toString()
          : '',
    );
    _unit = widget.item?.unit ?? 'kg';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.item != null && widget.item!.quantity > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.cardBorderRadius,
        boxShadow: AppTheme.cardShadow,
        border: Border.all(
          color: isSelected ? AppTheme.primaryColor : Colors.transparent,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primaryColor.withValues(alpha: 0.1)
                        : AppTheme.backgroundCream,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _iconFor(widget.category.slug),
                    color: isSelected
                        ? AppTheme.primaryColor
                        : AppTheme.textMuted,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.isHindi
                        ? widget.category.name.hi
                        : widget.category.name.en,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: isSelected
                          ? AppTheme.primaryColor
                          : AppTheme.textPrimary,
                    ),
                  ),
                ),
                if (isSelected)
                  const FaIcon(
                    FontAwesomeIcons.solidCircleCheck,
                    color: AppTheme.primaryColor,
                    size: 18,
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _controller,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      hintText: widget.isHindi
                          ? 'मात्रा दर्ज करें'
                          : 'Enter quantity',
                      hintStyle: const TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 13,
                      ),
                      filled: true,
                      fillColor: AppTheme.backgroundCream,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (val) {
                      final qty = double.tryParse(val) ?? 0;
                      widget.onChanged(qty, _unit);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundCream,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        _UnitChip(
                          label: 'kg',
                          selected: _unit == 'kg',
                          onTap: () {
                            setState(() => _unit = 'kg');
                            final qty = double.tryParse(_controller.text) ?? 0;
                            if (qty > 0) widget.onChanged(qty, 'kg');
                          },
                        ),
                        _UnitChip(
                          label: 'pcs',
                          selected: _unit == 'pcs',
                          onTap: () {
                            setState(() => _unit = 'pcs');
                            final qty = double.tryParse(_controller.text) ?? 0;
                            if (qty > 0) widget.onChanged(qty, 'pcs');
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(String slug) {
    switch (slug.toLowerCase()) {
      case 'e-waste':
      case 'electronics':
        return FontAwesomeIcons.microchip;
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
      case 'hazardous-waste':
        return FontAwesomeIcons.triangleExclamation;
      default:
        return FontAwesomeIcons.box;
    }
  }
}

class _UnitChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _UnitChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppTheme.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: selected ? Colors.white : AppTheme.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}

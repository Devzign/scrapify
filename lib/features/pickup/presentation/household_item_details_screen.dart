import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_routes.dart';
import '../../../core/widgets/custom_button.dart';
import '../domain/models/basket_item.dart';
import '../domain/models/category.dart';
import '../domain/models/home_appliance_details.dart';
import '../domain/models/pickup_catalog_item.dart';
import '../domain/repositories/category_repository.dart';
import '../providers/basket_provider.dart';
import '../providers/category_provider.dart';
import '../../../core/theme/app_color.dart';

class HouseholdItemDetailsScreen extends ConsumerStatefulWidget {
  final PickupCatalogItem item;
  final String parentCategoryName;
  final int applianceCategoryId;
  final int? parentCategoryId;
  final bool selectionOnly;
  final String? selectionCtaLabel;

  const HouseholdItemDetailsScreen({
    super.key,
    required this.item,
    required this.parentCategoryName,
    required this.applianceCategoryId,
    this.parentCategoryId,
    this.selectionOnly = false,
    this.selectionCtaLabel,
  });

  @override
  ConsumerState<HouseholdItemDetailsScreen> createState() =>
      _HouseholdItemDetailsScreenState();
}

class _HouseholdItemDetailsScreenState
    extends ConsumerState<HouseholdItemDetailsScreen> {
  final Map<String, HomeApplianceOption> _selectedOptions =
      <String, HomeApplianceOption>{};
  bool _initializedSelections = false;
  double? _liveEstimatedPrice;
  double _selectedWeightKg = 1.0;
  bool _isEstimating = false;
  Timer? _estimateDebounce;
  int _estimateRequestId = 0;

  PickupCatalogItem get _item => widget.item;

  bool get _isHindi => context.locale.languageCode == 'hi';

  bool get _isTelevision {
    final name = _item.name.toLowerCase();
    return name.contains('television') || name.contains('tv');
  }

  bool get _isMicrowave => _item.name.toLowerCase().contains('microwave');

  bool get _isAirConditioner {
    final name = _item.name.toLowerCase();
    return name.contains('air conditioner') || name == 'ac';
  }

  bool get _isRefrigerator => _item.name.toLowerCase().contains('refrigerator');

  bool get _isWashingMachine =>
      _item.name.toLowerCase().contains('washing machine');

  bool get _isMobilePhone => _item.name.toLowerCase().contains('mobile phone');

  bool get _isLaptop => _item.name.toLowerCase().contains('laptop');

  bool get _isCablesAndWires {
    final name = _item.name.toLowerCase();
    return name.contains('cables') || name.contains('wires');
  }

  bool get _isCpuCabinet => _item.name.toLowerCase().contains('cpu cabinet');

  double _unitEstimate(HomeApplianceDetails details) {
    return _liveEstimatedPrice ?? details.estimatedPrice;
  }

  double _displayEstimate(HomeApplianceDetails details) {
    final unit = _unitEstimate(details);
    if (details.pricingType.toLowerCase() == 'per_kg') {
      return unit * _selectedWeightKg;
    }
    return unit;
  }

  @override
  void dispose() {
    _estimateDebounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final detailsAsync = ref.watch(
      homeApplianceDetailsProvider(widget.applianceCategoryId),
    );

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColor.primarySurface,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColor.primary.withValues(alpha: 0.20),
              ),
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              color: AppColor.primary,
              size: 18,
            ),
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          _isHindi ? 'वस्तु बेचें' : 'Sell Items',
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: detailsAsync.when(
        loading: _buildLoading,
        error: (error, _) => _buildErrorState(error.toString()),
        data: (details) {
          _ensureSelections(details);
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 16, 14, 0),
                        child: _buildHeroCard(details),
                      ),
                      const SizedBox(height: 12),
                      ..._buildSectionCards(details),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
              _buildBottomBar(details),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(color: AppTheme.primaryColor),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.redAccent,
              size: 40,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard(HomeApplianceDetails details) {
    return _sectionShell(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.primarySurface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppTheme.primaryLight),
        ),
        child: Row(
          children: [
            Container(
              width: 104,
              height: 104,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.88),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: _item.imageUrl.trim().isEmpty
                      ? Icon(_heroIcon, color: AppTheme.primaryDark, size: 42)
                      : Image.network(
                          _item.imageUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Icon(
                            _heroIcon,
                            color: AppTheme.primaryDark,
                            size: 42,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    details.name.isEmpty ? _item.name : details.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _isHindi ? 'एयर कंडीशनर' : _item.name,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Base ₹${_unitEstimate(details).toStringAsFixed(0)}${_pricingSuffix(details.pricingType)}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.primaryDark,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSectionCards(HomeApplianceDetails details) {
    final widgets = <Widget>[];

    for (final section in details.sections) {
      if (!_shouldRenderSection(section)) {
        continue;
      }
      final selected = _selectedOptions[section.slug];
      if (section.options.isEmpty || selected == null) {
        continue;
      }

      widgets.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
          child: _sectionShell(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _displayTitle(section.title, section.slug),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.primaryDark,
                        ),
                      ),
                      Text(
                        _hindiSubtitle(section),
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _buildSectionOptions(section, selected),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (details.pricingType.toLowerCase() == 'per_kg') {
      widgets.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
          child: _sectionShell(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isHindi ? 'वजन चुनें' : 'Select Weight',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _isHindi
                        ? '100g से 100kg (100g स्टेप)'
                        : '100g to 100kg (100g step)',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _weightControlButton(
                        icon: Icons.remove,
                        onTap: _selectedWeightKg > 0.1
                            ? () => setState(() {
                                _selectedWeightKg = (_selectedWeightKg - 0.1)
                                    .clamp(0.1, 100.0);
                              })
                            : null,
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            '${_selectedWeightKg.toStringAsFixed(1)} kg',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.primaryDark,
                            ),
                          ),
                        ),
                      ),
                      _weightControlButton(
                        icon: Icons.add,
                        onTap: _selectedWeightKg < 100
                            ? () => setState(() {
                                _selectedWeightKg = (_selectedWeightKg + 0.1)
                                    .clamp(0.1, 100.0);
                              })
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '₹${(_unitEstimate(details) / 10).toStringAsFixed(0)} per 100g',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primaryDark,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    widgets.add(
      Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
        child: _sectionShell(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: AppTheme.primaryDark,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _infoText,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 10,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return widgets;
  }

  Widget _buildSectionOptions(
    HomeApplianceSection section,
    HomeApplianceOption selected,
  ) {
    final visibleOptions = _visibleOptionsForSection(section);
    if (visibleOptions.isEmpty) return const SizedBox.shrink();

    // Working Condition and Usage Age stay as pill chips
    if (_isConditionSection(section) || _isUsageAgeSection(section)) {
      return Wrap(
        spacing: 10,
        runSpacing: 10,
        children: visibleOptions
            .map(
              (option) => _outlinedOption(
                label: _localizedCondition(option.value),
                isSelected: selected.id == option.id,
                onTap: () => _updateSelection(section.slug, option),
                fullWidth: false,
              ),
            )
            .toList(),
      );
    }

    // Everything else → custom styled bottom-sheet dropdown
    final currentSelected = visibleOptions.any((o) => o.id == selected.id)
        ? selected
        : visibleOptions.first;

    return _buildCustomDropdownTrigger(
      section: section,
      selected: currentSelected,
      options: visibleOptions,
    );
  }

  Widget _buildCustomDropdownTrigger({
    required HomeApplianceSection section,
    required HomeApplianceOption selected,
    required List<HomeApplianceOption> options,
  }) {
    return GestureDetector(
      onTap: () => _showOptionBottomSheet(section, selected, options),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: BoxDecoration(
          color: AppTheme.primarySurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.primaryDark.withValues(alpha: 0.25),
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                selected.value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primaryDark,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppTheme.primaryDark,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOptionBottomSheet(
    HomeApplianceSection section,
    HomeApplianceOption currentSelected,
    List<HomeApplianceOption> options,
  ) {
    final title = _displayTitle(section.title, section.slug);
    final isBrandSelector = '${section.slug} ${section.title}'
        .toLowerCase()
        .contains('brand');

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return _OptionSelectionBottomSheet(
          title: title,
          isHindi: _isHindi,
          isBrandSelector: isBrandSelector,
          currentSelected: currentSelected,
          options: options,
          onSelected: (option) {
            _updateSelection(section.slug, option);
            Navigator.pop(ctx);
          },
        );
      },
    );
  }

  Widget _outlinedOption({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool fullWidth,
  }) {
    final child = InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: fullWidth ? double.infinity : null,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryLight : AppTheme.backgroundCream,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected ? AppTheme.primaryDark : AppTheme.cardBorderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: isSelected
                      ? AppTheme.primaryDark
                      : AppTheme.primaryDark,
                ),
              ),
            ),
            if (fullWidth)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(
                  isSelected
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: isSelected
                      ? AppTheme.primaryDark
                      : AppTheme.cardBorderColor,
                ),
              ),
          ],
        ),
      ),
    );

    if (fullWidth) {
      return child;
    }

    return IntrinsicWidth(child: child);
  }

  Widget _sectionShell({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppTheme.cardBorderColor),
        boxShadow: AppTheme.cardShadow,
      ),
      child: child,
    );
  }

  Widget _weightControlButton({
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: onTap == null ? AppTheme.hairline : AppTheme.primaryLight,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppTheme.cardBorderColor),
        ),
        child: Icon(icon, color: AppTheme.primaryDark, size: 20),
      ),
    );
  }

  Widget _buildBottomBar(HomeApplianceDetails details) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      color: AppTheme.backgroundLight,
      child: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: AppTheme.cardBorderColor),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isHindi ? 'अनुमानित मूल्य' : 'ESTIMATED',
                          style: const TextStyle(
                            fontSize: 9,
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '₹${_displayEstimate(details).toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 40,
                            height: 0.95,
                            color: AppTheme.primaryDark,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: _isEstimating
                        ? Container(
                            key: const ValueKey('estimating'),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primarySurface,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppTheme.primaryDark,
                              ),
                            ),
                          )
                        : Container(
                            key: const ValueKey('best_value'),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primarySurface,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Text(
                              '✓ BEST VALUE',
                              style: TextStyle(
                                color: AppTheme.primaryDark,
                                fontWeight: FontWeight.w800,
                                fontSize: 8,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  onPressed: () => _addToBasket(details),
                  text: widget.selectionOnly
                      ? (widget.selectionCtaLabel ??
                            (_isHindi ? 'आइटम जोड़ें' : 'Add Item'))
                      : (_isHindi ? 'बास्केट में जोड़ें' : 'Add to Basket'),
                  leading: const FaIcon(
                    FontAwesomeIcons.basketShopping,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _ensureSelections(HomeApplianceDetails details) {
    if (_initializedSelections) {
      return;
    }

    final existingBasketItem = ref
        .read(basketProvider)
        .where((item) => item.category.id == widget.applianceCategoryId)
        .cast<BasketItem?>()
        .firstWhere((item) => item != null, orElse: () => null);
    final storedAttributes = {
      for (final attribute
          in existingBasketItem?.selectedAttributes ?? <SelectedAttribute>[])
        attribute.name.toLowerCase(): attribute.value,
    };

    for (final section in details.sections) {
      if (section.options.isEmpty) {
        continue;
      }

      final storedValue = (storedAttributes[section.title.toLowerCase()] ?? '')
          .trim();
      final matchedOption = section.options
          .cast<HomeApplianceOption?>()
          .firstWhere(
            (option) =>
                option?.value.toLowerCase() == storedValue.toLowerCase(),
            orElse: () => null,
          );
      final otherOption = section.options
          .cast<HomeApplianceOption?>()
          .firstWhere(
            (option) => option?.value.toLowerCase() == 'other',
            orElse: () => null,
          );
      final selected =
          matchedOption ??
          (storedValue.isNotEmpty && otherOption != null
              ? HomeApplianceOption(id: otherOption.id, value: storedValue)
              : section.options.first);
      _selectedOptions[section.slug] = selected;
    }

    _initializedSelections = true;
    _debouncedEstimatePrice();
  }

  void _updateSelection(String slug, HomeApplianceOption option) {
    setState(() {
      _selectedOptions[slug] = option;
    });
    _debouncedEstimatePrice();
  }

  void _debouncedEstimatePrice() {
    _estimateDebounce?.cancel();
    _estimateDebounce = Timer(
      const Duration(milliseconds: 280),
      _recalculateEstimatedPrice,
    );
  }

  Future<void> _recalculateEstimatedPrice() async {
    final requestId = ++_estimateRequestId;
    setState(() => _isEstimating = true);

    final repository = ref.read(categoryRepositoryProvider);
    final response = await repository.estimateHomeAppliancePrice(
      categoryId: widget.applianceCategoryId,
      attributes: _buildEstimatePayload(),
    );

    if (!mounted || requestId != _estimateRequestId) {
      return;
    }

    setState(() {
      _isEstimating = false;
      if (response.isSuccess && response.data != null && response.data! > 0) {
        _liveEstimatedPrice = response.data;
      }
    });
  }

  List<Map<String, dynamic>> _buildEstimatePayload() {
    final details = ref.read(
      homeApplianceDetailsProvider(widget.applianceCategoryId),
    );

    return details.maybeWhen(
      data: (value) {
        return value.sections
            .where(
              (section) =>
                  _selectedOptions[section.slug] != null &&
                  _shouldRenderSection(section),
            )
            .map((section) {
              final selected = _selectedOptions[section.slug]!;
              return <String, dynamic>{
                'attribute_id': section.id > 0 ? section.id : null,
                'attribute_name': section.title,
                'option_id': selected.id,
                'value': selected.value,
              };
            })
            .toList();
      },
      orElse: () => const <Map<String, dynamic>>[],
    );
  }

  bool _shouldRenderSection(HomeApplianceSection section) {
    final key = '${section.slug} ${section.title}'.toLowerCase();
    final isUsageAgeSection = key.contains('usage') && key.contains('age');
    if (!isUsageAgeSection) {
      return true;
    }

    HomeApplianceOption? workingSelector;
    for (final entry in _selectedOptions.entries) {
      final selectorKey = entry.key.toLowerCase();
      if (selectorKey.contains('working-condition') ||
          selectorKey.contains('functional-status')) {
        workingSelector = entry.value;
        break;
      }
    }

    if (workingSelector == null) {
      return false;
    }

    final value = workingSelector.value.toLowerCase();
    return value.contains('working') &&
        !value.contains('non-working') &&
        !value.contains('not working');
  }

  bool _isConditionSection(HomeApplianceSection section) {
    // Rely ONLY on option values, not slug/title string matching,
    // to prevent brand / capacity sections from being misclassified as chips.
    return section.options.any((option) {
      final value = option.value.toLowerCase().trim();
      return value == 'working' ||
          value == 'fully working' ||
          value == 'partially working' ||
          value == 'not working' ||
          value == 'non-working';
    });
  }

  bool _isUsageAgeSection(HomeApplianceSection section) {
    // Must have BOTH 'usage' and 'age' in the slug or title,
    // AND must not look like a brand / capacity section.
    final key = '${section.slug} ${section.title}'.toLowerCase();
    if (key.contains('brand') ||
        key.contains('capacity') ||
        key.contains('type') ||
        key.contains('size')) {
      return false;
    }
    return key.contains('usage') && key.contains('age');
  }

  List<HomeApplianceOption> _visibleOptionsForSection(
    HomeApplianceSection section,
  ) {
    final key = '${section.slug} ${section.title}'.toLowerCase();
    if (key.contains('material')) {
      return section.options.where((option) {
        final value = option.value.toLowerCase();
        return value != 'paper' && value != 'glass';
      }).toList();
    }
    return section.options;
  }

  String _displayTitle(String title, String slug) {
    if (!_isHindi) {
      if ('${slug.toLowerCase()} ${title.toLowerCase()}'.contains('brand')) {
        return 'Select Brand';
      }
      return title;
    }

    final key = '$slug $title'.toLowerCase();
    if (key.contains('brand')) {
      return 'ब्रांड चुनें';
    }
    if (key.contains('capacity')) {
      if (_isRefrigerator || _isMicrowave) {
        return 'क्षमता (लीटर)';
      }
      if (_isTelevision) {
        return 'स्क्रीन साइज़ (इंच)';
      }
      if (_isWashingMachine) {
        return 'क्षमता (किलो)';
      }
      return 'क्षमता (टन)';
    }
    if (key.contains('condition')) {
      return 'स्थिति';
    }
    if (key.contains('body')) {
      return 'Body Type';
    }
    if (key.contains('mount')) {
      return 'फिटिंग का प्रकार';
    }
    if (key.contains('door')) {
      return 'दरवाज़े का प्रकार';
    }
    if (key.contains('display')) {
      return 'डिस्प्ले प्रकार';
    }
    if (key.contains('machine')) {
      return 'मशीन का प्रकार';
    }
    if (key.contains('type')) {
      return 'प्रकार';
    }
    return title;
  }

  String _hindiSubtitle(HomeApplianceSection section) {
    if (!_isHindi) {
      return '';
    }
    final key = '${section.slug} ${section.title}'.toLowerCase();
    if (key.contains('brand')) {
      return 'ब्रांड चुनें';
    }
    if (key.contains('capacity')) {
      return 'क्षमता';
    }
    if (key.contains('body')) {
      return 'बॉडी का प्रकार';
    }
    if (key.contains('condition')) {
      return 'स्थिति';
    }
    return '';
  }

  String _localizedCondition(String value) {
    if (!_isHindi) {
      return value;
    }

    final normalized = value.toLowerCase();
    if (normalized == 'working') {
      return 'वर्किंग';
    }
    if (normalized == 'fully working') {
      return 'पूरी तरह वर्किंग';
    }
    if (normalized == 'partially working') {
      return 'आंशिक रूप से वर्किंग';
    }
    if (normalized == 'not working') {
      return 'वर्किंग नहीं';
    }
    if (normalized == 'non-working') {
      return 'नॉन-वर्किंग';
    }
    return value;
  }

  String get _infoText {
    if (_isAirConditioner) {
      return 'Final price can vary based on compressor condition, copper coil quality, and working state.';
    }
    if (_isRefrigerator) {
      return 'Prices depend on copper coil, compressor health, and internal cooling condition.';
    }
    if (_isTelevision) {
      return 'Final price depends on panel condition, display type, board health, and screen age.';
    }
    if (_isMicrowave) {
      return 'Final price depends on magnetron health, cavity condition, control panel status, and overall age.';
    }
    if (_isMobilePhone) {
      return 'Final price varies by storage variant, device age, screen condition, and working status.';
    }
    if (_isLaptop) {
      return 'Final price varies by RAM/storage configuration, battery health, and working condition.';
    }
    if (_isCablesAndWires) {
      return 'Final price depends on copper content, stripping quality, and insulation condition.';
    }
    if (_isCpuCabinet) {
      return 'Final price varies by component completeness, configuration level, and working condition.';
    }
    return 'Final price can vary based on motor condition, drum material, and working status.';
  }

  IconData get _heroIcon {
    if (_isAirConditioner) {
      return Icons.ac_unit_rounded;
    }
    if (_isRefrigerator) {
      return Icons.kitchen_rounded;
    }
    if (_isTelevision) {
      return Icons.tv_rounded;
    }
    if (_isMicrowave) {
      return Icons.microwave_rounded;
    }
    if (_isMobilePhone) {
      return Icons.smartphone_rounded;
    }
    if (_isLaptop) {
      return Icons.laptop_mac_rounded;
    }
    if (_isCablesAndWires) {
      return Icons.cable_rounded;
    }
    if (_isCpuCabinet) {
      return Icons.computer_rounded;
    }
    return Icons.local_laundry_service_rounded;
  }

  void _addToBasket(HomeApplianceDetails details) {
    final totalEstimate = _displayEstimate(details);
    final unitEstimate = _unitEstimate(details);
    final isPerKg = details.pricingType.toLowerCase() == 'per_kg';

    if (widget.selectionOnly) {
      String? condition;
      for (final section in details.sections) {
        final key = '${section.slug} ${section.title}'.toLowerCase();
        if (key.contains('condition') || key.contains('working')) {
          condition = _selectedOptions[section.slug]?.value;
          break;
        }
      }

      Navigator.of(context).pop(<String, dynamic>{
        'item_id': widget.applianceCategoryId,
        'item_name': details.name.isEmpty ? _item.name : details.name,
        'rate_per_kg': unitEstimate,
        'pricing_type': details.pricingType,
        'weight_kg': isPerKg ? _selectedWeightKg : 1.0,
        'quantity': 1,
        'condition': condition,
        'estimated_total': totalEstimate,
      });
      return;
    }

    ref
        .read(basketProvider.notifier)
        .setItem(
          BasketItem(
            category: Category(
              id: widget.applianceCategoryId,
              name: LocalizedName(
                en: details.name.isEmpty ? _item.name : details.name,
                hi: details.name.isEmpty ? _item.name : details.name,
              ),
              slug: (details.name.isEmpty ? _item.name : details.name)
                  .toLowerCase()
                  .replaceAll(' ', '-'),
              pricingType: details.pricingType,
              basePrice: totalEstimate,
              imageUrl: _item.imageUrl,
              attributes: const [],
              children: const [],
            ),
            subCategoryName: widget.parentCategoryName,
            quantity: isPerKg ? _selectedWeightKg : 1,
            unit: _basketUnitFromPricingType(details.pricingType),
            pricePerUnit: unitEstimate,
            selectedAttributes: details.sections
                .where((section) => _selectedOptions[section.slug] != null)
                .map(
                  (section) => SelectedAttribute(
                    id: section.id,
                    name: section.title,
                    value: _selectedOptions[section.slug]!.value,
                  ),
                )
                .toList(),
          ),
        );

    context.push(AppRoutes.basket);
  }

  String _basketUnitFromPricingType(String pricingType) {
    return switch (pricingType.toLowerCase()) {
      'per_kg' => 'kg',
      'per_capacity' => 'capacity',
      _ => 'piece',
    };
  }

  String _pricingSuffix(String pricingType) {
    return switch (pricingType.toLowerCase()) {
      'per_kg' => '/kg',
      'per_capacity' => '/capacity',
      _ => '/piece',
    };
  }
}

class _OptionSelectionBottomSheet extends StatefulWidget {
  final String title;
  final bool isHindi;
  final bool isBrandSelector;
  final HomeApplianceOption currentSelected;
  final List<HomeApplianceOption> options;
  final ValueChanged<HomeApplianceOption> onSelected;

  const _OptionSelectionBottomSheet({
    required this.title,
    required this.isHindi,
    required this.isBrandSelector,
    required this.currentSelected,
    required this.options,
    required this.onSelected,
  });

  @override
  State<_OptionSelectionBottomSheet> createState() =>
      _OptionSelectionBottomSheetState();
}

class _OptionSelectionBottomSheetState
    extends State<_OptionSelectionBottomSheet> {
  late final TextEditingController _searchController;
  late final TextEditingController _textController;
  late HomeApplianceOption _selectedOption;
  late bool _showCustomInput;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();

    final isCustomValue =
        widget.currentSelected.value.toLowerCase() != 'other' &&
        widget.options.every(
          (option) =>
              option.value.toLowerCase() !=
              widget.currentSelected.value.toLowerCase(),
        );

    _textController = TextEditingController(
      text: isCustomValue ? widget.currentSelected.value : '',
    );
    _selectedOption = widget.currentSelected;
    _showCustomInput = isCustomValue;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredOptions = widget.options.where((option) {
      final label = option.value.toLowerCase();
      return _searchQuery.isEmpty || label.contains(_searchQuery.toLowerCase());
    }).toList();
    final keyboardInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: EdgeInsets.only(bottom: keyboardInset),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 8, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primarySurface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.tune_rounded,
                    color: AppTheme.primaryDark,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.primaryDark,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundCream,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Divider(color: Colors.grey.shade100, height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim();
                });
              },
              decoration: InputDecoration(
                hintText: widget.isHindi ? 'खोजें...' : 'Search brand...',
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppTheme.textSecondary,
                ),
                filled: true,
                fillColor: AppTheme.backgroundCream,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppTheme.cardBorderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppTheme.cardBorderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: AppTheme.primaryDark,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.only(bottom: 0),
              itemCount: filteredOptions.length,
              separatorBuilder: (_, __) =>
                  Divider(color: Colors.grey.shade100, height: 1),
              itemBuilder: (_, i) {
                final option = filteredOptions[i];
                final isOther = option.value.toLowerCase() == 'other';
                final isSelected = isOther
                    ? _showCustomInput ||
                          _selectedOption.value.toLowerCase() == 'other'
                    : option.value.toLowerCase() ==
                          _selectedOption.value.toLowerCase();

                return InkWell(
                  onTap: () {
                    if (isOther) {
                      setState(() {
                        _selectedOption = option;
                        _showCustomInput = true;
                      });
                    } else {
                      widget.onSelected(option);
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    color: isSelected
                        ? AppTheme.primarySurface
                        : Colors.transparent,
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? AppTheme.primaryDark
                                : Colors.transparent,
                            border: Border.all(
                              color: isSelected
                                  ? AppTheme.primaryDark
                                  : AppTheme.cardBorderColor,
                              width: 2,
                            ),
                          ),
                          child: isSelected
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 12,
                                )
                              : null,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            option.value,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: isSelected
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              color: isSelected
                                  ? AppTheme.primaryDark
                                  : AppTheme.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (filteredOptions.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                widget.isHindi
                    ? 'कोई ब्रांड नहीं मिला'
                    : 'No matching brands found',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
          if (_showCustomInput) ...[
            Divider(color: Colors.grey.shade100, height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.isHindi
                        ? 'ब्रांड का नाम दर्ज करें'
                        : widget.isBrandSelector
                        ? 'Enter Brand Name'
                        : 'Enter Custom Name',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: widget.isHindi
                          ? 'जैसे: Samsung, Sony'
                          : widget.isBrandSelector
                          ? 'e.g., Samsung, Sony'
                          : 'Enter name',
                      hintStyle: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppTheme.cardBorderColor,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppTheme.primaryDark,
                          width: 1.5,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    autofocus: true,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryDark,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        final customName = _textController.text.trim();
                        if (customName.isNotEmpty) {
                          final otherOption = widget.options.firstWhere(
                            (o) => o.value.toLowerCase() == 'other',
                          );
                          widget.onSelected(
                            HomeApplianceOption(
                              id: otherOption.id,
                              value: customName,
                            ),
                          );
                        }
                      },
                      child: Text(
                        widget.isHindi ? 'सेव करें' : 'Save',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

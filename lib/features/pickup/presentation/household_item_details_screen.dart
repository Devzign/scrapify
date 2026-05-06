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

class HouseholdItemDetailsScreen extends ConsumerStatefulWidget {
  final PickupCatalogItem item;
  final String parentCategoryName;
  final int applianceCategoryId;
  final int? parentCategoryId;

  const HouseholdItemDetailsScreen({
    super.key,
    required this.item,
    required this.parentCategoryName,
    required this.applianceCategoryId,
    this.parentCategoryId,
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

  double _displayEstimate(HomeApplianceDetails details) {
    return _liveEstimatedPrice ?? details.estimatedPrice;
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
      backgroundColor: const Color(0xFFF1EFEC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const FaIcon(
            FontAwesomeIcons.arrowLeft,
            color: AppTheme.textPrimary,
            size: 18,
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
          color: const Color(0xFFDDE6E1),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.88),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Center(
                child: _item.imageUrl.trim().isEmpty
                    ? Icon(_heroIcon, color: const Color(0xFF4A8E62), size: 42)
                    : Image.network(
                        _item.imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Icon(
                          _heroIcon,
                          color: const Color(0xFF4A8E62),
                          size: 42,
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
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF19372B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _isHindi ? 'एयर कंडीशनर' : _item.name,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF5D7368),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Base ₹${_displayEstimate(details).toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF458A5C),
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
                          color: Color(0xFF1E3A2F),
                        ),
                      ),
                      Text(
                        _hindiSubtitle(section),
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF5D7368),
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
                  color: Color(0xFF4A8E62),
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _infoText,
                    style: const TextStyle(
                      color: Color(0xFF5D7368),
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
    if (visibleOptions.isEmpty) {
      return const SizedBox.shrink();
    }

    if (_isConditionSection(section)) {
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

    if (_isBodySection(section)) {
      return Column(
        children: visibleOptions
            .map(
              (option) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _outlinedOption(
                  label: option.value,
                  isSelected: selected.id == option.id,
                  onTap: () => _updateSelection(section.slug, option),
                  fullWidth: true,
                ),
              ),
            )
            .toList(),
      );
    }

    final isCapacity = '${section.slug} ${section.title}'
        .toLowerCase()
        .contains('capacity');

    if (isCapacity) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 2.25,
        ),
        itemCount: visibleOptions.length,
        itemBuilder: (context, index) {
          final option = visibleOptions[index];
          return _outlinedOption(
            label: option.value,
            isSelected: selected.id == option.id,
            onTap: () => _updateSelection(section.slug, option),
            fullWidth: true,
          );
        },
      );
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: visibleOptions
          .map(
            (option) => _outlinedOption(
              label: option.value,
              isSelected: selected.id == option.id,
              onTap: () => _updateSelection(section.slug, option),
              fullWidth: false,
            ),
          )
          .toList(),
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
          color: isSelected ? const Color(0xFFD5E3DA) : const Color(0xFFF7FAF8),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF4A8E62)
                : const Color(0xFFC9D6CF),
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
                      ? const Color(0xFF4A8E62)
                      : const Color(0xFF1E3A2F),
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
                      ? const Color(0xFF4A8E62)
                      : const Color(0xFFC9D6CF),
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
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(30),
      ),
      child: child,
    );
  }

  Widget _buildBottomBar(HomeApplianceDetails details) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      color: const Color(0xFFF1EFEC),
      child: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FBF9),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: const Color(0xFFC9D6CF)),
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
                            color: Color(0xFF5D7368),
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
                            color: Color(0xFF458A5C),
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
                              color: const Color(0xFFDDEEE3),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF458A5C),
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
                              color: const Color(0xFFDDEEE3),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Text(
                              '✓ BEST VALUE',
                              style: TextStyle(
                                color: Color(0xFF458A5C),
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
                  text: _isHindi ? 'बास्केट में जोड़ें' : 'Add to Basket',
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

      final selected = section.options.firstWhere(
        (option) =>
            option.value.toLowerCase() ==
            (storedAttributes[section.title.toLowerCase()] ?? '').toLowerCase(),
        orElse: () => section.options.first,
      );
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
            .where((section) => _selectedOptions[section.slug] != null)
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

  bool _isConditionSection(HomeApplianceSection section) {
    final key = '${section.slug} ${section.title}'.toLowerCase();
    return key.contains('condition') ||
        section.options.any(
          (option) => option.value.toLowerCase() == 'working',
        );
  }

  bool _isBodySection(HomeApplianceSection section) {
    final key = '${section.slug} ${section.title}'.toLowerCase();
    return key.contains('body') || key.contains('mount');
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
    return Icons.local_laundry_service_rounded;
  }

  void _addToBasket(HomeApplianceDetails details) {
    final estimate = _displayEstimate(details);
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
              pricingType: _item.priceType,
              basePrice: estimate,
              imageUrl: _item.imageUrl,
              attributes: const [],
              children: const [],
            ),
            subCategoryName: widget.parentCategoryName,
            quantity: 1,
            unit: 'piece',
            pricePerUnit: estimate,
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
}

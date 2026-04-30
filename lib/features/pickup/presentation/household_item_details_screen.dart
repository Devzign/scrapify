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
import '../providers/basket_provider.dart';
import '../providers/category_provider.dart';

class HouseholdItemDetailsScreen extends ConsumerStatefulWidget {
  final PickupCatalogItem item;
  final String parentCategoryName;
  final int applianceCategoryId;

  const HouseholdItemDetailsScreen({
    super.key,
    required this.item,
    required this.parentCategoryName,
    required this.applianceCategoryId,
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
          icon: const FaIcon(
            FontAwesomeIcons.arrowLeft,
            color: AppTheme.textPrimary,
            size: 18,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          _isHindi ? 'आइटम विवरण' : 'Item Details',
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.notifications_none_rounded),
          ),
        ],
      ),
      body: detailsAsync.when(
        loading: _buildLoading,
        error: (error, _) => _buildErrorState(error.toString()),
        data: (details) {
          _ensureSelections(details);
          return Column(
            children: [
              Expanded(
                child: SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeroCard(details),
                        const SizedBox(height: 20),
                        ..._buildSections(details),
                        const SizedBox(height: 18),
                        _buildInfoCard(),
                      ],
                    ),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.cardBorderRadius,
        border: AppTheme.cardBorder,
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 1.55,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF7FAF8),
                borderRadius: BorderRadius.circular(20),
              ),
              clipBehavior: Clip.antiAlias,
              child: _item.imageUrl.trim().isEmpty
                  ? Icon(_heroIcon, color: AppTheme.primaryColor, size: 64)
                  : Image.network(
                      _item.imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Icon(
                        _heroIcon,
                        color: AppTheme.primaryColor,
                        size: 64,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            details.name.isEmpty ? _item.name : details.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _isHindi
                ? widget.parentCategoryName
                : '${widget.parentCategoryName} • ${_item.materialType}',
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSections(HomeApplianceDetails details) {
    final widgets = <Widget>[];

    for (final section in details.sections) {
      final selected = _selectedOptions[section.slug];
      if (section.options.isEmpty || selected == null) {
        continue;
      }

      if (widgets.isNotEmpty) {
        widgets.add(const SizedBox(height: 22));
      }

      widgets.add(
        _buildSectionTitle(_displayTitle(section.title, section.slug)),
      );
      widgets.add(const SizedBox(height: 12));

      if (_isConditionSection(section)) {
        widgets.add(_buildConditionSelector(section, selected));
        continue;
      }

      if (_isBodySection(section)) {
        widgets.add(
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppTheme.cardBorderRadius,
              border: AppTheme.cardBorder,
              boxShadow: AppTheme.cardShadow,
            ),
            child: Column(
              children: section.options
                  .map(
                    (option) => _buildRadioTile(
                      label: option.value,
                      isSelected: selected.id == option.id,
                      onTap: () => _updateSelection(section.slug, option),
                    ),
                  )
                  .toList(),
            ),
          ),
        );
        continue;
      }

      if (_isTypeSection(section)) {
        widgets.add(
          Row(
            children: section.options
                .asMap()
                .entries
                .map(
                  (entry) => Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: entry.key == section.options.length - 1 ? 0 : 10,
                      ),
                      child: _buildTypeCard(
                        label: entry.value.value,
                        isSelected: selected.id == entry.value.id,
                        onTap: () =>
                            _updateSelection(section.slug, entry.value),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        );
        continue;
      }

      widgets.add(
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: section.options
              .map(
                (option) => _buildChip(
                  label: option.value,
                  isSelected: selected.id == option.id,
                  onTap: () => _updateSelection(section.slug, option),
                ),
              )
              .toList(),
        ),
      );
    }

    return widgets;
  }

  Widget _buildBottomBar(HomeApplianceDetails details) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isHindi ? 'अनुमानित मूल्य' : 'ESTIMATED PRICE',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹ ${details.estimatedPrice.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 32,
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w900,
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
                  child: Text(
                    _isHindi ? 'बेस्ट वैल्यू' : 'Best Value',
                    style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
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
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5FBF6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD9EEDF)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppTheme.primaryColor,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _infoText,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w900,
        color: AppTheme.textPrimary,
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : const Color(0xFFE6ECF1),
          ),
          boxShadow: isSelected ? null : AppTheme.softShadow,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildTypeCard({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 18),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : const Color(0xFFE6ECF1),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? null : AppTheme.softShadow,
        ),
        child: Column(
          children: [
            Icon(
              _typeIcon(label),
              color: isSelected ? Colors.white : AppTheme.textSecondary,
              size: 22,
            ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: isSelected ? Colors.white : AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioTile({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? Colors.white : AppTheme.textPrimary,
                ),
              ),
            ),
            Icon(
              isSelected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: isSelected ? Colors.white : const Color(0xFFCBD5E1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConditionSelector(
    HomeApplianceSection section,
    HomeApplianceOption selected,
  ) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.cardBorderRadius,
        border: AppTheme.cardBorder,
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(
        children: section.options
            .map(
              (option) => Expanded(
                child: GestureDetector(
                  onTap: () => _updateSelection(section.slug, option),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: selected.id == option.id
                          ? AppTheme.primaryColor
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      _localizedCondition(option.value),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: selected.id == option.id
                            ? Colors.white
                            : AppTheme.textSecondary,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
            )
            .toList(),
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
  }

  void _updateSelection(String slug, HomeApplianceOption option) {
    setState(() {
      _selectedOptions[slug] = option;
    });
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

  bool _isTypeSection(HomeApplianceSection section) {
    final key = '${section.slug} ${section.title}'.toLowerCase();
    return key.contains('type') ||
        key.contains('door') ||
        key.contains('display') ||
        key.contains('machine');
  }

  String _displayTitle(String title, String slug) {
    if (!_isHindi) {
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
      return 'वर्तमान स्थिति';
    }
    if (key.contains('body')) {
      return 'बॉडी का प्रकार';
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

  IconData _typeIcon(String label) {
    final normalized = label.toLowerCase();
    if (normalized.contains('double') || normalized.contains('side')) {
      return Icons.view_week_rounded;
    }
    if (normalized.contains('single')) {
      return Icons.crop_portrait_rounded;
    }
    if (normalized.contains('front')) {
      return Icons.local_laundry_service_rounded;
    }
    if (normalized.contains('semi')) {
      return Icons.tune_rounded;
    }
    if (normalized.contains('led') || normalized.contains('lcd')) {
      return Icons.tv_rounded;
    }
    if (normalized.contains('smart')) {
      return Icons.smart_display_rounded;
    }
    if (normalized.contains('grill') || normalized.contains('convection')) {
      return Icons.microwave_rounded;
    }
    return Icons.vertical_align_top_rounded;
  }

  void _addToBasket(HomeApplianceDetails details) {
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
              basePrice: details.estimatedPrice,
              imageUrl: _item.imageUrl,
              attributes: const [],
              children: const [],
            ),
            subCategoryName: widget.parentCategoryName,
            quantity: 1,
            unit: 'piece',
            pricePerUnit: details.estimatedPrice,
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

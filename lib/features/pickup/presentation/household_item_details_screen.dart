import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_routes.dart';
import '../domain/models/basket_item.dart';
import '../domain/models/category.dart';
import '../domain/models/pickup_catalog_item.dart';
import '../providers/basket_provider.dart';

class HouseholdItemDetailsScreen extends ConsumerStatefulWidget {
  final PickupCatalogItem item;
  final String parentCategoryName;

  const HouseholdItemDetailsScreen({
    super.key,
    required this.item,
    required this.parentCategoryName,
  });

  @override
  ConsumerState<HouseholdItemDetailsScreen> createState() =>
      _HouseholdItemDetailsScreenState();
}

class _HouseholdItemDetailsScreenState
    extends ConsumerState<HouseholdItemDetailsScreen> {
  late String _selectedBrand;
  late String _selectedCapacity;
  late String _selectedCondition;
  String? _selectedType;
  String? _selectedBodyType;

  @override
  void initState() {
    super.initState();
    _selectedBrand = _brandOptions.first;
    _selectedCapacity = _capacityOptions.first;
    _selectedCondition = 'Working';
    _selectedType = _typeOptions.isNotEmpty ? _typeOptions.first : null;
    _selectedBodyType = _bodyTypeOptions.isNotEmpty
        ? _bodyTypeOptions.first
        : null;
  }

  PickupCatalogItem get _item => widget.item;

  bool get _isAirConditioner {
    final name = _item.name.toLowerCase();
    return name.contains('ac') || name.contains('air conditioner');
  }

  bool get _isRefrigerator {
    return _item.name.toLowerCase().contains('refrigerator');
  }

  bool get _isWashingMachine {
    return _item.name.toLowerCase().contains('washing machine');
  }

  bool get _isTelevision {
    final name = _item.name.toLowerCase();
    return name.contains('television') || name.contains('tv');
  }

  bool get _isMicrowave {
    return _item.name.toLowerCase().contains('microwave');
  }

  List<String> get _brandOptions {
    if (_isAirConditioner) {
      return ['Voltas', 'LG', 'Samsung', 'Daikin', 'Blue Star'];
    }
    if (_isRefrigerator) {
      return ['LG', 'Samsung', 'Whirlpool', 'Haier', 'Godrej', 'Others'];
    }
    if (_isTelevision) {
      return ['Sony', 'Samsung', 'LG', 'Mi', 'Panasonic', 'Others'];
    }
    if (_isMicrowave) {
      return ['IFB', 'LG', 'Samsung', 'Whirlpool', 'Godrej', 'Others'];
    }
    return ['LG', 'Samsung', 'Whirlpool', 'IFB', 'Others'];
  }

  List<String> get _capacityOptions {
    if (_isAirConditioner) {
      return ['1 Ton', '1.5 Ton', '2 Ton', '2 Ton+'];
    }
    if (_isRefrigerator) {
      return ['190L', '250L', '350L', '500L+'];
    }
    if (_isTelevision) {
      return ['24"', '32"', '43"', '55"+'];
    }
    if (_isMicrowave) {
      return ['20L', '25L', '30L', '35L+'];
    }
    return ['6kg', '7kg', '8kg', '9kg+'];
  }

  List<String> get _typeOptions {
    if (_isRefrigerator) {
      return ['Single', 'Double', 'Side-by-Side'];
    }
    if (_isWashingMachine) {
      return ['Top Load', 'Front Load', 'Semi-Automatic'];
    }
    if (_isTelevision) {
      return ['LED', 'LCD', 'Smart TV'];
    }
    if (_isMicrowave) {
      return ['Solo', 'Grill', 'Convection'];
    }
    return const <String>[];
  }

  List<String> get _bodyTypeOptions {
    if (_isAirConditioner || _isWashingMachine) {
      return ['Metal Body', 'Plastic Body'];
    }
    if (_isTelevision) {
      return ['Wall Mounted', 'Table Stand'];
    }
    return const <String>[];
  }

  double get _estimatedPrice {
    double total = _item.price * _capacityMultiplier;
    total *= _conditionMultiplier;
    total += _brandBonus;
    total += _typeBonus;
    total += _bodyTypeBonus;
    return total;
  }

  double get _capacityMultiplier {
    if (_isAirConditioner) {
      switch (_selectedCapacity) {
        case '1 Ton':
          return 42;
        case '1.5 Ton':
          return 50;
        case '2 Ton':
          return 58;
        default:
          return 64;
      }
    }
    if (_isRefrigerator) {
      switch (_selectedCapacity) {
        case '190L':
          return 40;
        case '250L':
          return 48;
        case '350L':
          return 56;
        default:
          return 66;
      }
    }
    if (_isTelevision) {
      switch (_selectedCapacity) {
        case '24"':
          return 24;
        case '32"':
          return 31;
        case '43"':
          return 40;
        default:
          return 52;
      }
    }
    if (_isMicrowave) {
      switch (_selectedCapacity) {
        case '20L':
          return 18;
        case '25L':
          return 23;
        case '30L':
          return 28;
        default:
          return 34;
      }
    }
    switch (_selectedCapacity) {
      case '6kg':
        return 34;
      case '7kg':
        return 38;
      case '8kg':
        return 42;
      default:
        return 48;
    }
  }

  double get _conditionMultiplier {
    return _selectedCondition == 'Working' ? 1.0 : 0.76;
  }

  double get _brandBonus {
    const premiumBrands = {'LG', 'Samsung', 'Daikin', 'Voltas'};
    return premiumBrands.contains(_selectedBrand) ? 180 : 0;
  }

  double get _typeBonus {
    if (_selectedType == 'Double' || _selectedType == 'Front Load') {
      return 220;
    }
    if (_selectedType == 'Side-by-Side') {
      return 420;
    }
    if (_selectedType == 'Smart TV' || _selectedType == 'Convection') {
      return 260;
    }
    if (_selectedType == 'LED' || _selectedType == 'Grill') {
      return 120;
    }
    return 0;
  }

  double get _bodyTypeBonus {
    if (_selectedBodyType == 'Metal Body') {
      return 120;
    }
    if (_selectedBodyType == 'Wall Mounted') {
      return 80;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
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
          context.locale.languageCode == 'hi' ? 'आइटम विवरण' : 'Item Details',
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
      bottomNavigationBar: _buildBottomBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: AppTheme.softShadow,
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
                            ? Icon(
                                _heroIcon,
                                color: AppTheme.primaryColor,
                                size: 64,
                              )
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
                      _item.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.locale.languageCode == 'hi'
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
              ),
              const SizedBox(height: 20),
              _buildSectionTitle(
                context.locale.languageCode == 'hi'
                    ? 'ब्रांड चुनें'
                    : 'Select Brand',
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _brandOptions
                    .map(
                      (brand) => _buildChip(
                        label: brand,
                        isSelected: _selectedBrand == brand,
                        onTap: () => setState(() => _selectedBrand = brand),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 22),
              if (_typeOptions.isNotEmpty) ...[
                _buildSectionTitle(_localizedTypeSectionTitle),
                const SizedBox(height: 12),
                Row(
                  children: _typeOptions
                      .map(
                        (type) => Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: type == _typeOptions.last ? 0 : 10,
                            ),
                            child: _buildTypeCard(
                              label: type,
                              isSelected: _selectedType == type,
                              onTap: () => setState(() => _selectedType = type),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 22),
              ],
              _buildSectionTitle(
                context.locale.languageCode == 'hi'
                    ? _localizedCapacityTitleHi
                    : _isRefrigerator
                    ? 'Capacity (Liters)'
                    : _isTelevision
                    ? 'Screen Size (Inch)'
                    : _isMicrowave
                    ? 'Capacity (Liters)'
                    : _isWashingMachine
                    ? 'Capacity (kg)'
                    : 'Capacity (Tons)',
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _capacityOptions
                    .map(
                      (capacity) => _buildChip(
                        label: capacity,
                        isSelected: _selectedCapacity == capacity,
                        onTap: () =>
                            setState(() => _selectedCapacity = capacity),
                      ),
                    )
                    .toList(),
              ),
              if (_bodyTypeOptions.isNotEmpty) ...[
                const SizedBox(height: 22),
                _buildSectionTitle(_localizedBodySectionTitle),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: AppTheme.softShadow,
                  ),
                  child: Column(
                    children: _bodyTypeOptions
                        .map(
                          (bodyType) => _buildRadioTile(
                            label: bodyType,
                            isSelected: _selectedBodyType == bodyType,
                            onTap: () =>
                                setState(() => _selectedBodyType = bodyType),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
              const SizedBox(height: 22),
              _buildSectionTitle(
                context.locale.languageCode == 'hi'
                    ? 'वर्तमान स्थिति'
                    : 'Current Condition',
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: AppTheme.softShadow,
                ),
                child: Row(
                  children: ['Working', 'Non-Working']
                      .map(
                        (condition) => Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _selectedCondition = condition),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: _selectedCondition == condition
                                    ? AppTheme.primaryColor
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Text(
                                _localizedConditionLabel(condition),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: _selectedCondition == condition
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
              ),
              const SizedBox(height: 18),
              Container(
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
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
                        context.locale.languageCode == 'hi'
                            ? 'अनुमानित मूल्य'
                            : 'ESTIMATED PRICE',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹ ${_estimatedPrice.toStringAsFixed(0)}',
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
                    context.locale.languageCode == 'hi'
                        ? 'बेस्ट वैल्यू'
                        : 'Best Value',
                    style: TextStyle(
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
              child: ElevatedButton.icon(
                onPressed: _addToBasket,
                icon: const FaIcon(FontAwesomeIcons.basketShopping, size: 16),
                label: Text(
                  context.locale.languageCode == 'hi'
                      ? 'बास्केट में जोड़ें'
                      : 'Add to Basket',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
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
          color: isSelected ? const Color(0xFFEAF8EC) : Colors.white,
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
              color: isSelected
                  ? AppTheme.primaryColor
                  : AppTheme.textSecondary,
              size: 22,
            ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
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
          color: isSelected ? const Color(0xFFEAF8EC) : Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            Icon(
              isSelected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: isSelected
                  ? AppTheme.primaryColor
                  : const Color(0xFFCBD5E1),
            ),
          ],
        ),
      ),
    );
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
    return Icons.vertical_align_top_rounded;
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

  String get _typeSectionTitle {
    if (_isRefrigerator) {
      return 'Door Type';
    }
    if (_isWashingMachine) {
      return 'Machine Type';
    }
    if (_isTelevision) {
      return 'Display Type';
    }
    if (_isMicrowave) {
      return 'Microwave Type';
    }
    return 'Type';
  }

  String get _localizedTypeSectionTitle {
    return _isHindi ? _typeSectionSubtitle : _typeSectionTitle;
  }

  String get _typeSectionSubtitle {
    if (_isRefrigerator) {
      return 'दरवाज़े का प्रकार';
    }
    if (_isWashingMachine) {
      return 'मशीन का प्रकार';
    }
    if (_isTelevision) {
      return 'डिस्प्ले प्रकार';
    }
    if (_isMicrowave) {
      return 'माइक्रोवेव प्रकार';
    }
    return 'प्रकार';
  }

  String get _bodySectionTitle {
    if (_isTelevision) {
      return 'Mount Type';
    }
    return 'Body Type';
  }

  String get _localizedBodySectionTitle {
    return _isHindi ? _bodySectionSubtitle : _bodySectionTitle;
  }

  String get _bodySectionSubtitle {
    if (_isTelevision) {
      return 'फिटिंग का प्रकार';
    }
    return 'बॉडी का प्रकार';
  }

  String get _localizedCapacityTitleHi {
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

  bool get _isHindi => context.locale.languageCode == 'hi';

  String _localizedConditionLabel(String value) {
    if (!_isHindi) {
      return value;
    }
    return value == 'Working' ? 'वर्किंग' : 'नॉन-वर्किंग';
  }

  void _addToBasket() {
    ref
        .read(basketProvider.notifier)
        .addItem(
          BasketItem(
            category: Category(
              id: _item.id,
              name: LocalizedName(en: _item.name, hi: _item.name),
              slug: _item.name.toLowerCase().replaceAll(' ', '-'),
              pricingType: _item.priceType,
              basePrice: _estimatedPrice,
              imageUrl: _item.imageUrl,
              attributes: const [],
              children: const [],
            ),
            subCategoryName: widget.parentCategoryName,
            quantity: 1,
            unit: 'piece',
            pricePerUnit: _estimatedPrice,
            selectedAttributes: [
              SelectedAttribute(name: 'Brand', value: _selectedBrand),
              SelectedAttribute(name: 'Capacity', value: _selectedCapacity),
              SelectedAttribute(name: 'Condition', value: _selectedCondition),
              if (_selectedType != null)
                SelectedAttribute(name: 'Type', value: _selectedType!),
              if (_selectedBodyType != null)
                SelectedAttribute(name: 'Body Type', value: _selectedBodyType!),
            ],
          ),
        );

    context.push(AppRoutes.basket);
  }
}

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_color.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_routes.dart';
import '../../../core/widgets/custom_button.dart';
import '../domain/models/category.dart';
import '../domain/models/corporate_booking_option.dart';
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
  String _selectedUnit = 'kg';
  int? _selectedCategoryTypeId;
  Category? _selectedSubcategory;
  late final TextEditingController _qtyController;

  @override
  void initState() {
    super.initState();
    _qtyController = TextEditingController();
    Future.microtask(() => ref.read(corporateBookingProvider.notifier).reset());
  }

  @override
  void dispose() {
    _qtyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isHindi = context.locale.languageCode == 'hi';
    final booking = ref.watch(corporateBookingProvider);
    final categoryOptionsAsync = ref.watch(corporateBookingOptionsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      ),
      body: Column(
        children: [
          _buildHeaderSection(
            _selectedSubcategory?.getName(context) ?? '',
            isHindi,
            context,
          ),
          Expanded(
            child: categoryOptionsAsync.when(
              data: (options) {
                final categoryTypes = options.groups;
                if (_selectedCategoryTypeId == null &&
                    categoryTypes.isNotEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted && _selectedCategoryTypeId == null) {
                      setState(
                        () => _selectedCategoryTypeId = categoryTypes.first.id,
                      );
                    }
                  });
                }

                final selectedTypeId =
                    _selectedCategoryTypeId ??
                    (categoryTypes.isNotEmpty ? categoryTypes.first.id : null);
                if (selectedTypeId == null) {
                  return _emptyState(
                    isHindi
                        ? 'कोई कॉर्पोरेट श्रेणी उपलब्ध नहीं है'
                        : 'No corporate categories available',
                  );
                }

                final selectedType = categoryTypes.firstWhere(
                  (group) => group.id == selectedTypeId,
                  orElse: () => categoryTypes.first,
                );
                final subcategories = selectedType.subcategories;
                if ((_selectedSubcategory == null ||
                        !subcategories.any(
                          (cat) => cat.id == _selectedSubcategory!.id,
                        )) &&
                    subcategories.isNotEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!mounted) return;
                    setState(() => _selectedSubcategory = subcategories.first);
                  });
                }

                return _buildBody(
                  booking,
                  isHindi,
                  categoryTypes,
                  subcategories,
                  selectedTypeId,
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => _emptyState(error.toString()),
            ),
          ),
          _buildBottomBar(context, booking, isHindi),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(
    String selectedCategory,
    bool isHindi,
    BuildContext context,
  ) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A5C35), AppColor.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
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
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            selectedCategory.isEmpty ? '---' : selectedCategory,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isHindi
                ? 'श्रेणी चुनें, मात्रा जोड़ें और पिकअप शेड्यूल करें'
                : 'Choose category, add quantity and schedule pickup',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(
    CorporateBookingState booking,
    bool isHindi,
    List<CorporateCategoryGroup> categoryTypes,
    List<Category> subcategories,
    int selectedTypeId,
  ) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.hintPeach,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.warningColor),
          ),
          child: Text(
            isHindi
                ? 'कोटेशन पिकअप के समय होगा।'
                : 'Quotation will be provided at pickup.',
            style: const TextStyle(
              color: AppTheme.warningColor,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Corporate Category *',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  key: ValueKey('corp_type_$selectedTypeId'),
                  initialValue: selectedTypeId,
                  decoration: _inputDecoration(''),
                  items: categoryTypes
                      .map(
                        (cat) => DropdownMenuItem<int>(
                          value: cat.id,
                          child: Text(cat.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedCategoryTypeId = value;
                        _selectedSubcategory = null;
                      });
                    }
                  },
                  icon: const Icon(Icons.keyboard_arrow_down_rounded),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Corporate Item *',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  key: ValueKey('corp_sub_${_selectedSubcategory?.id ?? 0}'),
                  initialValue:
                      _selectedSubcategory != null &&
                          subcategories.any(
                            (cat) => cat.id == _selectedSubcategory!.id,
                          )
                      ? _selectedSubcategory!.id
                      : null,
                  decoration: _inputDecoration(
                    subcategories.isEmpty
                        ? (isHindi
                              ? 'कोई उप-श्रेणी उपलब्ध नहीं है'
                              : 'No sub-category available')
                        : '',
                  ),
                  items: subcategories
                      .map(
                        (cat) => DropdownMenuItem<int>(
                          value: cat.id,
                          child: Text(cat.getName(context)),
                        ),
                      )
                      .toList(),
                  onChanged: subcategories.isEmpty
                      ? null
                      : (value) {
                          if (value == null) return;
                          setState(
                            () => _selectedSubcategory = subcategories
                                .firstWhere((cat) => cat.id == value),
                          );
                        },
                  icon: const Icon(Icons.keyboard_arrow_down_rounded),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _qtyController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: _inputDecoration(
                          isHindi ? 'मात्रा दर्ज करें *' : 'Enter quantity *',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _unitButton('kg'),
                    const SizedBox(width: 6),
                    _unitButton('qns'),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _addCorporateCategoryEntry,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(48),
                      side: const BorderSide(color: AppTheme.primaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(isHindi ? 'श्रेणी जोड़ें' : 'Add Category'),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  isHindi ? 'चुने गए आइटम' : 'Selected Items',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                if (booking.corporateEntries.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.primaryColor.withValues(alpha: 0.28),
                      ),
                    ),
                    child: Text(
                      isHindi
                          ? 'अभी तक कोई आइटम नहीं जोड़ा गया'
                          : 'No items added yet',
                      style: const TextStyle(color: AppTheme.textMuted),
                    ),
                  ),
                ...booking.corporateEntries.asMap().entries.map((entry) {
                  final i = entry.key;
                  final item = entry.value;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.outline),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${item.category} - ${item.quantity % 1 == 0 ? item.quantity.toInt() : item.quantity} ${item.unit}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => ref
                              .read(corporateBookingProvider.notifier)
                              .removeCorporateEntryAt(i),
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      hintText: label.isEmpty ? null : label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5),
      ),
    );
  }

  Widget _unitButton(String unit) {
    final selected = _selectedUnit == unit;
    return InkWell(
      onTap: () => setState(() => _selectedUnit = unit),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 52,
        width: 62,
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppTheme.primaryColor : AppTheme.outline,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          unit,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  void _addCorporateCategoryEntry() {
    final category = _selectedSubcategory;
    final quantity = double.tryParse(_qtyController.text.trim()) ?? 0;
    if (category == null || quantity <= 0) return;

    ref
        .read(corporateBookingProvider.notifier)
        .addCorporateEntry(
          category.getName(context),
          quantity,
          _selectedUnit,
          categoryId: category.id,
        );

    setState(() {
      _qtyController.clear();
      _selectedUnit = 'kg';
    });
  }

  Widget _emptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppTheme.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(
    BuildContext context,
    CorporateBookingState booking,
    bool isHindi,
  ) {
    final itemCount = booking.corporateEntries.length;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
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
        child: SizedBox(
          width: double.infinity,
          child: CustomButton(
            onPressed: itemCount > 0
                ? () => context.push(AppRoutes.corporateSchedule)
                : null,
            text: isHindi ? 'पिकअप शेड्यूल करें' : 'SCHEDULE PICKUP',
            minHeight: 56,
            borderRadius: 16,
          ),
        ),
      ),
    );
  }
}

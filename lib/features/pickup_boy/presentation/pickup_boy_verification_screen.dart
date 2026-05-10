import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../pickup/domain/models/category.dart';
import '../../pickup/domain/models/pickup_catalog_item.dart';
import '../../pickup/providers/category_provider.dart';
import '../../pickup/presentation/household_item_details_screen.dart';
import '../../../core/theme/app_color.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/custom_button.dart';
import '../domain/models/pickup_item.dart';
import '../providers/pickup_boy_provider.dart';

class PickupBoyVerificationScreen extends ConsumerStatefulWidget {
  final int pickupId;
  const PickupBoyVerificationScreen({super.key, required this.pickupId});

  @override
  ConsumerState<PickupBoyVerificationScreen> createState() =>
      _PickupBoyVerificationScreenState();
}

class _PickupBoyVerificationScreenState
    extends ConsumerState<PickupBoyVerificationScreen> {
  List<PickupItem> _items = [];
  final List<File> _images = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    final repo = ref.read(pickupBoyRepositoryProvider);
    final result = await repo.getPickupDetail(widget.pickupId);
    if (mounted && result.isSuccess) {
      final data = result.data!;
      final itemsJson = data['items'] as List<dynamic>? ?? [];
      setState(() {
        _loading = false;
        _items = itemsJson
            .whereType<Map<String, dynamic>>()
            .map((j) => PickupItem.fromJson({...j, 'action': 'updated'}))
            .toList();
      });
    } else if (mounted) {
      setState(() => _loading = false);
    }
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage(imageQuality: 70);
    if (picked.isNotEmpty) {
      setState(() {
        _images.addAll(picked.map((x) => File(x.path)));
      });
    }
  }

  Future<void> _addItem() async {
    final item = await Navigator.of(context).push<PickupItem>(
      MaterialPageRoute(
        builder: (_) => const _AddItemPage(),
      ),
    );
    if (item != null && mounted) {
      setState(() => _items.add(item));
    }
  }

  void _removeItem(int index) {
    setState(() {
      final item = _items[index];
      if (item.id != null) {
        _items[index] = item.copyWith(action: 'removed');
      } else {
        _items.removeAt(index);
      }
    });
  }

  Future<void> _submitVerification() async {
    if (_images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one verification photo'),
        ),
      );
      return;
    }

    // Re-validate every active item so we don't post bad data.
    final activeItems = _items.where((i) => i.action != 'removed').toList();
    if (activeItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one item before submitting.')),
      );
      return;
    }
    for (final item in activeItems) {
      if (item.itemName.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Every item needs a name.')),
        );
        return;
      }
      final w = item.weight;
      if (w == null || w <= 0 || w > 10000) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"${item.itemName}" needs a valid weight (kg).'),
          ),
        );
        return;
      }
      final q = item.quantity;
      if (q == null || q <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '"${item.itemName}" needs a valid quantity.',
            ),
          ),
        );
        return;
      }
      final r = item.ratePerKg;
      if (r == null || r < 0 || r > 100000) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '"${item.itemName}" needs a valid rate per kg.',
            ),
          ),
        );
        return;
      }
    }

    final result = await ref
        .read(pickupBoyProvider.notifier)
        .verifyPickup(widget.pickupId, _items, _images);

    if (result != null && mounted) {
      final finalPayout = result['final_payout'] ?? result['final_amount'];
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radius2xl),
          ),
          title: const Text(
            'Verification Complete!',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: AppColor.textPrimary,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColor.successTint,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColor.success,
                  size: 44,
                ),
              ),
              if (finalPayout != null) ...[
                const SizedBox(height: AppTheme.space16),
                Text(
                  'Final Amount: ₹$finalPayout',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColor.textPrimary,
                  ),
                ),
              ],
            ],
          ),
          actions: [
            CustomButton(
              text: 'Done',
              variant: AppButtonVariant.primary,
              onPressed: () {
                ctx.pop();
                context.pop();
                context.pop();
              },
            ),
          ],
        ),
      );
    } else if (mounted) {
      final error = ref.read(pickupBoyProvider).error;
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
        ref.read(pickupBoyProvider.notifier).clearError();
      }
    }
  }

  double _grandTotal(List<PickupItem> items) {
    double total = 0;
    for (final item in items) {
      final weight = item.weight ?? 0;
      final qty = item.quantity ?? 0;
      final rate = item.ratePerKg ?? 0;
      total += weight * qty * rate;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pickupBoyProvider);
    final activeItems = _items.where((i) => i.action != 'removed').toList();

    return AppScaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Verify Items',
          style: TextStyle(
            color: AppColor.textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 17,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: AppColor.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionTitle(
                    title: 'Items',
                    trailing: TextButton.icon(
                      onPressed: _addItem,
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('Add Item'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColor.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.space8),
                  ...activeItems.asMap().entries.map((entry) {
                    final idx = _items.indexOf(entry.value);
                    return _ItemCard(
                      item: entry.value,
                      onUpdate: (updated) {
                        setState(() => _items[idx] = updated);
                      },
                      onRemove: () => _removeItem(idx),
                    );
                  }),
                  if (activeItems.isNotEmpty) ...[
                    const SizedBox(height: AppTheme.space4),
                    AppCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.space12,
                        vertical: AppTheme.space12,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Grand Total',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColor.textPrimary,
                            ),
                          ),
                          Text(
                            '₹${_grandTotal(activeItems).toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: AppColor.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: AppTheme.space20),
                  _SectionTitle(
                    title: 'Verification Photos',
                    trailing: TextButton.icon(
                      onPressed: _pickImages,
                      icon: const FaIcon(FontAwesomeIcons.camera, size: 13),
                      label: const Text('Add Photos'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColor.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.space8),
                  if (_images.isNotEmpty)
                    SizedBox(
                      height: 100,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _images.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (ctx, idx) => Stack(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(AppTheme.radiusMd),
                                border: Border.all(color: AppColor.cardBorder),
                                image: DecorationImage(
                                  image: FileImage(_images[idx]),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _images.removeAt(idx)),
                                child: Container(
                                  width: 22,
                                  height: 22,
                                  alignment: Alignment.center,
                                  decoration: const BoxDecoration(
                                    color: AppColor.error,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close_rounded,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    GestureDetector(
                      onTap: _pickImages,
                      child: Container(
                        width: double.infinity,
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppColor.backgroundCream,
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusLg),
                          border: Border.all(
                            color: AppColor.outline,
                            width: 1.2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColor.primarySurface,
                                shape: BoxShape.circle,
                              ),
                              child: const FaIcon(
                                FontAwesomeIcons.camera,
                                color: AppColor.primary,
                                size: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Tap to add photos',
                              style: TextStyle(
                                color: AppColor.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
      bottomBar: state.isActionLoading
          ? const SizedBox(
              height: 50,
              child: Center(child: CircularProgressIndicator()),
            )
          : CustomButton(
              text: 'Submit Verification',
              variant: AppButtonVariant.primary,
              onPressed: _submitVerification,
            ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final Widget? trailing;
  const _SectionTitle({required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColor.textPrimary,
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _ItemCard extends StatefulWidget {
  final PickupItem item;
  final ValueChanged<PickupItem> onUpdate;
  final VoidCallback onRemove;

  const _ItemCard({
    required this.item,
    required this.onUpdate,
    required this.onRemove,
  });

  @override
  State<_ItemCard> createState() => _ItemCardState();
}

class _ItemCardState extends State<_ItemCard> {
  late TextEditingController _weightCtrl;
  late TextEditingController _qtyCtrl;
  late TextEditingController _rateCtrl;
  String _condition = 'working';

  @override
  void initState() {
    super.initState();
    _weightCtrl = TextEditingController(
      text: widget.item.weight?.toString() ?? '',
    );
    _qtyCtrl = TextEditingController(
      text: widget.item.quantity?.toString() ?? '',
    );
    _rateCtrl = TextEditingController(
      text: widget.item.ratePerKg?.toString() ?? '',
    );
    _condition = (widget.item.condition?.trim().isNotEmpty ?? false)
        ? widget.item.condition!.trim().toLowerCase()
        : 'working';
  }

  @override
  void dispose() {
    _weightCtrl.dispose();
    _qtyCtrl.dispose();
    _rateCtrl.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      isDense: true,
      filled: true,
      fillColor: AppColor.surface,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 12,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        borderSide: const BorderSide(color: AppColor.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        borderSide: const BorderSide(color: AppColor.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        borderSide: const BorderSide(color: AppColor.primary, width: 1.4),
      ),
      labelStyle: const TextStyle(
        color: AppColor.textSecondary,
        fontSize: 12,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.space12),
      child: AppCard(
        padding: const EdgeInsets.all(AppTheme.space12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.item.itemName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: AppColor.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppColor.error,
                  ),
                  onPressed: widget.onRemove,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.space12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _weightCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                      LengthLimitingTextInputFormatter(7),
                    ],
                    decoration: _fieldDecoration('Weight (kg)'),
                    onChanged: (v) => widget.onUpdate(
                      widget.item.copyWith(weight: double.tryParse(v)),
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.space12),
                Expanded(
                  child: TextField(
                    controller: _qtyCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(5),
                    ],
                    decoration: _fieldDecoration('Quantity'),
                    onChanged: (v) => widget.onUpdate(
                      widget.item.copyWith(quantity: int.tryParse(v)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.space12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _condition,
                    items: const [
                      DropdownMenuItem(value: 'working', child: Text('Working')),
                      DropdownMenuItem(
                        value: 'refurbished',
                        child: Text('Refurbished'),
                      ),
                      DropdownMenuItem(value: 'damaged', child: Text('Damaged')),
                      DropdownMenuItem(value: 'scrap', child: Text('Scrap')),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _condition = value);
                      widget.onUpdate(widget.item.copyWith(condition: value));
                    },
                    decoration: _fieldDecoration('Condition'),
                  ),
                ),
                const SizedBox(width: AppTheme.space12),
                Expanded(
                  child: TextField(
                    controller: _rateCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                      LengthLimitingTextInputFormatter(8),
                    ],
                    decoration: _fieldDecoration('Rate (per kg)'),
                    onChanged: (v) => widget.onUpdate(
                      widget.item.copyWith(ratePerKg: double.tryParse(v)),
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
}

class _AddItemPage extends ConsumerStatefulWidget {
  const _AddItemPage();

  @override
  ConsumerState<_AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends ConsumerState<_AddItemPage> {
  final _nameCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController();
  final _rateCtrl = TextEditingController();
  final _searchCtrl = TextEditingController();
  String _condition = 'working';
  Category? _selectedCategory;
  Category? _selectedSubCategory;
  int? _selectedSubCategoryId;
  bool _showSubCategories = false;
  bool _conditionFromDetailsFlow = false;

  @override
  void initState() {
    super.initState();
    // Always refetch when opening this page.
    Future.microtask(() => ref.invalidate(categoriesProvider));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _weightCtrl.dispose();
    _qtyCtrl.dispose();
    _rateCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      isDense: true,
      filled: true,
      fillColor: AppColor.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        borderSide: const BorderSide(color: AppColor.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        borderSide: const BorderSide(color: AppColor.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        borderSide: const BorderSide(color: AppColor.primary, width: 1.4),
      ),
      labelStyle: const TextStyle(
        color: AppColor.textSecondary,
        fontSize: 13,
      ),
    );
  }

  void _saveItem() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item name is required.')),
      );
      return;
    }
    if (name.length > 80) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item name is too long.')),
      );
      return;
    }

    final weight = double.tryParse(_weightCtrl.text.trim());
    if (weight == null || weight <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid weight (kg).')),
      );
      return;
    }
    if (weight > 10000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Weight is too large.')),
      );
      return;
    }

    final qty = int.tryParse(_qtyCtrl.text.trim());
    if (qty == null || qty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quantity must be a positive whole number.')),
      );
      return;
    }

    final rate = double.tryParse(_rateCtrl.text.trim());
    if (rate == null || rate < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid rate per kg.')),
      );
      return;
    }
    if (rate > 100000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rate is unreasonably large.')),
      );
      return;
    }

    final item = PickupItem(
      itemId: _selectedSubCategoryId,
      itemName: name,
      weight: weight,
      quantity: qty,
      condition: _condition,
      ratePerKg: rate,
      action: 'added',
    );
    Navigator.of(context).pop(item);
  }

  double _estimateTotal() {
    final weight = double.tryParse(_weightCtrl.text.trim()) ?? 0;
    final qty = int.tryParse(_qtyCtrl.text.trim()) ?? 0;
    final rate = double.tryParse(_rateCtrl.text.trim()) ?? 0;
    return weight * qty * rate;
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final subCategoriesAsync = _selectedCategory == null
        ? null
        : ref.watch(subCategoriesProvider(_selectedCategory!.id));
    final query = _searchCtrl.text.trim().toLowerCase();

    return AppScaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Add New Item',
          style: TextStyle(
            color: AppColor.textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 17,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColor.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 104),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _searchCtrl,
              onChanged: (_) => setState(() {}),
              decoration: _fieldDecoration(
                _showSubCategories
                    ? 'Search sub-categories...'
                    : 'Find metal, paper, e-waste, plastic...',
              ).copyWith(prefixIcon: const Icon(Icons.search_rounded)),
            ),
            const SizedBox(height: AppTheme.space12),
            if (_showSubCategories && _selectedCategory != null)
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  _selectedCategory!.getName(context),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColor.textPrimary,
                  ),
                ),
              ),
            if (!_showSubCategories)
              categoriesAsync.when(
                data: (categories) {
                  final filtered = categories
                      .where(
                        (c) =>
                            query.isEmpty ||
                            c.name.en.toLowerCase().contains(query) ||
                            c.name.hi.toLowerCase().contains(query),
                      )
                      .toList();
                  return Column(
                    children: filtered.map((c) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                          onTap: () {
                            setState(() {
                              _selectedCategory = c;
                              _showSubCategories = true;
                              _searchCtrl.clear();
                            });
                            ref.invalidate(subCategoriesProvider(c.id));
                          },
                          child: AppCard(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color: AppColor.primarySurface,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: c.imageUrl.isNotEmpty
                                      ? Image.network(
                                          c.imageUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => const Icon(Icons.category_rounded),
                                        )
                                      : const Icon(Icons.category_rounded),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        c.getName(context),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                          color: AppColor.textPrimary,
                                          height: 1.25,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      const Text(
                                        'Tap to explore sub-categories',
                                        style: TextStyle(
                                          color: AppColor.textSecondary,
                                          fontSize: 11,
                                          height: 1.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_right_rounded,
                                  color: AppColor.primary,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: LinearProgressIndicator(minHeight: 2),
                ),
                error: (err, __) => _buildErrorCard(
                  message: 'Failed to load categories.\n$err',
                  onRetry: () => ref.invalidate(categoriesProvider),
                ),
              ),
            if (_showSubCategories)
              _buildSubCategoryList(subCategoriesAsync, query),
            if (_selectedSubCategory != null) ...[
              const SizedBox(height: AppTheme.space16),
              const Divider(),
              const SizedBox(height: AppTheme.space12),
              TextField(
                controller: _nameCtrl,
                maxLength: 80,
                decoration: _fieldDecoration('Item Name *')
                    .copyWith(counterText: ''),
              ),
              const SizedBox(height: AppTheme.space12),
              TextField(
                controller: _weightCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                  LengthLimitingTextInputFormatter(7),
                ],
                onChanged: (_) => setState(() {}),
                decoration: _fieldDecoration('Weight (kg)'),
              ),
              const SizedBox(height: AppTheme.space12),
              TextField(
                controller: _qtyCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(5),
                ],
                onChanged: (_) => setState(() {}),
                decoration: _fieldDecoration('Quantity'),
              ),
              const SizedBox(height: AppTheme.space12),
              if (!_conditionFromDetailsFlow) ...[
                DropdownButtonFormField<String>(
                  initialValue: _condition,
                  items: const [
                    DropdownMenuItem(value: 'working', child: Text('Working')),
                    DropdownMenuItem(value: 'refurbished', child: Text('Refurbished')),
                    DropdownMenuItem(value: 'damaged', child: Text('Damaged')),
                    DropdownMenuItem(value: 'scrap', child: Text('Scrap')),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _condition = value);
                  },
                  decoration: _fieldDecoration('Condition'),
                ),
                const SizedBox(height: AppTheme.space12),
              ],
              TextField(
                controller: _rateCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                  LengthLimitingTextInputFormatter(8),
                ],
                onChanged: (_) => setState(() {}),
                decoration: _fieldDecoration('Rate (per kg)'),
              ),
              const SizedBox(height: AppTheme.space12),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Estimated Total: ₹${_estimateTotal().toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: AppColor.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      bottomBar: Row(
        children: [
          Expanded(
            child: CustomButton(
              text: 'Cancel',
              variant: AppButtonVariant.outline,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          const SizedBox(width: AppTheme.space12),
          Expanded(
            child: CustomButton(
              text: 'Add',
              variant: AppButtonVariant.primary,
              onPressed: _selectedSubCategory == null ? null : _saveItem,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubCategoryList(
    AsyncValue<List<Category>>? subCategoriesAsync,
    String query,
  ) {
    if (subCategoriesAsync == null) return const SizedBox.shrink();
    return subCategoriesAsync.when(
      data: (subCategories) {
        final filtered = subCategories
            .where(
              (s) =>
                  query.isEmpty ||
                  s.name.en.toLowerCase().contains(query) ||
                  s.name.hi.toLowerCase().contains(query),
            )
            .toList();
        return Column(
          children: filtered.map((s) {
            final selected = _selectedSubCategoryId == s.id;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppTheme.space12),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                onTap: () => _selectSubCategory(s),
                child: AppCard(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppColor.primarySurface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: s.imageUrl.isNotEmpty
                            ? Image.network(
                                s.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(Icons.inventory_2_rounded),
                              )
                            : const Icon(Icons.inventory_2_rounded),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.getName(context),
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 17,
                                color: AppColor.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              s.requiresDetails
                                  ? 'Tap to configure and estimate price'
                                  : 'Base ₹${(s.basePrice ?? 0).toStringAsFixed(0)}',
                              style: const TextStyle(color: AppColor.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      if (selected)
                        const Icon(Icons.check_circle_rounded, color: AppColor.primary),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: LinearProgressIndicator(minHeight: 2),
      ),
      error: (err, __) => _buildErrorCard(
        message: 'Failed to load sub-categories.\n$err',
        onRetry: () {
          final categoryId = _selectedCategory?.id;
          if (categoryId != null) {
            ref.invalidate(subCategoriesProvider(categoryId));
          }
        },
      ),
    );
  }

  Widget _buildErrorCard({
    required String message,
    required VoidCallback onRetry,
  }) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: const TextStyle(
              color: AppColor.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppTheme.space12),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Future<void> _selectSubCategory(Category subCategory) async {
    setState(() {
      _selectedSubCategory = subCategory;
      _selectedSubCategoryId = subCategory.id;
      _conditionFromDetailsFlow = false;
      _nameCtrl.text = subCategory.getName(context);
      _rateCtrl.text = (subCategory.basePrice ?? 0).toStringAsFixed(2);
      _weightCtrl.text = '1';
      _qtyCtrl.text = '1';
    });

    if (subCategory.requiresDetails) {
      final result = await Navigator.of(context).push<Map<String, dynamic>>(
        MaterialPageRoute(
          builder: (_) => HouseholdItemDetailsScreen(
            item: PickupCatalogItem(
              id: subCategory.id,
              name: subCategory.name.en,
              price: subCategory.basePrice ?? 0,
              unit: (subCategory.pricingType ?? 'per_piece'),
              materialType: '',
              pickupSize: '',
              priceType: subCategory.pricingType ?? 'per_piece',
              condition: '',
              imageUrl: subCategory.imageUrl,
            ),
            parentCategoryName: _selectedCategory?.getName(context) ?? '',
            applianceCategoryId: subCategory.id,
            parentCategoryId: _selectedCategory?.id,
            selectionOnly: true,
            selectionCtaLabel: 'Use This Item',
          ),
        ),
      );
      if (result != null && mounted) {
        setState(() {
          _conditionFromDetailsFlow = true;
          _nameCtrl.text = (result['item_name']?.toString() ?? _nameCtrl.text);
          _rateCtrl.text = ((result['rate_per_kg'] as num?)?.toDouble() ?? 0).toStringAsFixed(2);
          _weightCtrl.text = ((result['weight_kg'] as num?)?.toDouble() ?? 1).toString();
          _qtyCtrl.text = ((result['quantity'] as num?)?.toInt() ?? 1).toString();
          final cond = result['condition']?.toString().toLowerCase();
          if (cond != null && cond.isNotEmpty) {
            _condition = cond.contains('non') || cond.contains('not')
                ? 'damaged'
                : cond.contains('scrap')
                    ? 'scrap'
                    : 'working';
          }
        });
      }
    } else {
      setState(() {});
    }
  }
}

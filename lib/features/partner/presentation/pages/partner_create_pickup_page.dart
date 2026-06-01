import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_routes.dart';
import '../../../channel_partner/providers/channel_partner_provider.dart';

class PartnerCreatePickupPage extends ConsumerStatefulWidget {
  const PartnerCreatePickupPage({super.key});

  @override
  ConsumerState<PartnerCreatePickupPage> createState() =>
      _PartnerCreatePickupPageState();
}

class _PickupLine {
  String categoryId = '';
  String subcategoryId = '';
  String productName = '';
  String quantity = '1';
  String unit = 'kg';
  String weight = '';
  String condition = 'Working';
  String estimatedPrice = '';
  String remarks = '';
}

class _PartnerCreatePickupPageState extends ConsumerState<PartnerCreatePickupPage> {
  static const _steps = [
    'Customer Details',
    'Request Type',
    'Category & Subcategory',
    'Item Details',
    'Pickup Details',
    'Review & Submit',
  ];

  int _step = 0;
  String _customerType = 'individual';
  String _requestType = 'basic_scrap';
  int? _selectedCustomerId;
  DateTime? _scheduledAt;
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  final _lines = <_PickupLine>[_PickupLine()];
  final _images = <XFile>[];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ref.read(channelPartnerProvider.notifier).loadCustomers();
      await ref.read(channelPartnerProvider.notifier).loadRequestCategories();
    });
  }

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(channelPartnerProvider);
    final customers = state.customers.whereType<Map<String, dynamic>>().toList();
    final categories =
        state.requestCategories.whereType<Map<String, dynamic>>().toList();
    final selectedCustomer = customers
        .where((c) => (c['id']?.toString() ?? '') == _selectedCustomerId?.toString())
        .cast<Map<String, dynamic>?>()
        .firstWhere((_) => true, orElse: () => null);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(title: const Text('Create Pickup Request')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          children: [
            _sectionCard(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(
                  _steps.length,
                  (i) => ChoiceChip(
                    label: Text('${i + 1}. ${_steps[i]}'),
                    selected: _step == i,
                    onSelected: (_) {
                      if (i <= _step) setState(() => _step = i);
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (_step == 0) ...[
              _sectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Customer Details',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      initialValue: _selectedCustomerId,
                      isExpanded: true,
                      items: customers
                          .map(
                            (c) => DropdownMenuItem<int>(
                              value: int.tryParse('${c['id'] ?? ''}'),
                              child: Text(
                                '${c['name'] ?? '-'} (${c['mobile'] ?? c['phone'] ?? '-'})',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        setState(() {
                          _selectedCustomerId = v;
                          final customer = customers.firstWhere(
                            (c) => int.tryParse('${c['id'] ?? ''}') == v,
                            orElse: () => <String, dynamic>{},
                          );
                          _addressController.text =
                              customer['address']?.toString() ?? _addressController.text;
                        });
                      },
                      decoration: const InputDecoration(hintText: 'Select customer'),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () => context.push(AppRoutes.partnerCustomers),
                      icon: const Icon(Icons.person_add_alt_1_rounded),
                      label: const Text('Add customer if not available'),
                    ),
                  ],
                ),
              ),
            ],
            if (_step == 1) ...[
              _sectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Request Type Selection',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _customerType,
                      items: const [
                        DropdownMenuItem(
                          value: 'individual',
                          child: Text('Individual Customer'),
                        ),
                        DropdownMenuItem(
                          value: 'corporate',
                          child: Text('Corporate Customer'),
                        ),
                      ],
                      onChanged: (v) => setState(() => _customerType = v ?? 'individual'),
                      decoration: const InputDecoration(hintText: 'Customer type'),
                    ),
                    const SizedBox(height: 10),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(
                          value: 'basic_scrap',
                          label: Text('Basic Scrap Request'),
                        ),
                        ButtonSegment(
                          value: 'corporate',
                          label: Text('Corporate Request'),
                        ),
                      ],
                      selected: {_requestType},
                      onSelectionChanged: (value) {
                        setState(() => _requestType = value.first);
                      },
                    ),
                  ],
                ),
              ),
            ],
            if (_step == 2 || _step == 3) ...[
              _sectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _step == 2
                              ? 'Category & Subcategory'
                              : 'Item Details',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        TextButton(
                          onPressed: () => setState(() => _lines.add(_PickupLine())),
                          child: const Text('Add Item'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    for (int i = 0; i < _lines.length; i++)
                      _itemLineCard(i, categories, state.subcategoriesByCategory),
                  ],
                ),
              ),
            ],
            if (_step == 4) ...[
              _sectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pickup Details',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _addressController,
                      maxLines: 2,
                      decoration: const InputDecoration(hintText: 'Pickup address'),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: _pickDateTime,
                      icon: const Icon(Icons.calendar_month_rounded),
                      label: Text(
                        _scheduledAt == null
                            ? 'Pickup date & time'
                            : _scheduledAt.toString(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: const InputDecoration(hintText: 'Notes'),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Item Images'),
                        TextButton.icon(
                          onPressed: _pickImages,
                          icon: const Icon(Icons.add_a_photo_rounded),
                          label: const Text('Upload'),
                        ),
                      ],
                    ),
                    if (_images.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _images
                            .map((x) => ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    File(x.path),
                                    width: 72,
                                    height: 72,
                                    fit: BoxFit.cover,
                                  ),
                                ))
                            .toList(),
                      ),
                  ],
                ),
              ),
            ],
            if (_step == 5) ...[
              _sectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Review & Submit',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    _reviewRow('Customer', selectedCustomer?['name']?.toString() ?? '-'),
                    _reviewRow('Customer Type', _customerType),
                    _reviewRow('Request Type', _requestType),
                    _reviewRow('Items', '${_lines.length}'),
                    _reviewRow('Address', _addressController.text.trim()),
                    _reviewRow(
                      'Schedule',
                      _scheduledAt == null ? '-' : _scheduledAt.toString(),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _step == 0 ? null : () => setState(() => _step -= 1),
                    child: const Text('Back'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSubmitting
                        ? null
                        : () async {
                            if (_step < _steps.length - 1) {
                              if (!_validateStep()) return;
                              setState(() => _step += 1);
                              return;
                            }
                            await _submit();
                          },
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(_step == _steps.length - 1 ? 'Submit' : 'Next'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _itemLineCard(
    int index,
    List<Map<String, dynamic>> categories,
    Map<int, List<dynamic>> subcategoriesByCategory,
  ) {
    final line = _lines[index];
    final categoryId = int.tryParse(line.categoryId);
    final subcategories = categoryId == null
        ? const <dynamic>[]
        : (subcategoriesByCategory[categoryId] ?? const <dynamic>[]);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.outline),
      ),
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            initialValue: line.categoryId.isEmpty ? null : line.categoryId,
            items: categories
                .map(
                  (c) => DropdownMenuItem<String>(
                    value: '${c['id']}',
                    child: Text(
                      (c['name'] is Map)
                          ? (c['name']['en']?.toString() ?? '-')
                          : (c['name']?.toString() ?? '-'),
                    ),
                  ),
                )
                .toList(),
            onChanged: (v) async {
              setState(() {
                line.categoryId = v ?? '';
                line.subcategoryId = '';
              });
              final id = int.tryParse(v ?? '');
              if (id != null) {
                await ref.read(channelPartnerProvider.notifier).loadSubcategories(id);
              }
            },
            decoration: const InputDecoration(hintText: 'Select category'),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: line.subcategoryId.isEmpty ? null : line.subcategoryId,
            items: subcategories
                .whereType<Map<String, dynamic>>()
                .map(
                  (s) => DropdownMenuItem<String>(
                    value: '${s['id']}',
                    child: Text(
                      (s['name'] is Map)
                          ? (s['name']['en']?.toString() ?? '-')
                          : (s['name']?.toString() ?? '-'),
                    ),
                  ),
                )
                .toList(),
            onChanged: (v) => setState(() => line.subcategoryId = v ?? ''),
            decoration: const InputDecoration(hintText: 'Select subcategory'),
          ),
          const SizedBox(height: 8),
          TextField(
            onChanged: (v) => line.productName = v,
            decoration: const InputDecoration(hintText: 'Product name'),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: line.quantity,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (v) => line.quantity = v,
                  decoration: const InputDecoration(hintText: 'Quantity'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: line.unit,
                  items: const [
                    DropdownMenuItem(value: 'kg', child: Text('kg')),
                    DropdownMenuItem(value: 'piece', child: Text('piece')),
                    DropdownMenuItem(value: 'lot', child: Text('lot')),
                  ],
                  onChanged: (v) => setState(() => line.unit = v ?? 'kg'),
                  decoration: const InputDecoration(hintText: 'Unit'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (v) => line.weight = v,
                  decoration: const InputDecoration(hintText: 'Weight (kg)'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (v) => line.estimatedPrice = v,
                  decoration: const InputDecoration(hintText: 'Estimated price'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: line.condition,
            items: const [
              DropdownMenuItem(value: 'Working', child: Text('Working')),
              DropdownMenuItem(value: 'Non-Working', child: Text('Non-Working')),
              DropdownMenuItem(value: 'Scrap', child: Text('Scrap')),
            ],
            onChanged: (v) => setState(() => line.condition = v ?? 'Working'),
            decoration: const InputDecoration(hintText: 'Condition'),
          ),
          const SizedBox(height: 8),
          TextField(
            onChanged: (v) => line.remarks = v,
            maxLines: 2,
            decoration: const InputDecoration(hintText: 'Remarks'),
          ),
          if (_lines.length > 1)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => setState(() => _lines.removeAt(index)),
                child: const Text('Remove'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _sectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: AppTheme.cardBorder,
        boxShadow: AppTheme.cardShadow,
      ),
      child: child,
    );
  }

  Widget _reviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
          Expanded(child: Text(value.isEmpty ? '-' : value)),
        ],
      ),
    );
  }

  bool _validateStep() {
    if (_step == 0 && _selectedCustomerId == null) {
      _snack('Please select a customer.');
      return false;
    }
    if (_step == 2) {
      for (final item in _lines) {
        if (item.categoryId.isEmpty) {
          _snack('Please select category for all items.');
          return false;
        }
      }
    }
    if (_step == 3) {
      for (final item in _lines) {
        final qty = double.tryParse(item.quantity) ?? 0;
        if (qty <= 0) {
          _snack('Quantity must be greater than 0.');
          return false;
        }
      }
    }
    if (_step == 4) {
      if (_addressController.text.trim().isEmpty) {
        _snack('Please enter pickup address.');
        return false;
      }
      if (_scheduledAt == null) {
        _snack('Please select pickup date/time.');
        return false;
      }
    }
    return true;
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 60)),
      initialDate: now.add(const Duration(days: 1)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now.add(const Duration(hours: 2))),
    );
    if (time == null) return;
    setState(() {
      _scheduledAt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final files = await picker.pickMultiImage(imageQuality: 82);
    if (files.isNotEmpty) setState(() => _images.addAll(files));
  }

  Future<void> _submit() async {
    if (!_validateStep()) return;

    setState(() => _isSubmitting = true);
    final images = <MultipartFile>[];
    for (final image in _images) {
      images.add(await MultipartFile.fromFile(image.path, filename: image.name));
    }

    final payload = <String, dynamic>{
      'customer_id': _selectedCustomerId,
      'customer_type': _customerType,
      'request_type': _requestType,
      'address': _addressController.text.trim(),
      'scheduled_at': _scheduledAt!.toIso8601String(),
      'notes': _notesController.text.trim(),
      'items': _lines
          .map(
            (line) => {
              'category_id': line.categoryId,
              'subcategory_id':
                  line.subcategoryId.isEmpty ? null : line.subcategoryId,
              'product_name': line.productName,
              'quantity': line.quantity,
              'unit': line.unit,
              'weight': line.weight,
              'condition': line.condition,
              'estimated_price': line.estimatedPrice,
              'remarks': line.remarks,
            },
          )
          .toList(),
    };

    final result = await ref.read(channelPartnerProvider.notifier).createPickupRequest(
          payload: payload,
          images: images,
        );
    setState(() => _isSubmitting = false);
    if (!mounted) return;
    if (result != null) {
      final pickupId =
          result['pickup_id'] ?? result['id'] ?? result['pickup_code'] ?? '-';
      _snack('Pickup request created successfully. ID: $pickupId');
      Navigator.pop(context);
    } else {
      final error =
          ref.read(channelPartnerProvider).error ?? 'Failed to create pickup request';
      _snack(error);
    }
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

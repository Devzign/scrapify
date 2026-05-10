import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_routes.dart';
import '../../../../core/utils/validators.dart';
import '../../../channel_partner/providers/channel_partner_provider.dart';

class PartnerCreatePickupPage extends ConsumerStatefulWidget {
  const PartnerCreatePickupPage({super.key});

  @override
  ConsumerState<PartnerCreatePickupPage> createState() => _PartnerCreatePickupPageState();
}

class _PartnerCreatePickupPageState extends ConsumerState<PartnerCreatePickupPage> {
  final _notesController = TextEditingController();
  final _addressController = TextEditingController();
  final _landmarkController = TextEditingController();
  final _weightController = TextEditingController(text: '1');
  final _quantityController = TextEditingController(text: '1');
  final _remarksController = TextEditingController();
  final _priceController = TextEditingController();
  String _selectedCondition = 'Working';
  DateTime? _pickupDate;
  String? _pickupSlot;
  int? _selectedCustomerId;
  final List<XFile> _images = [];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(channelPartnerProvider.notifier).loadCustomers());
  }

  @override
  void dispose() {
    _notesController.dispose();
    _addressController.dispose();
    _landmarkController.dispose();
    _weightController.dispose();
    _quantityController.dispose();
    _remarksController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(channelPartnerProvider);
    final customers = state.customers.whereType<Map<String, dynamic>>().toList();
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(title: const Text('Create Pickup Request')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Customer', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<int>(
                    initialValue: _selectedCustomerId,
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
                    onChanged: (v) => setState(() => _selectedCustomerId = v),
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
            const SizedBox(height: 12),
            _sectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Pickup Details', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  const SizedBox(height: 12),
                  _field(_addressController, 'Pickup address',
                      maxLength: 200, maxLines: 2),
                  _field(_landmarkController, 'Landmark', maxLength: 80),
                  Row(
                    children: [
                      Expanded(
                        child: _field(
                          _weightController,
                          'Estimated weight (kg)',
                          keyboardType:
                              const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d*$'),
                            ),
                            LengthLimitingTextInputFormatter(7),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _field(
                          _quantityController,
                          'Quantity',
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(5),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _field(
                          _priceController,
                          'Estimated price',
                          keyboardType:
                              const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d*$'),
                            ),
                            LengthLimitingTextInputFormatter(8),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedCondition,
                            isExpanded: true,
                            items: const [
                              DropdownMenuItem(value: 'Working', child: Text('Working')),
                              DropdownMenuItem(value: 'Non-Working', child: Text('Non-Working')),
                              DropdownMenuItem(value: 'Scrap', child: Text('Scrap')),
                            ],
                            onChanged: (value) {
                              if (value == null) return;
                              setState(() => _selectedCondition = value);
                            },
                            decoration: const InputDecoration(hintText: 'Condition'),
                          ),
                        ),
                      ),
                    ],
                  ),
                  _field(
                    _remarksController,
                    'Item remarks',
                    maxLength: 500,
                    maxLines: 3,
                  ),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isTight = constraints.maxWidth < 420;
                      final dateButton = OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: _pickDate,
                        icon: const Icon(Icons.calendar_month_rounded),
                        label: Text(
                          _pickupDate == null
                              ? 'Pickup date'
                              : '${_pickupDate!.year}-${_pickupDate!.month.toString().padLeft(2, '0')}-${_pickupDate!.day.toString().padLeft(2, '0')}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );

                      final slotDropdown = DropdownButtonFormField<String>(
                        initialValue: _pickupSlot,
                        isExpanded: true,
                        items: const [
                          DropdownMenuItem(value: '10:00 AM - 01:00 PM', child: Text('10:00 AM - 01:00 PM')),
                          DropdownMenuItem(value: '02:00 PM - 05:00 PM', child: Text('02:00 PM - 05:00 PM')),
                        ],
                        selectedItemBuilder: (context) => const [
                          Text('10:00 AM - 01:00 PM', overflow: TextOverflow.ellipsis),
                          Text('02:00 PM - 05:00 PM', overflow: TextOverflow.ellipsis),
                        ],
                        onChanged: (v) => setState(() => _pickupSlot = v),
                        decoration: const InputDecoration(hintText: 'Time slot'),
                      );

                      if (isTight) {
                        return Column(
                          children: [
                            SizedBox(width: double.infinity, child: dateButton),
                            const SizedBox(height: 10),
                            slotDropdown,
                          ],
                        );
                      }

                      return Row(
                        children: [
                          Expanded(child: dateButton),
                          const SizedBox(width: 10),
                          Expanded(child: slotDropdown),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _field(
                    _notesController,
                    'Notes',
                    maxLength: 500,
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _sectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Item Images', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                      TextButton.icon(
                        onPressed: _pickImages,
                        icon: const Icon(Icons.add_a_photo_rounded),
                        label: const Text('Upload'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_images.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: AppTheme.cardBorder,
                        borderRadius: AppTheme.cardBorderRadius,
                      ),
                      child: const Text('No images selected'),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(_images.length, (i) {
                        final image = _images[i];
                        return Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                File(image.path),
                                width: 90,
                                height: 90,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: InkWell(
                                onTap: () => setState(() => _images.removeAt(i)),
                                child: Container(
                                  decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                  child: const Icon(Icons.close_rounded, size: 16, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(56),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Submit Pickup Request'),
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

  Widget _field(
    TextEditingController controller,
    String hint, {
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        maxLength: maxLength,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          counterText: '',
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 60)),
      initialDate: now.add(const Duration(days: 1)),
    );
    if (selected != null) {
      setState(() => _pickupDate = selected);
    }
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final files = await picker.pickMultiImage(imageQuality: 82);
    if (files.isNotEmpty) {
      setState(() => _images.addAll(files));
    }
  }

  Future<void> _submit() async {
    if (_selectedCustomerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a customer.')),
      );
      return;
    }
    if (_pickupDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please pick a pickup date.')),
      );
      return;
    }
    if (_pickupSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please pick a pickup time slot.')),
      );
      return;
    }
    final dateErr = Validators.scheduledAt(_pickupDate);
    if (dateErr != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(dateErr)),
      );
      return;
    }
    final addressErr = Validators.address(_addressController.text);
    if (addressErr != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(addressErr)),
      );
      return;
    }
    if (_landmarkController.text.trim().length > 80) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Landmark is too long.')),
      );
      return;
    }
    final weightErr = Validators.weight(_weightController.text);
    if (weightErr != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(weightErr)),
      );
      return;
    }
    final qtyErr = Validators.positiveInteger(_quantityController.text);
    if (qtyErr != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(qtyErr)),
      );
      return;
    }
    final priceText = _priceController.text.trim();
    if (priceText.isNotEmpty) {
      final priceErr = Validators.rate(priceText);
      if (priceErr != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(priceErr)),
        );
        return;
      }
    }
    if (_remarksController.text.trim().length > 500) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item remarks are too long.')),
      );
      return;
    }
    if (_notesController.text.trim().length > 500) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notes are too long.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final images = <MultipartFile>[];
    for (final image in _images) {
      images.add(await MultipartFile.fromFile(image.path, filename: image.name));
    }
    final payload = <String, dynamic>{
      'customer_id': _selectedCustomerId,
      'address': _addressController.text.trim(),
      'landmark': _landmarkController.text.trim(),
      'estimated_weight_kg': _weightController.text.trim(),
      'quantity': _quantityController.text.trim(),
      'estimated_price': _priceController.text.trim(),
      'condition': _selectedCondition,
      'item_remarks': _remarksController.text.trim(),
      'scheduled_date':
          '${_pickupDate!.year}-${_pickupDate!.month.toString().padLeft(2, '0')}-${_pickupDate!.day.toString().padLeft(2, '0')}',
      'scheduled_slot': _pickupSlot,
      'notes': _notesController.text.trim(),
    };
    final result = await ref.read(channelPartnerProvider.notifier).createPickupRequest(
      payload: payload,
      images: images,
    );
    setState(() => _isSubmitting = false);
    if (!mounted) return;
    if (result != null) {
      final pickupId = result['pickup_id'] ?? result['id'] ?? result['pickup_code'] ?? '-';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pickup request created successfully. ID: $pickupId')),
      );
      Navigator.pop(context);
    } else {
      final error = ref.read(channelPartnerProvider).error ?? 'Failed to create pickup request';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    }
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_theme.dart';
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

  void _addItem() {
    showDialog(
      context: context,
      builder: (ctx) => _AddItemDialog(
        onAdd: (item) {
          setState(() => _items.add(item));
        },
      ),
    );
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
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final result = await ref
        .read(pickupBoyProvider.notifier)
        .verifyPickup(widget.pickupId, _items, _images);

    if (result != null && mounted) {
      final finalPayout = result['final_payout'] ?? result['final_amount'];
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Verification Complete!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 64),
              if (finalPayout != null) ...[
                const SizedBox(height: 16),
                Text(
                  'Final Amount: ₹$finalPayout',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                ctx.pop();
                context.pop();
                context.pop();
              },
              child: const Text('Done'),
            ),
          ],
        ),
      );
    } else if (mounted) {
      final error = ref.read(pickupBoyProvider).error;
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
        ref.read(pickupBoyProvider.notifier).clearError();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pickupBoyProvider);
    final activeItems = _items.where((i) => i.action != 'removed').toList();

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Verify Items',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Items List
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Items',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _addItem,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Item'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
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

                  const SizedBox(height: 24),

                  // Photo Upload
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Verification Photos',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _pickImages,
                        icon: const FaIcon(FontAwesomeIcons.camera, size: 14),
                        label: const Text('Add Photos'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_images.isNotEmpty)
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _images.length,
                        itemBuilder: (ctx, idx) => Stack(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(right: 8),
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: FileImage(_images[idx]),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 12,
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _images.removeAt(idx)),
                                child: const CircleAvatar(
                                  radius: 12,
                                  backgroundColor: Colors.red,
                                  child: Icon(
                                    Icons.close,
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
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.shade300,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FaIcon(
                              FontAwesomeIcons.camera,
                              color: Colors.grey,
                              size: 24,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Tap to add photos',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: state.isActionLoading
            ? const Center(child: CircularProgressIndicator())
            : ElevatedButton(
                onPressed: _submitVerification,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Submit Verification',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
      ),
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

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.item.itemName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppTheme.textPrimary,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: widget.onRemove,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _weightCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Weight (kg)',
                    isDense: true,
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                  ),
                  onChanged: (v) => widget.onUpdate(
                    widget.item.copyWith(weight: double.tryParse(v)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _qtyCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Quantity',
                    isDense: true,
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                  ),
                  onChanged: (v) => widget.onUpdate(
                    widget.item.copyWith(quantity: int.tryParse(v)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
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
                  decoration: const InputDecoration(
                    labelText: 'Condition',
                    isDense: true,
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _rateCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Rate (per kg)',
                    isDense: true,
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                  ),
                  onChanged: (v) => widget.onUpdate(
                    widget.item.copyWith(ratePerKg: double.tryParse(v)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AddItemDialog extends StatefulWidget {
  final ValueChanged<PickupItem> onAdd;
  const _AddItemDialog({required this.onAdd});

  @override
  State<_AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<_AddItemDialog> {
  final _nameCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController();
  final _rateCtrl = TextEditingController();
  String _condition = 'working';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Item'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(labelText: 'Item Name *'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _weightCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Weight (kg)'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _qtyCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Quantity'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
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
              if (value != null) setState(() => _condition = value);
            },
            decoration: const InputDecoration(labelText: 'Condition'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _rateCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Rate (per kg)'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_nameCtrl.text.trim().isEmpty) return;
            widget.onAdd(
              PickupItem(
                itemName: _nameCtrl.text.trim(),
                weight: double.tryParse(_weightCtrl.text),
                quantity: int.tryParse(_qtyCtrl.text),
                condition: _condition,
                ratePerKg: double.tryParse(_rateCtrl.text),
                action: 'added',
              ),
            );
            Navigator.pop(context);
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}

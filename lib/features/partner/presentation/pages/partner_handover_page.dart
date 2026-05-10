import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/validators.dart';
import '../../../channel_partner/providers/channel_partner_provider.dart';

class PartnerHandoverPage extends ConsumerStatefulWidget {
  const PartnerHandoverPage({super.key});

  @override
  ConsumerState<PartnerHandoverPage> createState() => _PartnerHandoverPageState();
}

class _PartnerHandoverPageState extends ConsumerState<PartnerHandoverPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(channelPartnerProvider.notifier).loadPartnerPickups(status: 'pickup_completed'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(channelPartnerProvider);
    final pickups = state.pickups.whereType<Map<String, dynamic>>().toList();
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(title: const Text('Deliver to Warehouse')),
      body: RefreshIndicator(
        onRefresh: () => ref.read(channelPartnerProvider.notifier).loadPartnerPickups(status: 'pickup_completed'),
        child: pickups.isEmpty && !state.isLoading
            ? ListView(
                children: const [
                  SizedBox(height: 220),
                  Center(child: Text('No completed pickups available')),
                ],
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                itemBuilder: (_, i) {
                  final p = pickups[i];
                  final id = int.tryParse('${p['id'] ?? p['pickup_id'] ?? ''}');
                  final code = p['pickup_code']?.toString() ?? p['order_code']?.toString() ?? '#${p['id']}';
                  final customer = p['customer_name']?.toString() ?? 'Customer';
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: AppTheme.cardBorderRadius,
                      border: AppTheme.cardBorder,
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(code, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text(customer, style: const TextStyle(color: AppTheme.textSecondary)),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: id == null ? null : () => _openHandoverForm(id, code),
                            child: const Text('Submit Handover'),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemCount: pickups.length,
              ),
      ),
    );
  }

  Future<void> _openHandoverForm(int pickupId, String code) async {
    final weight = TextEditingController();
    final amount = TextEditingController();
    final remarks = TextEditingController();
    final List<XFile> proofs = [];

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (context, setLocal) => Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Handover: $code', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                const SizedBox(height: 12),
                TextField(
                  controller: weight,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                    LengthLimitingTextInputFormatter(7),
                  ],
                  decoration: const InputDecoration(hintText: 'Final weight (kg)'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: amount,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                    LengthLimitingTextInputFormatter(8),
                  ],
                  decoration: const InputDecoration(hintText: 'Final amount (₹)'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: remarks,
                  maxLength: 300,
                  decoration: const InputDecoration(
                    hintText: 'Remarks',
                    counterText: '',
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Delivery Proofs', style: TextStyle(fontWeight: FontWeight.w700)),
                    TextButton.icon(
                      onPressed: () async {
                        final files = await ImagePicker().pickMultiImage(imageQuality: 82);
                        if (files.isNotEmpty) {
                          setLocal(() => proofs.addAll(files));
                        }
                      },
                      icon: const Icon(Icons.upload_file_rounded),
                      label: const Text('Upload'),
                    ),
                  ],
                ),
                Text('${proofs.length} file(s) selected'),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final modalContext = context;
                      final weightErr = Validators.weight(weight.text);
                      if (weightErr != null) {
                        ScaffoldMessenger.of(modalContext).showSnackBar(
                          SnackBar(content: Text(weightErr)),
                        );
                        return;
                      }
                      final amountErr =
                          Validators.positiveNumber(amount.text, fieldName: 'Amount');
                      if (amountErr != null) {
                        ScaffoldMessenger.of(modalContext).showSnackBar(
                          SnackBar(content: Text(amountErr)),
                        );
                        return;
                      }
                      if (proofs.isEmpty) {
                        ScaffoldMessenger.of(modalContext).showSnackBar(
                          const SnackBar(
                            content: Text('Upload at least one delivery proof.'),
                          ),
                        );
                        return;
                      }
                      final parsedWeight = double.parse(weight.text.trim());
                      final parsedAmount = double.parse(amount.text.trim());
                      final multipart = <MultipartFile>[];
                      for (final p in proofs) {
                        multipart.add(await MultipartFile.fromFile(p.path, filename: p.name));
                      }
                      final ok = await ref.read(channelPartnerProvider.notifier).submitWarehouseHandover(
                            pickupId: pickupId,
                            finalWeight: parsedWeight,
                            finalAmount: parsedAmount,
                            remarks: remarks.text.trim(),
                            proofs: multipart,
                          );
                      if (!modalContext.mounted) return;
                      Navigator.pop(modalContext);
                      ScaffoldMessenger.of(modalContext).showSnackBar(
                        SnackBar(content: Text(ok ? 'Delivered to warehouse successfully' : 'Handover failed')),
                      );
                      if (ok) {
                        ref.read(channelPartnerProvider.notifier).loadPartnerPickups(status: 'pickup_completed');
                      }
                    },
                    child: const Text('Submit Handover'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

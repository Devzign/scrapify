import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/payment_provider.dart';
import '../domain/models/payment_method_model.dart';

class AddEditPaymentScreen extends ConsumerStatefulWidget {
  final PaymentMethodModel? paymentMethod;

  const AddEditPaymentScreen({super.key, this.paymentMethod});

  @override
  ConsumerState<AddEditPaymentScreen> createState() => _AddEditPaymentScreenState();
}

class _AddEditPaymentScreenState extends ConsumerState<AddEditPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _type;
  late TextEditingController _bankNameController;
  late TextEditingController _accNoController;
  late TextEditingController _ifscController;
  late TextEditingController _holderNameController;
  late TextEditingController _upiIdController;
  late bool _isDefault;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final p = widget.paymentMethod;
    _type = p?.type ?? 'bank';
    _bankNameController = TextEditingController(text: p?.bankName);
    _accNoController = TextEditingController(text: p?.accountNumber);
    _ifscController = TextEditingController(text: p?.ifscCode);
    _holderNameController = TextEditingController(text: p?.accountHolderName);
    _upiIdController = TextEditingController(text: p?.upiId);
    _isDefault = p?.isDefault ?? false;
  }

  @override
  void dispose() {
    _bankNameController.dispose();
    _accNoController.dispose();
    _ifscController.dispose();
    _holderNameController.dispose();
    _upiIdController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final newPayment = PaymentMethodModel(
      id: widget.paymentMethod?.id ?? 0,
      type: _type,
      bankName: _type == 'bank' ? _bankNameController.text : null,
      accountNumber: _type == 'bank' ? _accNoController.text : null,
      ifscCode: _type == 'bank' ? _ifscController.text : null,
      accountHolderName: _type == 'bank' ? _holderNameController.text : null,
      upiId: _type == 'upi' ? _upiIdController.text : null,
      isDefault: _isDefault,
    );

    bool success;
    if (widget.paymentMethod != null) {
      success = await ref.read(paymentProvider.notifier).updatePaymentDetail(widget.paymentMethod!.id, newPayment);
    } else {
      success = await ref.read(paymentProvider.notifier).addPaymentDetail(newPayment);
    }

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save payment details')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF102213) : const Color(0xFFF6F8F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: isDark ? Colors.white : Colors.black),
          onPressed: () => context.pop(),
        ),
        title: Text(
          widget.paymentMethod == null ? 'payment.add.title'.tr() : 'payment.add.edit_title'.tr(),
          style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildTypeToggle(isDark),
            const SizedBox(height: 24),
            if (_type == 'bank') ...[
              _buildTextField(
                controller: _holderNameController,
                label: 'payment.add.holder_name'.tr(),
                hint: 'payment.add.holder_name_hint'.tr(),
                isDark: isDark,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _bankNameController,
                label: 'payment.add.bank_name'.tr(),
                hint: 'payment.add.bank_name_hint'.tr(),
                isDark: isDark,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _accNoController,
                label: 'payment.add.acc_no'.tr(),
                hint: 'payment.add.acc_no_hint'.tr(),
                isDark: isDark,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _ifscController,
                label: 'payment.add.ifsc'.tr(),
                hint: 'payment.add.ifsc_hint'.tr(),
                isDark: isDark,
                textCapitalization: TextCapitalization.characters,
              ),
            ] else ...[
              _buildTextField(
                controller: _upiIdController,
                label: 'payment.add.upi_id'.tr(),
                hint: 'payment.add.upi_id_hint'.tr(),
                isDark: isDark,
              ),
            ],
            const SizedBox(height: 24),
            SwitchListTile(
              title: const Text('Set as Default'),
              value: _isDefault,
              onChanged: (val) => setState(() => _isDefault = val),
              activeThumbColor: const Color(0xFF13EC30),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF13EC30),
                foregroundColor: const Color(0xFF0F172A),
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading 
                ? const CircularProgressIndicator(color: Color(0xFF0F172A))
                : Text('payment.add.save'.tr(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeToggle(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildToggleButton(
              label: 'payment.bank'.tr(),
              isSelected: _type == 'bank',
              onTap: () => setState(() => _type = 'bank'),
              isDark: isDark,
            ),
          ),
          Expanded(
            child: _buildToggleButton(
              label: 'payment.upi'.tr(),
              isSelected: _type == 'upi',
              onTap: () => setState(() => _type = 'upi'),
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({required String label, required bool isSelected, required VoidCallback onTap, required bool isDark}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: isSelected ? (isDark ? const Color(0xFF13EC30) : Colors.white) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected && !isDark ? [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2))] : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? (isDark ? Colors.black : const Color(0xFF0F172A)) : Colors.grey,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isDark,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.withValues(alpha: 0.5)),
            filled: true,
            fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF13EC30)),
            ),
          ),
          validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
        ),
      ],
    );
  }
}

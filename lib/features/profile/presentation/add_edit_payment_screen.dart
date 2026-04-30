import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_button.dart';
import '../providers/payment_provider.dart';
import '../domain/models/payment_method_model.dart';

class AddEditPaymentScreen extends ConsumerStatefulWidget {
  final PaymentMethodModel? paymentMethod;

  const AddEditPaymentScreen({super.key, this.paymentMethod});

  @override
  ConsumerState<AddEditPaymentScreen> createState() =>
      _AddEditPaymentScreenState();
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
  bool _hasSubmitted = false;

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
    _bankNameController.addListener(_handleFormChanged);
    _accNoController.addListener(_handleFormChanged);
    _ifscController.addListener(_handleFormChanged);
    _holderNameController.addListener(_handleFormChanged);
    _upiIdController.addListener(_handleFormChanged);
  }

  @override
  void dispose() {
    _bankNameController.removeListener(_handleFormChanged);
    _accNoController.removeListener(_handleFormChanged);
    _ifscController.removeListener(_handleFormChanged);
    _holderNameController.removeListener(_handleFormChanged);
    _upiIdController.removeListener(_handleFormChanged);
    _bankNameController.dispose();
    _accNoController.dispose();
    _ifscController.dispose();
    _holderNameController.dispose();
    _upiIdController.dispose();
    super.dispose();
  }

  void _handleFormChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  String? _validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    return null;
  }

  String? _validateAccountNumber(String? value) {
    if (_type != 'bank') {
      return null;
    }
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Required';
    }
    if (!RegExp(r'^\d{9,18}$').hasMatch(trimmed)) {
      return 'Enter a valid account number';
    }
    return null;
  }

  String? _validateIfsc(String? value) {
    if (_type != 'bank') {
      return null;
    }
    final trimmed = value?.trim().toUpperCase() ?? '';
    if (trimmed.isEmpty) {
      return 'Required';
    }
    if (!RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$').hasMatch(trimmed)) {
      return 'Enter a valid IFSC code';
    }
    return null;
  }

  String? _validateUpiId(String? value) {
    if (_type != 'upi') {
      return null;
    }
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Required';
    }
    if (!RegExp(r'^[a-zA-Z0-9.\-_]{2,256}@[a-zA-Z]{2,64}$').hasMatch(trimmed)) {
      return 'Enter a valid UPI ID';
    }
    return null;
  }

  bool get _isFormValid {
    if (_type == 'bank') {
      return _validateRequired(_holderNameController.text) == null &&
          _validateRequired(_bankNameController.text) == null &&
          _validateAccountNumber(_accNoController.text) == null &&
          _validateIfsc(_ifscController.text) == null;
    }

    return _validateUpiId(_upiIdController.text) == null;
  }

  Future<void> _handleSave() async {
    setState(() => _hasSubmitted = true);
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final newPayment = PaymentMethodModel(
      id: widget.paymentMethod?.id ?? 0,
      type: _type,
      bankName: _type == 'bank' ? _bankNameController.text.trim() : null,
      accountNumber: _type == 'bank' ? _accNoController.text.trim() : null,
      ifscCode: _type == 'bank'
          ? _ifscController.text.trim().toUpperCase()
          : null,
      accountHolderName: _type == 'bank'
          ? _holderNameController.text.trim()
          : null,
      upiId: _type == 'upi' ? _upiIdController.text.trim() : null,
      isDefault: _isDefault,
    );

    bool success;
    if (widget.paymentMethod != null) {
      success = await ref
          .read(paymentProvider.notifier)
          .updatePaymentDetail(widget.paymentMethod!.id, newPayment);
    } else {
      success = await ref
          .read(paymentProvider.notifier)
          .addPaymentDetail(newPayment);
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
      backgroundColor: isDark ? const Color(0xFF102213) : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark
            ? const Color(0xFF102213).withValues(alpha: 0.95)
            : Colors.white.withValues(alpha: 0.95),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          widget.paymentMethod == null
              ? 'payment.add.title'.tr()
              : 'payment.add.edit_title'.tr(),
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF0F172A),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: _hasSubmitted
            ? AutovalidateMode.always
            : AutovalidateMode.disabled,
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 128),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF16311B) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : const Color(0xFFE5E7EB),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: isDark ? 0.10 : 0.03,
                        ),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildTypeToggle(isDark),
                      const SizedBox(height: 24),
                      if (_type == 'bank') ...[
                        _buildTextField(
                          controller: _holderNameController,
                          label: 'payment.add.holder_name'.tr(),
                          hint: 'payment.add.holder_name_hint'.tr(),
                          isDark: isDark,
                          validator: _type == 'bank' ? _validateRequired : null,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _bankNameController,
                          label: 'payment.add.bank_name'.tr(),
                          hint: 'payment.add.bank_name_hint'.tr(),
                          isDark: isDark,
                          validator: _type == 'bank' ? _validateRequired : null,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _accNoController,
                          label: 'payment.add.acc_no'.tr(),
                          hint: 'payment.add.acc_no_hint'.tr(),
                          isDark: isDark,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(18),
                          ],
                          validator: _validateAccountNumber,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _ifscController,
                          label: 'payment.add.ifsc'.tr(),
                          hint: 'payment.add.ifsc_hint'.tr(),
                          isDark: isDark,
                          textCapitalization: TextCapitalization.characters,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[a-zA-Z0-9]'),
                            ),
                            LengthLimitingTextInputFormatter(11),
                          ],
                          validator: _validateIfsc,
                        ),
                      ] else ...[
                        _buildTextField(
                          controller: _upiIdController,
                          label: 'payment.add.upi_id'.tr(),
                          hint: 'payment.add.upi_id_hint'.tr(),
                          isDark: isDark,
                          validator: _validateUpiId,
                        ),
                      ],
                      const SizedBox(height: 20),
                      _buildDefaultTile(isDark),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  MediaQuery.of(context).padding.bottom + 16,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      isDark ? const Color(0xFF102213) : Colors.white,
                      isDark
                          ? const Color(0xFF102213).withValues(alpha: 0.9)
                          : Colors.white.withValues(alpha: 0.9),
                      (isDark ? const Color(0xFF102213) : Colors.white)
                          .withValues(alpha: 0.0),
                    ],
                  ),
                ),
                child: CustomButton(
                  onPressed: (!_isLoading && _isFormValid) ? _handleSave : null,
                  isLoading: _isLoading,
                  text: 'payment.add.save'.tr(),
                  borderRadius: 14,
                ),
              ),
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

  Widget _buildToggleButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppTheme.primaryColor : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected && !isDark
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? (isDark ? Colors.black : const Color(0xFF0F172A))
                : const Color(0xFF94A3B8),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultTile(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF102213) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Set as Default',
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Use this payment method for future payouts',
                  style: TextStyle(
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isDefault,
            onChanged: (val) => setState(() => _isDefault = val),
            activeThumbColor: Colors.white,
            activeTrackColor: AppTheme.primaryColor,
          ),
        ],
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
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.white70 : const Color(0xFF334155),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          inputFormatters: inputFormatters,
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.35)
                  : const Color(0xFF94A3B8),
            ),
            filled: true,
            fillColor: isDark
                ? const Color(0xFF1E293B)
                : const Color(0xFFFCFDFD),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark
                    ? const Color(0xFF334155)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark
                    ? const Color(0xFF334155)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppTheme.primaryColor,
                width: 1.6,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.4),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }
}

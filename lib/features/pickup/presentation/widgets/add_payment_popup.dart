import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../profile/domain/models/payment_method_model.dart';
import '../../../profile/providers/payment_provider.dart';

class AddPaymentPopup extends ConsumerStatefulWidget {
  final String type; // 'upi' or 'bank'
  final Function(PaymentMethodModel) onAdded;

  const AddPaymentPopup({super.key, required this.type, required this.onAdded});

  @override
  ConsumerState<AddPaymentPopup> createState() => _AddPaymentPopupState();
}

class _AddPaymentPopupState extends ConsumerState<AddPaymentPopup> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _bankNameController;
  late TextEditingController _accNoController;
  late TextEditingController _ifscController;
  late TextEditingController _holderNameController;
  late TextEditingController _upiIdController;
  bool _isLoading = false;
  bool _hasSubmitted = false;

  @override
  void initState() {
    super.initState();
    _bankNameController = TextEditingController();
    _accNoController = TextEditingController();
    _ifscController = TextEditingController();
    _holderNameController = TextEditingController();
    _upiIdController = TextEditingController();
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
    setState(() => _hasSubmitted = true);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final payment = PaymentMethodModel(
      id: 0,
      type: widget.type,
      bankName: widget.type == 'bank' ? _bankNameController.text.trim() : null,
      accountNumber: widget.type == 'bank'
          ? _accNoController.text.trim()
          : null,
      ifscCode: widget.type == 'bank'
          ? _ifscController.text.trim().toUpperCase()
          : null,
      accountHolderName: widget.type == 'bank'
          ? _holderNameController.text.trim()
          : null,
      upiId: widget.type == 'upi' ? _upiIdController.text.trim() : null,
      isDefault: true,
    );

    final success = await ref
        .read(paymentProvider.notifier)
        .addPaymentDetail(payment);

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        // Find the newly added payment (it should be the default one now or the last in list)
        // For simplicity, we refresh the list and pass back the data in onAdded if we had the ID
        // But the provider refreshes the list, so the selection sheet will see it.
        // We'll just close and let the sheet refresh.
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save payment details')),
        );
      }
    }
  }

  String? _validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    return null;
  }

  String? _validateAccountNumber(String? value) {
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
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Required';
    }
    if (!RegExp(r'^[a-zA-Z0-9._-]{2,256}@[a-zA-Z]{2,64}$').hasMatch(trimmed)) {
      return 'Enter a valid UPI ID';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          autovalidateMode: _hasSubmitted
              ? AutovalidateMode.always
              : AutovalidateMode.disabled,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add New ${widget.type.toUpperCase()}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 24),
                if (widget.type == 'bank') ...[
                  _buildTextField(
                    controller: _holderNameController,
                    label: 'Account Holder Name',
                    hint: 'As per bank records',
                    validator: _validateRequired,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _bankNameController,
                    label: 'Bank Name',
                    hint: 'e.g. SBI, HDFC',
                    validator: _validateRequired,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _accNoController,
                    label: 'Account Number',
                    hint: 'Enter bank account number',
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
                    label: 'IFSC Code',
                    hint: '11 characters code',
                    textCapitalization: TextCapitalization.characters,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                      LengthLimitingTextInputFormatter(11),
                    ],
                    validator: _validateIfsc,
                  ),
                ] else ...[
                  _buildTextField(
                    controller: _upiIdController,
                    label: 'UPI ID',
                    hint: 'e.g. name@bank',
                    validator: _validateUpiId,
                  ),
                ],
                const SizedBox(height: 32),
                CustomButton(
                  onPressed: _isLoading ? null : _handleSave,
                  isLoading: _isLoading,
                  text: 'SAVE & PROCEED',
                  borderRadius: 16,
                ),
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'CANCEL',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
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
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.primaryColor),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }
}

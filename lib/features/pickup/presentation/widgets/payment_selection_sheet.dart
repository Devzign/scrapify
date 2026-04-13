import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../profile/domain/models/payment_method_model.dart';
import '../../../profile/providers/payment_provider.dart';

class PaymentSelectionSheet extends ConsumerWidget {
  final String payoutType; // 'upi' or 'bank'
  final PaymentMethodModel? selectedMethod;
  final ValueChanged<PaymentMethodModel> onSelect;
  final VoidCallback onAddNew;

  const PaymentSelectionSheet({
    super.key,
    required this.payoutType,
    required this.selectedMethod,
    required this.onSelect,
    required this.onAddNew,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentsAsync = ref.watch(paymentProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Select ${payoutType.toUpperCase()} Detail',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textPrimary,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          const SizedBox(height: 24),
          paymentsAsync.when(
            data: (methods) {
              final filtered = methods
                  .where((m) => m.type == payoutType)
                  .toList();
              if (filtered.isEmpty) {
                return _buildEmptyState(context);
              }
              return Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final method = filtered[index];
                    final isSelected = selectedMethod?.id == method.id;
                    return InkWell(
                      onTap: () {
                        onSelect(method);
                        Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.primaryColor
                                : const Color(0xFFE2E8F0),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            FaIcon(
                              payoutType == 'upi'
                                  ? FontAwesomeIcons.mobileScreenButton
                                  : FontAwesomeIcons.buildingColumns,
                              color: isSelected
                                  ? AppTheme.primaryColor
                                  : AppTheme.textSecondary,
                              size: 18,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    payoutType == 'upi'
                                        ? method.upiId ?? ''
                                        : method.bankName ?? 'Bank Account',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  if (payoutType == 'bank')
                                    Text(
                                      'A/C: ${method.maskedAccountNumber}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check_circle,
                                color: AppTheme.primaryColor,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Text('Error: $err'),
          ),
          const SizedBox(height: 24),
          CustomButton(
            onPressed: onAddNew,
            text: '+ Add New ${payoutType.toUpperCase()}',
            isOutlined: true,
            backgroundColor: AppTheme.primaryColor,
            borderRadius: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Column(
      children: [
        const Text(
          'No payment details found for this method.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

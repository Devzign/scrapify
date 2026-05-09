import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_routes.dart';
import '../../../core/widgets/custom_button.dart';
import '../providers/payment_provider.dart';
import '../domain/models/payment_method_model.dart';

class PaymentMethodsScreen extends ConsumerWidget {
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final paymentState = ref.watch(paymentProvider);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF102213) : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark
            ? const Color(0xFF102213).withValues(alpha: 0.9)
            : Colors.white.withValues(alpha: 0.9),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: isDark ? Colors.white : AppTheme.textPrimary,
            size: 24,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'payment.title'.tr(),
          style: TextStyle(
            color: isDark ? Colors.white : AppTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () =>
                ref.read(paymentProvider.notifier).getPaymentDetails(),
            child: ListView(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: 100,
              ),
              children: [
                paymentState.when(
                  data: (methods) {
                    if (methods.isEmpty) {
                      return Container(
                        margin: const EdgeInsets.only(top: 8, bottom: 24),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 36,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF16311B)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : const Color(0xFFE5E7EB),
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 88,
                              height: 88,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.05)
                                    : AppTheme.backgroundCream,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.account_balance_wallet_outlined,
                                size: 42,
                                color: isDark
                                    ? AppTheme.outline
                                    : AppTheme.textMuted,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              'No payment methods found.',
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white
                                    : AppTheme.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add your bank or UPI details to receive instant payments after scrap pickups.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isDark
                                    ? AppTheme.textMuted
                                    : AppTheme.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: methods.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final method = methods[index];
                        return _buildPaymentCard(
                          context,
                          ref,
                          method: method,
                          isDark: isDark,
                        );
                      },
                    );
                  },
                  loading: () => Container(
                    margin: const EdgeInsets.only(top: 8, bottom: 24),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF16311B) : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  error: (err, stack) => Center(child: Text('Error: $err')),
                ),
                const SizedBox(height: 16),
                // Info hint
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    border: Border.all(
                      color: AppTheme.primaryColor.withValues(alpha: 0.2),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: isDark
                            ? AppTheme.primaryColor
                            : const Color(0xFF0FB825),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'payment.info'.tr(),
                          style: TextStyle(
                            color: isDark
                                ? AppTheme.outline
                                : const Color(0xFF334155),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Action Button Area
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    isDark ? const Color(0xFF102213) : Colors.white,
                    isDark
                        ? const Color(0xFF102213).withValues(alpha: 0.8)
                        : Colors.white.withValues(alpha: 0.8),
                    isDark
                        ? const Color(0xFF102213).withValues(alpha: 0.0)
                        : Colors.white.withValues(alpha: 0.0),
                  ],
                ),
              ),
              child: SafeArea(
                child: CustomButton(
                  onPressed: () => context.push(AppRoutes.addEditPayment),
                  text: 'payment.add_new'.tr(),
                  leading: const Icon(Icons.add),
                  borderRadius: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(
    BuildContext context,
    WidgetRef ref, {
    required PaymentMethodModel method,
    required bool isDark,
  }) {
    final title = method.isBank ? method.bankName ?? 'Bank Account' : 'UPI ID';
    final subtitle = method.isBank
        ? method.maskedAccountNumber
        : method.upiId ?? '';
    final icon = method.isBank
        ? Icons.account_balance
        : Icons.vibration; // UPI icon? Maybe Icons.qr_code

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.textPrimary : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppTheme.textPrimary : AppTheme.hairline,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: method.isDefault
                        ? AppTheme.primaryColor.withValues(alpha: 0.1)
                        : (isDark
                              ? AppTheme.textPrimary
                              : AppTheme.hairline),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: method.isDefault
                        ? (isDark
                              ? AppTheme.primaryColor
                              : const Color(0xFF0FB825))
                        : (isDark
                              ? AppTheme.textMuted
                              : AppTheme.textSecondary),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white
                                  : AppTheme.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (method.isDefault) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withValues(
                                  alpha: 0.2,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'DEFAULT',
                                style: TextStyle(
                                  color: Color(0xFF0FB825),
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: isDark
                              ? AppTheme.textMuted
                              : AppTheme.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: () =>
                      context.push(AppRoutes.addEditPayment, extra: method),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: Text('payment.edit'.tr()),
                  style: TextButton.styleFrom(
                    foregroundColor: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
              ),
              Container(
                width: 1,
                height: 24,
                color: Colors.grey.withValues(alpha: 0.3),
              ),
              Expanded(
                child: TextButton.icon(
                  onPressed: () =>
                      _showDeleteConfirmation(context, ref, method),
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: Text('payment.delete'.tr()),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    PaymentMethodModel method,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Payment Method'),
        content: const Text(
          'Are you sure you want to delete this payment method?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref
                  .read(paymentProvider.notifier)
                  .deletePaymentDetail(method.id);
              if (context.mounted && !success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to delete payment method'),
                  ),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

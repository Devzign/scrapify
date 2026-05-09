import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_shimmer.dart';
import '../../../core/widgets/custom_button.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/models/help_support_ticket_model.dart';
import '../providers/help_support_provider.dart';

class HelpSupportScreen extends ConsumerStatefulWidget {
  final int? orderId;

  const HelpSupportScreen({super.key, this.orderId});

  @override
  ConsumerState<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends ConsumerState<HelpSupportScreen> {
  late final TextEditingController _subjectController;
  late final TextEditingController _messageController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _subjectController = TextEditingController(
      text: widget.orderId != null
          ? 'Need help with order #${widget.orderId}'
          : '',
    );
    _messageController = TextEditingController();
    _phoneController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authProvider);
      if (user != null && _phoneController.text.isEmpty) {
        _phoneController.text = user.phone;
      }
      ref.read(helpSupportProvider.notifier).loadTickets();
    });
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final supportState = ref.watch(helpSupportProvider);

    ref.listen(helpSupportProvider, (prev, next) {
      final previousError = prev?.error;
      if (next.error != null && next.error != previousError) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.error!)));
        ref.read(helpSupportProvider.notifier).clearError();
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Help & Support',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(helpSupportProvider.notifier).loadTickets(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF4FF),
                borderRadius: AppTheme.cardBorderRadius,
                border: Border.all(color: const Color(0xFFBFD3FF)),
              ),
              child: const Text(
                'Still need help? Raise a support request and our team will contact you.',
                style: TextStyle(
                  color: Color(0xFF0A0AC2),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildFormCard(supportState.isSubmitting),
            const SizedBox(height: 20),
            const Text(
              'Previous Requests',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            if (supportState.isLoading)
              _buildPreviousRequestsShimmer()
            else if (supportState.tickets.isEmpty)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppTheme.cardBorderRadius,
                  border: AppTheme.cardBorder,
                  boxShadow: AppTheme.cardShadow,
                ),
                child: const Text(
                  'No support requests yet.',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            else
              ...supportState.tickets.map(_buildTicketCard),
          ],
        ),
      ),
    );
  }

  Widget _buildFormCard(bool isSubmitting) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.cardBorderRadius,
        border: AppTheme.cardBorder,
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          TextField(
            controller: _subjectController,
            decoration: _inputDecoration('Subject'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _messageController,
            minLines: 4,
            maxLines: 6,
            decoration: _inputDecoration('Message'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            decoration: _inputDecoration('Phone number'),
          ),
          const SizedBox(height: 16),
          CustomButton(
            onPressed: isSubmitting ? null : _submit,
            isLoading: isSubmitting,
            text: 'Submit Request',
            borderRadius: 12,
          ),
        ],
      ),
    );
  }

  Widget _buildTicketCard(HelpSupportTicketModel ticket) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
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
            Row(
              children: [
                Expanded(
                  child: Text(
                    ticket.subject,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                if (ticket.status != null)
                  Text(
                    ticket.status.toString().toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              ticket.message,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _formatMeta(ticket.orderId, ticket.createdAt),
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviousRequestsShimmer() {
    return AppShimmer(
      child: Column(
        children: List.generate(3, (index) {
          return Padding(
            padding: EdgeInsets.only(bottom: index == 2 ? 0 : 10),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppTheme.cardBorderRadius,
                border: AppTheme.cardBorder,
                boxShadow: AppTheme.cardShadow,
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ShimmerBox(height: 14, borderRadius: BorderRadius.all(Radius.circular(6))),
                      ),
                      SizedBox(width: 12),
                      ShimmerBox(
                        width: 64,
                        height: 12,
                        borderRadius: BorderRadius.all(Radius.circular(6)),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  ShimmerBox(height: 12, borderRadius: BorderRadius.all(Radius.circular(6))),
                  SizedBox(height: 8),
                  ShimmerBox(height: 12, borderRadius: BorderRadius.all(Radius.circular(6))),
                  SizedBox(height: 10),
                  ShimmerBox(
                    width: 160,
                    height: 11,
                    borderRadius: BorderRadius.all(Radius.circular(6)),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: AppTheme.primaryColor),
      ),
    );
  }

  String _formatMeta(int? orderId, DateTime? createdAt) {
    final dateLabel = createdAt == null
        ? ''
        : DateFormat('dd MMM yyyy, hh:mm a').format(createdAt);
    if (orderId != null && dateLabel.isNotEmpty) {
      return 'Order #$orderId • $dateLabel';
    }
    if (orderId != null) return 'Order #$orderId';
    return dateLabel;
  }

  Future<void> _submit() async {
    final subject = _subjectController.text.trim();
    final message = _messageController.text.trim();
    final phone = _phoneController.text.trim();

    if (subject.isEmpty || message.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill subject, message and phone')),
      );
      return;
    }
    if (!RegExp(r'^\d{10}$').hasMatch(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 10-digit mobile number')),
      );
      return;
    }

    final success = await ref
        .read(helpSupportProvider.notifier)
        .submitTicket(
          subject: subject,
          message: message,
          phone: phone,
          orderId: widget.orderId,
        );

    if (!mounted) return;
    if (success) {
      _messageController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Support request submitted successfully.'),
        ),
      );
    }
  }
}

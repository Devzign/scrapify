import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../channel_partner/providers/channel_partner_provider.dart';
import '../partner_locale.dart';

class PartnerApprovalsPage extends ConsumerStatefulWidget {
  const PartnerApprovalsPage({super.key});

  @override
  ConsumerState<PartnerApprovalsPage> createState() =>
      _PartnerApprovalsPageState();
}

class _PartnerApprovalsPageState extends ConsumerState<PartnerApprovalsPage> {
  String? _statusFilter;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref
          .read(channelPartnerProvider.notifier)
          .loadApprovalRequests(status: _statusFilter),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(channelPartnerProvider);
    final user = ref.watch(authProvider);
    final approvals = state.approvalRequests
        .whereType<Map<String, dynamic>>()
        .toList();

    final pending = approvals
        .where(
          (request) =>
              (request['status']?.toString() ?? '').toLowerCase() == 'pending',
        )
        .length;
    final approved = approvals
        .where(
          (request) =>
              (request['status']?.toString() ?? '').toLowerCase() == 'approved',
        )
        .length;
    final rejected = approvals
        .where(
          (request) =>
              (request['status']?.toString() ?? '').toLowerCase() == 'rejected',
        )
        .length;
    final initial = (user?.name.trim().isNotEmpty ?? false)
        ? user!.name.trim()[0].toUpperCase()
        : 'P';

    return AppScaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                border: const Border(bottom: BorderSide(color: AppTheme.hairline)),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.textPrimary.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppTheme.primaryColor.withValues(
                      alpha: 0.12,
                    ),
                    child: Text(
                      initial,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      context.partnerText(
                        'Approval Requests',
                        'अनुमोदन अनुरोध',
                      ),
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: state.isLoading && approvals.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: () => ref
                          .read(channelPartnerProvider.notifier)
                          .loadApprovalRequests(status: _statusFilter),
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                        children: [
                          Text(
                            context.partnerText(
                              'Track and manage approval updates from your network.',
                              'अपने नेटवर्क के अनुमोदन अपडेट ट्रैक और प्रबंधित करें।',
                            ),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 16),
                          if (state.error != null)
                            AppCard(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(12),
                              color: AppTheme.hintPeach,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppTheme.warningColor.withValues(alpha: 0.35),
                              ),
                              boxShadow: null,
                              child: Text(
                                state.error!,
                                style: TextStyle(
                                  color: AppTheme.warningColor,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          Row(
                            children: [
                              Expanded(
                                child: _buildSummaryCard(
                                  label: context.partnerText(
                                    'Pending',
                                    'लंबित',
                                  ),
                                  value: '$pending',
                                  color: const Color(0xFFD97706),
                                  background: AppTheme.hintPeach,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildSummaryCard(
                                  label: context.partnerText(
                                    'Approved',
                                    'मंजूर',
                                  ),
                                  value: '$approved',
                                  color: AppTheme.primaryColor,
                                  background: AppTheme.primarySurface,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildSummaryCard(
                                  label: context.partnerText(
                                    'Rejected',
                                    'अस्वीकृत',
                                  ),
                                  value: '$rejected',
                                  color: Colors.red,
                                  background: const Color(0xFFFEE2E2),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildStatusFilters(),
                          const SizedBox(height: 16),
                          if (approvals.isEmpty)
                            AppCard(
                              padding: const EdgeInsets.all(28),
                              child: Text(
                                context.partnerText(
                                  'No approval requests found.',
                                  'कोई अनुमोदन अनुरोध नहीं मिला।',
                                ),
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            )
                          else
                            ...approvals.map(_buildApprovalCard),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String label,
    required String value,
    required Color color,
    required Color background,
  }) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilters() {
    final statuses = [
      (null, context.partnerText('All', 'सभी')),
      ('pending', localizedPartnerStatus(context, 'pending')),
      ('approved', localizedPartnerStatus(context, 'approved')),
      ('rejected', localizedPartnerStatus(context, 'rejected')),
    ];

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: statuses.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final status = statuses[index].$1;
          final isSelected = _statusFilter == status;
          return GestureDetector(
            onTap: () {
              setState(() => _statusFilter = status);
              ref
                  .read(channelPartnerProvider.notifier)
                  .loadApprovalRequests(status: status);
            },
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryColor : Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: isSelected ? AppTheme.softShadow : null,
              ),
              child: Text(
                statuses[index].$2,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : Colors.grey.shade600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildApprovalCard(Map<String, dynamic> request) {
    final id = request['id']?.toString() ?? '';
    final title =
        request['title']?.toString() ??
        request['type']?.toString() ??
        context.partnerText('Request', 'अनुरोध');
    final description =
        request['description']?.toString() ??
        request['summary']?.toString() ??
        '';
    final requester =
        request['requester_name']?.toString() ??
        request['requested_by']?.toString() ??
        request['user']?['name']?.toString() ??
        '';
    final createdAt =
        request['created_at']?.toString() ??
        request['request_date']?.toString() ??
        '';
    final warehouseName = request['warehouse_name']?.toString();
    final status = request['status']?.toString() ?? 'pending';
    final isPending = status.toLowerCase() == 'pending';
    final (statusBg, statusFg) = _statusStyle(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    if (id.isNotEmpty)
                      Text(
                        '#$id',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade500,
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  localizedPartnerStatus(context, status),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: statusFg,
                  ),
                ),
              ),
            ],
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              description,
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: Colors.grey.shade600,
              ),
            ),
          ],
          const SizedBox(height: 12),
          if (requester.isNotEmpty)
            _buildMetaRow(
              context.partnerText('Requester', 'अनुरोधकर्ता'),
              requester,
            ),
          if (createdAt.isNotEmpty)
            _buildMetaRow(context.partnerText('Date', 'तारीख'), createdAt),
          if (warehouseName != null && warehouseName.isNotEmpty)
            _buildMetaRow(
              context.partnerText('Warehouse', 'गोदाम'),
              warehouseName,
            ),
          if (isPending) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: ref.watch(channelPartnerProvider).isActionLoading
                        ? null
                        : () => _submitAction(request['id'], 'rejected'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                    child: Text(context.partnerText('Reject', 'अस्वीकार')),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: ref.watch(channelPartnerProvider).isActionLoading
                        ? null
                        : () => _submitAction(request['id'], 'approved'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                    ),
                    child: Text(context.partnerText('Approve', 'मंजूर')),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetaRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF334155),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitAction(dynamic requestId, String action) async {
    if (requestId == null) return;

    final success = await ref
        .read(channelPartnerProvider.notifier)
        .submitStatusRequest({'request_id': requestId, 'status': action});

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            action == 'approved'
                ? context.partnerText('Request approved.', 'अनुरोध मंजूर हुआ।')
                : context.partnerText(
                    'Request rejected.',
                    'अनुरोध अस्वीकार हुआ।',
                  ),
          ),
          backgroundColor: action == 'approved'
              ? AppTheme.primaryColor
              : Colors.red,
        ),
      );
      ref
          .read(channelPartnerProvider.notifier)
          .loadApprovalRequests(status: _statusFilter);
    }
  }

  (Color, Color) _statusStyle(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return (AppTheme.primarySurface, AppTheme.primaryDark);
      case 'rejected':
        return (const Color(0xFFFEE2E2), const Color(0xFFEF4444));
      default:
        return (AppTheme.hintPeach, const Color(0xFF92400E));
    }
  }
}

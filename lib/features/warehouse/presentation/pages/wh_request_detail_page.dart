import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_color.dart';
import '../../domain/models/warehouse_pickup_boy.dart';
import '../../domain/models/warehouse_request.dart';
import '../../providers/warehouse_provider.dart';

class WhRequestDetailPage extends ConsumerStatefulWidget {
  final WarehouseRequest request;

  const WhRequestDetailPage({super.key, required this.request});

  @override
  ConsumerState<WhRequestDetailPage> createState() =>
      _WhRequestDetailPageState();
}

class _WhRequestDetailPageState extends ConsumerState<WhRequestDetailPage> {
  int? _selectedBoyId;
  late WarehouseRequest _request;

  @override
  void initState() {
    super.initState();
    _request = widget.request;
  }

  String _formatScheduledAt(String raw) {
    try {
      final dt = DateTime.parse(raw).toLocal();
      return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = _request;
    final state = ref.watch(warehouseProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBentoContent(r),
                    _buildAgentAssignment(r, state),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColor.hairline)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(
                  Icons.arrow_back_rounded,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Request Detail',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColor.backgroundCream,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_none_rounded,
              color: AppColor.textSecondary,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  (Color, Color, String) _statusStyle(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return (const Color(0xFFEDE9FE), const Color(0xFF7C3AED), 'Completed');
      case 'assigned':
        return (AppTheme.primarySurface, AppTheme.successColor, 'Assigned');
      case 'active':
      case 'in_progress':
        return (AppTheme.hintPeach, AppColor.warning, 'Active');
      case 'rescheduled':
        return (
          const Color(0xFFFCE7F3),
          const Color(0xFFDB2777),
          'Rescheduled',
        );
      case 'cancelled':
        return (AppColor.errorTint, AppColor.error, 'Cancelled');
      default:
        return (AppColor.errorTint, AppColor.error, 'Unassigned');
    }
  }

  Widget _buildBentoContent(WarehouseRequest r) {
    final (statusBg, statusText, statusLabel) = _statusStyle(r.status);
    final isAssignmentBlocked = r.requiresCorporateQuote;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // REQUEST ID - Full width at top
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppTheme.cardBorderRadius,
              border: AppTheme.cardBorder,
              boxShadow: AppTheme.cardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'REQUEST ID',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  r.orderCode,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (isAssignmentBlocked)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColor.hintPeach,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColor.warning.withValues(alpha: 0.25),
                ),
              ),
              child: Text(
                'Corporate quote required before pickup assignment. Submit the estimate from admin first.',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColor.warning,
                  height: 1.4,
                ),
              ),
            )
          else if (r.isCorporate && r.estimatedAmount != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primarySurface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'Corporate quote: Rs ${r.estimatedAmount!.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primaryDark,
                ),
              ),
            ),
          // CUSTOMER DETAILS (left) + STATUS & ITEM SUMMARY (right stacked)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: CUSTOMER DETAILS
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.all(20),
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'CUSTOMER DETAILS / ग्राहक विवरण',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.primaryColor,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  r.customerName,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.textPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          if (r.customerPhone.isNotEmpty)
                            GestureDetector(
                              onTap: () async {
                                final uri = Uri.parse('tel:${r.customerPhone}');
                                if (await canLaunchUrl(uri)) {
                                  launchUrl(uri);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.primaryColor.withValues(
                                        alpha: 0.3,
                                      ),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.call,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        icon: Icons.location_on_rounded,
                        value: r.address,
                        subLabel: 'Full Address / पूरा पता',
                      ),
                      const SizedBox(height: 14),
                      _buildInfoRow(
                        icon: Icons.access_time_rounded,
                        value: _formatScheduledAt(r.scheduledAt),
                        subLabel: 'Scheduled Slot / निर्धारित समय',
                        isBold: true,
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () async {
                          final lat = r.latitude;
                          final lng = r.longitude;
                          Uri uri;
                          if (lat != null && lng != null) {
                            uri = Uri.parse(
                              'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng',
                            );
                          } else if (r.address.isNotEmpty) {
                            uri = Uri.parse(
                              'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(r.address)}',
                            );
                          } else {
                            return;
                          }
                          if (await canLaunchUrl(uri)) {
                            launchUrl(
                              uri,
                              mode: LaunchMode.externalApplication,
                            );
                          }
                        },
                        child: Container(
                          height: 110,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppTheme.hairline,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColor.hairline),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.near_me_rounded,
                                    color: AppTheme.primaryColor,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  const Text(
                                    'Open in Maps',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Right: STATUS BADGE & ITEM SUMMARY (stacked)
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    // Status Badge
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: statusText,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            statusLabel.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: statusText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Item Summary
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withValues(alpha: 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ITEM SUMMARY / वस्तुओं का विवरण',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: Colors.white.withValues(alpha: 0.8),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 18),
                          if (r.itemSummary != null &&
                              r.itemSummary!.isNotEmpty)
                            Text(
                              r.itemSummary!,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.white,
                                height: 1.4,
                              ),
                            )
                          else
                            Text(
                              'No item details.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.6),
                              ),
                            ),
                          const SizedBox(height: 20),
                          if (r.estimatedWeight != null)
                            Container(
                              padding: const EdgeInsets.only(top: 16),
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                    color: Colors.white.withValues(alpha: 0.1),
                                  ),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'EST. WEIGHT',
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: Colors.white.withValues(
                                        alpha: 0.7,
                                      ),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${r.estimatedWeight} kg',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.hairline,
              borderRadius: AppTheme.cardBorderRadius,
              border: AppTheme.cardBorder,
              boxShadow: AppTheme.cardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ASSIGNMENT INFO',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColor.textSecondary,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 12),
                if (r.assignedPickupBoyName != null &&
                    r.assignedPickupBoyName!.isNotEmpty)
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: AppTheme.primaryColor.withValues(
                          alpha: 0.15,
                        ),
                        child: Text(
                          r.assignedPickupBoyName![0].toUpperCase(),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Assigned Agent',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          Text(
                            r.assignedPickupBoyName!,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                else
                  Text(
                    'No pickup boy assigned yet.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColor.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String value,
    required String subLabel,
    bool isBold = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, color: AppColor.textMuted, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
                  color: AppTheme.textPrimary,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subLabel.toUpperCase(),
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: AppColor.textSecondary,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAgentAssignment(WarehouseRequest r, WarehouseState state) {
    final alreadyAssigned = r.assignedPickupBoyId != null;
    final boys = state.assignablePickupBoys;
    final isAssignmentBlocked = r.requiresCorporateQuote;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppTheme.cardBorderRadius,
          border: Border.all(color: AppColor.hairline),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          alreadyAssigned
                              ? 'Reassign Pickup Boy'
                              : 'Assign Pickup Boy',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          isAssignmentBlocked
                              ? 'Quote must be submitted before assignment'
                              : 'Select an available agent near the area',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColor.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: isAssignmentBlocked
                        ? null
                        : () {
                            ref
                                .read(warehouseProvider.notifier)
                                .loadAssignablePickupBoys(r.id);
                          },
                    child: Text(
                      'REFRESH',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: AppColor.backgroundCream),
            if (state.isActionLoading)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (isAssignmentBlocked)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'This corporate booking cannot be assigned until the estimate amount is submitted from admin.',
                  style: TextStyle(fontSize: 13, color: AppColor.textMuted),
                ),
              )
            else if (boys.isEmpty)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Tap REFRESH to load available agents.',
                  style: TextStyle(fontSize: 13, color: AppColor.textMuted),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ...boys.map((boy) => _buildAgentOption(boy, r)),
                    if (_selectedBoyId != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: state.isActionLoading
                                ? null
                                : () => _doAssign(r),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              alreadyAssigned
                                  ? 'Reassign Agent'
                                  : 'Confirm Assignment',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgentOption(WarehousePickupBoy boy, WarehouseRequest r) {
    final isSelected = _selectedBoyId == boy.id;
    final dotColor = boy.isOnline && boy.isAvailable
        ? AppTheme.successColor
        : const Color(0xFFF59E0B);
    final workloadColor = boy.currentAssignmentCount > 2
        ? (AppColor.errorTint, const Color(0xFFB91C1C))
        : boy.currentAssignmentCount > 0
        ? (AppTheme.hintPeach, const Color(0xFFB45309))
        : (AppTheme.primarySurface, const Color(0xFF15803D));

    return GestureDetector(
      onTap: () => setState(() => _selectedBoyId = boy.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withValues(alpha: 0.08)
              : AppTheme.backgroundCream,
          borderRadius: BorderRadius.circular(14),
          border: isSelected
              ? Border.all(color: AppTheme.primaryColor)
              : Border.all(color: Colors.transparent),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppTheme.outline,
                  child: Text(
                    boy.name.isNotEmpty ? boy.name[0].toUpperCase() : 'A',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: dotColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    boy.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: workloadColor.$1,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${boy.currentAssignmentCount} Active',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: workloadColor.$2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: AppTheme.primaryColor,
                size: 20,
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.primaryColor.withValues(alpha: 0.2),
                  ),
                ),
                child: Text(
                  'SELECT',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _doAssign(WarehouseRequest r) async {
    if (_selectedBoyId == null) return;
    if (r.requiresCorporateQuote) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Corporate quote required before pickup assignment.'),
        ),
      );
      return;
    }
    final notifier = ref.read(warehouseProvider.notifier);
    final alreadyAssigned = r.assignedPickupBoyId != null;

    bool success;
    if (alreadyAssigned) {
      success = await notifier.reassignPickupBoy(
        r.id,
        _selectedBoyId!,
        'Reassigned from detail view',
      );
    } else {
      success = await notifier.assignPickupBoy(r.id, _selectedBoyId!);
    }

    if (success && mounted) {
      final selectedBoy = ref
          .read(warehouseProvider)
          .assignablePickupBoys
          .where((boy) => boy.id == _selectedBoyId)
          .cast<WarehousePickupBoy?>()
          .firstWhere((boy) => boy != null, orElse: () => null);

      setState(() {
        _request = _request.copyWith(
          status: 'assigned',
          assignedPickupBoyId: _selectedBoyId,
          assignedPickupBoyName:
              selectedBoy?.name ?? _request.assignedPickupBoyName,
        );
        _selectedBoyId = null;
      });

      ref.read(warehouseProvider.notifier).loadRequests();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            alreadyAssigned
                ? 'Reassigned successfully.'
                : 'Assigned successfully.',
          ),
          backgroundColor: AppTheme.primaryColor,
        ),
      );
      Navigator.pop(context);
    }
  }
}

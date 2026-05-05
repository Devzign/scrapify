import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/models/warehouse_pickup_boy.dart';

class WhPickupBoyDetailPage extends StatelessWidget {
  final WarehousePickupBoy boy;

  const WhPickupBoyDetailPage({super.key, required this.boy});

  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return 'N/A';
    try {
      final dt = DateTime.parse(raw).toLocal();
      return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = boy.isOnline;
    final isAvailable = boy.isAvailable;
    final isOffline = !isOnline;

    final statusLabel = isOffline
        ? 'OFFLINE'
        : isAvailable
            ? 'AVAILABLE'
            : 'ON ROUTE';
    final statusColor = isOffline
        ? Colors.grey.shade400
        : isAvailable
            ? AppTheme.primaryColor
            : const Color(0xFFEA580C);
    final statusBg = isOffline
        ? Colors.grey.shade100
        : isAvailable
            ? const Color(0xFFDCFCE7)
            : const Color(0xFFFEF3C7);
    final dotColor = isOffline
        ? Colors.grey.shade300
        : isAvailable
            ? const Color(0xFF22C55E)
            : const Color(0xFFFB923C);

    final initial = boy.name.isNotEmpty ? boy.name[0].toUpperCase() : '?';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 32),
                children: [
                  // Profile Header
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: AppTheme.cardBorderRadius,
                        border: AppTheme.cardBorder,
                        boxShadow: AppTheme.cardShadow,
                      ),
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              CircleAvatar(
                                radius: 40,
                                backgroundColor: isAvailable
                                    ? AppTheme.primaryLight.withValues(alpha: 0.3)
                                    : Colors.grey.shade100,
                                child: Text(
                                  initial,
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w800,
                                    color: isAvailable
                                        ? AppTheme.primaryDark
                                        : Colors.grey.shade500,
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 2,
                                right: 2,
                                child: Container(
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    color: dotColor,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 3),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            boy.name,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'ID: ${boy.id}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: statusBg,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: statusColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  statusLabel,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: statusColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () async {
                                    final uri = Uri.parse('tel:${boy.phone}');
                                    if (await canLaunchUrl(uri)) {
                                      launchUrl(uri);
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryColor,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.call, color: Colors.white, size: 18),
                                        SizedBox(width: 8),
                                        Text(
                                          'Call',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Stats Row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            '${boy.currentAssignmentCount}',
                            'Active',
                            Icons.assignment_rounded,
                            boy.currentAssignmentCount > 0
                                ? const Color(0xFFFEF3C7)
                                : const Color(0xFFF1F5F9),
                            boy.currentAssignmentCount > 0
                                ? const Color(0xFFD97706)
                                : Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            '${boy.completedCount}',
                            'Completed',
                            Icons.check_circle_rounded,
                            const Color(0xFFDCFCE7),
                            const Color(0xFF15803D),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Contact Info
                  _buildSectionCard(
                    'CONTACT INFORMATION',
                    [
                      _buildDetailRow(Icons.phone_rounded, 'Phone', boy.phone),
                      if (boy.email != null) _buildDetailRow(Icons.email_rounded, 'Email', boy.email!),
                    ],
                  ),

                  // Work Details
                  _buildSectionCard(
                    'WORK DETAILS',
                    [
                      if (boy.vehicleNumber != null)
                        _buildDetailRow(Icons.directions_car_rounded, 'Vehicle', boy.vehicleNumber!),
                      _buildDetailRow(
                        Icons.account_balance_wallet_rounded,
                        'Wallet Balance',
                        '₹ ${boy.walletBalance ?? '0.00'}',
                      ),
                      _buildDetailRow(
                        Icons.access_time_rounded,
                        'Last Active',
                        _formatDate(boy.lastActiveAt),
                      ),
                      _buildDetailRow(
                        Icons.location_on_rounded,
                        'Location Updated',
                        _formatDate(boy.locationUpdatedAt),
                      ),
                      if (boy.latitude != null && boy.longitude != null)
                        _buildDetailRow(
                          Icons.my_location_rounded,
                          'Coordinates',
                          '${boy.latitude!.toStringAsFixed(4)}, ${boy.longitude!.toStringAsFixed(4)}',
                        ),
                    ],
                  ),

                  // Bank Details
                  if (boy.bankName != null ||
                      boy.accountNumber != null ||
                      boy.ifscCode != null ||
                      boy.upiId != null)
                    _buildSectionCard(
                      'BANK DETAILS',
                      [
                        if (boy.bankName != null)
                          _buildDetailRow(Icons.account_balance_rounded, 'Bank', boy.bankName!),
                        if (boy.accountNumber != null)
                          _buildDetailRow(Icons.numbers_rounded, 'Account No.', boy.accountNumber!),
                        if (boy.ifscCode != null)
                          _buildDetailRow(Icons.code_rounded, 'IFSC', boy.ifscCode!),
                        if (boy.upiId != null)
                          _buildDetailRow(Icons.qr_code_rounded, 'UPI ID', boy.upiId!),
                      ],
                    ),

                  // Meta
                  _buildSectionCard(
                    'OTHER INFO',
                    [
                      _buildDetailRow(
                        Icons.calendar_today_rounded,
                        'Joined',
                        _formatDate(boy.createdAt),
                      ),
                      _buildDetailRow(
                        Icons.badge_rounded,
                        'Status',
                        boy.isActive ? 'Active' : 'Inactive',
                      ),
                    ],
                  ),
                ],
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
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
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
            'Agent Details',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String value,
    String label,
    IconData icon,
    Color bg,
    Color fg,
  ) {
    return Container(
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
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: bg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: fg, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
            ),
          ),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: Colors.grey.shade400,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(String title, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Container(
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
              title,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Colors.grey.shade400,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey.shade400, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade500,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class WhRequestsPage extends StatefulWidget {
  const WhRequestsPage({super.key});

  @override
  State<WhRequestsPage> createState() => _WhRequestsPageState();
}

class _WhRequestsPageState extends State<WhRequestsPage> {
  int _selectedFilter = 0;
  final _filters = ['All', 'Unassigned', 'Assigned', 'In Progress', 'Completed', 'Rescheduled'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    _buildFilterChips(),
                    _buildRequestCards(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.warehouse_rounded, color: AppTheme.primaryColor, size: 24),
              const SizedBox(width: 10),
              const Text(
                'Scrapi5 Warehouse',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.notifications_none_rounded,
                color: Colors.grey.shade500, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ACTIVE QUEUE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryColor,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Pickup Requests',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Operational Status',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade500,
                ),
              ),
              Text(
                '12 Requests Pending',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final isSelected = _selectedFilter == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryColor : Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: isSelected
                    ? [BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      )]
                    : null,
              ),
              child: Center(
                child: Text(
                  _filters[index],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.white : Colors.grey.shade600,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRequestCards() {
    final requests = [
      _RequestCardData(
        orderCode: '#SCR-4921',
        customerName: 'Aditi Sharma',
        status: 'Unassigned',
        statusColor: const Color(0xFFFEE2E2),
        statusTextColor: const Color(0xFF991B1B),
        infoIcon: Icons.access_time_rounded,
        infoLabel: 'Scheduled Time',
        infoValue: 'Today, 02:30 PM - 04:00 PM',
        secondInfoIcon: Icons.location_on_rounded,
        secondInfoLabel: 'Address Summary',
        secondInfoValue: 'Vasant Kunj, Sector B, New Delhi',
        actionLabel: 'Assign Driver',
        actionIcon: Icons.person_add_rounded,
        isPrimary: true,
      ),
      _RequestCardData(
        orderCode: '#SCR-5012',
        customerName: 'Rahul Varma',
        status: 'In Progress',
        statusColor: const Color(0xFFDCFCE7),
        statusTextColor: const Color(0xFF14532D),
        infoIcon: Icons.local_shipping_rounded,
        infoLabel: 'Driver Assigned',
        infoValue: 'Suresh Kumar (Truck #DL-04)',
        secondInfoIcon: Icons.location_on_rounded,
        secondInfoLabel: 'Current Location',
        secondInfoValue: '2.4km from Warehouse',
        actionLabel: 'Details',
        showCall: true,
        isPrimary: false,
        bgColor: const Color(0xFFF7F7F7),
      ),
      _RequestCardData(
        orderCode: '#SCR-4889',
        customerName: 'Priya Menon',
        status: 'Assigned',
        statusColor: const Color(0xFFF1F5F9),
        statusTextColor: const Color(0xFF1E293B),
        infoIcon: Icons.access_time_rounded,
        infoLabel: 'Scheduled Time',
        infoValue: 'Tomorrow, 10:00 AM',
        secondInfoIcon: Icons.location_on_rounded,
        secondInfoLabel: 'Address Summary',
        secondInfoValue: 'Golf Course Road, Gurugram',
        actionLabel: 'Manage Assignment',
        isPrimary: false,
      ),
      _RequestCardData(
        orderCode: '#SCR-5100',
        customerName: 'Vikram Singh',
        status: 'Rescheduled',
        statusColor: const Color(0xFFFFD9DF),
        statusTextColor: const Color(0xFF6F3443),
        infoIcon: Icons.event_repeat_rounded,
        infoLabel: 'New Appointment',
        infoValue: 'Oct 24, 09:00 AM',
        secondInfoIcon: Icons.info_rounded,
        secondInfoLabel: 'Reason',
        secondInfoValue: 'Customer unavailable on original date',
        actionLabel: 'Re-assign Priority',
        isPrimary: false,
        infoLabelColor: const Color(0xFF884958),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: requests.map((r) => _buildCard(r)).toList(),
      ),
    );
  }

  Widget _buildCard(_RequestCardData r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: r.bgColor ?? Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'ORDER CODE  ',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: Colors.grey.shade400,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Text(
                        r.orderCode,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    r.customerName,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: r.statusColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  r.status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: r.statusTextColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Info rows
          _buildDetailRow(
            icon: r.infoIcon,
            label: r.infoLabel,
            value: r.infoValue,
            labelColor: r.infoLabelColor ?? AppTheme.primaryColor,
          ),
          const SizedBox(height: 10),
          _buildDetailRow(
            icon: r.secondInfoIcon,
            label: r.secondInfoLabel,
            value: r.secondInfoValue,
            labelColor: r.infoLabelColor ?? AppTheme.primaryColor,
          ),
          const SizedBox(height: 20),
          // Action
          if (r.isPrimary)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: Icon(r.actionIcon, size: 18),
                label: Text(
                  r.actionLabel,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            )
          else if (r.showCall)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade200),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      r.actionLabel,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.call, color: AppTheme.primaryColor, size: 20),
                  ),
                ),
              ],
            )
          else
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey.shade200),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  r.actionLabel,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required Color labelColor,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey.shade500, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: labelColor,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RequestCardData {
  final String orderCode;
  final String customerName;
  final String status;
  final Color statusColor;
  final Color statusTextColor;
  final IconData infoIcon;
  final String infoLabel;
  final String infoValue;
  final IconData secondInfoIcon;
  final String secondInfoLabel;
  final String secondInfoValue;
  final String actionLabel;
  final IconData? actionIcon;
  final bool isPrimary;
  final bool showCall;
  final Color? bgColor;
  final Color? infoLabelColor;

  const _RequestCardData({
    required this.orderCode,
    required this.customerName,
    required this.status,
    required this.statusColor,
    required this.statusTextColor,
    required this.infoIcon,
    required this.infoLabel,
    required this.infoValue,
    required this.secondInfoIcon,
    required this.secondInfoLabel,
    required this.secondInfoValue,
    required this.actionLabel,
    this.actionIcon,
    this.isPrimary = false,
    this.showCall = false,
    this.bgColor,
    this.infoLabelColor,
  });
}

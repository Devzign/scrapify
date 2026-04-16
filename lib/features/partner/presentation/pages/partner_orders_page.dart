import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class PartnerOrdersPage extends StatefulWidget {
  const PartnerOrdersPage({super.key});

  @override
  State<PartnerOrdersPage> createState() => _PartnerOrdersPageState();
}

class _PartnerOrdersPageState extends State<PartnerOrdersPage> {
  final String _selectedStatus = 'All Statuses';
  final String _selectedWarehouse = 'North Hub';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
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
                    _buildSearchBar(),
                    _buildFilterBento(),
                    _buildOrderCards(),
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
              Icon(Icons.menu, color: Colors.grey.shade500),
              const SizedBox(width: 12),
              const Text(
                'Emerald Moss',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.notifications_none_rounded,
                    color: Colors.grey.shade500, size: 22),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Active Orders',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'सक्रिय ऑर्डर',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Manage and track your regional distribution requests.',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppTheme.softShadow,
        ),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Search Order ID or Customer...',
            hintStyle: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade400,
            ),
            prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterBento() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.8,
        children: [
          _buildFilterCard(
            icon: Icons.filter_list,
            label: 'STATUS स्थिति',
            value: _selectedStatus,
            isDropdown: true,
          ),
          _buildFilterCard(
            icon: Icons.calendar_today,
            label: 'DATE दिनांक',
            value: 'Today, 24 Oct',
          ),
          _buildFilterCard(
            icon: Icons.warehouse_rounded,
            label: 'WAREHOUSE गोदाम',
            value: _selectedWarehouse,
            isDropdown: true,
          ),
          _buildFilterCard(
            icon: Icons.badge_rounded,
            label: 'AGENT एजेंट',
            value: 'All Agents',
          ),
        ],
      ),
    );
  }

  Widget _buildFilterCard({
    required IconData icon,
    required String label,
    required String value,
    bool isDropdown = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppTheme.primaryColor, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: Colors.grey.shade400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isDropdown)
                Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade400, size: 16),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCards() {
    final orders = [
      _OrderCardData(
        name: 'Arjun Sharma',
        orderId: '#EM-90214',
        placedOn: 'Oct 24, 10:30 AM',
        warehouse: 'Central Distribution Hub',
        agentName: 'Rahul V.',
        agentStatus: '(Active)',
        status: 'In Transit',
        statusColor: const Color(0xFFDCFCE7),
        statusTextColor: const Color(0xFF14532D),
        hasAgent: true,
        avatarUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDfpOc-3MKZ5vYIR_qMPgDPDPKXQrxHaYhv8DYfbrlPg2xGX6estbjexWkHST8D5wRoe7rMGsiCz-icgdVZN0SezZGtko3qFEW2jNkArR0LNS-BWxqKOZlSgf4c2_OpZDxq-xMaEMQuydV5kab5EXtAvQJCJkdRAacIfhfpY-YKpcxe0klEpf4oxXZ1Yp1ot0bKCXZkQrrp1c6qm8V4G19qWs4Kdxb-H4PckRUrEfOD8aXKRe5FDB2KgZWiIxORpfy1go7htJBlf6Y',
        buttonColor: const Color(0xFF0F172A),
        buttonText: 'View Details',
      ),
      _OrderCardData(
        name: 'Priya Kapur',
        orderId: '#EM-90215',
        placedOn: 'Oct 24, 11:15 AM',
        warehouse: 'North Sector Terminal',
        agentName: 'Assign Agent Now',
        agentStatus: '',
        status: 'Pending',
        statusColor: const Color(0xFFFEF3C7),
        statusTextColor: const Color(0xFF92400E),
        hasAgent: false,
        avatarUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDUCbzl2r47Ul4vqPuvB74GvTc0JicnlwxdRegwPgqlifqGEcmkPWA0DGL5L1Rh_ErAhgoqUmoK_HG6-DH07HU3m45L8CCBTd_iBqnKG3ph3L8rkvVfzHaNp_XkERUOfT4viB-R3IQXyqDie6NdeMdkOEuUEs7aog1cSGF5CtqZop9SSJ8AA3eSevLjRpQUhEls9jzAW2ZQPjoA7_yFzkE7byfz5Wp5OVc7W6FcdiGFrEi3LlRQS0TdcfMJT9E3UPZKBgQM5osQlLA',
        buttonColor: const Color(0xFF0F172A),
        buttonText: 'View Details',
      ),
      _OrderCardData(
        name: 'Vikram Rao',
        orderId: '#EM-90199',
        placedOn: 'Oct 23, 04:50 PM',
        warehouse: 'South Center Base',
        agentName: 'Sanjay M.',
        agentStatus: '(Completed)',
        status: 'Delivered',
        statusColor: const Color(0xFFF1F5F9),
        statusTextColor: const Color(0xFF64748B),
        hasAgent: true,
        avatarUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCcnCfEzYQvUOTarSGcZGlE2vIsga9CCvuwkDeHZMrfITKnGPMYXXGtw7MMt6IyWSWf3DQSjoPNErwywpwATFddpvjGIJwvyS6I7IlYnLNGsPSAxlHt9_yGDUXXZlSsrvUG6VuNQmPTmDBRTpqyJQ8kcHufGpzQdSLzGZUikWu9ohQV580vH-jNfE3AFYERg4eDEBGW_I4p6-iO_DQzJh75kPMcVhBuIVfsindsxXmuEa_uZEQ-m2_4YSnXoJh9DtAaFxArTvoCPjE',
        buttonColor: const Color(0xFFF1F5F9),
        buttonText: 'Review Order',
        buttonTextColor: const Color(0xFF94A3B8),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: orders.map((order) => _buildOrderDetailCard(order)).toList(),
      ),
    );
  }

  Widget _buildOrderDetailCard(_OrderCardData order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.softShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFF1F5F9),
                      ),
                      child: ClipOval(
                        child: Image.network(
                          order.avatarUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.person,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          'Customer ग्राहक',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade400,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: order.statusColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    order.status,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: order.statusTextColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Order ID & Placed On
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border.symmetric(
                  horizontal: BorderSide(color: Colors.grey.shade50),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ORDER ID',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade400,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          order.orderId,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'monospace',
                            color: Color(0xFF334155),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PLACED ON',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade400,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          order.placedOn,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF334155),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Warehouse row
            _buildInfoRow(
              icon: Icons.warehouse_rounded,
              iconColor: Colors.grey.shade500,
              label: 'Warehouse',
              value: order.warehouse,
            ),
            const SizedBox(height: 8),
            // Agent row
            _buildInfoRow(
              icon: order.hasAgent ? Icons.moped_rounded : Icons.add_circle_rounded,
              iconColor: order.hasAgent ? Colors.grey.shade500 : AppTheme.primaryColor,
              label: 'Pickup Boy',
              value: order.hasAgent
                  ? '${order.agentName} ${order.agentStatus}'
                  : order.agentName,
              valueColor: order.hasAgent ? null : AppTheme.primaryColor,
              bgColor: order.hasAgent ? null : AppTheme.primaryColor.withValues(alpha: 0.1),
            ),
            const SizedBox(height: 16),
            // CTA Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: order.buttonColor,
                  foregroundColor: order.buttonTextColor ?? Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      order.buttonText,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      order.buttonText == 'Review Order'
                          ? Icons.visibility
                          : Icons.chevron_right,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    Color? valueColor,
    Color? bgColor,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: bgColor ?? const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade400,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: valueColor ?? const Color(0xFF334155),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _OrderCardData {
  final String name;
  final String orderId;
  final String placedOn;
  final String warehouse;
  final String agentName;
  final String agentStatus;
  final String status;
  final Color statusColor;
  final Color statusTextColor;
  final bool hasAgent;
  final String avatarUrl;
  final Color buttonColor;
  final String buttonText;
  final Color? buttonTextColor;

  const _OrderCardData({
    required this.name,
    required this.orderId,
    required this.placedOn,
    required this.warehouse,
    required this.agentName,
    required this.agentStatus,
    required this.status,
    required this.statusColor,
    required this.statusTextColor,
    required this.hasAgent,
    required this.avatarUrl,
    required this.buttonColor,
    required this.buttonText,
    this.buttonTextColor,
  });
}

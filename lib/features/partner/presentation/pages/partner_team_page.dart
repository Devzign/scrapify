import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class PartnerTeamPage extends StatelessWidget {
  const PartnerTeamPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.person_add_rounded, color: Colors.white, size: 28),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 80),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    _buildAgentCards(),
                    _buildTeamEfficiency(),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Team Management',
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
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'टीम प्रबंधन',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF14532D),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Monitoring 24 field agents across 4 warehouse zones.',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade100),
              boxShadow: AppTheme.softShadow,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check_circle, color: AppTheme.primaryColor, size: 20),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ONLINE NOW',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: Colors.grey.shade400,
                        letterSpacing: 1,
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(fontFamily: 'Inter'),
                        children: [
                          const TextSpan(
                            text: '18 ',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          TextSpan(
                            text: '/ 24',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade300,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgentCards() {
    final agents = [
      _AgentData(
        name: 'Arjun Mehta',
        id: 'EM-AG-102',
        warehouse: 'North Hub - Sector 12',
        status: 'Available for Pickup',
        statusLabel: 'Online',
        statusHindi: 'ऑनलाइन',
        isOnline: true,
        isBusy: false,
        isInactive: false,
        statusBgColor: const Color(0xFFDCFCE7),
        statusTextColor: AppTheme.primaryColor,
        avatarUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAPT0HUOvwRlar9SuJcvHfFHa8pXllhbNw0KynfaQgIm2reWs94pjruxj4pS4pFI0RWA4fmmPli1zsLpAFv3NwtUihiTujBrTfneIJaHO2GAdwPtrsqs2GVIzAM_Z3AixGoEhNzMC9VkDtzZXyrk9w0P20X4s2pGzYttVqI-a6ZBfBzCGR7QOlGVLx7t0P9HhkUmzUmsaBeM--Qr-msaf5sfxrZSSv-xmHPuEZYvbLerPzQlsL_Kt-t2t03s_Z7nx5TE3Zt-NzkhGg',
        showCall: true,
        actionLabel: 'View History',
        actionIcon: Icons.chevron_right,
      ),
      _AgentData(
        name: 'Priya Sharma',
        id: 'EM-AG-244',
        warehouse: 'East Terminal',
        status: 'Unavailable',
        statusLabel: 'Offline',
        statusHindi: 'ऑफलाइन',
        isOnline: false,
        isBusy: false,
        isInactive: false,
        statusBgColor: const Color(0xFFF1F5F9),
        statusTextColor: const Color(0xFF64748B),
        avatarUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCQst5jpm8BTT3DMVceDfBRZyuaRSINMi9ARmfHkEnA-7CHytRlU8xcWSYWo1QTwjnZgoqTgm55ubTT6SekUz18CI1acHLY2WmHxPdYJjlzhDtiAk6jd1t-hHd8gFf4S9sCfinrB2C2-85eb6yHLzLfJszJMJcQzTkmdKFCwacopRAMJfduK_dObZS6Rc2qKUHZ_Fa8Ktil0815lopvTziztoVuurZay1FjbWhpszqa-VKYfc7Uhvsm0cONLpJI7EzP9Cc0BkfE4X4',
        showCall: false,
        actionLabel: 'View History',
        actionIcon: Icons.chevron_right,
        isGrayscale: true,
      ),
      _AgentData(
        name: 'Vikram Singh',
        id: 'EM-AG-089',
        warehouse: 'South Dock',
        status: 'On Active Route',
        statusLabel: 'Busy',
        statusHindi: 'व्यस्त',
        isOnline: true,
        isBusy: true,
        isInactive: false,
        statusBgColor: const Color(0xFFFEF9C3),
        statusTextColor: const Color(0xFFD97706),
        avatarUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBvtxocjwlzdOsIs_OcX1SAIaH-SyIN5vfU5Obspt3LfsQKxWNsz9wnZbK1judbWjhzfncdWU-QM3sOa_KzSKYapefKGSUITA1e5B47Usd2yvtU5EI3GXcrz6Mxju0DH5DCdf8Aw4bnrFu1HKwcbZ5IPfvuxMCwRRISkLL4b3WSqQVHP2YflCeqCQbFd1t342RSRu8ri934l8-gXgr1yVbKXyJUYRTyc2OecEBQcjtLWwNYSQaZSwfHj8031CbJY1jXWacA5Ie9bI4',
        showCall: true,
        actionLabel: 'View Map',
        actionIcon: Icons.near_me,
      ),
      _AgentData(
        name: 'Rahul K. (On Leave)',
        id: 'EM-AG-441',
        warehouse: 'Unassigned',
        status: 'Back on 15 Oct',
        statusLabel: 'Inactive',
        statusHindi: 'निष्क्रिय',
        isOnline: false,
        isBusy: false,
        isInactive: true,
        statusBgColor: const Color(0xFFFEE2E2),
        statusTextColor: const Color(0xFFEF4444),
        avatarUrl: '',
        showCall: false,
        actionLabel: 'Edit Profile',
        actionIcon: Icons.edit,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: agents.map((agent) => _buildAgentCard(agent)).toList(),
      ),
    );
  }

  Widget _buildAgentCard(_AgentData agent) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar + Status Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: const Color(0xFFF1F5F9),
                          ),
                          child: agent.avatarUrl.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: ColorFiltered(
                                    colorFilter: agent.isGrayscale
                                        ? const ColorFilter.mode(
                                            Colors.grey, BlendMode.saturation)
                                        : const ColorFilter.mode(
                                            Colors.transparent, BlendMode.multiply),
                                    child: Image.network(
                                      agent.avatarUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Icon(
                                        Icons.person,
                                        color: Colors.grey.shade400,
                                        size: 32,
                                      ),
                                    ),
                                  ),
                                )
                              : Center(
                                  child: Icon(Icons.person,
                                      color: Colors.grey.shade300, size: 32),
                                ),
                        ),
                        if (agent.isOnline)
                          Positioned(
                            bottom: -2,
                            right: -2,
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3),
                              ),
                            ),
                          ),
                        if (!agent.isOnline && !agent.isInactive)
                          Positioned(
                            bottom: -2,
                            right: -2,
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3),
                              ),
                            ),
                          ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: agent.statusBgColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            agent.statusLabel,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: agent.statusTextColor,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          agent.statusHindi,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Name & ID
                Text(
                  agent.name,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: agent.isInactive
                        ? Colors.grey.shade400
                        : const Color(0xFF0F172A),
                    fontStyle: agent.isInactive ? FontStyle.italic : FontStyle.normal,
                  ),
                ),
                Text(
                  'ID: ${agent.id}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 12),
                // Info rows
                Opacity(
                  opacity: agent.isInactive ? 0.6 : 1.0,
                  child: Column(
                    children: [
                      _buildAgentInfoRow(
                        icon: Icons.warehouse_rounded,
                        iconColor: Colors.grey.shade400,
                        label: 'Warehouse',
                        value: agent.warehouse,
                      ),
                      const SizedBox(height: 8),
                      _buildAgentInfoRow(
                        icon: agent.isBusy
                            ? Icons.local_shipping_rounded
                            : agent.isInactive
                                ? Icons.event_busy_rounded
                                : agent.isOnline
                                    ? Icons.task_alt_rounded
                                    : Icons.block_rounded,
                        iconColor: agent.isBusy
                            ? const Color(0xFFD97706)
                            : agent.isOnline
                                ? AppTheme.primaryColor
                                : Colors.grey.shade400,
                        label: 'Status',
                        value: agent.status,
                        valueColor: agent.isBusy
                            ? const Color(0xFFD97706)
                            : agent.isOnline
                                ? AppTheme.primaryColor
                                : Colors.grey.shade500,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Footer Actions
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAFA),
              border: Border(top: BorderSide(color: Colors.grey.shade50)),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment:
                  agent.showCall ? MainAxisAlignment.spaceBetween : MainAxisAlignment.end,
              children: [
                if (agent.showCall)
                  Row(
                    children: [
                      Icon(Icons.call, size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(
                        'Call',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                Row(
                  children: [
                    Text(
                      agent.actionLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(agent.actionIcon, size: 14, color: AppTheme.primaryColor),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgentInfoRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 18),
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
                  color: valueColor ?? const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTeamEfficiency() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Efficiency card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppTheme.softShadow,
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Team Efficiency',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Average pickups per agent has increased by 14% this month.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 20),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.6,
                  children: [
                    _buildEfficiencyChip('Avg Time', '24m'),
                    _buildEfficiencyChip('Daily Trips', '142'),
                    _buildEfficiencyChip('Top Perf', 'Arjun M.'),
                    _buildEfficiencyChip('Zone Load', 'High'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Scale Your Force CTA
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -16,
                  top: -16,
                  child: Opacity(
                    opacity: 0.2,
                    child: Transform.rotate(
                      angle: 0.2,
                      child: const Icon(Icons.group_add_rounded,
                          color: Colors.white, size: 80),
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Scale Your Force',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Require more hands for the festive season? Onboard new agents instantly.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppTheme.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 4,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Start Recruitment',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(Icons.arrow_forward, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildEfficiencyChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _AgentData {
  final String name;
  final String id;
  final String warehouse;
  final String status;
  final String statusLabel;
  final String statusHindi;
  final bool isOnline;
  final bool isBusy;
  final bool isInactive;
  final Color statusBgColor;
  final Color statusTextColor;
  final String avatarUrl;
  final bool showCall;
  final String actionLabel;
  final IconData actionIcon;
  final bool isGrayscale;

  const _AgentData({
    required this.name,
    required this.id,
    required this.warehouse,
    required this.status,
    required this.statusLabel,
    required this.statusHindi,
    required this.isOnline,
    required this.isBusy,
    required this.isInactive,
    required this.statusBgColor,
    required this.statusTextColor,
    required this.avatarUrl,
    required this.showCall,
    required this.actionLabel,
    required this.actionIcon,
    this.isGrayscale = false,
  });
}

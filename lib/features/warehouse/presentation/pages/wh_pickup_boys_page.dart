import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class WhPickupBoysPage extends StatelessWidget {
  const WhPickupBoysPage({super.key});

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
                    _buildStatusBento(),
                    _buildAgentCards(),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Agent Fleet',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'FIELD OPERATIONS / फ़ील्ड ऑपरेशंस',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Colors.grey.shade500,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          // Search bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: AppTheme.softShadow,
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by name or ID...',
                hintStyle: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade400,
                ),
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBento() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Active Agents Card (Green)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(Icons.engineering_rounded,
                        color: AppTheme.primaryColor, size: 36),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'LIVE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF14532D),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  '12',
                  style: TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF14532D),
                    height: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Active Pickup Boys',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF14532D).withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Route Stats
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: AppTheme.softShadow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.route_rounded,
                                color: Colors.grey.shade600, size: 22),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'AVAILABILITY',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                              Text(
                                '82%',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '8 On Route',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        'En-route / रास्ते में',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Efficiency
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.task_alt_rounded,
                            color: Colors.white, size: 22),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '148',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'DAILY COMPLETIONS',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: Colors.grey.shade500,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAgentCards() {
    final agents = [
      _AgentData(
        name: 'Arjun Sharma',
        id: '#SB-9021',
        status: 'AVAILABLE / उपलब्ध',
        statusColor: AppTheme.primaryColor,
        dotColor: const Color(0xFF22C55E),
        borderColor: AppTheme.primaryColor,
        activeCount: '2',
        completedCount: '24',
        isGrayscale: false,
        actionLabel: 'Assign',
        actionIcon: Icons.call,
        canAssign: true,
        avatarUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBo628LJQFlxCpaV-xJJE8LuqD7FS4IJhLUhlmU8sQr2fsH7QkYklt8mx71HVqsaEs-6jnyr1sZ4U-wMA01sYCD4LimU8onS3mx1tykswFPXwEhbWwbm9FSwJJU_1S29Xkxl2hd3ptuAB9MMsI83HyyloCkKD0cRrdOCHypvpYRngbFEmCWRlFN9AK7qzwF0VH8o3xu5vTopFBJNtLKIov8P-ASd8lAF2oKEyLk3n3ZwVpas4fvBRWOfZCtmdcNUUAMrBGtObUDV7M',
      ),
      _AgentData(
        name: 'Rahul Verma',
        id: '#SB-9044',
        status: 'ON ROUTE / रास्ते में',
        statusColor: const Color(0xFFEA580C),
        dotColor: const Color(0xFFFB923C),
        borderColor: Colors.grey.shade200,
        activeCount: '5',
        completedCount: '18',
        isGrayscale: true,
        actionLabel: 'Full',
        actionIcon: Icons.location_on_rounded,
        canAssign: false,
        avatarUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBwG7cP66KJO48A9mJXR3PN7Hu8eOZEZZqug0IE-suq85npDxLIKbnHKNSp4_UUUzdlxSs5F_rO0ic3sWe3Tklzb_Cb2zV7yH9CHQxeCArA28SkOaqwHYQdsXKD0n9spIaaxTYfkAHU0sNuBYiphDP4bKwNuzTgA0sxe-CWk7za0XENgcrEJHb9lW5sPNOjMWK-vZncJLuPPEozkvFPOArH3wirZvDduC7LwjcnFiJ6pTibWE6ueNjMG6wrQFJiGBTJpAhalLiqPrI',
      ),
      _AgentData(
        name: 'Priya Das',
        id: '#SB-8821',
        status: 'OFFLINE / ऑफलाइन',
        statusColor: Colors.grey.shade400,
        dotColor: Colors.grey.shade300,
        borderColor: Colors.grey.shade100,
        activeCount: '0',
        completedCount: '32',
        isGrayscale: true,
        isOffline: true,
        actionLabel: 'Manage',
        actionIcon: Icons.history_rounded,
        canAssign: false,
        avatarUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuD-Zq1HocENgXBMwZaH9Rd43eFg47Saktc_zh6NjhywX2Q-ESF-aJzM_tlQC7GT7mRvaN28poGzZt-rlSdWoHZd08gx1xYlpg0vp7xulzCLSB4Fs6a6hfXputfiC1ULbCmiMWDpGHr_vWYAjwQo3sln64oYfEqHTP4D2gbMSfOcanSHao6AzPO4jxO3z-QeRUtWXLWuRtVBVz_XGXIMPI0zncmKu_M83vwNKYOQ6t4XF2upuiyPAxzbZTApbwRiFcd037hd0grrSC4',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: agents.map((a) => _buildAgentCard(a)).toList(),
      ),
    );
  }

  Widget _buildAgentCard(_AgentData agent) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.softShadow,
        border: Border(
          left: BorderSide(
            color: agent.borderColor,
            width: 4,
          ),
        ),
      ),
      child: Opacity(
        opacity: agent.isOffline ? 0.75 : 1.0,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Agent Info Row
              Row(
                children: [
                  // Avatar
                  Stack(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFF1F5F9),
                        ),
                        child: ClipOval(
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
                                size: 28,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: agent.dotColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  // Name & Status
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              agent.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'ID: ${agent.id}',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          agent.status,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: agent.statusColor,
                            fontStyle: agent.statusColor == const Color(0xFFEA580C)
                                ? FontStyle.italic
                                : FontStyle.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Stats + Actions Row
              Row(
                children: [
                  // Stats
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        border: Border.symmetric(
                          vertical: BorderSide(color: Colors.grey.shade50),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatColumn(agent.activeCount, 'Active',
                              agent.isOffline ? Colors.grey.shade400 : null),
                          _buildStatColumn(agent.completedCount, 'Completed', null),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Actions
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: () {},
                      icon: Icon(agent.actionIcon,
                          color: Colors.grey.shade600, size: 22),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: agent.canAssign ? () {} : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: agent.canAssign
                          ? const Color(0xFF0F172A)
                          : const Color(0xFFF1F5F9),
                      foregroundColor: agent.canAssign
                          ? Colors.white
                          : Colors.grey.shade400,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      agent.actionLabel,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(String value, String label, Color? valueColor) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: valueColor ?? const Color(0xFF0F172A),
          ),
        ),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            color: Colors.grey.shade400,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class _AgentData {
  final String name;
  final String id;
  final String status;
  final Color statusColor;
  final Color dotColor;
  final Color borderColor;
  final String activeCount;
  final String completedCount;
  final bool isGrayscale;
  final bool isOffline;
  final String actionLabel;
  final IconData actionIcon;
  final bool canAssign;
  final String avatarUrl;

  const _AgentData({
    required this.name,
    required this.id,
    required this.status,
    required this.statusColor,
    required this.dotColor,
    required this.borderColor,
    required this.activeCount,
    required this.completedCount,
    required this.isGrayscale,
    required this.actionLabel,
    required this.actionIcon,
    required this.canAssign,
    required this.avatarUrl,
    this.isOffline = false,
  });
}

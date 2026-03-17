import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/theme/app_theme.dart';

class PickupBoyDashboard extends StatefulWidget {
  const PickupBoyDashboard({super.key});

  @override
  State<PickupBoyDashboard> createState() => _PickupBoyDashboardState();
}

class _PickupBoyDashboardState extends State<PickupBoyDashboard> {
  bool _isActive = true;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundLight,
        appBar: AppBar(
          title: Text(
            'pickup_dashboard.title'.tr(),
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          actions: [
            Row(
              children: [
                Text(
                  _isActive
                      ? 'pickup_dashboard.active'.tr()
                      : 'pickup_dashboard.offline'.tr(),
                  style: TextStyle(
                    color: _isActive ? AppTheme.primaryColor : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Switch(
                  value: _isActive,
                  onChanged: (val) {
                    setState(() => _isActive = val);
                  },
                  activeTrackColor: AppTheme.primaryColor.withValues(
                    alpha: 0.5,
                  ),
                  activeThumbColor: AppTheme.primaryColor,
                ),
              ],
            ),
          ],
          bottom: TabBar(
            labelColor: AppTheme.primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppTheme.primaryColor,
            indicatorWeight: 3,
            tabs: [
              Tab(
                child: Text(
                  'pickup_dashboard.pending'.tr(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Tab(
                child: Text(
                  'pickup_dashboard.completed'.tr(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Pending Pickups Tab
            _buildPickupList(context),
            // Completed Tab (Placeholder)
            Center(child: Text('pickup_dashboard.no_completed'.tr())),
          ],
        ),
      ),
    );
  }

  Widget _buildPickupList(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3, // Mock data
      itemBuilder: (context, index) {
        return _buildPickupCard(index);
      },
    );
  }

  Widget _buildPickupCard(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: ID and Time
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '#OD-${4921 + index}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryDark,
                    fontSize: 12,
                  ),
                ),
              ),
              Text(
                '${'pickup_dashboard.today'.tr()} 02:00 PM',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Body: Customer Info
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: NetworkImage(
                      'https://i.pravatar.cc/100?img=${10 + index}',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Amit Sharma',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const FaIcon(
                          FontAwesomeIcons.locationDot,
                          size: 12,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '2.5 km ${'pickup_dashboard.away'.tr()}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Quick Actions
              Row(
                children: [
                  _buildQuickActionButton(
                    icon: FontAwesomeIcons.phone,
                    color: Colors.blue,
                    onPressed: () {},
                  ),
                  const SizedBox(width: 8),
                  _buildQuickActionButton(
                    icon: FontAwesomeIcons.mapLocationDot,
                    color: Colors.red,
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Details
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'pickup_dashboard.items'.tr(),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const Text(
                      'Newspaper, E-Waste',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'pickup_dashboard.est_weight'.tr(),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const Text(
                      '~ 15 kg',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade300),
                    foregroundColor: AppTheme.textSecondary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text('pickup_dashboard.reschedule'.tr()),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const FaIcon(
                        FontAwesomeIcons.play,
                        size: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text('pickup_dashboard.start_pickup'.tr()),
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

  Widget _buildQuickActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: FaIcon(icon, size: 16, color: color),
      ),
    );
  }
}

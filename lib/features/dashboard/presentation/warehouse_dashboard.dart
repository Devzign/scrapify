import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/app_routes.dart';
import '../../../core/theme/app_theme.dart';

class WarehouseDashboard extends StatelessWidget {
  const WarehouseDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const FaIcon(FontAwesomeIcons.store, color: AppTheme.primaryColor, size: 16),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Namaste, Team A',
                  style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
                const Text(
                  'Warehouse Dashboard',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(icon: const FaIcon(FontAwesomeIcons.bell, color: AppTheme.textPrimary), onPressed: () => context.push(AppRoutes.notifications)),
              Positioned(
                top: 12,
                right: 12,
                child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Stats Row
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const FaIcon(FontAwesomeIcons.truckFast, color: Colors.white, size: 20),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                              child: const Text('TODAY', style: TextStyle(color: AppTheme.primaryColor, fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text('2,400', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                            SizedBox(width: 4),
                            Text('kg', style: TextStyle(color: Colors.white, fontSize: 16)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text('Inbound Today', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E2A5E), // Dark Navy
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const FaIcon(FontAwesomeIcons.recycle, color: Colors.white, size: 20),
                        const SizedBox(height: 24),
                        const Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text('150', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                            SizedBox(width: 4),
                            Text('Units', style: TextStyle(color: Colors.white, fontSize: 16)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text('Ready for Processing', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            // Recent Shipments
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Recent Shipments', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                Row(
                  children: const [
                    Text('Filter', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                    SizedBox(width: 4),
                    FaIcon(FontAwesomeIcons.filter, size: 12, color: AppTheme.textSecondary),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildShipmentCard(
              title: 'E-Waste Mix',
              id: '#SCR-2049',
              supplier: 'Ravi Scrap Dealers',
              time: '12 mins ago',
              weight: '450 kg',
              status: 'pending',
            ),
            const SizedBox(height: 16),
            _buildShipmentCard(
              title: 'Mixed Metals',
              id: '#SCR-2048',
              supplier: 'Individual: Amit Kumar',
              time: '45 mins ago',
              weight: '120 kg',
              status: 'pending',
            ),
            const SizedBox(height: 16),
            _buildShipmentCard(
              title: 'Batteries',
              id: '#SCR-2045',
              supplier: 'Green City Recyclers',
              time: '2h ago',
              weight: '800 kg',
              status: 'received',
            ),
            
            const SizedBox(height: 100), // Bottom padding for navbar
          ],
        ),
      ),
      bottomNavigationBar: _buildMockNavBar(),
    );
  }

  Widget _buildShipmentCard({
    required String title,
    required String id,
    required String supplier,
    required String time,
    required String weight,
    required String status,
  }) {
    final isReceived = status == 'received';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: isReceived ? Colors.blue.shade50 : AppTheme.primaryLight, shape: BoxShape.circle),
                child: FaIcon(
                  isReceived ? FontAwesomeIcons.batteryFull : (title.contains('Mix') ? FontAwesomeIcons.microchip : FontAwesomeIcons.screwdriverWrench),
                  color: isReceived ? Colors.blue : AppTheme.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(id, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isReceived ? Colors.green.shade50 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isReceived ? 'RECEIVED' : weight,
                  style: TextStyle(
                    color: isReceived ? Colors.green.shade700 : AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.grey.shade200),
          const SizedBox(height: 16),
          Row(
            children: [
              const FaIcon(FontAwesomeIcons.building, size: 14, color: AppTheme.textSecondary),
              const SizedBox(width: 8),
              Expanded(
                child: Row(
                  children: [
                    Text(supplier, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                    const SizedBox(width: 8),
                    const Text('•', style: TextStyle(color: AppTheme.textSecondary)),
                    const SizedBox(width: 8),
                    Text(time, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
          if (!isReceived) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    FaIcon(FontAwesomeIcons.circleCheck, color: Colors.white, size: 16),
                    SizedBox(width: 8),
                    Text('Confirm Receipt', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMockNavBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -4))],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _navItem(icon: FontAwesomeIcons.house, label: 'Home', isActive: true),
            _navItem(icon: FontAwesomeIcons.barcode, label: 'Scan', isActive: false),
            // Floating Action Button Mock inside navbar
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(color: Color(0xFF1E2A5E), shape: BoxShape.circle),
              child: const FaIcon(FontAwesomeIcons.plus, color: Colors.white, size: 20),
            ),
            _navItem(icon: FontAwesomeIcons.boxesStacked, label: 'Stock', isActive: false),
            _navItem(icon: FontAwesomeIcons.solidUser, label: 'Profile', isActive: false),
          ],
        ),
      ),
    );
  }

  Widget _navItem({required IconData icon, required String label, required bool isActive}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FaIcon(icon, color: isActive ? AppTheme.primaryColor : Colors.grey.shade400, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isActive ? AppTheme.primaryColor : Colors.grey.shade500,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

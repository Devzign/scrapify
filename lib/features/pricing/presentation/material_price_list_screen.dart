import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class MaterialPriceListScreen extends StatefulWidget {
  const MaterialPriceListScreen({super.key});

  @override
  State<MaterialPriceListScreen> createState() => _MaterialPriceListScreenState();
}

class _MaterialPriceListScreenState extends State<MaterialPriceListScreen> {
  String _selectedCategory = 'All';
  
  final List<String> _categories = ['All', 'Metals / धातु', 'Electronics / इलेक्ट्रॉनिक'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeft, color: AppTheme.textPrimary, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text('Material Price List', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  icon: FaIcon(FontAwesomeIcons.magnifyingGlass, size: 16, color: AppTheme.textSecondary),
                  hintText: 'Search items / सामान खोजें',
                  hintStyle: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          
          // Category Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: _categories.map((category) {
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () => setState(() => _selectedCategory = category),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.primaryColor : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppTheme.textSecondary,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          
          // Live Rates Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('TODAY\'S RATES / आज के भाव', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.bold)),
                Row(
                  children: const [
                    FaIcon(FontAwesomeIcons.arrowsRotate, size: 10, color: AppTheme.primaryColor),
                    SizedBox(width: 4),
                    Text('Live', style: TextStyle(color: AppTheme.primaryColor, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          
          // List of Materials
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildPriceCard(
                  icon: FontAwesomeIcons.boltLightning,
                  iconColor: Colors.orange,
                  iconBg: Colors.orange.shade50,
                  titleEn: 'Copper Wire',
                  titleHi: 'तांबे की तार',
                  updated: 'Updated: 10:00 AM',
                  price: '₹450',
                  unit: '/ kg',
                  trend: '+2%',
                  isUp: true,
                ),
                const SizedBox(height: 12),
                _buildPriceCard(
                  icon: FontAwesomeIcons.screwdriverWrench,
                  iconColor: Colors.grey.shade700,
                  iconBg: Colors.grey.shade100,
                  titleEn: 'Iron Heavy',
                  titleHi: 'लोहा भारी',
                  updated: 'Updated: 09:30 AM',
                  price: '₹32',
                  unit: '/ kg',
                  trend: '- 0%',
                  isUp: null, // Neutral
                ),
                const SizedBox(height: 12),
                _buildPriceCard(
                  icon: FontAwesomeIcons.hammer,
                  iconColor: Colors.yellow.shade700,
                  iconBg: Colors.yellow.shade100,
                  titleEn: 'Brass Mix',
                  titleHi: 'पीतल मिक्स',
                  updated: 'Updated: Yesterday',
                  price: '₹305',
                  unit: '/ kg',
                  trend: '-1.5%',
                  isUp: false,
                ),
                const SizedBox(height: 12),
                _buildPriceCard(
                  icon: FontAwesomeIcons.newspaper,
                  iconColor: Colors.grey.shade800,
                  iconBg: Colors.grey.shade200,
                  titleEn: 'Newspaper',
                  titleHi: 'पुराना अखबार',
                  updated: 'Updated: Today, 11:00 AM',
                  price: '₹14',
                  unit: '/ kg',
                  trend: '+5%',
                  isUp: true,
                ),
                const SizedBox(height: 12),
                _buildPriceCard(
                  icon: FontAwesomeIcons.mobileScreen,
                  iconColor: Colors.blue,
                  iconBg: Colors.blue.shade50,
                  titleEn: 'Smartphone',
                  titleHi: 'स्मार्टफोन',
                  updated: 'Updated: Yesterday',
                  price: '₹20',
                  unit: '/ pc',
                  trend: '- 0%',
                  isUp: null,
                ),
                const SizedBox(height: 12),
                _buildPriceCard(
                  icon: FontAwesomeIcons.snowflake,
                  iconColor: Colors.cyan,
                  iconBg: Colors.cyan.shade50,
                  titleEn: 'Split AC (1.5 Ton)',
                  titleHi: 'एसी (पुराना)',
                  updated: 'Updated: 2 days ago',
                  price: '₹3500',
                  unit: '/ pc',
                  trend: '+1%',
                  isUp: true,
                ),
                const SizedBox(height: 120), // Bottom padding for FAB
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: AppTheme.primaryColor,
        icon: const FaIcon(FontAwesomeIcons.truckFast, size: 16, color: Colors.white),
        label: const Text('Sell Now', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildPriceCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String titleEn,
    required String titleHi,
    required String updated,
    required String price,
    required String unit,
    required String trend,
    required bool? isUp,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
            child: Center(child: FaIcon(icon, color: iconColor, size: 24)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titleEn, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textPrimary)),
                Text(titleHi, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                const SizedBox(height: 4),
                Text(updated, style: const TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(price, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primaryColor)),
                  Text(unit, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  if (isUp != null)
                    FaIcon(
                      isUp ? FontAwesomeIcons.arrowTrendUp : FontAwesomeIcons.arrowTrendDown,
                      size: 10,
                      color: isUp ? Colors.green : Colors.red,
                    ),
                  if (isUp != null) const SizedBox(width: 4),
                  Text(
                    trend,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isUp == true ? Colors.green : (isUp == false ? Colors.red : AppTheme.textSecondary),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class PickupOrderVerificationScreen extends StatefulWidget {
  const PickupOrderVerificationScreen({super.key});

  @override
  State<PickupOrderVerificationScreen> createState() =>
      _PickupOrderVerificationScreenState();
}

class _PickupOrderVerificationScreenState
    extends State<PickupOrderVerificationScreen> {
  final List<Map<String, dynamic>> _items = [
    {
      'name': 'Iron Scrap',
      'name_hi': 'लोहे का कबाड़',
      'weight': '42.50 kg',
      'rate': 28.00,
      'condition': 'Mixed / मिश्रित',
      'isVerified': false,
      'image': null,
    },
    {
      'name': 'Desktop Computer',
      'name_hi': 'डेस्कटॉप कंप्यूटर',
      'weight': '2 Units',
      'rate': 450.0,
      'condition': 'Good (Working) / अच्छी',
      'isVerified': true,
      'image':
          'https://plus.unsplash.com/premium_photo-1661339116712-401032393d93?q=80&w=150',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'pickup_dashboard.order_verification'.tr(),
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w900,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.grey),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOrderInfoCard(),
                _buildItemListSection(),
                _buildSummaryCard(),
              ],
            ),
          ),
          _buildBottomActions(),
        ],
      ),
    );
  }

  Widget _buildOrderInfoCard() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return _buildOrderDetailsCard();
        },
      ),
    );
  }

  Widget _buildOrderDetailsCard() {
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
          Wrap(
            spacing: 12,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Active Pickup Order'.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primaryColor,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const Text(
                    '#SC9022',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'IN-PROGRESS',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.primaryDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.person, 'Customer / ग्राहक', 'Amit Kumar'),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.location_on,
            'Address / पता',
            'B-42, 3rd Floor, Green Park Extension, New Delhi',
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.call, size: 18),
                  label: const Text('Call'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.directions, size: 18),
                  label: const Text('Navigate'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                    side: const BorderSide(
                      color: AppTheme.primaryColor,
                      width: 2,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppTheme.backgroundLight,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: AppTheme.textSecondary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
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

  Widget _buildItemListSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'pickup_dashboard.items_to_verify'.tr().toUpperCase(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 16),
        ..._items.map((item) => _buildItemCard(item)),
      ],
    );
  }

  Widget _buildItemCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.cardBorderRadius,
        boxShadow: AppTheme.cardShadow,
        border: Border.all(
          color: item['isVerified']
              ? AppTheme.primaryColor.withValues(alpha: 0.3)
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Media Column
                Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundLight,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.grey.shade200,
                          style: BorderStyle.none,
                        ),
                        image: item['image'] != null
                            ? DecorationImage(
                                image: NetworkImage(item['image']),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: item['image'] == null
                          ? const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo, color: Colors.grey),
                                Text(
                                  'Upload',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            )
                          : const Align(
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.check_circle,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 100,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'EST. WEIGHT',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          Text(
                            item['weight'],
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                // Content Column
                Expanded(
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
                                  item['name'],
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                Text(
                                  item['name_hi'],
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: item['isVerified']
                                  ? AppTheme.primaryLight
                                  : AppTheme.backgroundLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  'VERIFIED',
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w900,
                                    color: item['isVerified']
                                        ? AppTheme.primaryColor
                                        : Colors.grey,
                                  ),
                                ),
                                Checkbox(
                                  value: item['isVerified'],
                                  onChanged: (val) =>
                                      setState(() => item['isVerified'] = val),
                                  activeColor: AppTheme.primaryColor,
                                  visualDensity: VisualDensity.compact,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'RATE (per kg/unit)',
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w900,
                                    color: AppTheme.textSecondary,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.backgroundLight,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      const Text(
                                        '₹',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${item['rate']}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w900,
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'CONDITION',
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w900,
                                    color: AppTheme.textSecondary,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.backgroundLight,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    item['condition'],
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      color: AppTheme.textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
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
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.textPrimary,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Verification Summary / सारांश',
              style: TextStyle(
                color: Colors.white60,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '02',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'ITEMS\nVERIFIED',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'New Estimated Payout',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '₹2,090.00',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActions() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          border: Border(top: BorderSide(color: Colors.grey.shade100)),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.receipt_long),
                label: const Text(
                  'Complete & Generate Bill',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 1,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add),
                label: const Text('Add Item'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.textPrimary,
                  backgroundColor: AppTheme.backgroundLight,
                  side: BorderSide.none,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

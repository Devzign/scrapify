import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class PickupDetailsScreen extends StatelessWidget {
  const PickupDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        leading: IconButton(
          icon: const FaIcon(
            FontAwesomeIcons.arrowLeft,
            color: AppTheme.textPrimary,
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
        title: Column(
          children: const [
            Text(
              'Pickup #4092',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              'पिकअप #4092',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Blue left accent line
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: 6,
                      decoration: const BoxDecoration(
                        color: AppTheme.brandNavy,
                        borderRadius: BorderRadius.horizontal(
                          right: Radius.circular(6),
                        ),
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: const FaIcon(
                          FontAwesomeIcons.truckFast,
                          size: 24,
                          color: AppTheme.brandNavy,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'STATUS / स्थिति',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textSecondary,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Assigned',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.brandNavy,
                        ),
                      ),
                      const Text(
                        'असाइन किया गया',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.brandNavy,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Scheduled Today / आज के लिए निर्धारित',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Agent Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 24,
                        backgroundColor: AppTheme.primaryLight,
                        child: FaIcon(
                          FontAwesomeIcons.solidUser,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Ramesh Kumar',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const Text(
                            'रमेश कुमार',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: const [
                              FaIcon(
                                FontAwesomeIcons.solidStar,
                                color: Colors.orange,
                                size: 12,
                              ),
                              SizedBox(width: 4),
                              Text(
                                '4.8',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              SizedBox(width: 4),
                              Text(
                                '(150 Reviews)',
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const FaIcon(
                        FontAwesomeIcons.phone,
                        size: 14,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Call Agent / कॉल करें',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Pickup Items List
            const Text(
              'Pickup Items / पिकअप आइटम',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildItemRow(
                    icon: FontAwesomeIcons.newspaper,
                    enTitle: 'Old Newspaper',
                    hiTitle: 'पुराना अखबार',
                    weight: '12 kg',
                    price: '₹144',
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  _buildItemRow(
                    icon: FontAwesomeIcons.cubes,
                    enTitle: 'Iron Scrap',
                    hiTitle: 'लोहे का कबाड़',
                    weight: '5 kg',
                    price: '₹150',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Address and Map
            Container(
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Fake map area
                  Container(
                    height: 120,
                    width: double.infinity,
                    color: Colors.blue.shade50,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const FaIcon(
                          FontAwesomeIcons.mapLocationDot,
                          size: 64,
                          color: Colors.black12,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(color: Colors.black12, blurRadius: 4),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              FaIcon(
                                FontAwesomeIcons.locationArrow,
                                size: 14,
                                color: AppTheme.textPrimary,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Navigate / नेविगेट',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryLight,
                            shape: BoxShape.circle,
                          ),
                          child: const FaIcon(
                            FontAwesomeIcons.locationDot,
                            color: AppTheme.primaryColor,
                            size: 12,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Pickup Address / पता',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                '12, Green Park Main, Block A, New Delhi, Delhi 110016',
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '१२, ग्रीन पार्क मेन, ब्लॉक ए, नई दिल्ली, दिल्ली ११००१६',
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 11,
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
            const SizedBox(height: 32),

            // Order Status Timeline
            const Text(
              'Order Status / ऑर्डर की स्थिति',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            _buildTimelineStep(
              enText: 'Requested / अनुरोधित',
              subText: '10:30 AM, Today',
              dotColor: AppTheme.primaryColor,
              isFirst: true,
            ),
            _buildTimelineStep(
              enText: 'Assigned / असाइन किया गया',
              subText: '11:15 AM, Today',
              dotColor: AppTheme.brandNavy,
            ),
            _buildTimelineStep(
              enText: 'Picked Up / उठाया गया',
              subText: 'Pending',
              dotColor: Colors.grey.shade300,
            ),
            _buildTimelineStep(
              enText: 'Paid / भुगतान किया गया',
              subText: 'Pending',
              dotColor: Colors.grey.shade300,
              isLast: true,
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildItemRow({
    required IconData icon,
    required String enTitle,
    required String hiTitle,
    required String weight,
    required String price,
  }) {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: FaIcon(icon, color: AppTheme.textSecondary, size: 24),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                enTitle,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              Text(
                hiTitle,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              weight,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              price,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimelineStep({
    required String enText,
    required String subText,
    required Color dotColor,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            if (!isFirst)
              Container(width: 2, height: 20, color: Colors.grey.shade200)
            else
              const SizedBox(height: 20),
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            if (!isLast)
              Container(width: 2, height: 40, color: Colors.grey.shade200)
            else
              const SizedBox(height: 40),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: isFirst ? 16 : 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  enText,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: dotColor == Colors.grey.shade300
                        ? AppTheme.textSecondary
                        : AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subText,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

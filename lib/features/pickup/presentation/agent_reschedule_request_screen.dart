import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class AgentRescheduleRequestScreen extends StatefulWidget {
  const AgentRescheduleRequestScreen({super.key});

  @override
  State<AgentRescheduleRequestScreen> createState() => _AgentRescheduleRequestScreenState();
}

class _AgentRescheduleRequestScreenState extends State<AgentRescheduleRequestScreen> {
  String? _selectedReason;
  final TextEditingController _detailsController = TextEditingController();

  final List<Map<String, String>> _reasons = [
    {
      'id': 'vehicle_breakdown',
      'label': 'Vehicle Breakdown',
      'label_hi': 'वाहन खराब',
      'icon': 'car_repair',
    },
    {
      'id': 'heavy_traffic',
      'label': 'Heavy Traffic',
      'label_hi': 'भारी जाम',
      'icon': 'traffic',
    },
    {
      'id': 'personal_issue',
      'label': 'Personal Issue',
      'label_hi': 'व्यक्तिगत आपात',
      'icon': 'emergency_home',
    },
    {
      'id': 'other',
      'label': 'Other Reason',
      'label_hi': 'अन्य कारण',
      'icon': 'more_horiz',
    },
  ];

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primaryColor),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Reschedule Pickup',
              style: TextStyle(color: Color(0xFF0D2B52), fontWeight: FontWeight.w900, fontSize: 20),
            ),
            Text(
              'पुनर्निर्धारण का अनुरोध'.toUpperCase(),
              style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.grey),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildActivePickupCard(),
            const SizedBox(height: 32),
            _buildReasonSelectionHeader(),
            const SizedBox(height: 16),
            _buildReasonGrid(),
            const SizedBox(height: 32),
            _buildAdditionalDetailsSection(),
            const SizedBox(height: 40),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildActivePickupCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppTheme.primaryLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.location_on, color: AppTheme.primaryColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(4)),
                      child: const Text('#SC9022', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey)),
                    ),
                    const SizedBox(width: 6),
                    const Text('ACTIVE PICKUP', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5)),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Sector 45, Green Park',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0D2B52)),
                ),
                const Text(
                  'Gurugram, Haryana',
                  style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReasonSelectionHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select a Reason',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF0D2B52)),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Why can\'t you make it?',
              style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500),
            ),
            Text(
              'कारण चुनें'.toUpperCase(),
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.primaryColor, letterSpacing: 1.2),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReasonGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemCount: _reasons.length,
      itemBuilder: (context, index) {
        final reason = _reasons[index];
        final isSelected = _selectedReason == reason['id'];

        return InkWell(
          onTap: () => setState(() => _selectedReason = reason['id']),
          borderRadius: BorderRadius.circular(30),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFF0FDF4) : Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: isSelected ? AppTheme.primaryColor : Colors.transparent, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryColor : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    _getIconData(reason['icon']!),
                    color: isSelected ? Colors.white : AppTheme.primaryColor,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  reason['label']!,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF0D2B52)),
                ),
                Text(
                  reason['label_hi']!.toUpperCase(),
                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.grey, letterSpacing: 0.5),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'car_repair':
        return Icons.car_repair;
      case 'traffic':
        return Icons.traffic;
      case 'emergency_home':
        return Icons.emergency;
      case 'more_horiz':
        return Icons.more_horiz;
      default:
        return Icons.help_outline;
    }
  }

  Widget _buildAdditionalDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Additional Details (Optional)',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF0D2B52)),
            ),
            Text(
              'अतिरिक्त विवरण',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.2),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _detailsController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Briefly explain the situation for the customer...',
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
            fillColor: Colors.white,
            filled: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide(color: Colors.grey.shade200)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide(color: Colors.grey.shade200)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2)),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _selectedReason == null ? null : () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 60),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 8,
            shadowColor: AppTheme.primaryColor.withValues(alpha: 0.3),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Send Request to Customer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
              SizedBox(width: 8),
              Icon(Icons.send, size: 20),
            ],
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF0D2B52),
            minimumSize: const Size(double.infinity, 60),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            side: BorderSide(color: Colors.grey.shade200, width: 2),
            backgroundColor: Colors.white,
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.support_agent, color: AppTheme.primaryColor),
              SizedBox(width: 8),
              Text('Call Support', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
            ],
          ),
        ),
      ],
    );
  }
}

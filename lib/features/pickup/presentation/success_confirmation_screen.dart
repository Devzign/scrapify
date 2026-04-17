import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_routes.dart';
import '../domain/models/pickup_request_model.dart';

class SuccessConfirmationScreen extends StatelessWidget {
  final PickupRequestModel? pickup;
  final bool isDonation;

  const SuccessConfirmationScreen({
    super.key,
    this.pickup,
    this.isDonation = false,
  });

  @override
  Widget build(BuildContext context) {
    final bookingId = pickup?.pickupCode.isNotEmpty == true
        ? pickup!.pickupCode
        : 'SCR-2026-001';

    final scheduledDate = pickup?.scheduledAt.toLocal() ?? DateTime.now();
    final dateStr = DateFormat('EEEE, hh:mm a').format(scheduledDate);
    // Rough Hindi translation for "Tomorrow, 10:00 AM" equivalent
    final hindiDateStr = "कल, सुबह ${DateFormat('hh:mm').format(scheduledDate)} बजे";

    final itemCount = pickup?.items.length ?? 0;
    final firstCategory = pickup?.items.isNotEmpty == true
        ? (pickup?.items.first.name ?? 'Scrap')
        : 'Items';
    final itemsSummary = "$itemCount Items ($firstCategory)";
    final hindiItemsSummary = "$itemCount आइटम ($firstCategory)";

    final address = pickup?.address ?? "Flat 402, Green Valley Apartments, HSR Layout, Bangalore";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => context.go(AppRoutes.customerDashboard),
        ),
        title: Text(
          isDonation ? 'Donation Confirmed' : 'Booking Confirmed',
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w900,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: AppTheme.textPrimary),
            onPressed: () {},
          ),
        ],
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildHeroSection(),
            const SizedBox(height: 24),
            Text(
              isDonation ? 'Donation Successful!' : 'Booking Successful!',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isDonation ? 'दान सफल!' : 'बुकिंग सफल!',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF639A70),
              ),
            ),
            const SizedBox(height: 16),
            _buildBookingIdChip(bookingId),
            const SizedBox(height: 32),
            _buildIllustrationCard(),
            const SizedBox(height: 24),
            _buildPickupSummary(
              dateStr: dateStr,
              hindiDateStr: hindiDateStr,
              itemsSummary: itemsSummary,
              hindiItemsSummary: hindiItemsSummary,
              address: address,
            ),
            const SizedBox(height: 32),
            _buildActionButtons(context),
            const SizedBox(height: 32),
            _buildBottomBanner(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildHeroSection() {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer circles
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF639A70).withValues(alpha: 0.1),
            ),
          ),
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF639A70).withValues(alpha: 0.2),
            ),
          ),
          // Inner checkmark circle
          Container(
            width: 75,
            height: 75,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF639A70),
            ),
            child: const Icon(
              Icons.check,
              color: Colors.white,
              size: 40,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingIdChip(String bookingId) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'BOOKING ID: ',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF64748B),
              letterSpacing: 0.5,
            ),
          ),
          Text(
            bookingId,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIllustrationCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      height: 160,
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Stack(
        children: [
          // Recycling symbol watermark
          Positioned(
            right: -10,
            bottom: -10,
            child: Icon(
              Icons.recycling,
              size: 100,
              color: const Color(0xFF639A70).withValues(alpha: 0.15),
            ),
          ),
          Center(
            child: Image.asset(
              'assets/images/trash_bin_success.png',
              height: 120,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const FaIcon(
                  FontAwesomeIcons.trashCan,
                  size: 80,
                  color: Color(0xFF639A70),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPickupSummary({
    required String dateStr,
    required String hindiDateStr,
    required String itemsSummary,
    required String hindiItemsSummary,
    required String address,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.receipt_long_outlined, color: Color(0xFF639A70), size: 22),
              const SizedBox(width: 12),
              const Text(
                'Pickup Summary',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSummaryItem(
            icon: Icons.calendar_today_outlined,
            label: 'SCHEDULED FOR',
            value: dateStr,
            hindiValue: hindiDateStr,
          ),
          const SizedBox(height: 20),
          _buildSummaryItem(
            icon: Icons.inventory_2_outlined,
            label: 'ITEMS',
            value: itemsSummary,
            hindiValue: hindiItemsSummary,
          ),
          const SizedBox(height: 20),
          _buildSummaryItem(
            icon: Icons.location_on_outlined,
            label: 'PICKUP ADDRESS',
            value: address,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String label,
    required String value,
    String? hindiValue,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF475569), size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF94A3B8),
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                  height: 1.3,
                ),
              ),
              if (hindiValue != null) ...[
                const SizedBox(height: 2),
                Text(
                  hindiValue,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF639A70),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          ElevatedButton(
            onPressed: pickup == null
                ? null
                : () => context.go('${AppRoutes.pickupTracking}/${pickup!.id}'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF639A70),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 64),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isDonation ? 'TRACK DONATION' : 'Track Pickup',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
                Text(
                  isDonation ? 'दान ट्रैक करें' : 'पिकअप ट्रैक करें',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.go(AppRoutes.customerDashboard),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF1F5F9),
              foregroundColor: const Color(0xFF0F172A),
              minimumSize: const Size(double.infinity, 64),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 0,
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Back to Home',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
                Text(
                  'होम पर जाएं',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBanner() {
    return Container(
      width: double.infinity,
      height: 140,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEEE7),
        borderRadius: BorderRadius.circular(24),
        image: const DecorationImage(
          image: AssetImage('assets/images/map_banner.png'),
          fit: BoxFit.cover,
          opacity: 0.7,
        ),
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF639A70),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Driver will arrive in HSR Layout',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF639A70),
      unselectedItemColor: const Color(0xFF94A3B8),
      currentIndex: 1, // "My Bookings" selected
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 10),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 10),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'HOME'),
        BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'MY BOOKINGS'),
        BottomNavigationBarItem(icon: Icon(Icons.currency_rupee), label: 'RATES'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'PROFILE'),
      ],
    );
  }
}

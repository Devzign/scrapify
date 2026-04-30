import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_routes.dart';
import '../domain/models/tracking_timeline_model.dart';
import '../providers/pickup_provider.dart';

class PickupTrackingScreen extends ConsumerStatefulWidget {
  final int pickupId;

  const PickupTrackingScreen({super.key, required this.pickupId});

  @override
  ConsumerState<PickupTrackingScreen> createState() =>
      _PickupTrackingScreenState();
}

class _PickupTrackingScreenState extends ConsumerState<PickupTrackingScreen> {
  final Set<Marker> _markers = {};

  @override
  Widget build(BuildContext context) {
    final trackingAsync = ref.watch(trackingProvider(widget.pickupId));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
              return;
            }
            context.go(AppRoutes.customerDashboard);
          },
        ),
        title: Text(
          'Track Pickup #OD-${widget.pickupId}',
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: trackingAsync.when(
        data: (tracking) {
          _updateMarkers(tracking);
          return _buildBody(context, tracking);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Error: $err',
              style: const TextStyle(color: AppTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  void _updateMarkers(TrackingTimelineModel tracking) {
    if (tracking.latitude != null && tracking.longitude != null) {
      _markers.clear();
      _markers.add(
        Marker(
          markerId: MarkerId('pickup_location_${tracking.id}'),
          position: LatLng(tracking.latitude!, tracking.longitude!),
          infoWindow: InfoWindow(
            title: 'Pickup Location',
            snippet: tracking.pickupCode,
          ),
        ),
      );
    }
  }

  Widget _buildBody(BuildContext context, TrackingTimelineModel tracking) {
    final statusLabel = _formatStatusLabel(tracking.status);

    return Column(
      children: [
        // Top Map Section
        Expanded(
          flex: 4,
          child: Stack(
            children: [
              if (tracking.latitude != null && tracking.longitude != null)
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(tracking.latitude!, tracking.longitude!),
                    zoom: 15,
                  ),
                  markers: _markers,
                  zoomControlsEnabled: false,
                  myLocationButtonEnabled: false,
                )
              else
                Container(
                  color: Colors.grey.shade100,
                  child: const Center(
                    child: Icon(
                      Icons.map_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                  ),
                ),

              // Status Badge floating on map
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF639A70).withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.local_shipping,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          statusLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Timeline Content
        Expanded(
          flex: 6,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppTheme.cardBorderRadius,
              border: AppTheme.cardBorder,
              boxShadow: AppTheme.cardShadow,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                children: [
                  const Text(
                    'Collection in Progress',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Estimated arrival: 15-20 mins',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Dynamic Timeline
                  ...List.generate(3, (index) {
                    // Mapping statuses to timeline steps for visualization
                    // Step 0: Request Sent (Completed)
                    // Step 1: Agent Assigned (Active/Assigned)
                    // Step 2: Pickup in Progress (Next)

                    if (index == 0) {
                      return _buildTimelineStep(
                        title: 'Request Sent',
                        subtitle: 'Today, 10:00 AM',
                        isCompleted: true,
                        isActive: false,
                        isLast: false,
                      );
                    } else if (index == 1) {
                      return _buildTimelineStep(
                        title: 'Agent Assigned',
                        subtitle: tracking.agent != null
                            ? '${tracking.agent!.name} is on the way'
                            : 'Assigning pickup agent...',
                        isCompleted: false,
                        isActive: true,
                        isLast: false,
                        child: tracking.agent != null
                            ? _buildAgentCard(tracking.agent!)
                            : null,
                      );
                    } else {
                      return _buildTimelineStep(
                        title: 'Pickup in Progress',
                        subtitle: 'Pending arrival',
                        isCompleted: false,
                        isActive: false,
                        isLast: true,
                      );
                    }
                  }),

                  const SizedBox(height: 32),

                  // Need help button
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.help_outline,
                          color: AppTheme.textSecondary,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Need help with this order?',
                            style: TextStyle(
                              color: Color(0xFF475569),
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right,
                          color: Color(0xFF94A3B8),
                          size: 20,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Call Button
                  SizedBox(
                    width: double.infinity,
                    height: 64,
                    child: ElevatedButton(
                      onPressed: tracking.agent?.phone != null
                          ? () => _makePhoneCall(tracking.agent!.phone!)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2D3E50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.call, color: Colors.white, size: 20),
                          const SizedBox(width: 12),
                          const Text(
                            'CALL AGENT',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_canReschedule(tracking.status)) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await context.push(
                            '${AppRoutes.userReschedule}/${widget.pickupId}',
                          );
                          ref.invalidate(trackingProvider(widget.pickupId));
                          ref.invalidate(pickupsProvider);
                          ref.invalidate(pickupDetailProvider(widget.pickupId));
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryColor,
                          side: const BorderSide(color: AppTheme.primaryColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: const Icon(Icons.schedule_rounded),
                        label: const Text(
                          'RESCHEDULE PICKUP',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineStep({
    required String title,
    required String subtitle,
    required bool isCompleted,
    required bool isActive,
    required bool isLast,
    Widget? child,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? const Color(0xFF639A70)
                      : (isActive ? const Color(0xFF3B82F6) : Colors.white),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isCompleted
                        ? const Color(0xFF639A70)
                        : (isActive
                              ? const Color(0xFF3B82F6)
                              : const Color(0xFFE2E8F0)),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Icon(
                    isCompleted
                        ? Icons.check
                        : (isActive ? Icons.person : null),
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(width: 2, color: const Color(0xFFE2E8F0)),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: isActive
                          ? const Color(0xFF3B82F6)
                          : AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  if (child != null) ...[const SizedBox(height: 16), child],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgentCard(TrackingAgent agent) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: const DecorationImage(
                    image: NetworkImage(
                      'https://i.pravatar.cc/150?img=11',
                    ), // Use agent image if available
                    fit: BoxFit.cover,
                  ),
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: -4,
                right: -4,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFACC15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        '4.8',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 2),
                      Icon(Icons.star, size: 8, color: Colors.black),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  agent.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tata Ace • ${agent.vehicle ?? 'GJ-01-AB-1234'}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatStatusLabel(String status) {
    if (status.isEmpty) return 'Pending';
    return status[0].toUpperCase() + status.substring(1).toLowerCase();
  }

  bool _canReschedule(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'cancelled':
      case 'cancelled_by_user':
      case 'failed':
        return false;
      default:
        return true;
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch dialer for $phoneNumber')),
        );
      }
    }
  }
}

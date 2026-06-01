import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_color.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_routes.dart';
import '../domain/models/pickup_request_model.dart';
import '../domain/models/tracking_timeline_model.dart';
import '../providers/pickup_provider.dart';
import 'widgets/pickup_price_summary.dart';

class PickupTrackingScreen extends ConsumerStatefulWidget {
  final int pickupId;
  final PickupRequestModel? initialPickup;

  const PickupTrackingScreen({
    super.key,
    required this.pickupId,
    this.initialPickup,
  });

  @override
  ConsumerState<PickupTrackingScreen> createState() =>
      _PickupTrackingScreenState();
}

class _PickupTrackingScreenState extends ConsumerState<PickupTrackingScreen> {
  final Set<Marker> _markers = {};

  @override
  Widget build(BuildContext context) {
    final trackingAsync = ref.watch(trackingProvider(widget.pickupId));
    final detailAsync = ref.watch(pickupDetailProvider(widget.pickupId));
    final preferredDetail = widget.initialPickup ?? detailAsync.asData?.value;

    return Scaffold(
      backgroundColor: AppColor.backgroundLight,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A5C35),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1A5C35), AppColor.primary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.30)),
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
              return;
            }
            context.go(AppRoutes.customerDashboard);
          },
        ),
        title: Text(
          'Track Pickup ${preferredDetail?.pickupCode.isNotEmpty == true ? preferredDetail!.pickupCode : '#OD-${widget.pickupId}'}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 17,
            letterSpacing: -0.2,
          ),
        ),
        centerTitle: true,
      ),
      body: trackingAsync.when(
        data: (tracking) {
          final mapLocation = _resolveMapLocation(
            detail: preferredDetail,
            tracking: tracking,
          );
          _updateMarkers(
            latitude: mapLocation?.latitude,
            longitude: mapLocation?.longitude,
            pickupCode: preferredDetail?.pickupCode ?? tracking.pickupCode,
          );
          return _buildBody(context, tracking, preferredDetail, mapLocation);
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

  void _updateMarkers({
    required double? latitude,
    required double? longitude,
    required String pickupCode,
  }) {
    _markers.clear();
    if (latitude != null && longitude != null) {
      _markers.add(
        Marker(
          markerId: MarkerId('pickup_location_${widget.pickupId}'),
          position: LatLng(latitude, longitude),
          infoWindow: InfoWindow(title: 'Pickup Location', snippet: pickupCode),
        ),
      );
    }
  }

  Widget _buildBody(
    BuildContext context,
    TrackingTimelineModel tracking,
    PickupRequestModel? pickupDetail,
    _MapLocation? mapLocation,
  ) {
    final statusLabel = _formatStatusLabel(tracking.status);
    final statusConfig = _buildStatusConfig(
      tracking.status,
      tracking.scheduledAt,
      pickupDetail,
    );
    final timelineSteps = _buildTimelineSteps(tracking, pickupDetail);

    return Column(
      children: [
        // Top Map Section
        Expanded(
          flex: 4,
          child: Stack(
            children: [
              if (mapLocation != null)
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(mapLocation.latitude, mapLocation.longitude),
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
                      color: AppTheme.primaryColor.withValues(alpha: 0.85),
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
                  Text(
                    statusConfig.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    statusConfig.subtitle,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ...timelineSteps.asMap().entries.map((entry) {
                    final index = entry.key;
                    final step = entry.value;
                    return _buildTimelineStep(
                      title: step.title,
                      subtitle: step.subtitle,
                      isCompleted: step.isCompleted,
                      isActive: step.isActive,
                      isLast: index == timelineSteps.length - 1,
                      child: step.child,
                    );
                  }),

                  const SizedBox(height: 24),

                  if (pickupDetail != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: PickupPriceSummary(pickup: pickupDetail),
                    ),

                  if (pickupDetail != null) ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildPaymentStatusCard(pickupDetail),
                    ),
                  ],

                  if (pickupDetail != null) ...[
                    const SizedBox(height: 8),
                    _buildAddressCard(pickupDetail),
                    if (pickupDetail.images.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _buildImagesSection(pickupDetail.images),
                    ],
                  ],

                  const SizedBox(height: 8),

                  // Need help button
                  InkWell(
                    onTap: () => context.push(
                      AppRoutes.helpSupport,
                      extra: {'orderId': widget.pickupId},
                    ),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundCream,
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
                                color: AppTheme.textSecondary,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right,
                            color: AppTheme.textMuted,
                            size: 20,
                          ),
                        ],
                      ),
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
                        backgroundColor: AppTheme.brandNavy,
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
                      ? AppTheme.primaryColor
                      : (isActive ? AppTheme.infoColor : Colors.white),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isCompleted
                        ? AppTheme.primaryColor
                        : (isActive ? AppTheme.infoColor : AppTheme.outline),
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
                Expanded(child: Container(width: 2, color: AppTheme.outline)),
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
                          ? AppTheme.infoColor
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
        color: AppTheme.backgroundCream,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.hairline),
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
                    color: AppTheme.warningColor,
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

  Widget _buildAddressCard(PickupRequestModel pickup) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundCream,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.hairline),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.location_on_outlined,
            color: AppTheme.primaryColor,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pickup Address',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  pickup.address,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentStatusCard(PickupRequestModel pickup) {
    final isPaid = pickup.paymentCompleted;
    final statusLabel = isPaid ? 'Payment Completed' : 'Payment Pending';
    final subtitle = isPaid
        ? (pickup.paidAt != null
              ? 'Paid on ${_formatDateTime(pickup.paidAt!)}'
              : 'Payout has been marked as paid.')
        : (pickup.status.toLowerCase() == 'completed'
              ? 'Pickup is completed, but payment is not marked as paid yet.'
              : 'Payment will be updated after pickup completion.');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.hairline),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isPaid
                  ? AppTheme.primarySurface
                  : AppTheme.backgroundCream,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPaid ? Icons.check_circle : Icons.schedule_rounded,
              color: isPaid ? AppTheme.primaryColor : AppTheme.warningColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Payment Status',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: isPaid
                        ? AppTheme.primaryColor
                        : AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          if (pickup.payoutStatus != null && pickup.payoutStatus!.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isPaid
                    ? AppTheme.primarySurface
                    : AppTheme.backgroundCream,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                _formatStatusLabel(pickup.payoutStatus!),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: isPaid
                      ? AppTheme.primaryColor
                      : AppTheme.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImagesSection(List<PickupImageModel> images) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Uploaded Photos (${images.length})',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 84,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final image = images[index];
                final imageUrl = image.url ?? image.imagePath;

                return ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          width: 84,
                          height: 84,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _imagePlaceholder(),
                        )
                      : _imagePlaceholder(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: 84,
      height: 84,
      color: AppTheme.primarySurface,
      child: const Icon(
        Icons.image_not_supported_outlined,
        color: AppTheme.primaryColor,
      ),
    );
  }

  _MapLocation? _resolveMapLocation({
    required PickupRequestModel? detail,
    required TrackingTimelineModel tracking,
  }) {
    if (_isValidCoordinate(detail?.latitude, detail?.longitude)) {
      return _MapLocation(detail!.latitude, detail.longitude);
    }

    if (_isValidCoordinate(tracking.latitude, tracking.longitude)) {
      return _MapLocation(tracking.latitude!, tracking.longitude!);
    }

    final imageWithGeo = detail?.images.where((image) {
      return _isValidCoordinate(image.latitude, image.longitude);
    }).firstOrNull;

    if (imageWithGeo != null) {
      return _MapLocation(imageWithGeo.latitude!, imageWithGeo.longitude!);
    }

    return null;
  }

  bool _isValidCoordinate(double? latitude, double? longitude) {
    if (latitude == null || longitude == null) {
      return false;
    }

    return latitude.abs() > 0.000001 || longitude.abs() > 0.000001;
  }

  String _formatStatusLabel(String status) {
    if (status.isEmpty) return 'Pending';
    return status[0].toUpperCase() + status.substring(1).toLowerCase();
  }

  _TrackingStatusConfig _buildStatusConfig(
    String status,
    DateTime? scheduledAt,
    PickupRequestModel? pickupDetail,
  ) {
    final normalized = status.toLowerCase();
    switch (normalized) {
      case 'completed':
        return _TrackingStatusConfig(
          title: 'Pickup Completed',
          subtitle: pickupDetail?.finalAmount != null
              ? 'Final payout has been confirmed.'
              : 'This pickup has been completed successfully.',
        );
      case 'cancelled':
      case 'cancelled_by_user':
      case 'failed':
        return const _TrackingStatusConfig(
          title: 'Pickup Closed',
          subtitle: 'This pickup is no longer active.',
        );
      case 'assigned':
      case 'accepted':
        return const _TrackingStatusConfig(
          title: 'Agent Assigned',
          subtitle: 'Your pickup partner is preparing to arrive.',
        );
      case 'in_progress':
      case 'pickup_in_progress':
      case 'arrived':
        return const _TrackingStatusConfig(
          title: 'Pickup in Progress',
          subtitle: 'Collection is currently underway.',
        );
      default:
        return _TrackingStatusConfig(
          title: 'Collection in Progress',
          subtitle: scheduledAt != null
              ? 'Scheduled for ${_formatDateTime(scheduledAt)}'
              : 'Estimated arrival: 15-20 mins',
        );
    }
  }

  List<_TrackingStepViewModel> _buildTimelineSteps(
    TrackingTimelineModel tracking,
    PickupRequestModel? pickupDetail,
  ) {
    final normalized = tracking.status.toLowerCase();
    final createdAt = pickupDetail?.createdAt;
    final completionTime = pickupDetail?.priceLockedAt ?? tracking.scheduledAt;
    final requestSubtitle = createdAt != null
        ? _formatDateTime(createdAt)
        : 'Pickup request created';

    final agentSubtitle = tracking.agent != null
        ? '${tracking.agent!.name} is on the way'
        : 'Assigning pickup agent...';

    if (normalized == 'completed') {
      return [
        _TrackingStepViewModel(
          title: 'Request Sent',
          subtitle: requestSubtitle,
          isCompleted: true,
        ),
        _TrackingStepViewModel(
          title: 'Agent Assigned',
          subtitle: tracking.agent != null
              ? '${tracking.agent!.name} handled this pickup'
              : 'Pickup agent assigned',
          isCompleted: true,
          child: tracking.agent != null
              ? _buildAgentCard(tracking.agent!)
              : null,
        ),
        _TrackingStepViewModel(
          title: 'Pickup Completed',
          subtitle: completionTime != null
              ? _formatDateTime(completionTime)
              : 'Completed successfully',
          isCompleted: true,
        ),
        _TrackingStepViewModel(
          title: pickupDetail?.paymentCompleted == true
              ? 'Payment Completed'
              : 'Payment Pending',
          subtitle: pickupDetail?.paymentCompleted == true
              ? (pickupDetail?.paidAt != null
                    ? _formatDateTime(pickupDetail!.paidAt!)
                    : 'Payout marked as paid')
              : 'Pickup is completed, but payment is not marked as paid yet.',
          isCompleted: pickupDetail?.paymentCompleted == true,
          isActive: pickupDetail?.paymentCompleted != true,
        ),
      ];
    }

    if (normalized == 'assigned' || normalized == 'accepted') {
      return [
        _TrackingStepViewModel(
          title: 'Request Sent',
          subtitle: requestSubtitle,
          isCompleted: true,
        ),
        _TrackingStepViewModel(
          title: 'Agent Assigned',
          subtitle: agentSubtitle,
          isActive: true,
          child: tracking.agent != null
              ? _buildAgentCard(tracking.agent!)
              : null,
        ),
        const _TrackingStepViewModel(
          title: 'Pickup in Progress',
          subtitle: 'Pending arrival',
        ),
      ];
    }

    if (normalized == 'in_progress' ||
        normalized == 'pickup_in_progress' ||
        normalized == 'arrived') {
      return [
        _TrackingStepViewModel(
          title: 'Request Sent',
          subtitle: requestSubtitle,
          isCompleted: true,
        ),
        _TrackingStepViewModel(
          title: 'Agent Assigned',
          subtitle: agentSubtitle,
          isCompleted: true,
          child: tracking.agent != null
              ? _buildAgentCard(tracking.agent!)
              : null,
        ),
        const _TrackingStepViewModel(
          title: 'Pickup in Progress',
          subtitle: 'Collection is underway',
          isActive: true,
        ),
      ];
    }

    return [
      _TrackingStepViewModel(
        title: 'Request Sent',
        subtitle: requestSubtitle,
        isActive: normalized == 'pending' || normalized.isEmpty,
        isCompleted: normalized != 'pending' && normalized.isNotEmpty,
      ),
      _TrackingStepViewModel(
        title: 'Agent Assigned',
        subtitle: agentSubtitle,
        child: tracking.agent != null ? _buildAgentCard(tracking.agent!) : null,
      ),
      const _TrackingStepViewModel(
        title: 'Pickup in Progress',
        subtitle: 'Pending arrival',
      ),
    ];
  }

  String _formatDateTime(DateTime value) {
    final local = value.toLocal();
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final meridian = local.hour >= 12 ? 'PM' : 'AM';
    final weekday = _weekdayName(local.weekday);
    final month = _monthName(local.month);
    return '$weekday, $month ${local.day}, $hour:$minute $meridian';
  }

  String _weekdayName(int weekday) {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[(weekday - 1).clamp(0, 6)];
  }

  String _monthName(int month) {
    const names = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return names[(month - 1).clamp(0, 11)];
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

class _MapLocation {
  final double latitude;
  final double longitude;

  const _MapLocation(this.latitude, this.longitude);
}

class _TrackingStatusConfig {
  final String title;
  final String subtitle;

  const _TrackingStatusConfig({required this.title, required this.subtitle});
}

class _TrackingStepViewModel {
  final String title;
  final String subtitle;
  final bool isCompleted;
  final bool isActive;
  final Widget? child;

  const _TrackingStepViewModel({
    required this.title,
    required this.subtitle,
    this.isCompleted = false,
    this.isActive = false,
    this.child,
  });
}

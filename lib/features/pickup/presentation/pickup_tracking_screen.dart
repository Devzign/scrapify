import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/pickup_provider.dart';

class PickupTrackingScreen extends ConsumerStatefulWidget {
  final int? pickupId;
  const PickupTrackingScreen({super.key, this.pickupId});

  @override
  ConsumerState<PickupTrackingScreen> createState() =>
      _PickupTrackingScreenState();
}

class _PickupTrackingScreenState extends ConsumerState<PickupTrackingScreen> {
  Map<String, dynamic>? _tracking;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.pickupId != null) _loadTracking();
    else setState(() => _loading = false);
  }

  Future<void> _loadTracking() async {
    setState(() { _loading = true; _error = null; });
    final repo = ref.read(pickupRepositoryProvider);
    final result = await repo.getTracking(widget.pickupId!);
    if (mounted) {
      setState(() {
        _loading = false;
        if (result.isSuccess) _tracking = result.data;
        else _error = result.errorMessage;
      });
    }
  }

  String get _orderCode {
    if (_tracking != null) {
      return _tracking!['order_code']?.toString() ??
          _tracking!['pickup_code']?.toString() ??
          '#${widget.pickupId}';
    }
    return widget.pickupId != null ? '#${widget.pickupId}' : '#OD-4921';
  }

  String get _currentStatus {
    return _tracking?['status']?.toString() ?? 'assigned';
  }

  String? get _agentName {
    final pb = _tracking?['pickup_boy'];
    if (pb is Map) return pb['name']?.toString();
    return _tracking?['pickup_boy_name']?.toString();
  }

  String? get _agentPhone {
    final pb = _tracking?['pickup_boy'];
    if (pb is Map) return pb['phone']?.toString();
    return null;
  }

  List<_TrackStep> get _steps {
    final s = _currentStatus.toLowerCase();
    return [
      _TrackStep(
        title: 'tracking.step_1_title'.tr(),
        subtitle: 'tracking.step_1_sub'.tr(),
        done: true,
      ),
      _TrackStep(
        title: 'tracking.step_2_title'.tr(),
        subtitle: _agentName != null
            ? '$_agentName assigned'
            : 'tracking.step_2_sub'.tr(),
        done: ['assigned', 'on_the_way', 'arrived', 'completed'].contains(s),
        active: s == 'assigned',
      ),
      _TrackStep(
        title: 'On The Way',
        subtitle: 'Agent heading to your location',
        done: ['on_the_way', 'arrived', 'completed'].contains(s),
        active: s == 'on_the_way',
      ),
      _TrackStep(
        title: 'tracking.step_3_title'.tr(),
        subtitle: 'tracking.step_3_sub'.tr(),
        done: ['arrived', 'completed'].contains(s),
        active: s == 'arrived',
      ),
      _TrackStep(
        title: 'Completed',
        subtitle: 'Pickup completed',
        done: s == 'completed',
        active: s == 'completed',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeft,
              color: AppTheme.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          '${'tracking.title'.tr()} $_orderCode',
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null && _tracking == null
              ? _buildError()
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Status badge
                      Container(
                        margin: const EdgeInsets.all(24),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const FaIcon(FontAwesomeIcons.truck,
                                color: Colors.white, size: 14),
                            const SizedBox(width: 8),
                            Text(
                              _currentStatus
                                  .replaceAll('_', ' ')
                                  .toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Header
                      Text(
                        'tracking.collection_progress'.tr(),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'tracking.est_arrival'.tr(),
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Timeline
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Column(
                          children: _steps
                              .asMap()
                              .entries
                              .map(
                                (e) => _buildTimelineStep(
                                  step: e.value,
                                  isLast: e.key == _steps.length - 1,
                                  agentCard: e.key == 1 && _agentName != null
                                      ? _buildAgentCard()
                                      : null,
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Bottom actions
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 16),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const FaIcon(
                                      FontAwesomeIcons.solidCircleQuestion,
                                      color: Colors.grey,
                                      size: 18),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'tracking.need_help'.tr(),
                                      style: const TextStyle(
                                          color: AppTheme.textSecondary,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  const FaIcon(
                                      FontAwesomeIcons.chevronRight,
                                      color: Colors.grey,
                                      size: 14),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (_agentPhone != null)
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2C3E50),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const FaIcon(FontAwesomeIcons.phone,
                                        size: 16),
                                    const SizedBox(width: 8),
                                    Text('tracking.call_agent'.tr()),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(FontAwesomeIcons.triangleExclamation,
              color: Colors.orange, size: 48),
          const SizedBox(height: 16),
          Text(_error ?? 'Failed to load tracking',
              style: const TextStyle(color: AppTheme.textSecondary)),
          const SizedBox(height: 16),
          ElevatedButton(
              onPressed: _loadTracking, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildTimelineStep({
    required _TrackStep step,
    required bool isLast,
    Widget? agentCard,
  }) {
    final Color iconBg = step.done
        ? AppTheme.primaryColor
        : step.active
            ? Colors.blue.shade500
            : Colors.grey.shade300;
    final IconData icon =
        step.done ? FontAwesomeIcons.check : FontAwesomeIcons.circle;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
                child: Center(
                    child: FaIcon(icon, color: Colors.white, size: 12)),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: step.done
                        ? AppTheme.primaryColor
                        : Colors.grey.shade300,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 4),
                Text(
                  step.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: step.done || step.active
                        ? AppTheme.textPrimary
                        : AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(step.subtitle,
                    style: const TextStyle(
                        fontSize: 13, color: AppTheme.textSecondary)),
                if (agentCard != null) ...[
                  const SizedBox(height: 12),
                  agentCard,
                ],
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgentCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primaryLight,
            ),
            child: const Center(
              child: FaIcon(FontAwesomeIcons.user,
                  color: AppTheme.primaryColor, size: 20),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _agentName ?? 'Pickup Agent',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'tracking.agent_details'.tr(),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TrackStep {
  final String title;
  final String subtitle;
  final bool done;
  final bool active;

  const _TrackStep({
    required this.title,
    required this.subtitle,
    this.done = false,
    this.active = false,
  });
}

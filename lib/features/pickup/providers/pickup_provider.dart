import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/pickup_request_model.dart';
import '../domain/models/tracking_timeline_model.dart';
import '../domain/repositories/pickup_repository.dart';

final pickupsProvider = FutureProvider<List<PickupRequestModel>>((ref) async {
  final repository = ref.watch(pickupRepositoryProvider);
  final response = await repository.fetchPickups();
  if (response.isSuccess) {
    return response.data!;
  } else {
    throw Exception(response.errorMessage ?? 'Failed to fetch pickups');
  }
});

final pickupDetailProvider = FutureProvider.family<PickupRequestModel, int>((
  ref,
  id,
) async {
  final repository = ref.watch(pickupRepositoryProvider);
  final response = await repository.fetchPickupById(id);
  if (response.isSuccess) {
    return response.data!;
  } else {
    throw Exception(response.errorMessage ?? 'Failed to fetch pickup details');
  }
});

final trackingProvider = FutureProvider.family<TrackingTimelineModel, int>((
  ref,
  id,
) async {
  final repository = ref.watch(pickupRepositoryProvider);
  final response = await repository.fetchTracking(id);
  if (response.isSuccess) {
    return response.data!;
  } else {
    throw Exception(
      response.errorMessage ?? 'Failed to fetch tracking details',
    );
  }
});

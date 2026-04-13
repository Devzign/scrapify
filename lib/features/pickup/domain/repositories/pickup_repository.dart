import 'dart:io';

import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/pickup_request_model.dart';
import '../models/tracking_timeline_model.dart';

final pickupRepositoryProvider = Provider<PickupRepository>((ref) {
  return PickupRepository(DioClient());
});

class PickupRepository {
  final DioClient _dioClient;

  PickupRepository(this._dioClient);

  Future<ApiResponse<PickupRequestModel>> createPickup(
    Map<String, dynamic> data,
  ) async {
    return _submitPickupForm(ApiEndpoints.pickupRequest, data);
  }

  Future<ApiResponse<PickupRequestModel>> createDonationPickup(
    Map<String, dynamic> data,
  ) async {
    return _submitPickupForm(ApiEndpoints.donationRequest, data);
  }

  Future<ApiResponse<PickupRequestModel>> clonePickupAsDonation(int id) async {
    return _dioClient.post<PickupRequestModel>(
      ApiEndpoints.pickupRequestCloneAsDonation(id),
      parser: (json) =>
          PickupRequestModel.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<PickupRequestModel>> _submitPickupForm(
    String path,
    Map<String, dynamic> data,
  ) async {
    final Map<String, dynamic> payload = Map<String, dynamic>.from(data);
    final List<XFile> images =
        (payload.remove('images') as List<dynamic>? ?? []).cast<XFile>();
    final List<dynamic> items = payload.remove('items') as List<dynamic>? ?? [];

    final formData = FormData();

    _addFieldIfPresent(formData, 'address', payload['address']);
    _addFieldIfPresent(formData, 'address_id', payload['address_id']);
    _addFieldIfPresent(formData, 'city_id', payload['city_id']);
    _addFieldIfPresent(formData, 'pincode', payload['pincode']);
    _addFieldIfPresent(formData, 'latitude', payload['latitude']);
    _addFieldIfPresent(formData, 'longitude', payload['longitude']);
    _addFieldIfPresent(formData, 'scheduled_at', payload['scheduled_at']);
    _addFieldIfPresent(formData, 'payout_method', payload['payout_method']);
    _addFieldIfPresent(
      formData,
      'payment_detail_id',
      payload['payment_detail_id'],
    );

    for (var itemIndex = 0; itemIndex < items.length; itemIndex++) {
      final item = Map<String, dynamic>.from(items[itemIndex] as Map);
      _addFieldIfPresent(
        formData,
        'items[$itemIndex][category_id]',
        item['category_id'],
      );
      _addFieldIfPresent(
        formData,
        'items[$itemIndex][item_id]',
        item['item_id'],
      );
      _addFieldIfPresent(
        formData,
        'items[$itemIndex][quantity]',
        item['quantity'],
      );
      _addFieldIfPresent(formData, 'items[$itemIndex][weight]', item['weight']);

      final attributes = item['attributes'] as List<dynamic>? ?? [];
      for (var attrIndex = 0; attrIndex < attributes.length; attrIndex++) {
        final attribute = Map<String, dynamic>.from(
          attributes[attrIndex] as Map,
        );
        _addFieldIfPresent(
          formData,
          'items[$itemIndex][attributes][$attrIndex][attribute_id]',
          attribute['attribute_id'],
        );
        _addFieldIfPresent(
          formData,
          'items[$itemIndex][attributes][$attrIndex][value]',
          attribute['value'],
        );
      }
    }

    for (var i = 0; i < images.length; i++) {
      final imageFile = File(images[i].path);
      final exists = await imageFile.exists();
      if (!exists) {
        throw Exception('Selected image not found: ${images[i].path}');
      }

      formData.files.add(
        MapEntry(
          'images[]',
          await MultipartFile.fromFile(
            images[i].path,
            filename: images[i].name,
          ),
        ),
      );
    }

    AppLogger.info(
      'Pickup request prepared with ${formData.fields.length} fields and ${formData.files.length} files.',
    );

    return _dioClient.post<PickupRequestModel>(
      path,
      data: formData,
      parser: (json) =>
          PickupRequestModel.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<List<PickupRequestModel>>> fetchPickups() async {
    return _dioClient.get<List<PickupRequestModel>>(
      ApiEndpoints.pickupRequests,
      parser: (json) {
        final data = json['data'];
        final List<dynamic> list;

        if (data is List<dynamic>) {
          list = data;
        } else if (data is Map<String, dynamic>) {
          list = data['items'] as List<dynamic>? ?? const [];
        } else {
          throw const FormatException('Unexpected pickup list response shape');
        }

        return list
            .map((e) => PickupRequestModel.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }

  Future<ApiResponse<PickupRequestModel>> fetchPickupById(int id) async {
    return _dioClient.get<PickupRequestModel>(
      ApiEndpoints.pickupRequestById(id),
      parser: (json) =>
          PickupRequestModel.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<TrackingTimelineModel>> fetchTracking(int id) async {
    return _dioClient.get<TrackingTimelineModel>(
      ApiEndpoints.pickupRequestTracking(id),
      parser: (json) => TrackingTimelineModel.fromJson(json),
    );
  }

  Future<ApiResponse<void>> submitReview(
    int id,
    int rating,
    String? review,
  ) async {
    return _dioClient.post<void>(
      ApiEndpoints.pickupRequestReview(id),
      data: {'rating': rating, 'review': review},
    );
  }
}

void _addFieldIfPresent(FormData formData, String key, dynamic value) {
  if (value == null) {
    return;
  }

  final stringValue = value.toString();
  if (stringValue.isEmpty) {
    return;
  }

  formData.fields.add(MapEntry(key, stringValue));
}

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/dio_client.dart';
import '../models/address_model.dart';

class AddressRepository {
  final DioClient _apiClient;

  AddressRepository(this._apiClient);

  Future<ApiResponse<List<AddressModel>>> getAddresses() async {
    final response = await _apiClient.get(ApiEndpoints.authProfileAddresses);
    if (response.isSuccess) {
      try {
        final List<dynamic> data = response.data['data'] ?? [];
        final addresses = data.map((e) => AddressModel.fromJson(e)).toList();
        return ApiResponse.success(addresses);
      } catch (e) {
        return ApiResponse.error('Failed to parse addresses');
      }
    }
    return ApiResponse.error(
      response.errorMessage ?? 'Failed to fetch addresses',
    );
  }

  Future<ApiResponse<String>> addAddress(AddressModel address) async {
    final response = await _apiClient.post(
      ApiEndpoints.authProfileAddresses,
      data: address.toJson(),
    );
    if (response.isSuccess) {
      return ApiResponse.success(
        response.data['message'] ?? 'Address created successfully',
      );
    }
    return ApiResponse.error(response.errorMessage ?? 'Failed to add address');
  }

  Future<ApiResponse<String>> updateAddress(
    int id,
    AddressModel address,
  ) async {
    final response = await _apiClient.put(
      ApiEndpoints.authProfileAddressById(id),
      data: address.toJson(),
    );
    if (response.isSuccess) {
      return ApiResponse.success(
        response.data['message'] ?? 'Address updated successfully',
      );
    }
    return ApiResponse.error(
      response.errorMessage ?? 'Failed to update address',
    );
  }

  Future<ApiResponse<String>> deleteAddress(int id) async {
    final response = await _apiClient.delete(
      ApiEndpoints.authProfileAddressById(id),
    );
    if (response.isSuccess) {
      return ApiResponse.success(
        response.data['message'] ?? 'Address deleted successfully',
      );
    }
    return ApiResponse.error(
      response.errorMessage ?? 'Failed to delete address',
    );
  }
}

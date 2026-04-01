import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/dio_client.dart';
import '../models/payment_method_model.dart';

class PaymentRepository {
  final DioClient _apiClient;

  PaymentRepository(this._apiClient);

  Future<ApiResponse<List<PaymentMethodModel>>> getPaymentDetails() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.authProfilePaymentDetails);

      if (response.isSuccess) {
        final List<dynamic> data = response.data['data'] ?? [];
        final paymentMethods = data.map((json) => PaymentMethodModel.fromJson(json)).toList();
        return ApiResponse.success(paymentMethods);
      }
      return ApiResponse.error(response.errorMessage ?? 'Failed to fetch payment methods');
    } catch (e) {
      return ApiResponse.error('Exception fetching payment methods: $e');
    }
  }

  Future<ApiResponse<PaymentMethodModel>> addPaymentDetail(PaymentMethodModel payment) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.authProfilePaymentDetails,
        data: payment.toJson(),
      );

      if (response.isSuccess) {
        return ApiResponse.success(PaymentMethodModel.fromJson(response.data['data'] ?? {}));
      }
      return ApiResponse.error(response.errorMessage ?? 'Failed to add payment method');
    } catch (e) {
      return ApiResponse.error('Exception adding payment method: $e');
    }
  }

  Future<ApiResponse<PaymentMethodModel>> updatePaymentDetail(int id, PaymentMethodModel payment) async {
    try {
      final response = await _apiClient.put(
        ApiEndpoints.authProfilePaymentDetailById(id),
        data: payment.toJson(),
      );

      if (response.isSuccess) {
        return ApiResponse.success(PaymentMethodModel.fromJson(response.data['data'] ?? {}));
      }
      return ApiResponse.error(response.errorMessage ?? 'Failed to update payment method');
    } catch (e) {
      return ApiResponse.error('Exception updating payment method: $e');
    }
  }

  Future<ApiResponse<void>> deletePaymentDetail(int id) async {
    try {
      final response = await _apiClient.delete(ApiEndpoints.authProfilePaymentDetailById(id));

      if (response.isSuccess) {
        return ApiResponse.success(null);
      }
      return ApiResponse.error(response.errorMessage ?? 'Failed to delete payment method');
    } catch (e) {
      return ApiResponse.error('Exception deleting payment method: $e');
    }
  }
}

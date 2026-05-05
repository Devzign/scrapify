import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/dio_client.dart';
import '../../../auth/providers/auth_provider.dart';
import '../models/help_support_ticket_model.dart';

final helpSupportRepositoryProvider = Provider<HelpSupportRepository>((ref) {
  final dio = ref.watch(dioClientProvider);
  return HelpSupportRepository(dio);
});

class HelpSupportRepository {
  final DioClient _dioClient;

  HelpSupportRepository(this._dioClient);

  Future<ApiResponse<bool>> submitTicket({
    required String subject,
    required String message,
    required String phone,
    int? orderId,
  }) {
    return _dioClient.post<bool>(
      ApiEndpoints.helpSupport,
      data: {
        'subject': subject,
        'message': message,
        'phone': phone,
        if (orderId != null) 'order_id': orderId,
      },
      options: orderId == null ? null : _buildOrderHeaderOptions(orderId),
      parser: (json) {
        final map = json as Map<String, dynamic>;
        final success = map['success'] == true;
        final code = (map['code'] as num?)?.toInt();
        return success || (code != null && code >= 200 && code < 300);
      },
    );
  }

  Future<ApiResponse<List<HelpSupportTicketModel>>> getTickets({
    int perPage = 15,
  }) {
    return _dioClient.get<List<HelpSupportTicketModel>>(
      ApiEndpoints.helpSupport,
      queryParameters: {'per_page': perPage},
      parser: (json) {
        final map = json as Map<String, dynamic>;
        final rawData = map['data'];
        final list = rawData is List
            ? rawData
            : (rawData is Map<String, dynamic>
                  ? rawData['data'] as List<dynamic>? ?? const []
                  : const []);
        return list
            .whereType<Map>()
            .map(
              (e) =>
                  HelpSupportTicketModel.fromJson(Map<String, dynamic>.from(e)),
            )
            .toList();
      },
    );
  }
}

Options _buildOrderHeaderOptions(int orderId) {
  return Options(headers: {'X-Order-Id': orderId.toString()});
}

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/dio_client.dart';
import '../models/kyc_document_model.dart';

final kycRepositoryProvider = Provider<KycRepository>((ref) {
  return KycRepository(DioClient());
});

class KycRepository {
  final DioClient _dioClient;

  KycRepository(this._dioClient);

  Future<ApiResponse<KycDocumentModel>> uploadKyc({
    required String documentType,
    required String documentNumber,
    required File image,
  }) async {
    final formData = FormData.fromMap({
      'document_type': documentType,
      'document_number': documentNumber,
      'image': await MultipartFile.fromFile(image.path),
    });

    return _dioClient.post<KycDocumentModel>(
      ApiEndpoints.authProfileKyc,
      data: formData,
      parser: (json) => KycDocumentModel.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<List<KycDocumentModel>>> getKycDocuments() async {
    // Assuming there might be a GET endpoint for this, or it's part of profile
    return _dioClient.get<List<KycDocumentModel>>(
      ApiEndpoints.authProfileKyc, // Adjust if endpoint is different
      parser: (json) {
        final List<dynamic> list = json['data'] as List<dynamic>;
        return list.map((e) => KycDocumentModel.fromJson(e as Map<String, dynamic>)).toList();
      },
    );
  }
}

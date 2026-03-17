import 'package:dio/dio.dart';

/// A custom core exception class for API errors.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

/// Helper utility to parse [DioException] into readable [ApiException]s.
class ApiErrorHandler {
  static ApiException handle(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          return ApiException('Connection timeout with the server.');
        case DioExceptionType.sendTimeout:
          return ApiException('Send timeout in connection with the server.');
        case DioExceptionType.receiveTimeout:
          return ApiException('Receive timeout in connection with the server.');
        case DioExceptionType.badCertificate:
          return ApiException('Invalid certificate. Connection is not secure.');
        case DioExceptionType.badResponse:
          return _handleBadResponse(error);
        case DioExceptionType.cancel:
          return ApiException('Request to the server was cancelled.');
        case DioExceptionType.connectionError:
          return ApiException(
            'No internet connection. Please check your network.',
          );
        case DioExceptionType.unknown:
          return ApiException(
            'Unexpected error occurred. Please try again later.',
          );
      }
    }
    return ApiException('An unexpected error occurred: ${error.toString()}');
  }

  static ApiException _handleBadResponse(DioException error) {
    final statusCode = error.response?.statusCode;
    final responseData = error.response?.data;

    // Default error message from backend if available
    String defaultMessage = 'Something went wrong. Please try again.';
    if (responseData is Map<String, dynamic> &&
        responseData.containsKey('message')) {
      defaultMessage = responseData['message'];
    }

    switch (statusCode) {
      case 400:
        return ApiException(
          'Bad Request: $defaultMessage',
          statusCode: statusCode,
        );
      case 401:
        return ApiException(
          'Unauthorized: $defaultMessage',
          statusCode: statusCode,
        );
      case 403:
        return ApiException(
          'Forbidden: $defaultMessage',
          statusCode: statusCode,
        );
      case 404:
        return ApiException(
          'Not Found: $defaultMessage',
          statusCode: statusCode,
        );
      case 500:
        return ApiException(
          'Internal Server Error: $defaultMessage',
          statusCode: statusCode,
        );
      case 502:
        return ApiException(
          'Bad Gateway: $defaultMessage',
          statusCode: statusCode,
        );
      case 503:
        return ApiException(
          'Service Unavailable: $defaultMessage',
          statusCode: statusCode,
        );
      default:
        return ApiException(
          'Server Error ($statusCode): $defaultMessage',
          statusCode: statusCode,
        );
    }
  }
}

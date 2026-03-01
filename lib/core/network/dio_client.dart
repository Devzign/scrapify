import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_exceptions.dart';
import 'api_response.dart';

/// Core Networking Class handling all HTTP requests for the application.
class DioClient {
  late final Dio _dio;

  // Ideally, read this from an environment variables configuration (.env)
  static const String _baseUrl = 'https://floralwhite-spoonbill-935004.hostingersite.com/api';

  DioClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Fetch token from local storage and append it
          final prefs = await SharedPreferences.getInstance();
          String? token = prefs.getString('auth_token');
          
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token'; // JWT Format
          }

          if (kDebugMode) {
            print('--> ${options.method.toUpperCase()} ${options.baseUrl}${options.path}');
            print('Headers: ${options.headers}');
            if (options.data != null) {
              print('Body: ${options.data}');
            }
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            print('<-- ${response.statusCode} ${response.requestOptions.path}');
            print('Response: ${response.data}');
          }
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          if (kDebugMode) {
            print('<-- Error ${e.response?.statusCode} ${e.requestOptions.path}');
            print('Error Message: ${e.message}');
            if (e.response?.data != null) {
              print('Error Data: ${e.response?.data}');
            }
          }

          // Format error using custom handler before passing up stream
          final customException = ApiErrorHandler.handle(e);
          
          return handler.next(
            DioException(
              requestOptions: e.requestOptions,
              response: e.response,
              type: e.type,
              error: customException,
              message: customException.message,
            ),
          );
        },
      ),
    );
  }

  /// Expose the underlying Dio instance if needed directly
  Dio get instance => _dio;

  //===================================================================
  // REUSABLE REST METHODS
  //===================================================================

  /// Performs a standardized GET request.
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    T Function(dynamic data)? parser,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return _processResponse(response, parser);
    } catch (e) {
      return _handleException(e);
    }
  }

  /// Performs a standardized POST request.
  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    T Function(dynamic data)? parser,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return _processResponse(response, parser);
    } catch (e) {
      return _handleException(e);
    }
  }

  /// Performs a standardized PUT request.
  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    T Function(dynamic data)? parser,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return _processResponse(response, parser);
    } catch (e) {
      return _handleException(e);
    }
  }

  /// Performs a standardized DELETE request.
  Future<ApiResponse<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    T Function(dynamic data)? parser,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return _processResponse(response, parser);
    } catch (e) {
      return _handleException(e);
    }
  }

  //===================================================================
  // INTERNAL HELPERS
  //===================================================================

  /// Generic mapping strategy for responses.
  /// If a [parser] is provided, parses [response.data]. Otherwise, returns data blindly.
  ApiResponse<T> _processResponse<T>(
    Response response,
    T Function(dynamic data)? parser,
  ) {
    try {
      final responseData = response.data;
      if (parser != null) {
        return ApiResponse.success(
          parser(responseData),
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse.success(
          responseData as T,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error(
        'Failed to parse response: ${e.toString()}',
        statusCode: response.statusCode,
      );
    }
  }

  /// Generic exception mapper
  ApiResponse<T> _handleException<T>(dynamic error) {
    if (error is DioException && error.error is ApiException) {
      final apiException = error.error as ApiException;
      return ApiResponse.error(
        apiException.message,
        statusCode: apiException.statusCode ?? error.response?.statusCode,
      );
    }
    final fallbackException = ApiErrorHandler.handle(error);
    return ApiResponse.error(
      fallbackException.message,
      statusCode: fallbackException.statusCode,
    );
  }
}

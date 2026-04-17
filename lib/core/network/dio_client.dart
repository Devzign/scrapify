import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';
import '../session/session_controller.dart';
import '../storage/app_preferences.dart';
import '../utils/app_logger.dart';
import '../utils/app_routes.dart';
import 'api_exceptions.dart';
import 'api_response.dart';

class DioClient {
  static bool _isHandlingUnauthorized = false;
  late final Dio _dio;

  DioClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.instance.baseUrl,
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
            options.headers['Authorization'] = 'Bearer $token';
          }

          if (kDebugMode) {
            AppLogger.info(
              '--> [REQUEST] ${options.method.toUpperCase()} ${options.baseUrl}${options.path}',
            );
            AppLogger.info('Headers: ${options.headers}');
            if (options.data != null) {
              try {
                final prettyJson = const JsonEncoder.withIndent(
                  '  ',
                ).convert(options.data);
                AppLogger.info('Request Body:\n$prettyJson');
              } catch (_) {
                AppLogger.info('Request Body: ${options.data}');
              }
            }
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            AppLogger.info(
              '<-- [RESPONSE] ${response.statusCode} ${response.requestOptions.baseUrl}${response.requestOptions.path}',
            );
            try {
              final prettyJson = const JsonEncoder.withIndent(
                '  ',
              ).convert(response.data);
              AppLogger.info('Response Body:\n$prettyJson');
            } catch (_) {
              AppLogger.info('Response Body: ${response.data}');
            }
          }
          return handler.next(response);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            await _handleUnauthorized();
          }

          if (kDebugMode) {
            AppLogger.error(
              '<-- [ERROR] ${e.response?.statusCode} ${e.requestOptions.baseUrl}${e.requestOptions.path}',
            );
            AppLogger.error('Error Message: ${e.message}');
            if (e.response?.data != null) {
              try {
                final prettyJson = const JsonEncoder.withIndent(
                  '  ',
                ).convert(e.response?.data);
                AppLogger.error('Error Data:\n$prettyJson');
              } catch (_) {
                AppLogger.error('Error Data: ${e.response?.data}');
              }
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
      final requestOptions = options?.copyWith() ?? Options();
      if (data is FormData) {
        requestOptions.contentType = Headers.multipartFormDataContentType;
        requestOptions.headers = {
          ...?requestOptions.headers,
          'Accept': 'application/json',
        }..remove('Content-Type');
      }

      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: requestOptions,
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

  Future<void> _handleUnauthorized() async {
    if (_isHandlingUnauthorized) {
      return;
    }

    _isHandlingUnauthorized = true;

    try {
      await AppPreferences().clearSession();
      SessionController.instance.notifyForcedLogout();

      final currentPath =
          AppRoutes.router.routeInformationProvider.value.uri.path;
      final shouldRedirect =
          currentPath != AppRoutes.login &&
          currentPath != AppRoutes.splash &&
          currentPath != AppRoutes.onboarding &&
          currentPath != AppRoutes.language;

      if (shouldRedirect) {
        AppRoutes.router.go(AppRoutes.login);
      }
    } finally {
      _isHandlingUnauthorized = false;
    }
  }
}

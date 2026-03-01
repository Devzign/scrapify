/// Wrapper class for API responses that holds either parsed data [T] or an error message.
class ApiResponse<T> {
  final T? data;
  final String? errorMessage;
  final int? statusCode;

  ApiResponse({
    this.data,
    this.errorMessage,
    this.statusCode,
  });

  /// Check if the API call was successful
  bool get isSuccess => errorMessage == null && data != null;

  /// Check if the API call failed
  bool get isError => errorMessage != null;

  /// Factory method for successful responses
  factory ApiResponse.success(T data, {int? statusCode}) {
    return ApiResponse(
      data: data,
      statusCode: statusCode,
    );
  }

  /// Factory method for failed responses
  factory ApiResponse.error(String message, {int? statusCode}) {
    return ApiResponse(
      errorMessage: message,
      statusCode: statusCode,
    );
  }
}

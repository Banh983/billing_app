class ApiResult<T> {
  final bool success;
  final T? data;
  final String? message;
  final int? statusCode;

  ApiResult({required this.success, this.data, this.message, this.statusCode});

  /// SUCCESS helper
  factory ApiResult.success({T? data, String? message, int? statusCode}) {
    return ApiResult<T>(
      success: true,
      data: data,
      message: message,
      statusCode: statusCode,
    );
  }

  /// ERROR helper
  factory ApiResult.error({String? message, int? statusCode, T? data}) {
    return ApiResult<T>(
      success: false,
      data: data,
      message: message,
      statusCode: statusCode,
    );
  }

  /// Convert HTTP response → ApiResult (optional helper)
  static ApiResult<T> fromResponse<T>({
    required int statusCode,
    dynamic body,
    T? data,
  }) {
    final isSuccess = statusCode >= 200 && statusCode < 300;

    String? message;

    if (body is Map && body["message"] != null) {
      message = body["message"].toString();
    }

    return ApiResult<T>(
      success: isSuccess,
      data: data,
      message: message,
      statusCode: statusCode,
    );
  }
}

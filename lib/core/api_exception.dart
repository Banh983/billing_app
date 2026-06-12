class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic error;

  const ApiException({required this.message, this.statusCode, this.error});

  bool get isUnauthorized => statusCode == 401;

  @override
  String toString() => message;
}

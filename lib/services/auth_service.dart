import 'dart:convert';

import 'package:billing_app/core/api_exception.dart';
import 'package:billing_app/core/app_config.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/auth_model.dart';

class AuthService {
  final String baseUrl = AppConfig.baseUrl;

  // ======================
  // DECODE RESPONSE
  // ======================

  Map<String, dynamic> _decodeJsonOrThrow(http.Response response) {
    if (kDebugMode) {
      debugPrint("STATUS: ${response.statusCode}");

      // Không in toàn bộ response đăng nhập vì có access token.
      debugPrint("RESPONSE RECEIVED: ${response.request?.url}");
    }

    final String body = utf8.decode(response.bodyBytes);

    if (body.trim().isEmpty) {
      throw ApiException(
        statusCode: response.statusCode,
        message: "Server không trả về dữ liệu",
      );
    }

    try {
      final dynamic decoded = jsonDecode(body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }

      throw ApiException(
        statusCode: response.statusCode,
        message: "Dữ liệu server trả về không đúng định dạng",
      );
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(
        statusCode: response.statusCode,
        message: "Server không trả về JSON hợp lệ. Kiểm tra lại API endpoint.",
      );
    }
  }

  // ======================
  // GET BACKEND MESSAGE
  // ======================

  String _extractMessage(
    Map<String, dynamic> responseData, {
    required String fallback,
  }) {
    final dynamic rawMessage = responseData["message"];

    if (rawMessage is String && rawMessage.trim().isNotEmpty) {
      return rawMessage.trim();
    }

    if (rawMessage is List && rawMessage.isNotEmpty) {
      final dynamic firstError = rawMessage.first;

      if (firstError is Map) {
        final dynamic fieldMessage = firstError["message"];

        if (fieldMessage != null && fieldMessage.toString().trim().isNotEmpty) {
          return fieldMessage.toString().trim();
        }
      }

      return rawMessage.join(", ");
    }

    return fallback;
  }

  // ======================
  // THROW API ERROR
  // ======================

  Never _throwApiError(
    http.Response response,
    Map<String, dynamic> responseData, {
    required String fallbackMessage,
  }) {
    throw ApiException(
      statusCode: response.statusCode,
      message: _extractMessage(responseData, fallback: fallbackMessage),
      error: responseData["error"],
    );
  }

  // ======================
  // LOGIN
  // ======================

  Future<AuthModel> login(String username, String password) async {
    final Uri url = Uri.parse("$baseUrl/login");

    final http.Response response = await http.post(
      url,
      headers: const {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode({"username": username, "password": password}),
    );

    if (kDebugMode) {
      debugPrint("LOGIN URL: $url");
    }

    final Map<String, dynamic> responseData = _decodeJsonOrThrow(response);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final dynamic rawData = responseData["data"];

      if (rawData is! Map) {
        throw ApiException(
          statusCode: response.statusCode,
          message: "Backend không trả về dữ liệu đăng nhập hợp lệ",
        );
      }

      final Map<String, dynamic> loginData = Map<String, dynamic>.from(rawData);

      final AuthModel loginResult = AuthModel.fromJson(loginData);

      if (loginResult.accessToken.trim().isEmpty) {
        throw ApiException(
          statusCode: response.statusCode,
          message:
              "Backend đăng nhập thành công nhưng không trả về access token",
        );
      }

      return loginResult;
    }

    _throwApiError(
      response,
      responseData,
      fallbackMessage: "Đăng nhập thất bại",
    );
  }

  // ======================
  // GET ACCOUNT
  // ======================

  Future<AuthModel> getAccount(String token) async {
    final Uri url = Uri.parse("$baseUrl/account");

    final http.Response response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (kDebugMode) {
      debugPrint("ACCOUNT URL: $url");
    }

    final Map<String, dynamic> responseData = _decodeJsonOrThrow(response);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final dynamic rawData = responseData["data"];

      if (rawData is! Map) {
        throw ApiException(
          statusCode: response.statusCode,
          message: "Backend không trả về thông tin tài khoản hợp lệ",
        );
      }

      return AuthModel.fromJson(Map<String, dynamic>.from(rawData));
    }

    // Nếu backend trả 401:
    // message sẽ giữ nguyên:
    // "Token không hợp lệ, đã hết hạn hoặc bạn chưa đăng nhập"
    _throwApiError(
      response,
      responseData,
      fallbackMessage: "Không lấy được thông tin tài khoản",
    );
  }

  // ======================
  // CHANGE PASSWORD
  // ======================

  Future<String> changePassword(
    String oldPass,
    String newPass,
    String confirmPass,
    String token,
  ) async {
    final Uri url = Uri.parse("$baseUrl/users/me/password");

    final http.Response response = await http.put(
      url,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "oldPassword": oldPass,
        "newPassword": newPass,
        "confirmPassword": confirmPass,
      }),
    );

    if (kDebugMode) {
      debugPrint("CHANGE PASSWORD URL: $url");
    }

    final Map<String, dynamic> responseData = _decodeJsonOrThrow(response);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final dynamic rawData = responseData["data"];

      if (rawData is Map) {
        final dynamic dataMessage = rawData["message"];

        if (dataMessage != null && dataMessage.toString().trim().isNotEmpty) {
          return dataMessage.toString().trim();
        }
      }

      final dynamic rootMessage = responseData["message"];

      if (rootMessage is String &&
          rootMessage.trim().isNotEmpty &&
          rootMessage != "Call API successful") {
        return rootMessage.trim();
      }

      // Backend hiện chỉ trả "Call API successful"
      // nên cần nội dung thân thiện làm fallback.
      return "Đổi mật khẩu thành công";
    }

    _throwApiError(
      response,
      responseData,
      fallbackMessage: "Đổi mật khẩu thất bại",
    );
  }
}

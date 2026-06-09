import 'dart:convert';

import 'package:billing_app/core/app_config.dart';
import 'package:http/http.dart' as http;

import '../models/auth_model.dart';

class AuthService {
  final String baseUrl = AppConfig.baseUrl;

  dynamic _decodeJsonOrThrow(http.Response res) {
    print("STATUS: ${res.statusCode}");
    print("BODY: ${res.body}");

    try {
      return jsonDecode(res.body);
    } catch (_) {
      throw Exception(
        "Server không trả về JSON. Kiểm tra lại baseUrl/API endpoint.\n"
        "Status: ${res.statusCode}",
      );
    }
  }

  Future<AuthModel> login(String username, String password) async {
    final res = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"username": username, "password": password}),
    );

    print("LOGIN URL: $baseUrl/login");

    final data = _decodeJsonOrThrow(res);

    if (res.statusCode == 200 && data["data"] != null) {
      return AuthModel.fromJson(data["data"]);
    }

    if (data["message"] is List && data["message"].isNotEmpty) {
      final firstError = data["message"][0];

      if (firstError is Map && firstError["message"] != null) {
        throw Exception(firstError["message"]);
      }
    }

    if (data["message"] != null) {
      throw Exception(data["message"]);
    }

    throw Exception("Đăng nhập thất bại");
  }

  Future<AuthModel> getAccount(String token) async {
    final res = await http.get(
      Uri.parse("$baseUrl/account"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    print("ACCOUNT URL: $baseUrl/account");

    final data = _decodeJsonOrThrow(res);

    if (res.statusCode == 200 && data["data"] != null) {
      return AuthModel.fromJson(data["data"]);
    }

    if (data["message"] != null) {
      throw Exception(data["message"]);
    }

    throw Exception("Không lấy được thông tin tài khoản");
  }

  Future<String> changePassword(
    String oldPass,
    String newPass,
    String confirmPass,
    String token,
  ) async {
    final res = await http.put(
      Uri.parse("$baseUrl/users/me/password"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "oldPassword": oldPass,
        "newPassword": newPass,
        "confirmPassword": confirmPass,
      }),
    );

    print("CHANGE PASSWORD URL: $baseUrl/users/me/password");

    final data = _decodeJsonOrThrow(res);

    if (res.statusCode == 200) {
      if (data["data"] != null && data["data"]["message"] != null) {
        return data["data"]["message"];
      }

      if (data["message"] is String &&
          data["message"] != "Call API successful") {
        return data["message"];
      }

      return "Đổi mật khẩu thành công";
    }

    if (data["message"] is List && data["message"].isNotEmpty) {
      final firstError = data["message"][0];

      if (firstError is Map && firstError["message"] != null) {
        throw Exception(firstError["message"]);
      }
    }

    if (data["message"] is String) {
      throw Exception(data["message"]);
    }

    throw Exception("Đổi mật khẩu thất bại");
  }
}

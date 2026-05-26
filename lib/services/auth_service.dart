import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/auth_model.dart';

class AuthService {
  // Dùng mạng nào thì đưa ip mạng đó vào
  // final String baseUrl = "http://192.168.1.35:8080";

  final String baseUrl = "http://192.168.97.204:8080";

  // ======================
  // LOGIN
  // ======================

  Future<AuthModel> login(String email, String password) async {
    final res = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    final data = jsonDecode(res.body);

    print("LOGIN STATUS: ${res.statusCode}");
    print("LOGIN BODY: ${res.body}");

    // ======================
    // SUCCESS
    // ======================

    if (res.statusCode == 200 && data["data"] != null) {
      return AuthModel.fromJson(data["data"]);
    }

    // ======================
    // VALIDATION ERRORS
    // ======================

    if (data["message"] is List && data["message"].isNotEmpty) {
      final firstError = data["message"][0];

      if (firstError is Map && firstError["message"] != null) {
        throw Exception(firstError["message"]);
      }
    }

    // ======================
    // NORMAL MESSAGE
    // ======================

    if (data["message"] != null) {
      throw Exception(data["message"]);
    }

    // ======================
    // FALLBACK
    // ======================

    throw Exception("Đăng nhập thất bại");
  }

  // ======================
  // GET ACCOUNT
  // ======================

  Future<AuthModel> getAccount(String token) async {
    final res = await http.get(
      Uri.parse("$baseUrl/account"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    final data = jsonDecode(res.body);

    print("ACCOUNT STATUS: ${res.statusCode}");
    print("ACCOUNT BODY: ${res.body}");

    // ======================
    // SUCCESS
    // ======================

    if (res.statusCode == 200 && data["data"] != null) {
      return AuthModel.fromJson(data["data"]);
    }

    // ======================
    // NORMAL MESSAGE
    // ======================

    if (data["message"] != null) {
      throw Exception(data["message"]);
    }

    // ======================
    // FALLBACK
    // ======================

    throw Exception("Không lấy được thông tin tài khoản");
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

    final data = jsonDecode(res.body);

    print("CHANGE PASSWORD STATUS: ${res.statusCode}");
    print("CHANGE PASSWORD BODY: ${res.body}");

    // ======================
    // SUCCESS
    // ======================

    if (res.statusCode == 200) {
      // nested success message
      if (data["data"] != null && data["data"]["message"] != null) {
        return data["data"]["message"];
      }

      // normal success message
      if (data["message"] is String &&
          data["message"] != "Call API successful") {
        return data["message"];
      }

      return "Đổi mật khẩu thành công";
    }

    // ======================
    // VALIDATION ERRORS
    // ======================

    if (data["message"] is List && data["message"].isNotEmpty) {
      final firstError = data["message"][0];

      if (firstError is Map && firstError["message"] != null) {
        throw Exception(firstError["message"]);
      }
    }

    // ======================
    // NORMAL MESSAGE
    // ======================

    if (data["message"] is String) {
      throw Exception(data["message"]);
    }

    // ======================
    // FALLBACK
    // ======================

    throw Exception("Đổi mật khẩu thất bại");
  }
}

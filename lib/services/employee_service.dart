import 'dart:convert';

import 'package:billing_app/models/api_result.dart';
import 'package:http/http.dart' as http;

import '../models/employee.dart';

class EmployeeService {
  final String baseUrl;

  final String token;

  EmployeeService({required this.baseUrl, required this.token});

  Map<String, String> get headers => {
    "Content-Type": "application/json",
    "Authorization": "Bearer $token",
  };

  // =========================
  // GET ALL
  // =========================

  Future<List<Employee>> getAll() async {
    final res = await http.get(Uri.parse("$baseUrl/users"), headers: headers);

    print("GET STATUS: ${res.statusCode}");
    print("GET BODY: ${res.body}");

    if (res.statusCode != 200) {
      throw Exception("Load employees failed");
    }

    final json = jsonDecode(res.body);

    final data = json["data"]?["content"] ?? json["data"] ?? [];

    return data.map<Employee>((e) => Employee.fromJson(e)).toList();
  }

  // =========================
  // CREATE
  // =========================

  Future<Employee> create(Employee emp, String password) async {
    final body = {
      "fullName": emp.fullName.trim(),

  
      "username": emp.username.trim(),

      "password": password.trim(),

      "role": emp.role,

      "status": emp.status ?? "ACTIVE",

      "phone": emp.phone?.trim(),
    }..removeWhere((k, v) => v == null);

    final res = await http.post(
      Uri.parse("$baseUrl/users"),
      headers: headers,
      body: jsonEncode(body),
    );

    print("CREATE STATUS: ${res.statusCode}");
    print("CREATE BODY: ${res.body}");

    final json = jsonDecode(res.body);

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception(json["message"] ?? "Create failed");
    }

    return Employee.fromJson(json["data"] ?? json);
  }

  // =========================
  // UPDATE INFO
  // =========================

  Future<Employee> update(int id, Employee emp) async {
    final body = {
      "fullName": emp.fullName.trim(),

      "username": emp.username.trim(),

      "role": emp.role,

      "phone": emp.phone?.trim(),
    }..removeWhere((k, v) => v == null);

    final res = await http.put(
      Uri.parse("$baseUrl/users/$id"),
      headers: headers,
      body: jsonEncode(body),
    );

    print("UPDATE STATUS: ${res.statusCode}");
    print("UPDATE BODY: ${res.body}");
    print("UPDATE REQUEST: ${jsonEncode(body)}");

    final json = jsonDecode(res.body);

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception(json["message"] ?? "Update failed");
    }

    return Employee.fromJson(json["data"] ?? json);
  }

  // =========================
  // SET STATUS
  // =========================

  Future<ApiResult<void>> setStatus(int id, String status) async {
    try {
      final res = await http.patch(
        Uri.parse("$baseUrl/users/$id/status?status=$status"),
        headers: headers,
      );

      final body = res.body.isNotEmpty ? jsonDecode(res.body) : null;

      print("STATUS CODE: ${res.statusCode}");
      print("STATUS BODY: ${res.body}");

      if (res.statusCode < 200 || res.statusCode >= 300) {
        return ApiResult(
          success: false,
          message: body?["message"] ?? "HTTP ${res.statusCode}",
        );
      }

      return ApiResult(
        success: true,
        message: body?["message"] ?? "Cập nhật thành công",
      );
    } catch (e) {
      return ApiResult(success: false, message: e.toString());
    }
  }

  // =========================
  // DELETE
  // =========================

  Future<void> delete(int id) async {
    final res = await http.delete(
      Uri.parse("$baseUrl/users/$id"),
      headers: headers,
    );

    print("DELETE STATUS: ${res.statusCode}");
    print("DELETE BODY: ${res.body}");

    if (res.statusCode < 200 || res.statusCode >= 300) {
      final json = jsonDecode(res.body);

      throw Exception(json["message"] ?? "Delete failed");
    }
  }
}

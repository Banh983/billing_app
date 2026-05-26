import 'dart:convert';
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

  /// =========================
  /// GET ALL EMPLOYEES (FIX RESPONSE STRUCTURE)
  /// =========================
  Future<List<Employee>> getAll() async {
    final res = await http.get(Uri.parse("$baseUrl/users"), headers: headers);

    print("GET USERS STATUS: ${res.statusCode}");
    print("GET USERS BODY: ${res.body}");

    if (res.statusCode != 200) {
      throw Exception("Failed to load employees");
    }

    final Map<String, dynamic> json = jsonDecode(res.body);

    final List<dynamic> data = json["data"]?["content"] ?? json["data"] ?? [];

    return data.map((e) => Employee.fromJson(e)).toList();
  }

  /// =========================
  /// CREATE EMPLOYEE
  /// =========================
  Future<Employee> create(Employee emp, String password) async {
    final Map<String, dynamic> body = {
      "fullName": emp.fullName.trim(),
      "email": emp.email.trim(),
      "password": password.trim(),
      "role": emp.role,
      "status": emp.status ?? "ACTIVE",
    };

    // optional phone
    if (emp.phone != null && emp.phone!.trim().isNotEmpty) {
      body["phone"] = emp.phone!.trim();
    }

    final res = await http.post(
      Uri.parse("$baseUrl/users"),
      headers: headers,
      body: jsonEncode(body),
    );

    print("CREATE STATUS: ${res.statusCode}");
    print("CREATE BODY: ${res.body}");
    print("CREATE REQUEST: ${jsonEncode(body)}");

    final json = jsonDecode(res.body);

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception(json["message"] ?? "Create failed");
    }

    return Employee.fromJson(json["data"] ?? json);
  }

  /// =========================
  /// UPDATE EMPLOYEE
  /// =========================
  Future<Employee> update(int id, Employee emp) async {
    final Map<String, dynamic> body = {
      "fullName": emp.fullName.trim(),
      "email": emp.email.trim(),
      "role": emp.role,
      "status": emp.status ?? "ACTIVE",
    };

    // ⚠️ CHỈ GỬI KHI KHÔNG NULL + KHÔNG RỖNG
    if (emp.phone != null && emp.phone!.trim().isNotEmpty) {
      body["phone"] = emp.phone!.trim();
    }

    if (emp.password != null && emp.password!.trim().isNotEmpty) {
      body["password"] = emp.password!.trim();
    }

    final res = await http.put(
      Uri.parse("$baseUrl/users/$id"),
      headers: headers,
      body: jsonEncode(body),
    );

    print("UPDATE STATUS: ${res.statusCode}");
    print("UPDATE BODY: ${res.body}");
    print("UPDATE REQUEST: ${jsonEncode(body)}");

    final json = jsonDecode(res.body);

    if (res.statusCode != 200) {
      throw Exception(json["message"] ?? "Update failed");
    }

    return Employee.fromJson(json["data"] ?? json);
  }
  /// =========================
  /// DELETE EMPLOYEE
  /// =========================
  Future<void> delete(int id) async {
    final res = await http.delete(
      Uri.parse("$baseUrl/users/$id"),
      headers: headers,
    );

    print("DELETE STATUS: ${res.statusCode}");
    print("DELETE BODY: ${res.body}");

    if (res.statusCode != 200 && res.statusCode != 204) {
      final json = jsonDecode(res.body);
      throw Exception(json["message"] ?? "Delete failed");
    }
  }
  
}

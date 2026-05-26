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
  /// GET ALL EMPLOYEES
  /// =========================
  Future<List<Employee>> getAll() async {
    final res = await http.get(Uri.parse("$baseUrl/users"), headers: headers);

    print("GET USERS STATUS: ${res.statusCode}");
    print("GET USERS BODY: ${res.body}");

    if (res.statusCode != 200) {
      throw Exception("Failed to load employees");
    }

    final json = jsonDecode(res.body);

    // 👇 FIX CHÍNH Ở ĐÂY
    final List data = json["data"]["content"] ?? [];

    return data.map((e) => Employee.fromJson(e)).toList();
  }

  /// =========================
  /// CREATE EMPLOYEE
  /// =========================
  Future<Employee> create(Employee emp, String password) async {
    final body = {
      "fullName": emp.fullName,
      "email": emp.email,
      "password": password,
      "role": emp.role,
    };

    // chỉ thêm phone nếu có
    if (emp.phone != null && emp.phone!.isNotEmpty) {
      body["phone"] = emp.phone!;
    }

    final res = await http.post(
      Uri.parse("$baseUrl/users"),
      headers: headers,
      body: jsonEncode(body),
    );

    final json = jsonDecode(res.body);

    return Employee.fromJson(json["data"] ?? json);
  }

  /// =========================
  /// UPDATE EMPLOYEE
  /// =========================
  Future<Employee> update(int id, Employee emp) async {
    final res = await http.put(
      Uri.parse("$baseUrl/users/$id"),
      headers: headers,
      body: jsonEncode(emp.toJson()),
    );

    print("UPDATE STATUS: ${res.statusCode}");
    print("UPDATE BODY: ${res.body}");

    if (res.statusCode != 200) {
      throw Exception("Update failed");
    }

    final json = jsonDecode(res.body);
    final data = json["data"] ?? json;

    return Employee.fromJson(data);
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
      throw Exception("Delete failed");
    }
  }
}

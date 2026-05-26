import 'package:flutter/material.dart';
import '../models/employee.dart';
import '../services/employee_service.dart';

class EmployeeProvider extends ChangeNotifier {
  final EmployeeService service;

  EmployeeProvider(this.service);

  List<Employee> employees = [];
  bool loading = false;

  String? error;

  // =========================
  // FETCH ALL
  // =========================
  Future<void> fetchEmployees() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final result = await service.getAll();

      // 🔥 FIX: chỉ lấy CONSULTANT
      employees = result.where((e) => e.role == "CONSULTANT").toList();
    } catch (e) {
      error = e.toString();
      debugPrint("Employee fetch error: $e");
      employees = [];
    }

    loading = false;
    notifyListeners();
  }

  // =========================
  // ADD
  // =========================
  Future<bool> addEmployee(Employee emp, String password) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final newEmp = await service.create(emp, password);
      employees.insert(0, newEmp);

      return true;
    } catch (e) {
      error = e.toString();
      debugPrint("Add employee error: $e");

      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // =========================
  // UPDATE
  // =========================
  Future<bool> updateEmployee(int id, Employee emp) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final updated = await service.update(id, emp);

      final index = employees.indexWhere((e) => e.id == id);

      if (index != -1) {
        employees[index] = updated;
      } else {
        // fallback reload nếu không tìm thấy
        await fetchEmployees();
      }

      return true;
    } catch (e) {
      error = e.toString();
      debugPrint("Update employee error: $e");

      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // =========================
  // DELETE
  // =========================
  Future<bool> deleteEmployee(int id) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      await service.delete(id);
      employees.removeWhere((e) => e.id == id);

      return true;
    } catch (e) {
      error = e.toString();
      debugPrint("Delete employee error: $e");

      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}

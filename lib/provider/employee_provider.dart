import 'package:flutter/material.dart';
import '../models/employee.dart';
import '../services/employee_service.dart';

class EmployeeProvider extends ChangeNotifier {
  late EmployeeService service;

  EmployeeProvider(this.service);

  List<Employee> employees = [];

  bool loading = false;
  bool actionLoading = false;

  String? error;
  String? actionMessage;

  void _setLoading(bool v) {
    loading = v;
    notifyListeners();
  }

  void _setActionLoading(bool v) {
    actionLoading = v;
    notifyListeners();
  }

  // =========================
  // FETCH
  // =========================
  Future<void> fetchEmployees() async {
    _setLoading(true);
    error = null;

    try {
      final result = await service.getAll();
      employees = result.where((e) => e.role == "CONSULTANT").toList();
    } catch (e) {
      error = e.toString();
      employees = [];
    }

    _setLoading(false);
  }

  // =========================
  // ADD
  // =========================
  Future<bool> addEmployee(Employee emp, String password) async {
    _setActionLoading(true);

    try {
      final newEmp = await service.create(emp, password);
      employees.insert(0, newEmp);

      actionMessage = "Thêm nhân viên thành công";
      return true;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      _setActionLoading(false);
    }
  }

  // =========================
  // UPDATE
  // =========================
  Future<bool> updateEmployee(int id, Employee emp) async {
    _setActionLoading(true);

    try {
      final updated = await service.update(id, emp);

      final index = employees.indexWhere((e) => e.id == id);

      if (index != -1) {
        employees[index] = updated;
      } else {
        await fetchEmployees();
      }

      actionMessage = "Cập nhật thành công";
      return true;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      _setActionLoading(false);
    }
  }

  // =========================
  // DELETE
  // =========================
  Future<bool> deleteEmployee(int id) async {
    _setActionLoading(true);

    try {
      await service.delete(id);
      employees.removeWhere((e) => e.id == id);

      actionMessage = "Đã xoá nhân viên";
      return true;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      _setActionLoading(false);
    }
  }
}

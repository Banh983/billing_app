import 'package:billing_app/models/api_result.dart';
import 'package:flutter/material.dart';

import '../models/employee.dart';
import '../services/employee_service.dart';

class EmployeeProvider extends ChangeNotifier {
  EmployeeService service;

  EmployeeProvider(this.service);

  List<Employee> employees = [];

  bool loading = false;

  bool actionLoading = false;

  String? error;

  String? actionMessage;

  // =========================
  // LOADING
  // =========================

  void _setLoading(bool v) {
    loading = v;

    notifyListeners();
  }

  void _setActionLoading(bool v) {
    actionLoading = v;

    notifyListeners();
  }

  void _resetActionState() {
    error = null;

    actionMessage = null;
  }

  String _parseError(Object e) {
    final msg = e.toString();

    return msg.replaceFirst("Exception:", "").trim();
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
      error = _parseError(e);

      employees = [];
    } finally {
      _setLoading(false);
    }
  }

  // =========================
  // VALIDATE PHONE
  // =========================

  ApiResult<void>? _validatePhone(String? phone) {
    final value = phone?.trim() ?? "";

    if (value.isEmpty) {
      return null;
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return ApiResult.error(message: "Số điện thoại chỉ được chứa chữ số");
    }

    if (value.length != 10) {
      return ApiResult.error(message: "Số điện thoại phải gồm đúng 10 số");
    }

    return null;
  }

  // =========================
  // ADD
  // =========================

  Future<ApiResult<void>> addEmployee(Employee emp, String password) async {
    _setActionLoading(true);

    _resetActionState();

    try {
      final phoneError = _validatePhone(emp.phone);

      if (phoneError != null) {
        error = phoneError.message;

        return phoneError;
      }

      final newEmp = await service.create(emp, password);

      employees.insert(0, newEmp);

      const msg = "Cập nhật thông tin thành công";

      actionMessage = msg;

      return ApiResult.success(message: msg);
    } catch (e) {
      final msg = _parseError(e);

      error = msg;

      return ApiResult.error(message: msg);
    } finally {
      _setActionLoading(false);
    }
  }

  // =========================
  // UPDATE
  // =========================

  Future<ApiResult<Employee>> updateEmployee(int id, Employee emp) async {
    _setActionLoading(true);

    _resetActionState();

    try {
      final phoneError = _validatePhone(emp.phone);

      if (phoneError != null) {
        error = phoneError.message;

        return ApiResult.error(message: phoneError.message);
      }

      final updated = await service.update(id, emp);

      final statusResult = await service.setStatus(id, emp.status ?? "ACTIVE");

      if (!statusResult.success) {
        error = statusResult.message;

        return ApiResult.error(
          message: statusResult.message ?? "Cập nhật trạng thái thất bại",
          statusCode: statusResult.statusCode,
        );
      }

      await fetchEmployees();

      final updatedWithStatus = updated.copyWith(
        status: emp.status ?? updated.status,
      );

      const msg = "Cập nhật thông tin thành công";

      actionMessage = msg;

      return ApiResult.success(data: updatedWithStatus, message: msg);
    } catch (e) {
      final msg = _parseError(e);

      error = msg;

      return ApiResult.error(message: msg);
    } finally {
      _setActionLoading(false);
    }
  }
  // =========================
  // DELETE
  // =========================

  Future<ApiResult<void>> deleteEmployee(int id) async {
    _setActionLoading(true);

    _resetActionState();

    try {
      await service.delete(id);

      employees.removeWhere((e) => e.id == id);

      const msg = "Đã xoá nhân viên";

      actionMessage = msg;

      return ApiResult.success(message: msg);
    } catch (e) {
      final msg = _parseError(e);

      error = msg;

      return ApiResult.error(message: msg);
    } finally {
      _setActionLoading(false);
    }
  }

  // =========================
  // SET STATUS
  // =========================

  Future<ApiResult<void>> setStatus(int id, String status) async {
    _setActionLoading(true);

    _resetActionState();

    try {
      final res = await service.setStatus(id, status);

      if (!res.success) {
        error = res.message;

        return ApiResult.error(
          message: res.message,
          statusCode: res.statusCode,
        );
      }

      await fetchEmployees();

      const msg = "Cập nhật thông tin thành công";

      actionMessage = msg;

      return ApiResult.success(message: msg, statusCode: res.statusCode);
    } catch (e) {
      final msg = _parseError(e);

      error = msg;

      return ApiResult.error(message: msg);
    } finally {
      _setActionLoading(false);
    }
  }
}

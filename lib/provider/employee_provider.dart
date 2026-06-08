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
  // PAGINATION
  // =========================

  int currentPage = 0;

  int pageSize = 10;

  int totalPages = 1;

  int totalElements = 0;

  String? keyword;

  String? roleFilter;

  bool get hasNextPage => currentPage + 1 < totalPages;

  bool get hasPreviousPage => currentPage > 0;

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

  Future<void> fetchEmployees({
    int page = 0,
    String? keywordValue,
    String? roleValue,
  }) async {
    _setLoading(true);

    error = null;

    try {
      keyword = keywordValue;
      roleFilter = roleValue;

      final result = await service.getAll(
        page: page,
        size: pageSize,
        keyword: keyword,
        role: roleFilter,
      );

      employees = result.employees;

      currentPage = result.currentPage;

      pageSize = result.pageSize;

      totalPages = result.totalPages;

      totalElements = result.totalElements;
    } catch (e) {
      error = _parseError(e);

      employees = [];

      currentPage = 0;

      totalPages = 1;

      totalElements = 0;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> nextPage() async {
    if (!hasNextPage) return;

    await fetchEmployees(
      page: currentPage + 1,
      keywordValue: keyword,
      roleValue: roleFilter,
    );
  }

  Future<void> previousPage() async {
    if (!hasPreviousPage) return;

    await fetchEmployees(
      page: currentPage - 1,
      keywordValue: keyword,
      roleValue: roleFilter,
    );
  }

  Future<void> refreshEmployees() async {
    await fetchEmployees(
      page: currentPage,
      keywordValue: keyword,
      roleValue: roleFilter,
    );
  }

  Future<void> resetAndFetchEmployees() async {
    await fetchEmployees(page: 0, keywordValue: keyword, roleValue: roleFilter);
  }

  Future<void> goToPage(int page) async {
    if (page < 0 || page >= totalPages) {
      return;
    }

    await fetchEmployees(
      page: page,
      keywordValue: keyword,
      roleValue: roleFilter,
    );
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

      await service.create(emp, password);

      await fetchEmployees(
        page: 0,
        keywordValue: keyword,
        roleValue: roleFilter,
      );

      const msg = "Thêm nhân viên thành công";

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

      await refreshEmployees();

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

      if (employees.length == 1 && currentPage > 0) {
        await fetchEmployees(
          page: currentPage - 1,
          keywordValue: keyword,
          roleValue: roleFilter,
        );
      } else {
        await refreshEmployees();
      }

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

      await refreshEmployees();

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

  // =========================
  // UPDATE ME
  // =========================

  Future<ApiResult<Employee>> updateMe(Employee emp) async {
    _setActionLoading(true);

    _resetActionState();

    try {
      final phoneError = _validatePhone(emp.phone);

      if (phoneError != null) {
        error = phoneError.message;

        return ApiResult.error(message: phoneError.message);
      }

      final updated = await service.updateMe(emp);

      const msg = "Cập nhật thông tin thành công";

      actionMessage = msg;

      return ApiResult.success(data: updated, message: msg);
    } catch (e) {
      final msg = _parseError(e);

      error = msg;

      return ApiResult.error(message: msg);
    } finally {
      _setActionLoading(false);
    }
  }
}

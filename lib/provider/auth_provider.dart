import 'package:flutter/material.dart';

import '../models/auth_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _service = AuthService();

  // ======================
  // USER
  // ======================

  AuthModel? user;

  String? get token => user?.accessToken;

  // ======================
  // LOGIN STATE
  // ======================

  bool loading = false;

  String? emailError;

  String? passwordError;

  String? generalError;

  // ======================
  // CHANGE PASSWORD STATE
  // ======================

  bool changePassLoading = false;

  String? changePassError;

  bool get isChangingPassword => changePassLoading;

  final TextEditingController oldPassController = TextEditingController();

  final TextEditingController newPassController = TextEditingController();

  final TextEditingController confirmPassController = TextEditingController();

  // ======================
  // LOGIN
  // ======================

  Future<bool> login(String email, String password) async {
    loading = true;

    _clearErrors();

    notifyListeners();

    try {
      // ======================
      // LOGIN API
      // ======================

      final loginUser = await _service.login(email, password);

      // lưu user tạm để lấy token
      user = loginUser;

      // ======================
      // GET FULL ACCOUNT INFO
      // ======================

      if (loginUser.accessToken.isNotEmpty) {
        try {
          final fullUser = await _service.getAccount(loginUser.accessToken);

          // giữ lại access token từ login
          user = AuthModel(
            id: fullUser.id,
            fullName: fullUser.fullName,
            email: fullUser.email,
            phone: fullUser.phone,
            role: fullUser.role,
            status: fullUser.status,
            createdAt: fullUser.createdAt,
            updatedAt: fullUser.updatedAt,
            accessToken: loginUser.accessToken,
          );
        } catch (e) {
          // nếu get account lỗi thì vẫn dùng data login
          user = loginUser;
        }
      }

      return true;
    } catch (e) {
      _mapError(e.toString().replaceAll("Exception: ", ""));

      return false;
    } finally {
      loading = false;

      notifyListeners();
    }
  }

  // ======================
  // LOGOUT
  // ======================

  void logout() {
    user = null;

    clearPasswordFields();

    notifyListeners();
  }

  // ======================
  // CHANGE PASSWORD
  // ======================

  Future<Map<String, dynamic>> changePassword() async {
    changePassError = null;

    // token invalid
    if (token == null || token!.isEmpty) {
      return {"success": false, "message": "Phiên đăng nhập đã hết hạn"};
    }

    // confirm password mismatch
    if (newPassController.text.trim() != confirmPassController.text.trim()) {
      return {"success": false, "message": "Mật khẩu xác nhận không khớp"};
    }

    changePassLoading = true;

    notifyListeners();

    try {
      final msg = await _service.changePassword(
        oldPassController.text.trim(),
        newPassController.text.trim(),
        confirmPassController.text.trim(),
        token!,
      );

      clearPasswordFields();

      return {"success": true, "message": msg};
    } catch (e) {
      final errorMsg = e.toString().replaceAll("Exception: ", "");

      changePassError = errorMsg;

      return {"success": false, "message": errorMsg};
    } finally {
      changePassLoading = false;

      notifyListeners();
    }
  }

  // ======================
  // CLEAR PASSWORD FIELDS
  // ======================

  void clearPasswordFields() {
    oldPassController.clear();

    newPassController.clear();

    confirmPassController.clear();

    changePassError = null;

    notifyListeners();
  }

  // ======================
  // CLEAR LOGIN ERRORS
  // ======================

  void _clearErrors() {
    emailError = null;

    passwordError = null;

    generalError = null;
  }

  // ======================
  // MAP BACKEND ERRORS
  // ======================

  void _mapError(String raw) {
    if (!raw.contains("field")) {
      generalError = raw;

      return;
    }

    final regex = RegExp(r'field:\s*([^,]+),\s*message:\s*([^}]+)');

    final matches = regex.allMatches(raw);

    for (final m in matches) {
      final field = m.group(1)?.trim();

      final message = m.group(2)?.trim();

      switch (field) {
        case "email":
          emailError = message;
          break;

        case "password":
          passwordError = message;
          break;

        default:
          generalError = message;
      }
    }
  }

  // ======================
  // DISPOSE
  // ======================

  @override
  void dispose() {
    oldPassController.dispose();

    newPassController.dispose();

    confirmPassController.dispose();

    super.dispose();
  }
}

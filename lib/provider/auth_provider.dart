import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/auth_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _service = AuthService();

  static const String _tokenKey = "access_token";

  // ======================
  // USER
  // ======================

  AuthModel? user;

  String? get token => user?.accessToken;

  bool get isLoggedIn => user != null && token != null && token!.isNotEmpty;

  // ======================
  // APP INIT STATE
  // ======================

  bool initializing = true;

  // ======================
  // LOGIN STATE
  // ======================

  bool loading = false;

  String? usernameError;

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
  // INIT AUTH
  // ======================

  Future<void> initAuth() async {
    initializing = true;

    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();

      final savedToken = prefs.getString(_tokenKey);

      if (savedToken == null || savedToken.isEmpty) {
        user = null;
        return;
      }

      final fullUser = await _service.getAccount(savedToken);

      user = AuthModel(
        id: fullUser.id,
        fullName: fullUser.fullName,
        username: fullUser.username,
        phone: fullUser.phone,
        role: fullUser.role,
        status: fullUser.status,
        createdAt: fullUser.createdAt,
        updatedAt: fullUser.updatedAt,
        accessToken: savedToken,
      );
    } catch (_) {
      await _clearSavedToken();

      user = null;
    } finally {
      initializing = false;

      notifyListeners();
    }
  }

  // ======================
  // LOGIN
  // ======================

  Future<bool> login(String username, String password) async {
    loading = true;

    _clearErrors();

    notifyListeners();

    try {
      final loginUser = await _service.login(username, password);

      user = loginUser;

      await _saveToken(loginUser.accessToken);

      if (loginUser.accessToken.isNotEmpty) {
        try {
          final fullUser = await _service.getAccount(loginUser.accessToken);

          user = AuthModel(
            id: fullUser.id,
            fullName: fullUser.fullName,
            username: fullUser.username,
            phone: fullUser.phone,
            role: fullUser.role,
            status: fullUser.status,
            createdAt: fullUser.createdAt,
            updatedAt: fullUser.updatedAt,
            accessToken: loginUser.accessToken,
          );
        } catch (e) {
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

  Future<void> logout() async {
    user = null;

    await _clearSavedToken();

    clearPasswordFields();

    notifyListeners();
  }

  // ======================
  // TOKEN STORAGE
  // ======================

  Future<void> _saveToken(String token) async {
    if (token.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_tokenKey, token);
  }

  Future<void> _clearSavedToken() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_tokenKey);
  }

  // ======================
  // CHANGE PASSWORD
  // ======================

  Future<Map<String, dynamic>> changePassword() async {
    changePassError = null;

    if (token == null || token!.isEmpty) {
      return {"success": false, "message": "Phiên đăng nhập đã hết hạn"};
    }

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
    usernameError = null;

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
        case "username":
          usernameError = message;
          break;

        case "password":
          passwordError = message;
          break;

        case "oldPassword":
          generalError = message;
          break;

        case "newPassword":
          generalError = message;
          break;

        case "confirmPassword":
          generalError = message;
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

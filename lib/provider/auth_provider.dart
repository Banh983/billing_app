  import 'package:flutter/material.dart';
  import 'package:shared_preferences/shared_preferences.dart';

  import '../core/api_exception.dart';
  import '../models/auth_model.dart';
  import '../services/auth_service.dart';

  class AuthProvider extends ChangeNotifier {
    final AuthService _service = AuthService();

    static const String _tokenKey = "access_token";

    // Tránh nhiều API cùng trả 401 và xử lý đăng xuất nhiều lần.
    bool _handlingUnauthorized = false;

    // ======================
    // USER
    // ======================

    AuthModel? user;

    String? get token => user?.accessToken;

    bool get isLoggedIn {
      final currentToken = token?.trim() ?? "";

      return user != null && currentToken.isNotEmpty;
    }

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

        final savedToken = prefs.getString(_tokenKey)?.trim() ?? "";

        if (savedToken.isEmpty) {
          user = null;
          return;
        }

        // Backend kiểm tra token bằng API /account.
        // Token hết hạn hoặc không hợp lệ sẽ trả 401.
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

        generalError = null;
      } on ApiException catch (e) {
        user = null;

        await _clearSavedToken();

        // Lấy nguyên message backend.
        generalError = e.message;
      } catch (e) {
        user = null;

        await _clearSavedToken();

        generalError = _cleanExceptionMessage(e);
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
        // Vẫn gửi dữ liệu lên backend như code cũ.
        // Không tự chặn username/password rỗng ở frontend.
        final loginUser = await _service.login(username.trim(), password.trim());

        final accessToken = loginUser.accessToken.trim();

        if (accessToken.isEmpty) {
          throw Exception(
            "Máy chủ đăng nhập thành công nhưng không trả về access token",
          );
        }

        // Token chỉ được xem là hợp lệ khi gọi /account thành công.
        final fullUser = await _service.getAccount(accessToken);

        final authenticatedUser = AuthModel(
          id: fullUser.id,
          fullName: fullUser.fullName,
          username: fullUser.username,
          phone: fullUser.phone,
          role: fullUser.role,
          status: fullUser.status,
          createdAt: fullUser.createdAt,
          updatedAt: fullUser.updatedAt,
          accessToken: accessToken,
        );

        await _saveToken(accessToken);

        user = authenticatedUser;

        generalError = null;

        return true;
      } on ApiException catch (e) {
        user = null;

        await _clearSavedToken();

        // Giữ nguyên cách hiển thị lỗi cũ qua generalError.
        _mapError(e.message);

        return false;
      } catch (e) {
        user = null;

        await _clearSavedToken();

        _mapError(_cleanExceptionMessage(e));

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

      usernameError = null;
      passwordError = null;
      generalError = null;

      await _clearSavedToken();

      clearPasswordFields(notify: false);

      notifyListeners();
    }

    // ======================
    // HANDLE UNAUTHORIZED
    // ======================

    /// Gọi hàm này khi bất kỳ API nào trong app trả về HTTP 401.
    ///
    /// Message được truyền vào phải là message backend trả về,
    /// ví dụ:
    /// "Token không hợp lệ, đã hết hạn hoặc bạn chưa đăng nhập".
    Future<void> handleUnauthorized(String message) async {
      if (_handlingUnauthorized) return;

      _handlingUnauthorized = true;

      try {
        user = null;

        usernameError = null;
        passwordError = null;

        generalError = message.trim();

        await _clearSavedToken();

        clearPasswordFields(notify: false);

        notifyListeners();
      } finally {
        _handlingUnauthorized = false;
      }
    }

    // ======================
    // TOKEN STORAGE
    // ======================

    Future<void> _saveToken(String token) async {
      final normalizedToken = token.trim();

      if (normalizedToken.isEmpty) return;

      final prefs = await SharedPreferences.getInstance();

      await prefs.setString(_tokenKey, normalizedToken);
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

      final currentToken = token?.trim() ?? "";

      if (currentToken.isEmpty) {
        return {"success": false, "message": "Không tìm thấy phiên đăng nhập"};
      }

      if (newPassController.text.trim() != confirmPassController.text.trim()) {
        return {"success": false, "message": "Mật khẩu xác nhận không khớp"};
      }

      changePassLoading = true;

      notifyListeners();

      try {
        final message = await _service.changePassword(
          oldPassController.text.trim(),
          newPassController.text.trim(),
          confirmPassController.text.trim(),
          currentToken,
        );

        clearPasswordFields(notify: false);

        return {"success": true, "message": message};
      } on ApiException catch (e) {
        if (e.isUnauthorized) {
          // Lấy đúng message 401 từ backend.
          await handleUnauthorized(e.message);

          return {"success": false, "message": e.message};
        }

        changePassError = e.message;

        return {"success": false, "message": e.message};
      } catch (e) {
        final errorMessage = _cleanExceptionMessage(e);

        changePassError = errorMessage;

        return {"success": false, "message": errorMessage};
      } finally {
        changePassLoading = false;

        notifyListeners();
      }
    }

    // ======================
    // CLEAR PASSWORD FIELDS
    // ======================

    void clearPasswordFields({bool notify = true}) {
      oldPassController.clear();

      newPassController.clear();

      confirmPassController.clear();

      changePassError = null;

      if (notify) {
        notifyListeners();
      }
    }

    // ======================
    // CLEAR LOGIN ERRORS
    // ======================

    void clearLoginErrors() {
      _clearErrors();

      notifyListeners();
    }

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

      if (matches.isEmpty) {
        generalError = raw;
        return;
      }

      for (final match in matches) {
        final field = match.group(1)?.trim();

        final message = match.group(2)?.trim();

        switch (field) {
          case "username":
            usernameError = message;
            break;

          case "password":
            passwordError = message;
            break;

          case "oldPassword":
          case "newPassword":
          case "confirmPassword":
            generalError = message;
            break;

          default:
            generalError = message;
        }
      }

      // LoginPage hiện tại chỉ hiển thị generalError.
      // Nếu backend trả lỗi theo field thì đưa lỗi đầu tiên
      // vào generalError để giữ đúng khung thông báo cũ.
      generalError ??= usernameError ?? passwordError;
    }

    String _cleanExceptionMessage(Object error) {
      return error
          .toString()
          .replaceFirst("ApiException: ", "")
          .replaceFirst("Exception: ", "")
          .trim();
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

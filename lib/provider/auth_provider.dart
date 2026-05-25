import 'package:billing_app/services/auth_service.dart';
import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool loading = false;
  String? token;
  Map<String, dynamic>? user;

  Future<bool> login(String email, String password) async {
    loading = true;
    notifyListeners();

    try {
      final data = await _authService.login(email, password);

      token = data["accessToken"] ?? "";
      user = data;

      loading = false;
      notifyListeners();

      return true;
    } catch (e) {
      loading = false;
      notifyListeners();
      return false;
    }
  }
}

import 'package:flutter/material.dart';

import '../utils/app_constants.dart';

class AuthService {
  bool _isAdminLoggedIn = false;

  Future<bool> adminLogin(String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final isValid = password == AppConstants.adminPassword;
    _isAdminLoggedIn = isValid;
    return isValid;
  }

  Future<void> logout() async {
    _isAdminLoggedIn = false;
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }

  Future<bool> isLoggedIn() async {
    return _isAdminLoggedIn;
  }
}

extension AuthServiceProvider on BuildContext {
  static final _authService = AuthService();

  AuthService get authService => _authService;
}

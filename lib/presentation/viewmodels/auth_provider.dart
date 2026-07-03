import 'package:flutter/material.dart';
import 'package:mamgo/data/models/user_account.dart';
import 'package:mamgo/data/datasources/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final _svc = AuthService();
  UserAccount? _user;

  UserAccount? get user => _user;
  bool get isLoggedIn => _user != null;

  Future<void> loadSession() async {
    _user = await _svc.currentUser();
    notifyListeners();
  }

  Future<String?> rememberedEmail() => _svc.rememberedEmail();

  /// Trả về null nếu thành công, ngược lại là thông báo lỗi.
  Future<String?> login(String email, String password,
      {bool remember = true}) async {
    final account = await _svc.login(email, password);
    if (account == null) return 'Email hoặc mật khẩu không đúng!';
    _user = account;
    await _svc.saveSession(account.email);
    await _svc.setRememberedEmail(remember ? account.email : null);
    notifyListeners();
    return null;
  }

  /// Trả về null nếu thành công, ngược lại là thông báo lỗi.
  Future<String?> register(
      String name, String email, String password) async {
    final error = await _svc.register(
        UserAccount(name: name, email: email, password: password));
    if (error != null) return error;
    // Tự động đăng nhập sau khi đăng ký
    return login(email, password);
  }

  Future<void> logout() async {
    await _svc.logout();
    _user = null;
    notifyListeners();
  }
}
